function colorPlot(input_Array, cb)

%%%%%
%
%   Function that recieves input array and plots using imagesc
%       Automatic scaling with colorbar and reshapes data such that minimum
%       length axis are the rows
%
%       Usage:
%       
%           colorPlot(input_Array, colorbar on?)
%
%%%%%

[sX,sY] = size(input_Array);

if sX > sY
    input_Array = input_Array';
end


imagesc(input_Array)

if cb == 1
    colorbar
end
