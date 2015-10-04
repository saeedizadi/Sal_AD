function predConf  = SaliencyAggregation(num)
%%
%predConf: contains the estimated accuracy of methods
%num: ID of the desired maps
%The function will read the maps from the folder 'maps'
%After execution, a bar will be shown up which visualizes the accuracy of experts
%The maps will be rewrited into the folder 'Maps_Ranking' in the descending
%order of the estimated accuracies. The filename of the best map starts with number '1' and the the worst map with '17'
%

%%
stepValue = 0.01;
R = 17;

methods = {'AC','AIM','CA','CB','FT','GB','HC','IM','IT','LC','MSS','RC','SEG','SeR','SR','SUN','SWD'};
id_str{1}  = [num2str(num) '_'];
id_str = repmat(id_str,1,17);

names = strcat(id_str,methods);

for i=1:17
    immap = imread(['./maps/' names{i} '.png']);   
    maps(i,:) = immap(:)';
    [row,col] = size(immap);
end


commonInstances = zeros(R);
contradict = zeros(R);

for i=1:R
    clc;
    disp('Calculating the Disagreemnet Between the Maps, Please Wait...')
    for j=i+1:R
        contradict(i,j) = 0;
        contradict(i,j) = 1-CC(maps(i,:),maps(j,:));
        contradict(j,i) = contradict(i,j);
    end
end

predConf = optimization_func(R, contradict, stepValue, 1);
if (numel(find(predConf>0.5))<R/2) % we know majority of labelers are above 0.5 accuracy
    predConf = 1-predConf;
end

bar(predConf);
set(gca,'XTick',1:17);
set(gca,'XTickLabel',methods');

[~,indx] = sort(predConf,'descend');
for i=1:17
   
    b = reshape(maps(indx(i),:)',row,col);    
    imwrite(b,['Maps_Ranking/' num2str(i) '_' names{indx(i)} '.png'],'png');
end

end

