function CMOS = shiftCMOS(cmosData)

% transfers each pixel from 3D CMOS data set and shifts into struct
% variables in 2-dimensional space

% Arthur Morrissette v1 may 2015

% *assuming 100x100 pixel space

% lcmos = length(cmosData(1,1,:));

% Create Structure for data copy
CMOS = struct('timeSeries',[],'std',[]);

    for pixNumX = 1:100;
        
        for pixNumY = 1:100;
            
            CMOS.timeSeries.(['X' num2str(pixNumX),'Y' num2str(pixNumY)])...
                = squeeze(cmosData(pixNumX, pixNumY, :));
            
            CMOS.std.(['X' num2str(pixNumX),'Y' num2str(pixNumY)])...
                = std(CMOS.timeSeries.(['X' num2str(pixNumX),'Y' num2str(pixNumY)]));
        
        end
        
    end
     
end

