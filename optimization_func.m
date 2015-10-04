% In the name of God

function res = optimization_func(R,contradict,stepValue,norm)
curInd = 0;
for ii=1:R
    cont = [contradict(ii, 1:ii-1) contradict(ii,ii+1:R)];
    mn = min(min(cont, 1-cont));
    mx = max(max(cont, 1-cont));
    vals = [0:stepValue:mn mx:stepValue:1];    
    for ind=1:numel(vals)
        curInd = curInd+1;
        temp(:,curInd) = zeros(R,1);
        temp(ii,curInd) = vals(ind);        
        
        for j=1:R
            if (ii~=j)
                temp(j,curInd) = (contradict(ii,j)-temp(ii,curInd))/(1-2*temp(ii,curInd));
            end
        end        
        err(curInd) = 0;        
        for j=1:R
            for k=j+1:R
                if ((j~=ii) && (k~=ii))
                    err(curInd) = err(curInd) + abs(temp(j,curInd)+temp(k,curInd)-2*temp(j,curInd)*temp(k,curInd)-contradict(j,k))^norm;                    
                end
            end
        end        
        err(curInd) = err(curInd)^(1/norm);        
    end
end
[~, errInd] = sort(err);

res = temp(:,errInd(1));