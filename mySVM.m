load('data2');
features = features';
label = label';

ordering = randperm(numel(label));
features = features(ordering,:);
label = label(ordering);


CVO = cvpartition(label,'k',5);

disp('Training the Classifier ...')

for i=1:CVO.NumTestSets
    fprintf('Train SVM for k = %d\n',i);

    trIdx = CVO.training(i);
    teIdx = CVO.test(i);

    trData = features(trIdx == 1,:);
    trLabel = label(trIdx == 1,:);

    teData = features(teIdx == 1,:);
    teLabel = label(teIdx == 1,:);

    model = svmtrain(trLabel, trData,'-s 0 -t 0 -c 1 -q');
    [~,accuracy,~] = svmpredict(teLabel,teData,model);
    acc(i) = accuracy(1);

end

cvAcc = mean(acc);
