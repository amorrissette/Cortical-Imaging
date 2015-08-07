function avgVSFP = vsfpAvg(vsfp_data, numDiv)

% Generates example traces and plots from region averages based on number of
% divisions of vsfp imaging area
%
%   Usage outTraces = vsfpPlot(vsfp_data, numDiv, plotOn)
%
%   * Must use divisions that play nicely with 100 (eg 25,50,5,10,etc)

%% 
% if strcmp(plotOn, 'on') == 1 
%     p = 1;
% else p = 0;
% end

[d1,~,d3] = size(vsfp_data);

totalDiv = floor(d1/numDiv);
avgVSFP = zeros(totalDiv, totalDiv, d3);
%
% if mod(numDiv,d1) ~= 0 
%     error('Number of divisions must be divisible by 100')
% end

%% Divide and Conquer

tic
i = 1;
figure

for x = 1:totalDiv
    for y = 1:totalDiv
        avgVSFP(x,y,1:d3) = mean(mean(vsfp_data(numDiv*(x-1)+1:(numDiv*x),numDiv*(y-1)+1:(numDiv*y),:)));
        subplot(totalDiv, totalDiv, i);
        plot(squeeze(avgVSFP(x,y,600:1000)));
        axis off
        i = i+1;
    end
end
toc


% old stuff

%         I(numDiv*(x-1)+1:(numDiv*x),numDiv*(y-1)+1:(numDiv*y),i) = ones(numDiv);
%         for z = 1:d3
%             avgVSFP(x,y,z) = mean(vsfp_data(:,:,z).*I(1:100,1:100,i));
%         end

% I = zeros(100,100,totalDiv);
