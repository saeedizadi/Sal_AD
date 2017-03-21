function [flag, meanIntensityRank]= whichMinimumBW(accuracies,sups)

% [~,I] = sort(accuracies,'descend');
% I = I(1:3);
% 
% 
% topRankIntensties = sups(:,I);
% meanIntensityRank = mean(mean(topRankIntensties,2),1);
% meanIntensityRank = meanIntensityRank./255;

meanAcc = mean(accuracies(1:17));
%accMean = accuracies(18);


if accuracies(12)<meanAcc
    flag = true;
else
    flag = false;
end

%Background
% if abs(meanIntensityBest-meanIntensityRank) < 0.1
%     flag = false;
% else
%     flag = true;
% end
% if abs(meanIntensityBest-meanIntensityRank) < 0.1
%     if accuracies(9) > 0.8
%         flag = false;
%     else
%         flag = true;
%     end
% else
%     if accuracies(12)< 0.3
%         flag = true;
%     else
%         flag = false;
%     end
% end
    
end