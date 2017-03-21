function flag = whichMinimum(accuracies,sups,gt)

[~,minIdx] = min(accuracies);
[~,maxIdx] = max(accuracies);

minSP = sups(:,minIdx);
maxSP = sups(:,maxIdx);

minSpScore = mean(abs(bsxfun(@minus,double(gt./255),minSP./255)));
maxSpScore = mean(abs(bsxfun(@minus,double(gt./255),maxSP./255)));


if minSpScore < maxSpScore
    flag = true;
else
    flag = false;
end
end