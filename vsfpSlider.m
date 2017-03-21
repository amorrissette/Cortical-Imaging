function displayIm3d(out)

im = out.blur3;
im2 = out.imgGD;
im3 = out.imgGA;
sizeImg = size(im);
minSlice = 1;
maxSlice = sizeImg(3);
startSlice = 1;

% Create a figure without toolbar and menubar.
hfig = figure('Toolbar','none',...
              'Menubar', 'none',...
              'Name','VSFP Viewer',...
              'NumberTitle','off',...
              'IntegerHandle','off');
slider1 = uicontrol(hfig,'Style','slider','Callback',@slider1_Callback,'Position', [131 5 200 20]);
          
set(slider1,'value',startSlice); %
set(slider1,'max',maxSlice); %
set(slider1,'min',minSlice); 
set(slider1,'SliderStep', [1/1024,0.01]);

slice = get(slider1,'Value'); % returns position of slider

% Display the image in a figure with imshow.
subplot(1,2,1)
himage = imshow(im(:,:,slice)); 
colormap('parula')
caxis([0 0.01]);

newLabel = [num2str(slice*5) ' ms'];
text('units','pixels','position',[5 5],'fontsize',18,'string',newLabel,'Color','r')

hpixinfo = impixelinfo(himage);

set(himage,'ButtonDownFcn',@pixelInfo)


function slider1_Callback(slider1,eventdata,handles)
% update the displayed image when the slider is adjusted
slice = round(get(slider1,'Value'));
temp = guidata(gcbo);
coords = temp.coords;
subplot(1,4,1)
imshow(im(:,:,slice)),colormap('parula'),caxis([0 0.01]);
rectangle('position',[coords(1)-1 coords(2)-1 2 2],'EdgeColor','r','curvature',1,'LineWidth',2)
newLabel = [num2str(slice*5) ' ms'];
text('units','pixels','position',[5 5],'fontsize',18,'string',newLabel,'Color','r')

data = temp.dataTrace;
subplot(1,4,2)
plot(data,'k'), axis square, hold on, title('point')
line([slice slice],[min(data), max(data)],'Color',[1 0 0])
hold off

data2 = temp.dataTrace2;
subplot(1,4,3)
plot(data2,'k'), axis square, hold on, title('point')
line([slice slice],[min(data2), max(data2)],'Color',[1 0 0])
hold off

data3 = temp.dataTrace3;
subplot(1,4,4)
plot(data3,'k'), axis square, hold on, title('point')
line([slice slice],[min(data3), max(data3)],'Color',[1 0 0])
hold off
end


function pixelInfo(cursor,eventdata,handles)
% get coordinates of clicked pixel
[ x, y ] = ginput(1);
data = squeeze(im(round(x),round(y),:));
data2 = squeeze(im2(round(x),round(y),:));
data3 = squeeze(im3(round(x),round(y),:));
myhandles = guidata(gcbo);
% Modify the value of your counter
myhandles.dataTrace = data;
myhandles.dataTrace2 = data2;
myhandles.dataTrace3 = data3;
myhandles.coords = [round(x),round(y)];
% Save the change you made to the structure
guidata(gcbo,myhandles) 


end

end


% function vsfpSlider(dataIn)
% %% Beginning of outer function red_blue
% % Create figure
% 
% f = figure('Visible','on','Name','My GUI',...
%            'Position',[360,500,600,600]);
% % Create an axes object to show which color is selected
% Img = axes('Parent',f,'units','pixels',...
%            'Position',[50 50 512 512]);
% % Create a slider to display the images
% slider1 = uicontrol('Style', 'slider', 'Parent', f, 'String', 'Image No.', 'Callback', @slider_callback, ...
%     'Units', 'pixels', 'Position', [231 5 100 20]);
% 
% movegui(Img,'onscreen')% To display application onscreen
% movegui(Img,'center') % To display application in the center of screen
% 
%  imagesc(dataIn(:,:,1));
%  set(findobj(gcf,'type','axes'),'hittest','off');
%  
%  set(handles.slider1, 'Min', 1);
%  set(handles.slider1, 'Max', 1024);
%  set(handles.slider1, 'SliderStep', 1);
%  
% %% Beginning of slider callback function
%     function slider_callback(handles, eventdata)
%         axes(handles.Img);
%         imagesc(dataIn(:,:,currentSlice));
%     end
% end
