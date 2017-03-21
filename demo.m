clear;
clc;


sp_nums = [500 400 200 100 50 20];
sp_param = [1 1 1.5 1.5 3 4];

% sp_nums = [500 400 ];
% sp_param = [1 1];


for i=1:numel(sp_nums)
    disp(i)
    estMaps{i} = Process('0010',sp_nums(i),sp_param(i));
end

temp = cat(3,estMaps{:});
finalEstMap = mean(temp,3);