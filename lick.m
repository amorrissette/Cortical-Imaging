% lick2 = [532,553,555,558] ;
lick2 = [113,114,116,117,119];
lick1 = [111,112,115,118,120];
% lick1 = [554,556,557,559,560,561,562] ;

l1 = ones(100,100,1024,length(lick1));
l2 = ones(100,100,1024,length(lick2));

for x = 1:length(lick1)
    out = preProcVSFP4('0208',num2str(lick1(x)));
    l1(:,:,:,x) = spatialAvg(out.imgDR,3);
end

for x = 1:length(lick2)
    out = preProcVSFP4('0208',num2str(lick2(x)));
    l2(:,:,:,x) = spatialAvg(out.imgDR,3);
end
    