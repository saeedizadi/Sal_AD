function [contextPatch] = ContextRegion(supLabel,supID,img,alpha)

[x,y] = find(supLabel==supID);
clear mask
%mask = zeros(size(supLabel));

%[x,y] = ind2sub(size(supLabel),xy);
%mask(sub2ind(size(supLabel),x,y)) = 1;

minx = min(x);maxx = max(x);miny = min(y);maxy = max(y);
w = ceil(alpha*(maxy-miny+1));
h = ceil(alpha*(maxx-minx+1));

xc = ceil((minx+maxx)/2);
yc = ceil((miny+maxy)/2)

if xc>size(supLabel,1)
    xc = size(supLabel,1);
end
if yc>size(supLabel,2)
    yc = size(supLabel,2);
end

X = [-w/2 w/2 w/2 -w/2 -w/2];
Y = [h/2 h/2 -h/2 -h/2 h/2];

P = [X;Y];

P(1,:) = P(1,:)+xc;
P(2,:) = P(2,:)+yc;

if xc>size(supLabel,1)
    xc = size(supLabel,1);
end
if yc>size(supLabel,2)
    yc = size(supLabel,2);
end

contextPatch = imcrop(img,[min(P(1,:)) min(P(2,:)) w h]);
imshow(contextPatch)
end

