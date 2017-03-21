function out = vsfpPCA(out)

%%%%%
%
%   Function to run PCA on dual camera imaging stacks
%
%   Recieves input from output from preProcVSFP7
%   
%   Usage:
%       
%
%
%%%%%

%% Run PCA - Currently Removed in Version 5!

imgD1 = out.imgD1;
imgA1 = out.imgA1;
[sX,sY,sZ] = size(imgD1);
sXY = sX*sY;
avgingFr = 10;

disp('Running PCA ...')
D1d = reshape(imgD1,[sX*sY*sZ,1]);
A1d = reshape(imgA1,[sX*sY*sZ,1]);
imgTotal = [A1d,D1d];

% specify number of componenets = 2
[~,score,~] = pca(imgTotal,'NumComponents', 2);  

imgVolt2dRaw = reshape(score(:,2),[sXY,sZ]);
imgHem2dRaw = reshape(score(:,1),[sXY,sZ]);

% Calculate output of PCA as change from baseline as done for ratio eql
imgHemAvg = mean(imgHem2dRaw(1:sXY,1:avgingFr),2);
imgVoltAvg = mean(imgVolt2dRaw(1:sXY,1:avgingFr),2);

imgHem2d = bsxfun(@rdivide,bsxfun(@minus,imgHem2dRaw,imgHemAvg),imgHem2dRaw(1:sXY,1));
imgVolt2d = bsxfun(@rdivide,bsxfun(@minus,imgVolt2dRaw,imgVoltAvg),imgVolt2dRaw(1:sXY,1));

imgHem = reshape(imgHem2d,[sX,sY,sZ]);
imgVolt = reshape(imgVolt2d,[sX,sY,sZ]);

HemBlur = spatialAvg(imgHem,3);
VoltBlur = spatialAvg(imgVolt,3);

out.HemBlur = HemBlur;
out.VoltBlur = VoltBlur;

disp('done!')
end
