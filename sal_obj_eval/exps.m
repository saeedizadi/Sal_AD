methods = {'sp'};
%methods = {'OUR'};

for iter=1:numel(methods)
    met = ['_' methods{iter}];
    fprintf('Working on method: %s\n',methods{iter});
    evaluate_salient_object;
    save(['evals/' methods{iter} '_evals.mat']);
    clearvars -except iter methods
end
