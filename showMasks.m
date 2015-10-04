function showMasks(masks,im)
overalMask = masks{end};

temp = zeros([size(overalMask) 2]);

colorMask = cat(3,overalMask,temp);
tmp = colorMask(:,:,1);
tmp(masks{1}) = 0;
colorMask(:,:,1) = tmp;

tmp = colorMask(:,:,3);
tmp(masks{1}) = 1;
colorMask(:,:,3) = tmp;

%t = imfuse(im,im2uint8(colorMask));
imshow(colorMask,[]);

end