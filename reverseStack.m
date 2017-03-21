function imgOut = reverseStack(imgIn)

% Used for converting image stack for use with Thunder Python Image
% Processing Programs

[sX, sY, sZ] = size(imgIn);
imgOut = ones(sZ,sX,sY);

for z = 1:sZ
    imgOut(z,:,:) = imgIn(:,:,z);
end

