function out = dataShuff(indata,divisions)

% Function to shuffle data (time series) by number of divisions
%   
%   Usage
%       out = dataShuff(indata,divisions)
%
%

lData = length(indata);
lDiv = lData./divisions;
newData = ones(1,lData);
seq = randperm(divisions);

for x = 1:divisions
    oldData = indata(lDiv*(x-1)+1:lDiv*x);
    newData(lDiv*(seq(x)-1)+1:lDiv*seq(x)) = oldData;
end

out = newData;
