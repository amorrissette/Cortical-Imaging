function regImgs = imgRegistration(inImgs)

%%%%%%
%
% Using cross correlation 
%
%
%
%%%%%%

onion = imread('onion.png');
peppers = imread('peppers.png');

imshow(onion)
figure, imshow(peppers)


rect_onion = [111 33 65 58];
rect_peppers = [163 47 143 151];
sub_onion = imcrop(onion,rect_onion);
sub_peppers = imcrop(peppers,rect_peppers);


figure
im3 = stdfilt(im2);
im4 = stdfilt(im1);
C = ones(2,1024);
for X = 1:length(squeeze(im4(9,9,:)))
    
    c = normxcorr2(im3,im4(:,:,X));
    [max_c, imax] = max(abs(c(:)));
    [C(1,X), C(2,X)] = ind2sub(size(c),imax(1));
%     imagesc(c)
end

% offset found by correlation
[max_c, imax] = max(abs(c(:)));
[ypeak, xpeak] = ind2sub(size(c),imax(1));
corr_offset = [(xpeak-size(sub_onion,2))
               (ypeak-size(sub_onion,1))];

% relative offset of position of subimages
rect_offset = [(rect_peppers(1)-rect_onion(1))
               (rect_peppers(2)-rect_onion(2))];

% total offset
offset = corr_offset + rect_offset;
xoffset = offset(1);
yoffset = offset(2);


