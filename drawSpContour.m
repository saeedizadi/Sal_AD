function maskim = drawSpContour(l, im,spNum ,col)
    
    % Form the mask by applying a sobel edge detector to the labeled image,
    % thresholding and then thinning the result.
%    h = [1  0 -1
%         2  0 -2
%         1  0 -1];
    l(l ~= spNum) = 500;
    h = [-1 1];  % A simple small filter is better in this application.
                 % Small regions 1 pixel wide get missed using a Sobel
                 % operator 
    gx = filter2(h ,l);
    gy = filter2(h',l);
    maskim = (gx.^2 + gy.^2) > 0;
    maskim = bwmorph(maskim, 'thin', Inf);
    
    % Zero out any mask values that may have been set around the edge of the
    % image.
    maskim(1,:) = 0; maskim(end,:) = 0;
    maskim(:,1) = 0; maskim(:,end) = 0;
    
    % If an image has been supplied apply the mask to the image and return it 
    if exist('im', 'var') 
        if ~exist('col', 'var'), col = 0; end
        [~,~,dep] = size(im);
        if dep == 1
            im = repmat(im,[1,1,3]);    
        end
        maskim = maskimage(im, maskim, col);
    end