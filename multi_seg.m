addpath('./multi-segmentation/')
addpath(genpath('./multiscale_Segmentation/'))

image = imread('0001.jpg');
num_segmentation = 15;

 %Tthe approach to generate superpixels
    sp_method = 'pedro'; 

% Parameters for multiple segmentations
    k = [5:5:35 40:10:120 150:30:600 660:60:1200 1300:100:1800];
    k = k(ind(1 : num_segmentation)); 

    imsegs = im2superpixels(image, sp_method );    

% Get proprocessed features, which will be used in the following feature extraction steps 
    imdata = getImageData( image, textons, imsegs );
    spfeat = getSuperpixelData( imdata );

    % Generate the features to predict the similarity of two adjacent regions
    efeat = getEdgeData( spfeat, imdata );
    
    % predict the similarity of two adjacent regions
    same_label_likelihood = test_boosted_dt_mc( same_label_classifier, efeat );
    same_label_likelihood = 1 ./ (1+exp(ecal(1)*same_label_likelihood+ecal(2)));

nSuperpixel = imsegs.nseg;
    multi_segmentations = mexMergeAdjRegs_Felzenszwalb( imdata.adjlist, same_label_likelihood, nSuperpixel, k, imsegs.npixels );


