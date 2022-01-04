function varargout = ImageMask(varargin)
% IMAGEMASK MATLAB code for ImageMask.fig
%      IMAGEMASK, by itself, creates a new IMAGEMASK or raises the existing
%      singleton*.
%
%      H = IMAGEMASK returns the handle to a new IMAGEMASK or the handle to
%      the existing singleton*.
%
%      IMAGEMASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEMASK.M with the given input arguments.
%
%      IMAGEMASK('Property','Value',...) creates a new IMAGEMASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageMask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageMask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageMask

% Last Modified by GUIDE v2.5 10-May-2021 17:45:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageMask_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageMask_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ImageMask is made visible.
function ImageMask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageMask (see VARARGIN)

% Choose default command line output for ImageMask
handles.output = hObject;
handles.drawType = 1;
handles.superPixelsNumber = 0;
handles.transparent  =0.5;
handles.acc_num = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageMask wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageMask_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes_main_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_main
xticks('');
yticks('');
box on;


% --------------------------------------------------------------------
function up_openFolder_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to up_openFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    dir_path = fileread([pwd,'\defaultPath.txt']);
catch
    dir_path = '';
end


format='*.jpg;*.JPG;*.jpeg;*.JPEG;*.bmp;*.BMP;*.png;*.PNG;*.tiff;*.TIFF;*.tif;*.TIF';
[filenames,pathname,~] = uigetfile(fullfile(dir_path,format),'select image','MultiSelect', 'on');
filefype = filenames(end-3:end);
if ~iscell(filenames)
    handles.pathname = pathname;
    
    handles.scanfiles =  dir([pathname,'\*',filefype]);
    for jj = 1:size(handles.scanfiles,1)
        if strcmp(filenames,handles.scanfiles(jj).name)     
            handles.currentID = jj;
        end
    end
    %axes(handles.axes_main);
    %handles.currentImg = imread([handles.pathname,handles.scanfiles(1).name]);
    %imshow(handles.currentImg);
    
    handles = updateplot(hObject, handles);
    %handles.currentMask = zeros(size(handles.currentImg));
else
end

guidata(hObject,handles);

% --------------------------------------------------------------------
function up_backforward_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to up_backforward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles = guidata(hObject);
handles.currentID =  handles.currentID -1;
if handles.currentID == 0
    handles.currentID = 1;
end
guidata(hObject,handles);
% handles.currentImg = imread([handles.pathname,handles.scanfiles(handles.currentID).name]);
guidata(hObject,handles);
handles = updateplot(hObject, handles);
guidata(hObject,handles);
set(handles.txt_status,'String','')



% --------------------------------------------------------------------
function up_forward_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to up_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currentID < size(handles.scanfiles,1)
    handles.currentID =  handles.currentID +1;
end
% handles.currentImg = imread([handles.pathname,handles.scanfiles(handles.currentID).name]);
guidata(hObject,handles);
handles = updateplot(hObject, handles);
guidata(hObject,handles);



function handles = updateplot(hObject, handles)
% handles = guidata(hObject);
axes(handles.axes_main);
handles.currentImg = imread([handles.pathname,handles.scanfiles(handles.currentID).name]);

