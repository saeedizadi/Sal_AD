clear
load('data1')

% temp = bsxfun(@gt,bad,0.2);
% temp2 = sum(temp,1);

%load('auc')
%temp = [good,good];
%aucs = roc_aucs(2:end);
%[~,I] = sort(temp,1,'descend');
%
%for i=1:size(temp,2)
%    t = I(:,i);
%    temp2(:,i) = aucs(t)';
%end

 for i=1:size(bad,2)
     for j=1:17
         better(j,i) = sum(bsxfun(@gt,bad(j,i),bad(:,i)),1);
     end
 end

% for i=1:size(good,2)
%     nLess(i) = numel(find(good(:,i)<0.2));
% end
% 
% nLess = nLess>10;
% 
% temp = sum(nLess)/numel(nLess)
% 
% [~,I] = sort(good,1,'descend');
% I = I(1,:);
% ismem = sum(ismember(I,[8,13,14]),1)>0;
% 
% temp = sum(ismem)/numel(ismem)
% 
% goodM = or(nLess,ismem);
% temp = sum(goodM)/numel(goodM)
% 
% for i=1:size(good,2)
%     isGreater(i) = sum(bsxfun(@ge,good(8,i),[good(4,i) good(12,i) good(7,i)]))>0;
% end
% goodM = or(goodM,isGreater);
% temp = sum(goodM)/numel(goodM)
% 
