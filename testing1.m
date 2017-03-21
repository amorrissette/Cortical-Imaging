
TM = [1,10,1,10;10,1,10,1;1,10,1,10;10,1,10,1];
TM2 = imresize(TM, 25);


x1 = gausswin(10);
x2 = -gausswin(10);
x3 = [x1;x2];
x4 = [];

for x = 1:1040/20
    x4(((x-1)*20+1):x*20) = x3;
end

x4 = x4(1:1024).*5 + 5;

x5 = bsxfun(@times,ones(10000,1024),x4);
x6 = reshape(x5,[100,100,1024]);

x7 = bsxfun(@plus,x6,TM2);

I = ones(100,100);
H = fspecial('gaussian',[100,100],50);
blurred = imfilter(I,H);

fH = figure;

for X = 1:1024
    if ishandle(fH)
        imagesc(x7(:,:,X)),caxis([0,20])
        pause(0.001)
    else
        break
    end
end

gausswin(200)