%handles.currentImg = imresize(handles.currentImg,[224,896]);
try
    if get(handles.rb_test,'value')==1
        str = '\prediction\';
    else
        str = '\mask\';
    end
    maskpath = strrep(handles.pathname,'\raw\',str);
    file_name = split(handles.scanfiles(handles.currentID).name,'.');
    trueMask = imread([maskpath,file_name{1},'.png']);
    if max(trueMask(:))==1
        trueMask=uint8(trueMask)*255;
    end
    handles.currentMask = zeros(size(trueMask));
    for i = 1:size(handles.ObjectClasses,2)
        handles.currentMask(trueMask == handles.ObjectValues{1,i}) = i;
    end
    overlay=labeloverlay(im2uint8(handles.currentImg),handles.currentMask,'Transparency',handles.transparent,...
    'Colormap',handles.objectColors(1:size(handles.ObjectClasses,2),:));
    handles.imax = imshow(handles.currentImg);    
    imshow(overlay);
    [m, n]=find(handles.currentMask~=0);   
    k = boundary(m,n,1); 
     xx=m(k);yy=n(k);
%      hold on;
%      plot(yy,xx, 'r', 'Linewidth', 1)
%      hold off;
     m=tabulate(xx);
     [val,~]=find(m(:,2)==2);

    for i=1:size(val,1)
        [mm,~]=find(xx==val(i));
        dis(:,i)=yy(mm);
    end

    realdis=rmoutliers(abs(dis(2,:)-dis(1,:)));
    all_dis=realdis*(10/112);
    ave=mean(all_dis);
    stnd=std(all_dis);

catch 
    handles.currentMask = double(zeros(size(handles.currentImg,1),size(handles.currentImg,2)));
    handles.imax = imshow(handles.currentImg);
end
title([num2str(handles.currentID),'\',num2str(size(handles.scanfiles,1)),':',...
handles.scanfiles(handles.currentID).name,],'interpreter','none');
% set(handles.e_currentID,'String',num2str(handles.currentID));
% set(handles.mean_thickness,'String',num2str(roundn(ave,-2)));
% set(handles.SD,'String',num2str(roundn(stnd,-2)));
guidata(hObject,handles);
set(handles.txt_status,'String','');

function e_currentID_Callback(hObject, eventdata, handles)
% hObject    handle to e_currentID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_currentID as text
%        str2double(get(hObject,'String')) returns contents of e_currentID as a double

try
    handles.currentID =  str2num(get(hObject,'String'));
    guidata(hObject,handles);
    handles = updateplot(hObject, handles);
    guidata(hObject,handles);
    set(handles.txt_status,'String','')
catch
end

% --- Executes during object creation, after setting all properties.
function e_currentID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_currentID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes_main_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pressed = 1;
guidata(hObject,handles);
PosAxes = get(handles.axes_main,'Position');
currGCF = get (gcf, 'CurrentPoint');
if currGCF(1)<PosAxes(1) || currGCF(1)>PosAxes(1)+PosAxes(3) || ...
    currGCF(2)<PosAxes(2) || currGCF(2)>PosAxes(2)+PosAxes(4)
    return;
end
curr = get (gca, 'CurrentPoint');
try
handles = sketch(handles,curr(1,1),curr(1,2));
catch
end
guidata(hObject,handles);

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
if handles.pressed == 0
    return;
end
catch
    return;
end
PosAxes = get(handles.axes_main,'Position');
currGCF = get (gcf, 'CurrentPoint');
if currGCF(1)<PosAxes(1) || currGCF(1)>PosAxes(1)+PosAxes(3) || ...
    currGCF(2)<PosAxes(2) || currGCF(2)>PosAxes(2)+PosAxes(4)
    return;
end
curr = get (gca, 'CurrentPoint');
% handles.pre=handles.currentMask;
try
handles = sketch(handles,curr(1,1),curr(1,2));
catch
end
handles.post=handles.currentMask;
guidata(hObject,handles);

function  handles = sketch(handles,x,y)

if(handles.superPixelsNumber>0 && handles.drawType == 1)
    handle= impoint(handles.axes_main,x,y);
    set(handle,'visible','off');
    BWadd = createMask(handle);
    label=handles.superPixels;
    label(BWadd==0)=0;
    regionIndex=max(max(label));
    valueCur = handles.selectedObject;
    handles.currentMask(handles.superPixels==regionIndex) = valueCur;
elseif handles.drawType == 0
    [xx,yy] = meshgrid(1:size(handles.currentImg,2),1:size(handles.currentImg,1));
%     radii = 6;
    mask = false([size(handles.currentImg,1),size(handles.currentImg,2)]);
    mask = mask | hypot(xx-x,yy-y) <= handles.radii;
    mask = ~mask;
    mask = double(mask);
    handles.currentMask = handles.currentMask.*mask;
end
overlay=labeloverlay(im2uint8(handles.currentImg),uint8(handles.currentMask),'Transparency',handles.transparent,...
    'Colormap',handles.objectColors(1:size(handles.ObjectClasses,2),:));
v = axis;
imshow(overlay,'Parent',handles.axes_main); 
title([num2str(handles.currentID),'\',num2str(size(handles.scanfiles,1)),':',...
    handles.scanfiles(handles.currentID).name,],'interpreter','none','Parent',handles.axes_main);
axis(v);


    

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)i
handles = guidata(hObject);
if strcmp(eventdata.Key, 'control')
    zoom on;
    modifer = get(gcf,'currentModifier');
    while(~isempty(modifer))
        modifer = get(gcf,'currentModifier');
        pause(0.5);
    end
    title([num2str(handles.currentID),'\',num2str(size(handles.scanfiles,1)),':',...
    handles.scanfiles(handles.currentID).name,],'interpreter','none');
    zoom off;
