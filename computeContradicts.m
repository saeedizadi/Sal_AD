function contradicts = computeContradicts(contexts)
contradicts = zeros(17);
for i=1:17
    for j=i+1:17
        elemDisag = gsqrt((contexts(:,i)-contexts(:,j)).^2);
        sumDisag = sum(elemDisag)/(255*size(contexts,1));
        contradicts(i,j) = sumDisag;
        contradicts(j,i) = sumDisag;
    end
end

end