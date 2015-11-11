function outImg = imgReg(inImg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Image Registration for VSFP data 
%       
%       function outImg = imgReg(inImg)
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[sX, sY, sZ] = size(inImg);
newImg(bs-1:(bs-1+99),bs-1:(bs-1+99),:) = inImg;
change = zeros(3);
shifts = 0;
diff = [0,0,0,0];

for i = 2:length(sZ)
    diffImg0 = inImg(:,:,i) - inImg(:,:,i-1);
    diff0 = mean2(abs(diffImg0));
    diff(1) = mean2(abs(inImg(2:end,:,i) - inImg(1:end-1,:,i)));
    diff(2) = mean2(abs(inImg(1:end-1,:,i) - inImg(2:end,:,i)));
    diff(3) = mean2(abs(inImg(:,1:end-1,i) - inImg(:,2:end,i)));
    diff(4) = mean2(abs(inImg(:,2:end,i) - inImg(:,1:end-1,i)));
    
    for I = 1:4
        if diff(I) < diff0;
            shift = shift + 1;
        end
    end
    
    
end
    
    

end
            
    
    