elseif strcmp(eventdata.Key, 'leftarrow')
    up_backforward_ClickedCallback(hObject, eventdata, handles);
    handles = guidata(hObject);
    guidata(hObject,handles);
elseif strcmp(eventdata.Key, 'rightarrow')
    up_forward_ClickedCallback(hObject, eventdata, handles);
    handles = guidata(hObject);
    guidata(hObject,handles);
elseif strcmp(eventdata.Key, 'z')
    undo_ClickedCallback(hObject, eventdata, handles);
    handles = guidata(hObject);
    guidata(hObject,handles);
elseif strcmp(eventdata.Key, 'y')
    redo_ClickedCallback(hObject, eventdata, handles);
    handles = guidata(hObject);
    guidata(hObject,handles);
end
    



% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pressed = 0;
guidata(hObject,handles);



% --- Executes on button press in pb_super.
function pb_super_Callback(hObject, eventdata, handles)
% hObject    handle to pb_super (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num = str2num(get(handles.e_super_num,'String'));
comp = str2num(get(handles.e_super_comp,'String'));
iter = str2num(get(handles.e_super_iter,'String'));

[Label,Number] = superpixels(im2uint8(handles.currentImg),num,...
'Compactness',comp,'NumIterations',iter);
handles.superPixels=Label; 
handles.superPixelsNumber=Number;
BW = boundarymask(Label);
imageSeg=labeloverlay(im2uint8(handles.currentImg),BW,'Transparency',handles.transparent);
axes(handles.axes_main);
imshow(imageSeg);
guidata(hObject,handles);



function e_super_num_Callback(hObject, eventdata, handles)
% hObject    handle to e_super_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_super_num as text
%        str2double(get(hObject,'String')) returns contents of e_super_num as a double


% --- Executes during object creation, after setting all properties.
function e_super_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_super_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_super_comp_Callback(hObject, eventdata, handles)
% hObject    handle to e_super_comp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_super_comp as text
%        str2double(get(hObject,'String')) returns contents of e_super_comp as a double


% --- Executes during object creation, after setting all properties.
function e_super_comp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_super_comp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_super_iter_Callback(hObject, eventdata, handles)
% hObject    handle to e_super_iter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_super_iter as text
%        str2double(get(hObject,'String')) returns contents of e_super_iter as a double


% --- Executes during object creation, after setting all properties.
function e_super_iter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_super_iter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lb_defect.
function lb_defect_Callback(hObject, eventdata, handles)
% hObject    handle to lb_defect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_defect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_defect
handles.selectedObject = get(hObject,'Value');
handles.drawType = 1;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function lb_defect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_defect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

[num,txt,raw]=xlsread('Defects List.xlsx');
for i=2:size(raw,1)
    handles.ObjectClasses{i-1}=[num2str(raw{i,1}) '_' raw{i,2}];
    handles.ObjectValues{i-1}=raw{i,1};
    %if(i>2)
    handles.objectColors(i-1,:)=rand(1,3);
    %end
end

%setcolor:
handles.objectColors(1,:) = [1 0 0];
handles.objectColors(2,:) = [0 1 0];
handles.objectColors(3,:) = [0 0 1];
handles.objectColors(4,:) = [0 1 1];
handles.objectColors(5,:) = [1 1 0];

set(hObject,'String',handles.ObjectClasses);
handles.selectedObject = 1;
guidata(hObject,handles);
% set(findobj('Tag','classList'),'String',handles.ObjectClasses);
 


% --------------------------------------------------------------------
function up_save_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to up_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.txt_status,'String','saving...')
pause(0.5);
trueMask = zeros(size(handles.currentMask));
for i = 1:size(handles.ObjectClasses,2)
    trueMask(handles.currentMask == i) = handles.ObjectValues{1,i};
end

% specifically for NFT contam:----

