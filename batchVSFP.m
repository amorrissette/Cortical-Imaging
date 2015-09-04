function [out,outFilt,outROI,imagefilt,time,imgs] = batchVSFP(day,files)

% Function to perform some kind of calculation or processing on batches of
% VSFP image files.
% 
% Usage:
%   out = batchVSFP(fileNames, proc)
%
% fileNames must be 
%
% Options for proc
%   'avg' = average of (hopefully preprocessed) image files
%   'div' = division of image files (not implemented) yet...
%   'pre' = preprocess included image files
%   'post' = post-process image files (detrending/demean)
%   'ROI1' = generate and ROI of window (based on precense of HR in signal)
%   'ROI2' = generates ROI based on user selected window


% Version Control (1.1 updated on 6/22/15 - AEM)
% out = struct('Version','v1.1','date',date);

%% Cases

% if strcmp(proc,'avg') == 1

    
%% 
disp('Processing 1st file')
 [imgs140, ~] = preProcVSFP(day,files(1));
 imageDR0 = imgs140.imgDivDetrend;
 imageDR0filt = imgs140.imgDivFilt;
 imageDR0ROI = imgs140.imgROI;
 figure, title('140-1'), plot(squeeze(imgs.imgs140.imgDiv(30,55,:)));
 figure, title('140-2'), plot(squeeze(imgs.imgs140.imgDiv(75,40,:)));
 pause(5)
%  clear imgs140
disp('Processing 2nd file')
 [imgs141, ~] = preProcVSFP(day,files(2));
 imageDR1 = imgs141.imgDivDetrend;
 imageDR1filt = imgs141.imgDivFilt;
 imageDR1ROI = imgs141.imgROI;
  figure, title('141-1'), plot(squeeze(imgs.imgs141.imgDiv(30,55,:)));
 figure, title('141-2'), plot(squeeze(imgs.imgs141.imgDiv(75,40,:)));
 pause(5)
%  clear imgs141
disp('Processing 3rd file')
 [imgs142, ~] = preProcVSFP(day,files(3));
 imageDR2 = imgs142.imgDivDetrend;
 imageDR2filt = imgs142.imgDivFilt;
 imageDR2ROI = imgs142.imgROI;
  figure, title('142-1'), plot(squeeze(imgs.imgs142.imgDiv(30,55,:)));
 figure, title('142-2'), plot(squeeze(imgs.imgs142.imgDiv(75,40,:)));
 pause(5)
%  clear imgs142
disp('Processing 4th file')
 [imgs143, ~] = preProcVSFP(day,files(4));
 imageDR3 = imgs143.imgDivDetrend;
 imageDR3filt = imgs143.imgDivFilt;
 imageDR3ROI = imgs143.imgROI;
  figure, title('143-1'), plot(squeeze(imgs.imgs143.imgDiv(30,55,:)));
 figure, title('143-2'), plot(squeeze(imgs.imgs143.imgDiv(75,40,:)));
 pause(5)
%  clear imgs143
disp('Processing 5th file')
 [imgs144, time] = preProcVSFP(day,files(5));
 imageDR4 = imgs144.imgDivDetrend;
 imageDR4filt = imgs144.imgDivFilt;
 imageDR4ROI = imgs144.imgROI;
  figure, title('144-1'), plot(squeeze(imgs.imgs144.imgDiv(30,55,:)));
 figure, title('144-2'), plot(squeeze(imgs.imgs144.imgDiv(75,40,:)));
 pause(5)
%  clear imgs144
 
 out = imageDR0+imageDR1+imageDR2+imageDR3+imageDR4;
 outFilt = imageDR0filt+imageDR1filt+imageDR2filt+imageDR3filt+imageDR4filt;
 outROI = imageDR0ROI+imageDR1ROI+imageDR2ROI+imageDR3ROI+imageDR4ROI;
 
 imagefilt(1,:) = squeeze(imageDR0filt(60,70,1:1000));
 imagefilt(2,:) = squeeze(imageDR1filt(60,70,1:1000));
 imagefilt(3,:) = squeeze(imageDR2filt(60,70,1:1000));
 imagefilt(4,:) = squeeze(imageDR3filt(60,70,1:1000));
 imagefilt(5,:) = squeeze(imageDR4filt(60,70,1:1000));
 
 imgs.imgs140 = imgs140;
 imgs.imgs141 = imgs141;
 imgs.imgs142 = imgs142;
 imgs.imgs143 = imgs143;
 imgs.imgs144 = imgs144;
 
 
