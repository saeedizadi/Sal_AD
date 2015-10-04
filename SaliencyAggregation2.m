function [predConf maps] = SaliencyAggregation2(num)
%%
%predConf: contains the estimated accuracy of methods
%num: ID of the desired maps
%The function will read the maps from the folder 'maps'
%After execution, a bar will be shown up which visualizes the accuracy of experts
%The maps will be rewrited into the folder 'Maps_Ranking' in the descending
%order of the estimated accuracies. The filename of the best map starts with number '1' and the the worst map with '17'
%

%%
continuesBased = false;

stepValue = 0.01;
R = 17;
alpha = 0.8;

methods = {'AC','AIM','CA','CB','FT','GB','HC','IM','IT','LC','MSS','RC','SEG','SeR','SR','SUN','SWD'};
%methods = {'AIM','AWS','DVA','GBVS','ITTI','SIG','SUN'};
id_str{1}  = [num2str(num) '_'];
id_str = repmat(id_str,1,17);

names = strcat(id_str,methods);

for i=1:17
    immap = double(imread(['./maps/' names{i} '.png']));
    
    maps(i,:) = immap(:)';
    
    [row,col] = size(immap);
end

meanVec = mean(maps,2);
mapsBin = bsxfun(@ge,maps,meanVec);
countSalLab = sum(mapsBin,1);
validPixs = countSalLab> round(alpha*R);
contradict = zeros(R);
for i=1:R
    for j=i+1:R
        
%         contradict(i,j) = 1-abs(CC(double(maps(i,:))./255,double(maps(j,:))./255));
%         contradict(j,i) = contradict(i,j);
%         temp = abs(maps(i,:)./255-maps(j,:)./255);   
%         temp = temp>thr;        
%         contradict(i,j) = sum(temp)/(row*col);
%         contradict(j,i) = contradict(i,j);
        
        if (continuesBased)
            contradict(i,j) = 1-CC(maps(i,:),maps(j,:));
        else
%             A = zeros(size(maps(i,:)));
%             mn1 = mean(maps(i,:));
%             A(maps(i,:)>mn1) = 1;
%             
%             B = zeros(size(maps(j,:)));
%             mn2 = mean(maps(j,:));
%             B(maps(j,:)>mn2) = 1;
              A = mapsBin(i,validPixs);
              B = mapsBin(j,validPixs);
    
            contradict(i,j) = numel(find(A ~= B)) / numel(A);
            %contradict(i,j) = (1 - corr(A',B'))/2;
            contradict(j,i) = contradict(i,j);
        end        
    end
end
predConf = optimization_func(R, contradict, stepValue, 1);
% if (predConf(9)>predConf(4)) 
%     predConf = 1-predConf;    
% end

% bar(predConf);
% set(gca,'XTick',1:17);
% set(gca,'XTickLabel',methods');
%
% [~,indx] = sort(predConf,'descend');
% for i=1:17
%     b = reshape(maps(indx(i),:)',row,col);
%     if (continuesBased)
%         imwrite(b,['./Maps_Ranking/' num2str(i) '_' names{indx(i)} '.png'],'png');
%     else
%         a = zeros(size(b));
%         mn = mean(mean(b));
%         a(b>mn) = 1;
%         imwrite(a,['./Maps_Ranking/' num2str(i) '_' names{indx(i)} '.png'],'png');
%     end
%
% end

end

