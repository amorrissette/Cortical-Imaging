function playLick_Movie(out)

%%%%%
%
% Function to play Beta Movie
%   Need to run betaCalc first!
%
%%%%%


hF = figure;

for X = 1:1:out.sZ
    if ishandle(hF)
        subplot(1,2,1), imagesc(out.imgD(:,:,X)), caxis([0 8000]), axis off square
        subplot(1,2,2), imagesc(out.lickBlur(:,:,X)), caxis([0 0.003]), axis off square
        newLabel = [num2str(X*5) ' ms'];
        text('units','pixels','position',[20 10],'fontsize',25,'string',newLabel,'Color','k')
      
        pause(0.01)
        
    else
        break
    end
end
