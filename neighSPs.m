function [idx masks] =  neighSPs(label,Am,spID,numLevel )
%This function receives a superpixel and a level, and generates different
%levels of the neghboring pixels around the target superpixel.

Am = full(Am);

level{1} = spID;

for neighLevel = 1:numLevel
    listOfSPs = level{neighLevel};
    temp = [];
    for i = 1:numel(listOfSPs)
        temp = [temp find(Am(listOfSPs(i),:)==1)];
    end
    level{neighLevel+1} = unique(temp);
end

for i=1:length(level)
    if i ~=1
        mask = ismember(label,setdiff(level{i},[level{i-1} spID]));
    else
        mask = ismember(label,level{i});
    end
    masks{i} = mask;
end

allSPs = unique(cell2mat(level));
mask = ismember(label,allSPs);
masks{length(level)+1} = mask;

temppp = masks{1}(:);
idx = find(temppp == 1);
end

