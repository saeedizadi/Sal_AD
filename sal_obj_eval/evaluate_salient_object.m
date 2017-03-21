% Evaluate salient object detection algorithms on Achanta/Liu's salient
% object detection dataset.
%
% If you use any of this work in scientific research or as part of a larger
% software system, you are kindly requested to cite the use in any related
% publications or technical documentation. The work is based upon:
%
% [1] B. Schauerte, R. Stiefelhagen, "How the Distribution of Salient
%     Objects in Images Influences Salient Object Detection". In Proceedings
%     of the 20th International Conference on Image Processing (ICIP), 2013.
%
% @author: B. Schauerte
% @date:   2011-2013
% @url:    http://cvhci.anthropomatik.kit.edu/~bschauer/

% Copyright 2011-2013 B. Schauerte. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%    1. Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%
%    2. Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the
%       distribution.
%
% THIS SOFTWARE IS PROVIDED BY B. SCHAUERTE ''AS IS'' AND ANY EXPRESS OR
% IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL B. SCHAUERTE OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
% OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% The views and conclusions contained in the software and documentation
% are those of the authors and should not be interpreted as representing
% official policies, either expressed or implied, of B. Schauerte.

%addpath(genpath('libs'));
%if isempty(which('spectral_saliency_multichannel')), addpath(genpath('../saliency')); end
if isempty(which('progressbar')), addpath(genpath('../libs/progressbar/')); end
%if isempty(which('qtfm_root')), addpath(genpath('../libs/qtfm')); end

% compile the provided .cpp file(s), if necessary
if ~exist('analyse_recall_precision_mex') %#ok<EXIST>
    mex analyse_recall_precision_mex.cpp -D__MEX
end
if ~exist('calculate_classification_scores_mex') %#ok<EXIST>
    mex calculate_classification_scores_mex.cpp -D__MEX
end

if ~exist('pr_div_by_zero_result','var')
    pr_div_by_zero_result = 1; % see http://stats.stackexchange.com/questions/1773/what-are-correct-values-for-precision-and-recall-in-edge-cases
    %pr_div_by_zero_result = 0; % see, e.g., Weka's TwoClassStats.java
end

if ~exist('saliency_resolution','var')
    fprintf('  Warning: setting default saliency resolution (saliency_resolution)\n');
    
    saliency_resolution = 1; % use the original/full image resolution
    %saliency_resolution = [48 64]; % specify a custom resolution
end

%% define the saliency function that should be evaluated
%if ~exist('saliency_func','var')
%    fprintf('  Warning: setting default saliency function (saliency_func)\n');
%
%    saliency_func = @(image,smap_resolution) spectral_saliency_multichannel(image,smap_resolution,'quat:dct',{'gaussian',9,2.5},{},1,{},false);
%end

% define a structuring element that may be used to dilate the mask (to
% account for the fact that the most salient peak on a saliency map is
% often on the border of the image and thus - using dilation - we can
% specify a tolerance boundary for evaluation)
if ~exist('mask_structuring_element','var')
    fprintf('  Warning: setting default mask structuring element (mask_structuring_element)\n');
    
    %mask_structuring_element = strel('ball',5,5);
    mask_structuring_element = []; % disable, default
end

% only consider images in which the object fills at most
% relative_object_size_limit (ratio) of the image pixels.
if ~exist('relative_object_size_limit','var')
    fprintf('  Warning: setting default value for the relative object size limit (relative_object_size_limit)\n');
    
    relative_object_size_limit = 1; % 0 no object, 1 the object is allowed to fill the whole image
end

