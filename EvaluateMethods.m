function res = EvaluateMethods(maps,ground,row,col)

AUC_Score = zeros(17,1);
AUCJudd_Score = zeros(17,1);
NSS_Score = zeros(17,1);
CC_Score  = zeros(17,1);

for i=1:17
    temp = reshape(maps(i,:)',row,col);
    AUC_Score(i) = AUC_Borji(double(temp)./255,double(ground)./255);
    NSS_Score(i) = NSS(double(temp)./255,double(ground)./255);
    CC_Score(i) = CC(double(temp)./255,double(ground)./255);
    %AUCJudd_Score(i) = AUC_Judd(double(temp)./255,double(ground)./255);
end
res = [AUC_Score NSS_Score CC_Score];

end

