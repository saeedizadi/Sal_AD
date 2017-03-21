function benchmark()
allImgPath = dir('./images/*.jpg');

for i=1:size(allImgPath,1)
    tic;
    disp(i)
    name = allImgPath(i).name;
    num = name(1:end-4);
    Process(num);
    toc
end

end