% Which masks to use? E.g., I use Linux servers for larger evaluations and
% Mac laptop for development (also occasionally another Windows laptop).
switch (computer)
    case {'MACI64'}
        imagepath = '/Users/bschauer/data/salient-objects/achanta/images';
        maskpath = '/Users/bschauer/data/salient-objects/achanta/binarymasks';
    case {'GLNXA64','GLNX86'}
        imagepath = '/home/saeed/Projects/Sal_AD/images';
        maskpath  = '/home/saeed/Projects/Sal_AD/masks'; % from Achanta
        mappath = '/home/saeed/Projects/Sal_AD/maps';
    case {'PCWIN64','PCWIN'}
        imagepath = 'C:\Users\Boris\Desktop\data\liu\images\';
        maskpath  = 'C:\Users\Boris\Desktop\data\achanta\binarymasks\'; % from Achanta
    otherwise
        error('Unknown platform');
end

do_result_figures   = false;
do_figures          = false;
do_progressbar      = true;
do_recall_precision = true;

if do_progressbar && ~exist('progressbar')
    warning('  Warning: Progressbar not found. Turning it off.');
    do_progressbar = false;
end

num_hits             = 0; % number of images in which the most salient points lies within the mask
num_images           = 0;
num_processed_images = 0;

% to calculate recall/precision
thresholds  = [0:0.005:1];
precisions  = zeros(size(thresholds));
recalls     = zeros(size(thresholds));
tnrs        = zeros(size(thresholds));
accuracies  = zeros(size(thresholds));
fscores     = zeros(size(thresholds));
fscores_alt = zeros(size(thresholds));
fprs        = zeros(size(thresholds));
tprs        = zeros(size(thresholds));

% total number of true positives/true negatives/false positives/false
% negatives depending on the threshold
total_tps = zeros(size(thresholds));
total_tns = zeros(size(thresholds));
total_fps = zeros(size(thresholds));
total_fns = zeros(size(thresholds));

% mean statistics over all images
mean_max_fscore              = 0;
mean_max_fscore_alt          = 0;
mean_pr_auc                  = 0;
mean_pr_auc_interpolated     = 0;
mean_average_precision       = 0;
mean_break_even_point        = 0;
mean_pr_int                  = 0;
mean_roc_auc                 = 0;

% iterate through all binary masks
if do_figures, figure('name', 'images, masks, and saliency'); end
if do_progressbar, progressbar('Masks'); end
maskfiles=dir(fullfile(maskpath,'*.png'));
time_total_start=tic;

