function playMovie(out, argsin)

h = figure;

[~,~,sZ] = size(out.imgDR);
if nargin > 1
    mask = argsin;
else
    mask = ones(100,100);
end
blur3 = bsxfun(@times,out.blur3,mask);
imgGA = bsxfun(@times,bsxfun(@minus,out.Aeql,out.Aeql(:,:,1)),mask);
imgGD = bsxfun(@times,bsxfun(@minus,out.Deql,out.Deql(:,:,1)),mask);

if isfield(out,'irLicks') 
    rLicks = out.irLicks;
    lLicks = out.ilLicks;
else
    rLicks = zeros(1,sZ);
    lLicks = zeros(1,sZ);
end    

if isfield(out,{'rTrial','lTrial'})
    rTrial = out.rTrial;
    lTrial = out.lTrial;
else 
    rTrial = 0;
    lTrial = 0;
end

if isfield(out,'APint')
    APint = out.APint;
else
    APint = [0,0];
end

% Aeql = bsxfun(@times,out.Aeql,mask);
% Deql = bsxfun(@times,out.Deql,mask);

for x = 1:2:sZ
    if ishandle(h) == 1
        subplot(2,2,1), imagesc(out.imgD1(:,:,x)), caxis([0 8000]), colormap('parula'), title('Base'), axis off square
        subplot(2,2,2), imagesc(blur3(:,:,x)), caxis([-0.01 0.01]), title('Ratiometric'), axis off square, hold on
        newLabel = [num2str(x*5) ' ms'];
        text('units','pixels','position',[5 5],'fontsize',18,'string',newLabel,'Color','r')
         % Plot Licks on the video as well
        if rLicks(x) == 1 
            plot(10,10,'r.','MarkerSize',50)
        elseif lLicks(x) == 1
            plot(10,10,'b.','MarkerSize',50)
        else
            plot(10,10,'w.','MarkerSize',50)
        end
               
        % Plot AP interval
        if x >= APint(1)*200 && x<=APint(2)*200
            if rTrial == 1
                plot(40,10,'r.','MarkerSize',50)
            else
                plot(40,10,'b.','MarkerSize',50)
            end
        else
            plot(40,10,'w.','MarkerSize',50)
        end
        
        hold off
        subplot(2,2,3), imagesc(imgGA(:,:,x)), caxis([-100 100]), title('Donor'), axis off square
        subplot(2,2,4), imagesc(imgGD(:,:,x)), caxis([-100 100]), title('Acceptor'), axis off square
       
 
% Pause is needed for the figure to update
        if (200 < x) && (x < 300)
            pause(0.0001)
        else
            pause(0.0001)
        end
        
        pause(0.0001)
    else
        break
    end
end