% if get(handles.rb_move,'value')==1
%     % if modify mode =  move file
%     newmaskpath = strrep(handles.pathname,'\raw','\train\mask');
%     newrawpath = strrep(handles.pathname,'\raw','\train\raw');
%     imgname = [newmaskpath,'\',handles.scanfiles(handles.currentID).name(1:end-3),'png'];
%     imwrite(uint8(trueMask),imgname);
%     movefile([handles.pathname,handles.scanfiles(handles.currentID).name],...
%        [newrawpath,handles.scanfiles(handles.currentID).name]);
%     handles.scanfiles(handles.currentID) = [];
%     guidata(hObject,handles);
% else
    % if modify mode = modify files
    newmaskpath = strrep(handles.pathname,'\raw','\mask');
    file_name = split(handles.scanfiles(handles.currentID).name,'.');
    if ~exist('mask')
        mkdir('mask')
    end
    imgname = [newmaskpath,file_name{1},'.png'];
    imwrite(uint8(trueMask),imgname);
% end


set(handles.txt_status,'String','Saved !')


% --- Executes on button press in pb_clean.
function pb_clean_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentMask = zeros(size(handles.currentImg,1),size(handles.currentImg,2));
handles.imax = imshow(handles.currentImg);
guidata(hObject,handles);


% --------------------------------------------------------------------
function up_erase_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to up_erase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(gcf,'WindowButtonDownFcn',@(hObject,eventdata)ImageMask('figure1_WindowButtonDownFcn',hObject,eventdata,guidata(hObject)));
handles.drawType = 0;
% set(gcf,'pointer','circle');
handles.radii = 6;
handles.pre=handles.currentMask;
guidata(hObject,handles);

% --- Executes on slider movement.
function sli_trans_Callback(hObject, eventdata, handles)
% hObject    handle to sli_trans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.transparent = (get(hObject,'Value'));
guidata(hObject,handles);
if size(handles.currentMask,1)~=0 && size(handles.currentImg,1)~=0
    overlay=labeloverlay(im2uint8(handles.currentImg),handles.currentMask,'Transparency',handles.transparent,...
    'Colormap',handles.objectColors(1:size(handles.ObjectClasses,2),:));
    handles.imax = imshow(handles.currentImg);    
    imshow(overlay);
else
handles = updateplot(hObject, handles);
end
set(handles.e_transparent,'String',num2str(handles.transparent));


% --- Executes during object creation, after setting all properties.
function sli_trans_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sli_trans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function e_transparent_Callback(hObject, eventdata, handles)
% hObject    handle to e_transparent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_transparent as text
%        str2double(get(hObject,'String')) returns contents of e_transparent as a double



% --- Executes during object creation, after setting all properties.
function e_transparent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_transparent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_test.
function rb_test_Callback(hObject, eventdata, handles)
% hObject    handle to rb_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_test


% --- Executes on button press in rb_mask.
function rb_mask_Callback(hObject, eventdata, handles)
% hObject    handle to rb_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_mask


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject,handles);
handles = updateplot(hObject, handles);
guidata(hObject,handles);



function SD_Callback(hObject, eventdata, handles)
% hObject    handle to SD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SD as text
%        str2double(get(hObject,'String')) returns contents of SD as a double


% --- Executes during object creation, after setting all properties.
function SD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mean_thickness_Callback(hObject, eventdata, handles)
% hObject    handle to mean_thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mean_thickness as text
%        str2double(get(hObject,'String')) returns contents of mean_thickness as a double




% --- Executes during object creation, after setting all properties.
function mean_thickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mean_thickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over txt_status.
function txt_status_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txt_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function txt_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pb_sketch.
function pb_sketch_Callback(hObject, eventdata, handles)
% hObject    handle to pb_sketch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedObject = 1;
handles.drawType = 1;
guidata(hObject,handles);


% --- Executes on button press in pb_erase.
function pb_erase_Callback(hObject, eventdata, handles)
% hObject    handle to pb_erase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
up_erase_ClickedCallback(hObject, eventdata, handles)


% --- Executes on button press in pb_save.
function pb_save_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
up_save_ClickedCallback(hObject, eventdata, handles);



function Erase_size_Callback(hObject, eventdata, handles)
% hObject    handle to Erase_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Erase_size as text
%        str2double(get(hObject,'String')) returns contents of Erase_size as a double
% handles.radii = (get(hObject,'Value'));




% --- Executes during object creation, after setting all properties.
function Erase_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Erase_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function Erase_sli_size_Callback(hObject, eventdata, handles)
% hObject    handle to Erase_sli_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.radii = ceil((get(hObject,'Value'))*100);
guidata(hObject,handles);
handles = updateplot(hObject, handles);
set(handles.Erase_size,'String',num2str(handles.radii));



