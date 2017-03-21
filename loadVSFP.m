function input = loadVSFP(files)

%%%%%%%%%%%%%%%
%
%   Loads in structs of PREPROCESSED VSFP files for analysis
%       *If no files exists, will prompt user to select files manually
%
%   Version 1.0 (May 13, 2016) - Arthur Morrissette
%
%%%%%%%%%%%%%%

[file, path, filterindex] = ...
    uigetfile('*_out.mat', 'Select VSFP Data File(s)','MultiSelect', 'on');
input = struct('date',date);
if length(file) > 1
    for fileNum = 1:length(file);
        input(fileNum).data = load([path file{fileNum}]);
    end
elseif length(file) == 1
    input.data = load([path file]);
else 
    error('Must select a valid file for analysis')
end
    
