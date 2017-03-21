function simpleMovie(out)

minI = mean2(mean(out.blur3,3))-std2(std(out.blur3));
maxI = mean2(mean(out.blur3,3))+std2(std(out.blur3));
fH = figure;
for x = 1:10:out.sZ
    if ishandle(fH)
        imagesc((out.blur3(:,:,x))), caxis([0 0.001]), colormap('parula'), axis off square, hold on
       
        newLabel = [num2str(x*5) ' ms'];
        text('units','pixels','position',[10 20],'fontsize',40,'string',newLabel,'Color','w')
        hold off
        
        pause(0.1)
    else break
    end
end