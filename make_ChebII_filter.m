function filt = make_ChebII_filter(ftype, Fs, passband, cutoff, attenuation)
% make_ChebII_filter: design a Chebyshev type 2 digital filter
%
% Usage: 
%		filt = make_ChebII_filter(ftype, Fs, passband, cutoff, attenuation);
%
% Arguments:
%
%	ftype: integer from 1 to 4
%		1 = bandpass
%		2 = lowpass
%		3 = highpass
%		4 = bandstop
%
%	Fs: sampling frequency (in Hz) for which this filter is valid.
%
%	passband: edges of the frequency band allowed to pass (in Hz)
%		--> single value for lowpass or highpass
%		--> 2-element vector for bandpass or bandstop
%		--> example: if the passband of a bandpass filter is [100, 1000], then
%				all frequencies from 100 - 1000 Hz will pass through with no
%				more than Rp decibals of attenuation (Rp is a parameter for the
%				cheb2ord function).
%
%	cutoff: edge freqs at which the filter achieves the desired attenuation
%		--> single value for lowpass or highpass
%		--> 2-element vector for bandpass or bandstop
%		--> example: if the cutoff is [80, 1200], then all frequencies <= 80
%				and >= 1200 Hz will be attenuated by at least <attenuation> dB.
%	
%	attenuation (optional): the minimum attenuation (in dB) achieved 
%		by the filter for frequencies that are outside passband cutoffs.
%		--> default is 20
%
% Usage Example:
%	myfilter = make_ChebII_filter(1, 10000, [300,3000], [270,3300], 40);
%	fdata = filtfilt(myfilter.numer, myfilter.denom, data);
%
% Author: J. Edgerton, 10/2009

if nargin < 4
	error('4 arguments required.');
elseif nargin < 5
	attenuation = 20;
end

filt = struct('type', [], 'Fs', Fs, 'passband', passband, 'Wpass', []);
filt.Wpass = filt.passband .* 2 ./ filt.Fs;
%	Wpass = passband in units of pi*radians per sample, used by cheb2ord()
filt.cutoff = cutoff;
filt.Wstop = filt.cutoff .* 2 ./ filt.Fs;
%	Wstop = stop band in units of pi*radians per sample, used by cheb2ord() and
%		cheby2().
filt.attenuation = attenuation;
filt.order = []; filt.numer = []; filt.denom = [];

if ftype == 2
	ft = 'low';
	filt.type = 'lowpass';
elseif ftype == 3
	ft = 'high';
	filt.type = 'highpass';
elseif ftype == 4
	ft = 'stop';
	filt.type = 'bandstop';
else
	ftype = 1;
	ft = 'band';
	filt.type = 'bandpass';
end

[filt.order,filt.Wstop] = cheb2ord(filt.Wpass, filt.Wstop, 3, filt.attenuation);

if ftype == 1
	[filt.numer, filt.denom] = cheby2(filt.order, filt.attenuation, filt.Wstop);
else
	[filt.numer,filt.denom]=cheby2(filt.order,filt.attenuation,filt.Wstop,ft);
end