for i=1:50
% for i=1:numel(maskfiles)
    num_images = num_images + 1;
    
    maskpathfull=fullfile(maskpath,maskfiles(i).name);
    filename=maskfiles(i).name(1:end-4); % maskname w/o file ending
    
    %    mappatfull = fullfile(mappath,[filename '_OUR.png']);
    mappatfull = fullfile(mappath,[filename met '.png']);
    
    %imagepathfull=fullfile(imagepath,'A',num2str(tmp(1)),[filename '.jpg']); % Liu's folder structure
    %imagepathfull=fullfile(imagepath,[filename '.jpg']);
    
    %    img=imread(imagepathfull);
    mask=double(imread(maskpathfull));
    saliency_map = double(imread(mappatfull));
    
    num_processed_images = num_processed_images + 1;
    
    % resize and normalize the saliency map
    if do_recall_precision
        sm=imresize(saliency_map,size(mask));
        sm=sm - min(min(sm));
        sm=sm ./ max(max(sm));
        mask=mask - min(min(mask));
        mask=mask / max(max(mask));
        %        mask_neg = 1 - mask;%I think it is not necesary!!
        
        % statistics for this image/saliency map
        local_precisions = zeros(size(thresholds));
        local_recalls    = zeros(size(thresholds));
        local_tnrs       = zeros(size(thresholds));
        local_accuracies = zeros(size(thresholds));
        local_fscores    = zeros(size(thresholds));
        local_tprs       = zeros(size(thresholds));
        local_fprs       = zeros(size(thresholds));
        local_tps        = zeros(size(thresholds));
        local_tns        = zeros(size(thresholds));
        local_fps        = zeros(size(thresholds));
        local_fns        = zeros(size(thresholds));
        for j=1:numel(thresholds)
            threshold=thresholds(j);
            mask_threshold=0.5;
            [local_precisions(j) local_recalls(j) local_tnrs(j) local_accuracies(j) local_fscores(j) local_tps(j) local_tns(j) local_fps(j) local_fns(j)] = calculate_classification_scores_mex(sm,mask,threshold,mask_threshold,1,pr_div_by_zero_result);
        end
        % true/false positive rate (for ROC curves and ROC-AUC)
        local_tprs=local_tps ./ (local_tps + local_fns);
        local_fprs=local_fps ./ (local_fps + local_tns);
        % alternative F-score
        fscore_beta = sqrt(0.3);
        local_fscores_alt = (1 + fscore_beta.^2) .* (local_precisions .* local_recalls) ./ ((fscore_beta.^2 .* local_precisions) + local_recalls);
        local_fscores_alt((local_precisions .* local_recalls) == 0) = 0;
        
        % local
        [local_pr_auc,local_pr_auc_interpolated,local_average_precision,local_break_even_point] = analyse_recall_precision_mex(flipdim(local_precisions,2),flipdim(local_recalls,2));
        
        % calculate mean (local) statistics (averaged over the images)
        mean_max_fscore          = mean_max_fscore + max(local_fscores);
        mean_max_fscore_alt      = mean_max_fscore_alt + max(local_fscores_alt);
        mean_pr_auc              = mean_pr_auc + local_pr_auc;
        mean_pr_auc_interpolated = mean_pr_auc_interpolated + local_pr_auc_interpolated;
        mean_average_precision   = mean_average_precision + local_average_precision;
        mean_break_even_point    = mean_break_even_point + local_break_even_point;
        mean_pr_int              = mean_pr_int - trapz([1,local_recalls,0],[1,local_precisions,0]);
        mean_roc_auc             = mean_roc_auc - trapz([1,local_fprs,0],[1,local_tprs,0]);
        
        % update the averages precisions/recalls/...
        precisions  = precisions + local_precisions;
        recalls     = recalls + local_recalls;
        tnrs        = tnrs + local_tnrs;
        accuracies  = accuracies + local_accuracies;
        fscores     = fscores + local_fscores;
        fscores_alt = fscores_alt + local_fscores_alt;
        
        % true/false positive rate (for ROC curves and ROC-AUC)
        tprs = tprs + local_tprs;
        fprs = fprs + local_fprs;

    end
    
    % update the progressbar
    if do_progressbar, progressbar(i/numel(maskfiles)); end
end
time_total=toc(time_total_start);

fprintf('  Total time for evaluation: %.3f (sec)\n',time_total);

if do_recall_precision
    precisions  = precisions / num_processed_images;
    recalls     = recalls / num_processed_images;
    tnrs        = tnrs / num_processed_images;
    accuracies  = accuracies / num_processed_images;
    fscores     = fscores / num_processed_images;
    fscores_alt = fscores_alt / num_processed_images;
    tprs        = tprs / num_processed_images;
    fprs        = fprs / num_processed_images;
    
    pr_int = -trapz(recalls,precisions); % create a single number for easier assessment of the quality
    [pr_auc,pr_auc_interpolated,average_precision,break_even_point] = analyse_recall_precision_mex(flipdim(precisions,2),flipdim(recalls,2)); % use flipdim to make the recall values monotonic increasing!
    roc_auc = -trapz([1,fprs,0],[1,tprs,0]); % create a single number for easier assessment of the quality
    
%     if do_figures || do_result_figures
%         figure('name',['recall vs precision (' num2str(pr_auc) ')']);
%         plot(recalls,precisions);
%         ylim([0 1]);
%         xlim([0 1]);
%         xlabel('Recall'); ylabel('Precision');
%         
%         figure('name',['FPR vs TPR (' num2str(roc_auc) ')']);
%         plot(fprs,tprs);
%         ylim([0 1]);
%         xlim([0 1]);
%         xlabel('FPR'); ylabel('TPR');
%         
%         figure('name',['fscores (' num2str(max(fscores)) ')']);
%         plot(thresholds,fscores,'r'); hold on;
%         plot(thresholds,fscores_alt,'g');
%         ylim([0 1]);
%         xlim([0 1]);
%         xlabel('Threshold'); ylabel('F1-Score (r) and F-beta score (g) (beta=0.3)');
%     end
    
    %%%
    % Averaged statistics
    %%%
