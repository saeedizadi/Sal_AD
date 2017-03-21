
function estMap = Process(num)
nSuperpixels = 500;
rSuperpixels = 1;
%function estMap = Process(num,nSuperpixels,rSuperpixels)
addpath('SLIC')

%%Define paths
imgPath = './images/';
maskPath = './masks/';
outmapPath = './ourmaps/';
unblurredmapPath = './unblurredmaps/';

%%Methods to take into account
methods = {'AC','AIM','CA','CB','FT','GB','HC','SIM','IT','LC','MSS','RC','SEG','SeR','SR','SUN','SWD'};




%%Intializing some variables
R = 17;
stepValue = 0.01;

id_str  = {[num '_']};
id_str = repmat(id_str,1,numel(methods));

names = strcat(id_str,methods);

im = imread(fullfile(imgPath,[num2str(num) '.jpg']));
gt = imread(fullfile(maskPath,[num2str(num) '.png']));
estMap = zeros(size(im,1),size(im,2));

%%Reading maps
for i=1:numel(methods)
    imMap{i} = double(imread(['./maps/' names{i} '.png']));
    mapsvec(:,i) = imMap{i}(:);
end


%%Generate Superpixels
[l, Am, ~, ~] = slic(im, nSuperpixels, 40, rSuperpixels);
nSp = numel(unique(l));

%%Aggregating superpixels
tempGt(:,1) = gt(:);
for nsp = 1:nSp
    
    [idx,masks,~] = neighSPs(l,Am,nsp,1);
    contexts = mapsvec(idx,:);   
        
    contextGT = tempGt(idx,:);
    
    %compute contradic
    contradict = computeContradicts(contexts);
    
    %optimize the objective funtion to get Acc's
    predConf= optimization_func(R, contradict, stepValue, 1);
    predConf = (predConf- min(predConf))/(max(predConf) - min(predConf));
   
    
    flag= whichMinimum(predConf,contexts,contextGT);
    if flag == 1
        predConf= 1-predConf;
    end
    
    estMap = produceBestMap(estMap,masks{1},imMap(1:numel(methods)),predConf);
    
%     gtContour= drawSpContour(l,gt,nsp,[255 0 0]);
    
%     for i=1:17
%         t = imMap{i};
%         t = im2uint8(mat2gray(t));
%         t = repmat(t,[1,1,3]);
%         draws{i}  = drawregionboundaries(l,t,[255 255 255]);
%     end
    
%     for i=1:17
%         draws{i} = im2uint8(drawSpContour(l,mat2gray(imMap{i}),nsp,[255 0 0]));
%     end
%     AllMaps = [gtContour,draws{1},draws{2},draws{3},draws{4},draws{5};draws{6},...
%         draws{7},draws{8},draws{9},draws{10},draws{11};draws{12},draws{13},draws{14},draws{15},...
%         draws{16},draws{17}];
    
            
end

blurred_estMap = imgaussfilt(estMap,4);
imwrite(uint8(blurred_estMap),[outmapPath num2str(num) '_OURS.png']);
imwrite(uint8(estMap),[unblurredmapPath num2str(num) '_OURS.png']);
end
