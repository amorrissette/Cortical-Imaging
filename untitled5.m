

% Nx = length(x);
% nsc = floor(Nx/4.5);
% nov = floor(nsc/2);
% nff = max(256,2^nextpow2(nsc));

Fs = out.Fs;
spectrogram(x,200,180,50,Fs,'yaxis','power'),caxis([-70,-50])

maxerr = max(abs(abs(t(:))-abs(s(:))))