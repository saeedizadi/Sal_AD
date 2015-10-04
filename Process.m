function Process(num)

imgPath = './groundtruths/';
methods = {'AC','AIM','CA','CB','FT','GB','HC','IM','IT','LC','MSS','RC','SEG','SeR','SR','SUN','SWD'};

R = 17;
stepValue = 0.01;

id_str  = {[num2str(num) '_']};
id_str = repmat(id_str,1,17);

names = strcat(id_str,methods);

im = imread(fullfile(imgPath,[num2str(num) '.jpg']));
gt = imread(fullfile(imgPath,[num2str(num) '.png']));

for i=1:numel(methods)
    
    imMap{i} = double(imread(['./maps/' names{i} '.png']));    
    mapsvec(:,i) = imMap{i}(:);
        
end

fprintf('Generating superpixels ...')

[l, Am, ~, ~] = slic(im, 500, 	40, 1);

nSp = numel(unique(l));

for nsp = 1:nSp
    [idx,masks] = neighSPs(l,Am,102,3); 
    showMasks(masks,im);
    contexts = mapsvec(idx,:);
    
    contradict = computeContradicts(contexts);
    predConf = optimization_func(R, contradict, stepValue, 1);
end


end