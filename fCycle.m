function output = fCycle(files, functions, params, Foutput)


%%%%%%%%
%
%   Used to chain a sequnce of functions together for any number of
%   fuctions
%
%       Usage:
%
%
%
%%%%%%%%

out = preProcVSFP7('1102','375','VSFP12');

lFiles = length(files);
fOutput = struct('files',files);
for n = 1:lFiles
    
    for func = functions
        
        
        
    