% --- Executes during object creation, after setting all properties.
function Erase_sli_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Erase_sli_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function undo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentMask=handles.pre;
guidata(hObject,handles);
% handles = updateplot(hObject, handles);
overlay=labeloverlay(im2uint8(handles.currentImg),handles.currentMask,'Transparency',handles.transparent,...
    'Colormap',handles.objectColors(1:size(handles.ObjectClasses,2),:));
    handles.imax = imshow(handles.currentImg);    
    imshow(overlay);


% --------------------------------------------------------------------
function redo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to redo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currentMask=handles.post;
guidata(hObject,handles);
% handles = updateplot(hObject, handles);
overlay=labeloverlay(im2uint8(handles.currentImg),handles.currentMask,'Transparency',handles.transparent,...
    'Colormap',handles.objectColors(1:size(handles.ObjectClasses,2),:));
    handles.imax = imshow(handles.currentImg);    
    imshow(overlay);


% --------------------------------------------------------------------
function Polygon_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
set(gcf,'WindowButtonDownFcn','');
mask = roipoly(handles.currentImg);
catch
    return;
end
handles.currentMask=mask;
guidata(hObject,handles);
overlay=labeloverlay(im2uint8(handles.currentImg),handles.currentMask,'Transparency',handles.transparent,...
    'Colormap',handles.objectColors(1:size(handles.ObjectClasses,2),:));
    handles.imax = imshow(handles.currentImg);    
    imshow(overlay); 
    guidata(hObject,handles);
%     set(gcf,'WindowButtonDownFcn',{@figure1_WindowButtonDownFcn,handles});
 

 function Polygon_c_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Polygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  mask = roipoly(handles.currentImg);
% pos=get(hObject,'CurrentPoint'); 
% disp(['You clicked X:',num2str(pos(1)),', Y:',num2str(pos(2))]);


% --- Executes during object creation, after setting all properties.
function uibuttongroup5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text8.
function text8_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % --- Executes on button press in Accept.
% function Accept_Callback(hObject, eventdata, handles)
% % hObject    handle to Accept (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% up_save_ClickedCallback2(hObject, eventdata, handles);
% 
% 
% --------------------------------------------------------------------
function up_save_ClickedCallback2(hObject, eventdata, handles)
% hObject    handle to up_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.txt_status,'String','saving...')
pause(0.5);
trueMask = zeros(size(handles.currentMask));
for i = 1:size(handles.ObjectClasses,2)
    trueMask(handles.currentMask == i) = handles.ObjectValues{1,i};
end

% specifically for NFT contam:----

% if get(handles.rb_move,'value')==1
%     % if modify mode =  move file
%     newmaskpath = strrep(handles.pathname,'\raw','\train\mask');
%     newrawpath = strrep(handles.pathname,'\raw','\train\raw');
%     imgname = [newmaskpath,'\',handles.scanfiles(handles.currentID).name(1:end-3),'png'];
%     imwrite(uint8(trueMask),imgname);
%     movefile([handles.pathname,handles.scanfiles(handles.currentID).name],...
%        [newrawpath,handles.scanfiles(handles.currentID).name]);
%     handles.scanfiles(handles.currentID) = [];
%     guidata(hObject,handles);
% else
    % if modify mode = modify files
    newmaskpath = strrep(handles.pathname,'\raw','\mask');
    file_name = split(handles.scanfiles(handles.currentID).name,'.');
    if ~exist('mask')
        mkdir('mask')
    end
    imgname = [newmaskpath,file_name{1},'.png'];
    imwrite(uint8(trueMask),imgname);
% end

if ~isfield(handles,'tem_ID')
    handles.acc_num = handles.acc_num +1 ;
elseif handles.tem_ID < handles.currentID
    handles.acc_num = handles.acc_num +1 ;
end
handles.tem_ID = handles.currentID;
guidata(hObject, handles);

set(handles.acct_status,'String',[num2str(handles.acc_num),'/',num2str(size(handles.scanfiles,1))])
set(handles.SD,'String',num2str(roundn(handles.acc_num/size(handles.scanfiles,1)*100,-2)));
set(handles.txt_status,'String','Saved !')


% --- Executes on button press in Accept.
function Accept_Callback(hObject, eventdata, handles)
% hObject    handle to Accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
up_save_ClickedCallback2(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function Accept_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function acct_status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to acct_status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
