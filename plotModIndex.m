function plotModIndex(out)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Plot modulation index around stim
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fs = 200;
% slope = diff(squeeze(out.imgD(50,50,:)));
% stim = find(abs(slope)>8*std(slope));
stim = 200;

s1 = stim(1);
s2 = stim(1)+200;
% % region = out.region;
% foff = mean(out.imgDR(region(3):region(4),region(1):region(2),s1-20:s1),3);
% fon = mean(out.imgDR(region(3):region(4),region(1):region(2),s2:s2+20),3);

foff = mean(out.imgDR(:,:,s1-10:s1),3);
fon = mean(out.imgDR(:,:,s1+20:s1+30),3);
% fon = mean(out.imgDR(region(3):region(4),region(1):region(2),s2:s2+20),3);


ModIndex = foff - fon ./ (fon + foff);
figure,
imagesc((ModIndex)), caxis([-5,3])
colorbar
