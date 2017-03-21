
% algs = {'OURS','AC','AIM','CA','CB','FT','GB','HC','IM','IT','LC','MSS','RC','SEG','SeR','SR','SUN','SWD'};
algs = {'bayes','sp'};
figure('name',['recall vs precision(MSRA10K)']);
ylim([0 1]);
xlim([0 1]);
xlabel('Recall'); ylabel('Precision');
hold on

cmap = hsv(18);
markers = {'--','-.','-'};
for it=1:numel(algs)
    disp(algs{it})
    load(['evals/' algs{it} '_evals']);
    algs = {'bayes','sp'};
    disp(it)
%     if it == 1
%         plot(recalls,precisions,'k--');
%     else
        disp('saeeeeeee');
        markIdx = randperm(3,1);
        plot(recalls,precisions,'color',cmap(it,:),'linestyle',markers{markIdx},'LineWidth',1);
%     end
end
legend(algs,'Orientation','vertical');

% figure('name',['FPR vs TPR']);
% ylim([0 0.15]);
% xlim([0 0.15]);
% xlabel('FPR'); ylabel('TPR');
% hold on
%
% cmap = hsv(18);
%
% markers = {'--','-.','-'};
% for it=1:numel(algs)
%     disp(algs{it})
%     load(['evals/' algs{it} '_evals']);
%     algs = {'bayes','sp'};
%     data = [];
%     if it == 1
%         fnrs = 1-tprs;
%         plot(fprs,(1-tprs),'k--');
%     else
%         markIdx = randperm(3,1);
%         plot(0.9*fprs,0.9*(1-tprs),'color',cmap(it,:),'linestyle',markers{markIdx},'LineWidth',1);
%     end
% end
% legend(algs,'Orientation','vertical');



% roc_aucs = [];
% fscore_betas = [];
% for it=1:numel(algs)
%     disp(algs{it})
%     load(['evals/' algs{it} '_evals']);
%     roc_aucs = [roc_aucs,roc_auc];
% end
% bar(roc_aucs);
% set(gca, 'XTickLabel',algs, 'XTick',1:numel(algs))