%     fprintf('  Averaged precision/recall statistics:\n');
%     fprintf('    Max. F1-score:          %.4f\n',max(fscores));
%     fprintf('    Max. F-alt score:       %.4f\n',max(fscores_alt));
%     fprintf('    PR-AUC:                 %.4f\n',pr_auc);
%     fprintf('    PR-AUC (interpolated):  %.4f\n',pr_auc_interpolated);
%     fprintf('    PR-Integral:            %.4f\n',pr_int);
%     fprintf('    Avg. Precision:         %.4f\n',average_precision);
%     fprintf('    Break Even Point:       %.4f\n',break_even_point);
%     fprintf('    ROC-AUC:                %.4f\n',roc_auc);
    %%%
  
    %%%
    % The mean statistics, i.e. averages over all images
    %%%
    fprintf('  Mean statistics:\n');
    mean_max_fscore          = mean_max_fscore / num_processed_images;
    mean_max_fscore_alt      = mean_max_fscore_alt / num_processed_images;
    mean_pr_auc              = mean_pr_auc / num_processed_images;
    mean_pr_auc_interpolated = mean_pr_auc_interpolated / num_processed_images;
    mean_average_precision   = mean_average_precision / num_processed_images;
    mean_break_even_point    = mean_break_even_point / num_processed_images;
    mean_pr_int              = mean_pr_int / num_processed_images;
    mean_roc_auc             = mean_roc_auc / num_processed_images;
%     fprintf('    Max. F1-score:          %.4f\n',mean_max_fscore);
%     fprintf('    Max. F-alt score:       %.4f\n',mean_max_fscore_alt);
%     fprintf('    PR-AUC:                 %.4f\n',mean_pr_auc);
%     fprintf('    PR-AUC (interpolated):  %.4f\n',mean_pr_auc_interpolated);
%     fprintf('    PR-Integral:            %.4f\n',mean_pr_int);
%     fprintf('    Avg. Precision:         %.4f\n',mean_average_precision);
%     fprintf('    Break Even Point:       %.4f\n',mean_break_even_point);
%     fprintf('    ROC-AUC:                %.4f\n',mean_roc_auc);
    
    % Small announcement
%     fprintf('\nWhat the ...? Why multiple variants of the same statistics?\n');
%     fprintf('  Well, the issue is that the results depend on the point at\nwhich you calculate the mean(s). Take care and be fair.\n');
%     fprintf('\nBoris Schauerte, 2011-2013\n');
%     fprintf('Karlsruhe Institute of Technology\n');
    
%     if do_figures || do_result_figures
%         figure('name',['recall vs precision (' num2str(total_pr_auc) '/' num2str(total_pr_auc_interpolated) ')']);
%         plot(total_recalls,total_precisions);
%         ylim([0 1]);
%         xlim([0 1]);
%         xlabel('Recall'); ylabel('Precision');
%         
%         figure('name',['FPR vs TPR (' num2str(total_roc_auc) ')']);
%         plot(total_fprs,total_tprs);
%         ylim([0 1]);
%         xlim([0 1]);
%         xlabel('FPR'); ylabel('TPR');
%         
%         figure('name',['fscores (' num2str(max(total_fscores)) ')']);
%         plot(thresholds,total_fscores,'r'); hold on;
%         plot(thresholds,total_fscores_alt,'g');
%         ylim([0 1]);
%         xlim([0 1]);
%         xlabel('Threshold'); ylabel('F1-Score (r) and F-beta score (g) (beta=0.3)');
%     end
end
