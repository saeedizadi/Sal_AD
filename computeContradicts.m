function contradicts = computeContradicts(contexts)
contradicts = zeros(17);
for i=1:17
    for j=i+1:17
%         contradicts(i,j) = (1-CC(contexts(:,i),contexts(:,j)))/2;
%         contradicts(j,i) = contradicts(i,j);
        
%           meanA = mean(contexts(:,i),1);
%           meanB = mean(contexts(:,j),1);
%           contradicts(i,j) = abs(meanA-meanB)/255;
%           contradicts(j,i) = abs(meanA-meanB)/255;
          
        elemDisag = gsqrt((contexts(:,i)-contexts(:,j)).^2);
        sumDisag = sum(elemDisag)/(255*size(contexts,1));
        contradicts(i,j) = sumDisag;
        contradicts(j,i) = sumDisag;
    end
end

%contradicts = (contradicts - min(contradicts(:)))./(max(contradicts(:))-min(contradicts(:)));
end