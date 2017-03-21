function output = vsfpICA(input, numComp)

%%%%%
%   Finds Independent componenets of VSFP signal from 
%
%
%
%%%%%

blur2d = reshape(bsxfun(@times,out.blur3,mask),[out.sX*out.sY,out.sZ]);
mask2d = reshape(mask,[100*100,1]);
blur2d2 = blur2d;

blur2d(mask2d == 0,:) = [];
mblur2d = mean(blur2d);
mblur3d = mean(blur2d2,2);


blur2dDeMean = bsxfun(@minus,blur2d2,mblur2d); 
blur3dDeMean = bsxfun(@minus,blur2dDeMean,mblur3d);

icasig = fastica(blur3dDeMean,'numOfIC',10);
