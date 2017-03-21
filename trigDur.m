function out = trigDur(in,Fs,info)

%%%%
%   
%    Input TTL signal and will output length of each pulse
%
%%%%

out = struct('Fs',Fs);
inDiff = diff(in);
[pulseStarts] = find(inDiff == 1);
[pulseEnds] = find(inDiff == -1);

if isempty(pulseEnds) || isempty(pulseStarts)
    pulseEnds = [];
    pulseStarts = [];
end

if length(pulseStarts) > length(pulseEnds)
    pulseStarts = pulseStarts(1:end-1);
elseif length(pulseStarts) < length(pulseEnds)
    if pulseStarts(1) < pulseEnds(1)
        pulseEnds = pulseEnds(1:end-1);
    else
        pulseEnds = pulseEnds(2:end);
    end
end
alignment = 1;

for x = 1:length(pulseStarts)
    if pulseStarts(x) > pulseEnds(x)
        disp('Bad alignment on Trial: Check program and signal traces')
        alignment = 0;
    else
        alignment = 1;
    end
end

pulseLengths = pulseEnds-pulseStarts;
pulseLengthsMSEC = pulseLengths.*5;

pulseFreqs = (pulseStarts(2:end)-pulseStarts(1:end-1)).\1;
pulseFreqsHZ = pulseFreqs./0.005;

if info == 1
    disp([num2str(length(pulseStarts)) ' pulses found in series']);
    disp(['Average duration of pulses is: ' num2str(mean(pulseLengthsMSEC)) ' msecs'])
    disp(['Average pulse freq is: ' num2str(mean(pulseFreqsHZ)) ' Hz'])
end

out.pulseFreqs = pulseFreqs;
out.pulseFreqsHZ = pulseFreqsHZ;
out.pulseLengths = pulseLengths;
out.pulseLengthsMSEC = pulseLengthsMSEC;
out.pulseStarts = pulseStarts;
out.pulseEnds = pulseEnds;
out.alignment = alignment;