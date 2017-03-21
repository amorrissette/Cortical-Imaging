
%%%%%%%
% 5392 5440 5477 5562 53
%   Function for brain poster fig... 
% 
%   Traces used in poster from coord.
%            trials 140  141  142  143  144
%       S1 - 75,40
%       M1 - 30,55 [    [/5070      [5449/5050][5450/5013]
%       middle - 60,70
%
%%%%%%%

f1 = 200;
f2 = 220;
DR2 = zeros(100,100,256,f2-f1+1);
% A2= zeros(100,100,256,f2-f1+1);
% D2= zeros(100,100,256,f2-f1+1);
region = roiSelect('0916', '190');
region2 = roiSelect('0916', '190');

avgGain = gainCalc('0916', f1:1:f2);
y = 1;
%%
for x = f1:f2
    out = preProcVSFP4('0916',num2str(x),region);
    out.region = region;
    DR2(:,:,:,y) = out.imgDR;
% 
%     dataEql = out.imgDR(region2(3):region2(4),region2(1):region2(2),:);
%     [sX,sY,sZ] = size(dataEql);
%     dataReEql = reshape(dataEql,[sX*sY,sZ]);
%     Nx = length(mean(dataReEql,1));
%     nsc = floor(Nx/20);
%     nov = floor(nsc/2);
%     [~,F1,T1,P1] = spectrogram(mean(dataReEql,1),hamming(nsc),nov,max(512),200,'yaxis');
%     F(:,:,y) = F1;
%     T(:,:,y) = T1;
%     P(:,:,y) = P1;
    clear out
    y = y + 1;
end

dr_mean2 = mean(DR2,4);
% a_mean2 = mean(A2,4);
% d_mean2 = mean(D2,4);

dr_avg2 = spatialAvg(dr_mean2,3);

surf(T(:,:,1),F(:,:,1),10*(log10(abs(P(:,:,1)))+log10(abs(P(:,:,2)))+log10(abs(P(:,:,3)))+log10(abs(P(:,:,4)))+log10(abs(P(:,:,5)))),'edgecolor','none');
%# this is actually a 3D plot, so we set the viewing
%# angle as straight up and rotated by 90 to match the previous plots
view(90,90);
axis tight;
ylabel('Freq (Hz)');
xlabel('Time');