function out = vsfpPowerMap(data, band)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Function to visualize power in specified BAND over cortical map
%       
%       Usage: 
%           out = vsfpPowerMap(data, band)
%
%   where DATA is the vsfp data file and BAND is the frequency band of
%   interest. DATA is structure from the output of preProcVSFP.
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Check if the specified band range has already been filtered from preProcVSFP

filt_range = data.filt;
if band(1) < 