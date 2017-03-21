
x = 31;
% 2, 4, 7, 8, 9 ,10?, 11, 18, 20, 21, 22, 23, 25, 26, 27?, 28, 29, 30?, 31
%%
data1 = dataOut(3).amplifier_data(x,:)-dataOut(3).amplifier_data(x+1,:);
[B,A] = butter(2,250/10000,'high');
data1 = filtfilt(B,A,data1);

%%
figure
plot(data1)