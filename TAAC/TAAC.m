function varargout = TAAC(varargin)
% TAAC MATLAB code for TAAC.fig
%       Created by Simone Russo
%       From Massimini's Lab, University of Milan (Italy)
%
% TMS Adaptable Auditory Control - TAAC is designed to prevent confoundings 
% from the Auditory Evoked Potential that, whether neglected, may affect 
% the EEG potential elicited by Transcranial Magnetic Stimulation (TMS). 
% 
% 
% Recoding: A microphone capable of recording your own TMS click without 
%           any filter and distortion is advised for. We recommend to
%           record a new audiotrack in case of major changes of your 
%           experimental setup, indeed TMS click: 
%               (1) significantly varies across TMS stimulators; 
%               (2) significantly varies across TMS coils; 
%               (3) may significantly vary across intensities with some
%                   stimulators and coils;
%           Please, be careful whether recording the TMS click. The
%           microphone and any metal object must be placed out of the 
%           magnetic field (e.g. 25 centimeters laterally to the TMS), 
%           otherwise metallic parts of it may be strongly throwed around. 
%           
% Cut: Select the audiotrack starting from the sharp transient until the
%       signal returns to baseline. 
% 
% Parameterization: 
%       Seconds to record: lenght of the audiotrack to be recorded in
%                          seconds.
%       
%       Fixed inter click: fixed latency between clicks in samples.
%       Min inter click: minimum of the uniform distruibution of samples to 
%                        be added to the fixed latency between clicks.
%       Max inter click: maximum of the uniform distruibution of samples to 
%                        be added to the fixed latency between clicks.
%
%       Click noise frequency: resampling frequency of the TMS click.
%       Click noise volume: noise volume.
%       White noise frequency: resampling frequency of the white noise.
%       White noise - Click noise ratio: percentage of white noise and
%                                        click-based noise in the adapted
%                                        noise (e.g. 0%: all white noise;
%                                        100% all click-based noise).
%       
%       Broadband shuffling: automatic shuffling of the selcted click in a
%                            standard battery of frequencies
%       
%       Maximum volume reduction: maximum percentage of the uniform
%                                 distribution of volume reduction at 
%                                 each click
%       Left max shift: maximum of the uniform distribution of delays of 
%                       the left ear over the right ear in samples. 
%       Right max shift: maximum of the uniform distribution of delays of 
%                       the right ear over the left ear in samples. 
%
%       Lenght test cycle: duration in seconds of each cycle of noise in the
%                          Test modality.
%       Lenght noise cycle: duration in seconds of each cycle of noise in 
%                           the Start modality.
% 
% Buttons: 
%       Get recording: starts recording the audiotrack of interest for the
%                      lenght specified by the user in the "Seconds to 
%                      record" box.
%       Play recorded: reproduce the entire recorded soundrack.
%       Cut click: allows to select the starting and end points of the
%                  the TMS click on the recorded soundrack.
%       Play click: reproduce the selected soundrack.
%
%       Test Noise: Start noise while allowing to iteratively modify a
%                   subset of parameters; to be run during the tuning. 
%       Noist Start: Start noise fixing the parameterization; to be run
%                    during the experimental procedure. 
%       Noise Stop: Stop noise. 
%
%       Save Audio: Saves the current parameterization generating the 
%                   following files:
%                     .mat file: contains the whole parameterization
%                     .bin file: contains the recorded audiotrack
%                     .txt file: contains the metadata
%       Load Audio: Loads a previous parameterization from the .mat file
%       Export Audio .wav: Exports a .wav file containing a noise masking
%                          generate with the current parameterization to be
%                          played through other devices or softwares
%
%
%
% License: Was created by Simone Russo and it is distributed under the GNU
%       GPLv3 License. 
%
%
%
% TAAC requires the ginputax function, licensed as following: 
%       Pedro Teodoro (2021). GINPUT funtion to be used in GUIs 
%       (https://www.mathworks.com/matlabcentral/fileexchange/39799-ginput-funtion-to-be-used-in-guis), 
%       MATLAB Central File Exchange. Retrieved August 19, 2021. 

% Last Modified by GUIDE v2.5 28-Jun-2021 13:11:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TAAC_OpeningFcn, ...
                   'gui_OutputFcn',  @TAAC_OutputFcn, ...
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


% --- Executes just before TAAC is made visible.
function TAAC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TAAC (see VARARGIN)

% Choose default command line output for TAAC
handles.output = hObject;

handles.MyVar.Stop=0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TAAC wait for user response (see UIRESUME)
% uiwait(handles.MainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = TAAC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ButtonGetRecording.
function ButtonGetRecording_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonGetRecording (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MyVar.AcquisitionRate=96000;

% Variables initialization and reset
handles.MyVar.ClickTrack=[];
handles.MyVar.ClickTrackTs=[];
handles.MyVar.ClickBoundaries=[];

% Record and get audio
handles.MyVar.recObj = audiorecorder(handles.MyVar.AcquisitionRate,24,1);
recordblocking(handles.MyVar.recObj, str2num(get(handles.EditSecToGet,'String')));
handles.MyVar.AudioTrack = getaudiodata(handles.MyVar.recObj);
handles.MyVar.AudioTrackTs=[1:size(handles.MyVar.AudioTrack,1)]/handles.MyVar.AcquisitionRate;

% Plot audiotrack
cla(handles.AxesClick)
plot(handles.AxesClick,handles.MyVar.AudioTrackTs,handles.MyVar.AudioTrack,'b')

% Disable/Enable buttons
set(handles.ButtonSaveAudio,'Enable','off')
set(handles.ButtonSaveAudioWav,'Enable','off')
set(handles.ButtonPlayClick,'Enable','off')
set(handles.TestNoiseStart,'Enable','off')
set(handles.ButtonNoiseStart,'Enable','off')
set(handles.ButtonPlayRecorded,'Enable','on')
set(handles.ButtonCutClick,'Enable','on')

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ButtonCutClick.
function ButtonCutClick_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonCutClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles.MyVar,'AudioTrack')
    return
end

% Plot audiotrack
cla(handles.AxesClick)
plot(handles.AxesClick,handles.MyVar.AudioTrackTs,handles.MyVar.AudioTrack,'b')

% Select click
[xTs,~]=ginputax(handles.AxesClick,2);
x=round(xTs*handles.MyVar.AcquisitionRate);

% Store selected click
handles.MyVar.ClickTrack=handles.MyVar.AudioTrack(x(1):x(2));
handles.MyVar.ClickTrackTs=handles.MyVar.AudioTrackTs(x(1):x(2));
handles.MyVar.ClickBoundaries=[x(1) x(2)];

% Plot selected click
hold(handles.AxesClick,'on')
plot(handles.AxesClick,handles.MyVar.ClickTrackTs,handles.MyVar.ClickTrack,'r')

% Enable buttons
set(handles.ButtonSaveAudio,'Enable','on')
set(handles.ButtonSaveAudioWav,'Enable','on')
set(handles.ButtonPlayClick,'Enable','on')
set(handles.TestNoiseStart,'Enable','on')
set(handles.ButtonNoiseStart,'Enable','on')

% Update handles structure
guidata(hObject, handles);


function EditSecToGet_Callback(hObject, eventdata, handles)
% hObject    handle to EditSecToGet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSecToGet as text
%        str2double(get(hObject,'String')) returns contents of EditSecToGet as a double


% --- Executes during object creation, after setting all properties.
function EditSecToGet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSecToGet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderNoiseFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update Noise Frequency value
currString=strcat('Noise resampling (',num2str(round(get(handles.SliderNoiseFrequency,'Value'))),'Hz)');
set(handles.TextNoiseFrequency,'String',currString)

% Update handles structure
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function MainFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SliderNoiseVolume_Callback(hObject, eventdata, handles)
% hObject    handle to SliderNoiseVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update Noise Volume value
currString=strcat('Noise volume (',num2str(round(get(handles.SliderNoiseVolume,'Value')*100)),'%)');
set(handles.TextNoiseVolume,'String',currString)

% Update handles structure
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SliderNoiseVolume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNoiseVolume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in ButtonNoiseStart.
function ButtonNoiseStart_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonNoiseStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isfield(handles.MyVar,'ClickTrack')) || (isempty(handles.MyVar.ClickTrack))
    return
end

% Initialize Stop function
handles.MyVar.Stop=0;

% Update handles structure
guidata(hObject, handles);

% Read parameters for noise generation
MeanRandDelay=mean([str2double(get(handles.EditMinInterClick,'String')) str2double(get(handles.EditMaxInterClick,'String'))]);
PlaysRate=get(handles.SliderNoiseFrequency,'Value');
AudioCut=handles.MyVar.ClickTrack;
FixedDelay=round(str2double(get(handles.EditFixedInterClick,'String')));
MeanTotDelay=MeanRandDelay+FixedDelay;
nSecondiPerCicloNoise=(str2double(get(handles.EditSecNoiseCycle,'String')));

handles.MyVar.SpatialShuffling.Min=-str2num(get(handles.EditLeftMaxShift,'String'));
handles.MyVar.SpatialShuffling.Max=str2num(get(handles.EditRightMaxShift,'String'));

% Select number of clicks according to the parameters
nEventi=round(((handles.MyVar.AcquisitionRate*nSecondiPerCicloNoise+size(AudioCut,1))/MeanTotDelay)*PlaysRate/handles.MyVar.AcquisitionRate);

% Randomize clicks delays
RandomDelay=(randi([str2double(get(handles.EditMinInterClick,'String')) str2double(get(handles.EditMaxInterClick,'String'))],[1 nEventi]));

% Initialize the new Noise Audiotrack for left and right hearphones
BuiltAudio1(1:(sum(RandomDelay)+FixedDelay*nEventi+size(AudioCut,1)-1))=0;
BuiltAudio2(1:(sum(RandomDelay)+FixedDelay*nEventi+size(AudioCut,1)-1))=0;

% Randomize clicks intensities
RandomIntensities=1-(rand(1,nEventi).*str2num(get(handles.EditMaximumVolumeReduction,'String'))./100);

% Randomize clicks location
RandomLocations=round(((rand(1,nEventi).*(handles.MyVar.SpatialShuffling.Min-handles.MyVar.SpatialShuffling.Max))-handles.MyVar.SpatialShuffling.Min)./2);

% Start click-noise generation
for counter=1:nEventi
    % Define time start and end of the current click
    currStart=(sum(RandomDelay(1:counter))+FixedDelay*counter);
    currEnd=currStart+size(AudioCut,1)-1;
    
    % Retrive the randomized location of the current click
    currRandomLocation=RandomLocations(counter);
    
    if currRandomLocation<0
        %Shift towards left
        currAudioCut1=AudioCut(1:end+currRandomLocation);
        currAudioCut2=AudioCut(1-currRandomLocation:end);
    elseif currRandomLocation>0
        %Shift towards right
        currAudioCut1=AudioCut(1+currRandomLocation:end);
        currAudioCut2=AudioCut(1:end-currRandomLocation);
    else
        % No shift
        currAudioCut1=AudioCut;
        currAudioCut2=AudioCut;
    end
    
    % integrate the current click to the click-noise audiotrack
    BuiltAudio1(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio1(currStart:currEnd-abs(currRandomLocation))+currAudioCut1'*RandomIntensities(counter);
    BuiltAudio2(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio2(currStart:currEnd-abs(currRandomLocation))+currAudioCut2'*RandomIntensities(counter);
    
end
% End click-noise generation

% Adjust lenght of the click-noise audiotrack
BuiltAudio1(end-size(AudioCut,1):end)=[];
BuiltAudio1(1:size(AudioCut,1))=[];
BuiltAudio2(end-size(AudioCut,1):end)=[];
BuiltAudio2(1:size(AudioCut,1))=[];

% Build the final sountrack of the click-noise
BuiltAudio=[BuiltAudio1;BuiltAudio2];

BuiltAudioBackup=BuiltAudio;
PlayRate=96000;
RoundPlayRate=round(PlayRate/4);

% Enable and Disable Buttons
set(handles.SliderNoiseFrequency,'Enable','off')
set(handles.SliderNoiseVolume,'Enable','off')
set(handles.SliderNoiseRatio,'Enable','off')
set(handles.SliderWhiteNoiseFrequency,'Enable','off')

set(handles.ButtonGetRecording,'Enable','off')
set(handles.ButtonCutClick,'Enable','off')
set(handles.ButtonPlayRecorded,'Enable','off')
set(handles.ButtonPlayClick,'Enable','off')

set(handles.EditFixedInterClick,'Enable','off')
set(handles.EditMaxInterClick,'Enable','off')
set(handles.EditMinInterClick,'Enable','off')
set(handles.EditSecNoiseCycle,'Enable','off')
set(handles.EditSecToGet,'Enable','off')
set(handles.EditLeftMaxShift,'Enable','off')
set(handles.EditRightMaxShift,'Enable','off')
set(handles.EditMaximumVolumeReduction,'Enable','off')
set(handles.TestNoiseStart,'Enable','off')
set(handles.ButtonNoiseStart,'Enable','off')
set(handles.CheckboxBroadbandShuffling,'Enable','off');
set(handles.ButtonNoiseStop,'Enable','on')
set(handles.TextNoiseStatus,'String','Noise ON')
set(handles.TextNoiseStatus,'ForegroundColor','g')

% Get parameters for the frequency shuffling
PlayRateClick=round(get(handles.SliderNoiseFrequency,'Value'));
PlayRateWhiteNoise=round(get(handles.SliderWhiteNoiseFrequency,'Value'));
NoiseRatio=get(handles.SliderNoiseRatio,'Value');
TmpClick=BuiltAudioBackup;


% Check the lenght of the noise audiotrack 
SizeCheckValue=PlayRate*PlayRateClick/gcd(PlayRate,PlayRateClick);

% Get broadband shuffling
BroadbandClickShuffling=get(handles.CheckboxBroadbandShuffling,'Value');

% Resample the click-noise audiotrack 
if BroadbandClickShuffling
    if (SizeCheckValue<2^31)
        TmpClickNew1=resample(TmpClick',PlayRate,PlayRate/10*10)';
        TmpClickNew2=resample(TmpClick',PlayRate,PlayRate/10*12)';
        TmpClickNew3=resample(TmpClick',PlayRate,PlayRate/10*14)';
        TmpClickNew4=resample(TmpClick',PlayRate,PlayRate/10*16)';
        TmpClickNew5=resample(TmpClick',PlayRate,PlayRate/10*18)';
        TmpClickNew6=resample(TmpClick',PlayRate,PlayRate/10*20)';
        TmpClickNew7=resample(TmpClick',PlayRate,PlayRate/10*8)';
        TmpClickNew8=resample(TmpClick',PlayRate,PlayRate/10*6)';
        TmpClickNew9=resample(TmpClick',PlayRate,PlayRate/10*5)';
        TmpClickNew10=resample(TmpClick',PlayRate,PlayRate/10*4)';
        TmpClickNew11=resample(TmpClick',PlayRate,PlayRate/10*3)';
    else
        TmpClickNew1=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*10)';
        TmpClickNew2=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*12)';
        TmpClickNew3=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*14)';
        TmpClickNew4=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*16)';
        TmpClickNew5=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*18)';
        TmpClickNew6=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*20)';
        TmpClickNew7=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*8)';
        TmpClickNew8=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*6)';
        TmpClickNew9=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*5)';
        TmpClickNew10=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*4)';
        TmpClickNew11=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*3)';
    end
    tmpWinSize=size(TmpClickNew6,2);
    TmpClickNew=[TmpClickNew11(:,1:tmpWinSize) + TmpClickNew10(:,1:tmpWinSize) + TmpClickNew9(:,1:tmpWinSize) + TmpClickNew8(:,1:tmpWinSize) + TmpClickNew7(:,1:tmpWinSize) + TmpClickNew6(:,1:tmpWinSize) + TmpClickNew5(:,1:tmpWinSize) + TmpClickNew4(:,1:tmpWinSize) + TmpClickNew3(:,1:tmpWinSize) + TmpClickNew2(:,1:tmpWinSize) + TmpClickNew1(:,1:tmpWinSize)];
    
else
    if (SizeCheckValue<2^31)
        TmpClickNew=resample(TmpClick',PlayRate,PlayRateClick)';
    else
        TmpClickNew=resample(TmpClick',RoundPlayRate,round(PlayRateClick/4))';
    end
end

% Normalize the click-noise audiotrack 
range = max(TmpClickNew(:)) - min(TmpClickNew(:));
TmpClickNew = (TmpClickNew - min(TmpClickNew(:))) / range;
TmpClickNew = 2 * TmpClickNew - 1;
TmpClickNew=TmpClickNew*(NoiseRatio);


% Generate white-noise
WhiteNoiseLenght=round(size(TmpClickNew,2)/PlayRate*PlayRateWhiteNoise);
TmpWhiteNoise=randn([1,WhiteNoiseLenght]);


% Check the lenght of the noise audiotrack 
SizeCheckValue=PlayRate*PlayRateWhiteNoise/gcd(PlayRate,PlayRateWhiteNoise);
% Resample the click-noise audiotrack 
if (SizeCheckValue<2^31)
    % Short audiotrack
    TmpWhiteNoise=resample(TmpWhiteNoise,PlayRate,PlayRateWhiteNoise);
else
    % Long audiotrack
    TmpWhiteNoise=resample(TmpWhiteNoise,RoundPlayRate,round(PlayRateWhiteNoise/4));
end

% Normalize the white-noise audiotrack 
range = max(TmpWhiteNoise(:)) - min(TmpWhiteNoise(:));
TmpWhiteNoise = (TmpWhiteNoise - min(TmpWhiteNoise(:))) / range;
TmpWhiteNoise = 2 * TmpWhiteNoise - 1;
TmpWhiteNoise=TmpWhiteNoise*(1-NoiseRatio);


% Merge click-noise and white-noise in the noise audiotrack
MinLenght=min([size(TmpClickNew,2) size(TmpWhiteNoise,2)]);
BuiltAudio=TmpClickNew(1,1:MinLenght)+TmpWhiteNoise(1,1:MinLenght);

% Normalize the noise audiotrack 
tmpTrack=BuiltAudio;
tmpTrack=tmpTrack-min(tmpTrack);
tmpTrack=tmpTrack/max(tmpTrack)*2;

% Adjust the noise audiotrack volume
BuiltAudio=tmpTrack*get(handles.SliderNoiseVolume,'Value')-1;

% Play the noise audiotrack until stop button is pressed
while handles.MyVar.Stop==0
    sound(BuiltAudio,PlaysRate);
    pause(size(BuiltAudio,2)./PlaysRate);
    handles = guidata(hObject);
end

% Re-initialize the stop button
handles.MyVar.Stop=0;

% Disable/Enable buttons
set(handles.SliderNoiseVolume,'Enable','on')
set(handles.SliderNoiseRatio,'Enable','on')
set(handles.SliderWhiteNoiseFrequency,'Enable','on')

set(handles.ButtonGetRecording,'Enable','on')
set(handles.ButtonCutClick,'Enable','on')
set(handles.ButtonPlayRecorded,'Enable','on')
set(handles.ButtonPlayClick,'Enable','on')

set(handles.EditFixedInterClick,'Enable','on')
set(handles.EditMaxInterClick,'Enable','on')
set(handles.EditMinInterClick,'Enable','on')
set(handles.EditSecNoiseCycle,'Enable','on')
set(handles.EditSecToGet,'Enable','on')
set(handles.EditLeftMaxShift,'Enable','on')
set(handles.EditRightMaxShift,'Enable','on')
set(handles.EditMaximumVolumeReduction,'Enable','on')
set(handles.TestNoiseStart,'Enable','on')
set(handles.ButtonNoiseStart,'Enable','on')
set(handles.CheckboxBroadbandShuffling,'Enable','on');
set(handles.ButtonNoiseStop,'Enable','off')
set(handles.TextNoiseStatus,'String','Noise OFF')
set(handles.TextNoiseStatus,'ForegroundColor','k')

if ~get(handles.CheckboxBroadbandShuffling,'Value')
    set(handles.SliderNoiseFrequency,'Enable','on');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ButtonNoiseStop.
function ButtonNoiseStop_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonNoiseStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Stop button pressed; Stop playing the audiotrack
handles.MyVar.Stop=1;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in ButtonPlayRecorded.
function ButtonPlayRecorded_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonPlayRecorded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Play recorded sountrack
if isfield(handles.MyVar,'AudioTrack')
    soundsc(handles.MyVar.AudioTrack,get(handles.SliderNoiseFrequency,'Value'))
else
    return
end


% --- Executes on button press in ButtonPlayClick.
function ButtonPlayClick_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonPlayClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Play the selected click sountrack
if isfield(handles.MyVar,'ClickTrack') && ~isempty(handles.MyVar.ClickTrack)
    soundsc(handles.MyVar.ClickTrack,get(handles.SliderNoiseFrequency,'Value'))
else
    return
end


function EditMaxInterClick_Callback(hObject, eventdata, handles)
% hObject    handle to EditMaxInterClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMaxInterClick as text
%        str2double(get(hObject,'String')) returns contents of EditMaxInterClick as a double


% --- Executes during object creation, after setting all properties.
function EditMaxInterClick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMaxInterClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditMinInterClick_Callback(hObject, eventdata, handles)
% hObject    handle to EditMinInterClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMinInterClick as text
%        str2double(get(hObject,'String')) returns contents of EditMinInterClick as a double


% --- Executes during object creation, after setting all properties.
function EditMinInterClick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMinInterClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SliderNoiseFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNoiseFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in TestNoiseStart.
function TestNoiseStart_Callback(hObject, eventdata, handles)
% hObject    handle to TestNoiseStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if (~isfield(handles.MyVar,'ClickTrack')) || (isempty(handles.MyVar.ClickTrack))
    return
end

% Initialize Stop function
handles.MyVar.Stop=0;

% Update handles structure
guidata(hObject, handles);

% Read parameters for noise generation
handles.MyVar.SpatialShuffling.Min=-str2num(get(handles.EditLeftMaxShift,'String'));
handles.MyVar.SpatialShuffling.Max=str2num(get(handles.EditRightMaxShift,'String'));

% Disable/Enable buttons
set(handles.ButtonGetRecording,'Enable','off')
set(handles.ButtonCutClick,'Enable','off')
set(handles.ButtonPlayRecorded,'Enable','off')
set(handles.ButtonPlayClick,'Enable','off')

set(handles.EditSecToGet,'Enable','off')
set(handles.EditLeftMaxShift,'Enable','off')
set(handles.EditRightMaxShift,'Enable','off')
set(handles.EditMaximumVolumeReduction,'Enable','off')
set(handles.EditFixedInterClick,'Enable','off')
set(handles.EditMinInterClick,'Enable','off')
set(handles.EditMaxInterClick,'Enable','off')
set(handles.EditSecTestNoiseCycle,'Enable','off')
set(handles.TestNoiseStart,'Enable','off')
set(handles.ButtonNoiseStart,'Enable','off')
set(handles.CheckboxBroadbandShuffling,'Enable','off');
set(handles.ButtonNoiseStop,'Enable','on')
set(handles.TextNoiseStatus,'String','Noise TEST')
set(handles.TextNoiseStatus,'ForegroundColor','b')

MeanRandDelay=mean([str2double(get(handles.EditMinInterClick,'String')) str2double(get(handles.EditMaxInterClick,'String'))]);
PlaysRate=get(handles.SliderNoiseFrequency,'Value');
AudioCut=handles.MyVar.ClickTrack;
FixedDelay=round(str2double(get(handles.EditFixedInterClick,'String')));%1;
MeanTotDelay=MeanRandDelay+FixedDelay;

nSecondiPerCicloNoise=(str2double(get(handles.EditSecTestNoiseCycle,'String')));

% Select number of clicks according to the parameters
nEventi=round(((handles.MyVar.AcquisitionRate.*nSecondiPerCicloNoise+size(AudioCut,1))/MeanTotDelay)*PlaysRate/handles.MyVar.AcquisitionRate);

% Randomize clicks delays
RandomDelay=(randi([str2double(get(handles.EditMinInterClick,'String')) str2double(get(handles.EditMaxInterClick,'String'))],[1 nEventi]));

% Initialize the new Noise Audiotrack for left and right hearphones
clear BuiltAudio
BuiltAudio1(1:(sum(RandomDelay)+FixedDelay*nEventi+size(AudioCut,1)-1))=0;
BuiltAudio2(1:(sum(RandomDelay)+FixedDelay*nEventi+size(AudioCut,1)-1))=0;

% Randomize clicks intensities
RandomIntensities=1-(rand(1,nEventi).*str2num(get(handles.EditMaximumVolumeReduction,'String'))./100);
% Randomize clicks location
RandomLocations=round(((rand(1,nEventi).*(handles.MyVar.SpatialShuffling.Min-handles.MyVar.SpatialShuffling.Max))-handles.MyVar.SpatialShuffling.Min)./2);

% Start click-noise generation
for counter=1:nEventi
    % Define time start and end of the current click
    currStart=(sum(RandomDelay(1:counter))+FixedDelay*counter);
    currEnd=currStart+size(AudioCut,1)-1;
    
    % Retrive the randomized location of the current click
    currRandomLocation=RandomLocations(counter);
    
    % Spatially shifts the current click
    if currRandomLocation<0
        %Shift towards left
        currAudioCut1=AudioCut(1:end+currRandomLocation);
        currAudioCut2=AudioCut(1-currRandomLocation:end);
    elseif currRandomLocation>0
        %Shift towards right
        currAudioCut1=AudioCut(1+currRandomLocation:end);
        currAudioCut2=AudioCut(1:end-currRandomLocation);
    else
        % No shift
        currAudioCut1=AudioCut;
        currAudioCut2=AudioCut;
    end
    % integrate the current click to the click-noise audiotrack
    BuiltAudio1(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio1(currStart:currEnd-abs(currRandomLocation))+currAudioCut1'*RandomIntensities(counter);
    BuiltAudio2(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio2(currStart:currEnd-abs(currRandomLocation))+currAudioCut2'*RandomIntensities(counter);
    
    
end
% End click-noise generation

% Adjust lenght of the click-noise audiotrack
BuiltAudio1(end-size(AudioCut,1):end)=[];
BuiltAudio2(end-size(AudioCut,1):end)=[];
BuiltAudio1(1:size(AudioCut,1))=[];
BuiltAudio2(1:size(AudioCut,1))=[];

% Build the final sountrack of the click-noise
BuiltAudio=[BuiltAudio1;BuiltAudio2];

BuiltAudioBackup=BuiltAudio;
PlayRate=96000;
RoundPlayRate=round(PlayRate/4);

% Get broadband shuffling
BroadbandClickShuffling=get(handles.CheckboxBroadbandShuffling,'Value');


while handles.MyVar.Stop==0
    % Get parameters for the frequency shuffling
    PlayRateClick=round(get(handles.SliderNoiseFrequency,'Value'));
    PlayRateWhiteNoise=round(get(handles.SliderWhiteNoiseFrequency,'Value'));
    NoiseRatio=get(handles.SliderNoiseRatio,'Value');
    TmpClick=BuiltAudioBackup;
    
    % Check the lenght of the noise audiotrack 
    SizeCheckValue=PlayRate*PlayRateClick/gcd(PlayRate,PlayRateClick);
    
    % Resample the click-noise audiotrack 
    if BroadbandClickShuffling
        if (SizeCheckValue<2^31)
            TmpClickNew1=resample(TmpClick',PlayRate,PlayRate/10*10)';
            TmpClickNew2=resample(TmpClick',PlayRate,PlayRate/10*12)';
            TmpClickNew3=resample(TmpClick',PlayRate,PlayRate/10*14)';
            TmpClickNew4=resample(TmpClick',PlayRate,PlayRate/10*16)';
            TmpClickNew5=resample(TmpClick',PlayRate,PlayRate/10*18)';
            TmpClickNew6=resample(TmpClick',PlayRate,PlayRate/10*20)';
            TmpClickNew7=resample(TmpClick',PlayRate,PlayRate/10*8)';
            TmpClickNew8=resample(TmpClick',PlayRate,PlayRate/10*6)';
            TmpClickNew9=resample(TmpClick',PlayRate,PlayRate/10*5)';
            TmpClickNew10=resample(TmpClick',PlayRate,PlayRate/10*4)';
            TmpClickNew11=resample(TmpClick',PlayRate,PlayRate/10*3)';
        else
            TmpClickNew1=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*10)';
            TmpClickNew2=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*12)';
            TmpClickNew3=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*14)';
            TmpClickNew4=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*16)';
            TmpClickNew5=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*18)';
            TmpClickNew6=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*20)';
            TmpClickNew7=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*8)';
            TmpClickNew8=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*6)';
            TmpClickNew9=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*5)';
            TmpClickNew10=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*4)';
            TmpClickNew11=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*3)';
        end
        tmpWinSize=size(TmpClickNew6,2);
        TmpClickNew=[TmpClickNew11(:,1:tmpWinSize) + TmpClickNew10(:,1:tmpWinSize) + TmpClickNew9(:,1:tmpWinSize) + TmpClickNew8(:,1:tmpWinSize) + TmpClickNew7(:,1:tmpWinSize) + TmpClickNew6(:,1:tmpWinSize) + TmpClickNew5(:,1:tmpWinSize) + TmpClickNew4(:,1:tmpWinSize) + TmpClickNew3(:,1:tmpWinSize) + TmpClickNew2(:,1:tmpWinSize) + TmpClickNew1(:,1:tmpWinSize)];
        
    else
        if (SizeCheckValue<2^31)
            TmpClickNew=resample(TmpClick',PlayRate,PlayRateClick)';
        else
            TmpClickNew=resample(TmpClick',RoundPlayRate,round(PlayRateClick/4))';
        end
    end
    
    % Normalize the click-noise audiotrack 
    range = max(TmpClickNew(:)) - min(TmpClickNew(:));
    TmpClickNew = (TmpClickNew - min(TmpClickNew(:))) / range;
    TmpClickNew = 2 * TmpClickNew - 1;
    TmpClickNew=TmpClickNew*(NoiseRatio);
    
    % Generate white-noise
    WhiteNoiseLenght=round(size(TmpClickNew,2)/PlayRate*PlayRateWhiteNoise);
    TmpWhiteNoise=randn([1,WhiteNoiseLenght]);
    
    % Check the lenght of the noise audiotrack 
    SizeCheckValue=PlayRate*PlayRateWhiteNoise/gcd(PlayRate,PlayRateWhiteNoise);
    
    % Resample the click-noise audiotrack 
    if (SizeCheckValue<2^31)
        % Short audiotrack
        TmpWhiteNoise=resample(TmpWhiteNoise',PlayRate,PlayRateWhiteNoise)';
    else
        % Long audiotrack
        TmpWhiteNoise=resample(TmpWhiteNoise',RoundPlayRate,round(PlayRateWhiteNoise/4))';
    end
    
    % Normalize the white-noise audiotrack 
    range = max(TmpWhiteNoise(:)) - min(TmpWhiteNoise(:));
    TmpWhiteNoise = (TmpWhiteNoise - min(TmpWhiteNoise(:))) / range;
    TmpWhiteNoise = 2 * TmpWhiteNoise - 1;
    TmpWhiteNoise=TmpWhiteNoise*(1-NoiseRatio);
    TmpWhiteNoise=[TmpWhiteNoise;TmpWhiteNoise];
    
    % Merge click-noise and white-noise in the noise audiotrack
    MinLenght=min([size(TmpClickNew,2) size(TmpWhiteNoise,2)]);
    BuiltAudio=TmpClickNew(:,1:MinLenght)+TmpWhiteNoise(:,1:MinLenght);
    
    % Normalize the noise audiotrack 
    tmpTrack=BuiltAudio;
    tmpTrack=tmpTrack-min(min(tmpTrack));
    tmpTrack=tmpTrack/max(max(tmpTrack))*2;
    
    % Adjust the noise audiotrack volume
    BuiltAudio=tmpTrack*get(handles.SliderNoiseVolume,'Value')-1;
    
    % Play the noise audiotrack until stop button is pressed
    sound(BuiltAudio,PlaysRate);
    pause(size(BuiltAudio,2)./PlaysRate);
    handles = guidata(hObject);
end

% Re-initialize the stop button
handles.MyVar.Stop=0;

% Disable/Enable buttons
set(handles.ButtonGetRecording,'Enable','on')
set(handles.ButtonCutClick,'Enable','on')
set(handles.ButtonPlayRecorded,'Enable','on')
set(handles.ButtonPlayClick,'Enable','on')

set(handles.EditSecToGet,'Enable','on')
set(handles.EditLeftMaxShift,'Enable','on')
set(handles.EditRightMaxShift,'Enable','on')
set(handles.EditMaximumVolumeReduction,'Enable','on')
set(handles.EditFixedInterClick,'Enable','on')
set(handles.EditMinInterClick,'Enable','on')
set(handles.EditMaxInterClick,'Enable','on')
set(handles.EditSecTestNoiseCycle,'Enable','on')
set(handles.TestNoiseStart,'Enable','on')
set(handles.ButtonNoiseStart,'Enable','on')
set(handles.CheckboxBroadbandShuffling,'Enable','on');
set(handles.ButtonNoiseStop,'Enable','off')
set(handles.TextNoiseStatus,'String','Noise OFF')
set(handles.TextNoiseStatus,'ForegroundColor','k')

% Update handles structure
guidata(hObject, handles);



function EditFixedInterClick_Callback(hObject, eventdata, handles)
% hObject    handle to EditFixedInterClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditFixedInterClick as text
%        str2double(get(hObject,'String')) returns contents of EditFixedInterClick as a double


% --- Executes during object creation, after setting all properties.
function EditFixedInterClick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditFixedInterClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSecNoiseCycle_Callback(hObject, eventdata, handles)
% hObject    handle to EditSecNoiseCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSecNoiseCycle as text
%        str2double(get(hObject,'String')) returns contents of EditSecNoiseCycle as a double


% --- Executes during object creation, after setting all properties.
function EditSecNoiseCycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSecNoiseCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SliderNoiseRatio_Callback(hObject, eventdata, handles)
% hObject    handle to SliderNoiseRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

currString=strcat('White noise - Click noise ratio (',num2str(round(get(handles.SliderNoiseRatio,'Value')*100)),'%)');
set(handles.TextNoiseRatio,'String',currString)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SliderNoiseRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderNoiseRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SliderWhiteNoiseFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to SliderWhiteNoiseFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

currString=strcat('White noise resampling (',num2str(round(get(handles.SliderWhiteNoiseFrequency,'Value'))),' Hz)');
set(handles.TextWhiteNoiseFrequency,'String',currString)

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SliderWhiteNoiseFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliderWhiteNoiseFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in ButtonSaveAudio.
function ButtonSaveAudio_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSaveAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles.MyVar,'ClickTrack')
    return
end

% Create ToSave variable
ToSave.AcquisitionRate=handles.MyVar.AcquisitionRate;

ToSave.Audio.Track=handles.MyVar.AudioTrack;
ToSave.Audio.Ts=handles.MyVar.AudioTrackTs;
ToSave.Click.Track=handles.MyVar.ClickTrack;
ToSave.Click.Ts=handles.MyVar.ClickTrackTs;
ToSave.Click.Boundaries=handles.MyVar.ClickBoundaries;

ToSave.Parameters.EditFixedInterClick=str2double(get(handles.EditFixedInterClick,'String'));
ToSave.Parameters.EditMinInterClick=str2double(get(handles.EditMinInterClick,'String'));
ToSave.Parameters.EditMaxInterClick=str2double(get(handles.EditMaxInterClick,'String'));
ToSave.Parameters.EditSecTestNoiseCycle=str2double(get(handles.EditSecTestNoiseCycle,'String'));
ToSave.Parameters.EditSecNoiseCycle=str2double(get(handles.EditSecNoiseCycle,'String'));
ToSave.Parameters.EditSecToGet=str2double(get(handles.EditSecToGet,'String'));

ToSave.Parameters.SliderNoiseFrequency=(get(handles.SliderNoiseFrequency,'Value'));
ToSave.Parameters.SliderNoiseRatio=(get(handles.SliderNoiseRatio,'Value'));
ToSave.Parameters.SliderNoiseVolume=(get(handles.SliderNoiseVolume,'Value'));
ToSave.Parameters.SliderWhiteNoiseFrequency=(get(handles.SliderWhiteNoiseFrequency,'Value'));

ToSave.Parameters.EditMaximumVolumeReduction=(get(handles.EditMaximumVolumeReduction,'String'));
ToSave.Parameters.EditLeftMaxShift=(get(handles.EditLeftMaxShift,'String'));
ToSave.Parameters.EditRightMaxShift=(get(handles.EditRightMaxShift,'String'));

ToSave.Parameters.CheckboxBroadbandShuffling=(get(handles.CheckboxBroadbandShuffling,'Value'));

ToSave.Log.datetime=datetime('now');
InputLabels={'Subject','EEG Session','Protocol','Area','Stimulation spot','Task','Comments','Stimulator','Intensity','Microphone'};
Notes=inputdlg(InputLabels);

if isempty(Notes)
    return
end
ToSave.Log.Subject=Notes{1,1};
ToSave.Log.EEG_Session=Notes{2,1};
ToSave.Log.Protocol=Notes{3,1};
ToSave.Log.Area=Notes{4,1};
ToSave.Log.Stimulation_Spot=Notes{5,1};
ToSave.Log.Task=Notes{6,1};
ToSave.Log.Comments=Notes{7,1};
ToSave.Log.Stimulator=Notes{8,1};
ToSave.Log.Intensity=Notes{9,1};
ToSave.Log.Microphone=Notes{10,1};

[file,path,indx] = uiputfile({'*.mat'});
[filepath,name,ext] = fileparts(fullfile(path,file));

if isequal(file,0)
    return
end

%Save .mat
save(fullfile(filepath,[name '.mat']),'ToSave');

%Clear previous versions of .txt
if exist(fullfile(filepath,[name '.txt']));
    delete(fullfile(filepath,[name '.txt']));
end

%Clear previous versions of .bin
if exist(fullfile(filepath,[name '.bin']));
    delete(fullfile(filepath,[name '.bin']));
end

%Create .txt and .bin
fileTxtID = fopen(fullfile(filepath,[name '.txt']),'w');
fileBinID = fopen(fullfile(filepath,[name '.bin']),'w');

fprintf(fileTxtID, ['date and time:   ' datestr(ToSave.Log.datetime) '\r\n']);
fprintf(fileTxtID,['Subject:   ' ToSave.Log.Subject '\r\n']);
fprintf(fileTxtID,['EEG Session:   ' ToSave.Log.EEG_Session '\r\n']);
fprintf(fileTxtID,['Protocol:   ' ToSave.Log.Protocol '\r\n']);
fprintf(fileTxtID,['Area:   ' ToSave.Log.Area '\r\n']);
fprintf(fileTxtID,['Stimulation spot:   ' ToSave.Log.Stimulation_Spot '\r\n']);
fprintf(fileTxtID,['Task:   ' ToSave.Log.Task '\r\n']);
fprintf(fileTxtID,['Comments:   ' ToSave.Log.Comments '\r\n']);
fprintf(fileTxtID,['Stimulator:   ' ToSave.Log.Stimulator '\r\n']);
fprintf(fileTxtID,['Intensity:   ' ToSave.Log.Intensity '\r\n']);
fprintf(fileTxtID,['Microphone:   ' ToSave.Log.Microphone '\r\n']);


fwrite(fileBinID,ToSave.Click.Track,'double');

fclose(fileTxtID);
fclose(fileBinID);

% --- Executes on button press in ButtonLoadAudio.
function ButtonLoadAudio_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonLoadAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,FilterIndex] =uigetfile();
if isequal(FileName,0)
    return
end

%Load .mat
load(fullfile(PathName,FileName))
handles.MyVar.AcquisitionRate=ToSave.AcquisitionRate;
handles.MyVar.AudioTrack=ToSave.Audio.Track;
handles.MyVar.AudioTrackTs=ToSave.Audio.Ts;
handles.MyVar.ClickTrack=ToSave.Click.Track;
handles.MyVar.ClickTrackTs=ToSave.Click.Ts;
handles.MyVar.ClickBoundaries=ToSave.Click.Boundaries;

%Update GUI parameters
set(handles.EditFixedInterClick,'String',num2str(ToSave.Parameters.EditFixedInterClick));
set(handles.EditMinInterClick,'String',num2str(ToSave.Parameters.EditMinInterClick));
set(handles.EditMaxInterClick,'String',num2str(ToSave.Parameters.EditMaxInterClick));
set(handles.EditSecNoiseCycle,'String',num2str(ToSave.Parameters.EditSecNoiseCycle));
set(handles.EditSecToGet,'String',num2str(ToSave.Parameters.EditSecToGet));

set(handles.SliderNoiseFrequency,'Value',ToSave.Parameters.SliderNoiseFrequency);
set(handles.SliderNoiseRatio,'Value',ToSave.Parameters.SliderNoiseRatio);
set(handles.SliderNoiseVolume,'Value',ToSave.Parameters.SliderNoiseVolume);
set(handles.SliderWhiteNoiseFrequency,'Value',ToSave.Parameters.SliderWhiteNoiseFrequency);

set(handles.EditSecTestNoiseCycle,'String',num2str(ToSave.Parameters.EditSecTestNoiseCycle));
set(handles.EditMaximumVolumeReduction,'String',num2str(ToSave.Parameters.EditMaximumVolumeReduction));
set(handles.EditLeftMaxShift,'String',num2str(ToSave.Parameters.EditLeftMaxShift));
set(handles.EditRightMaxShift,'String',num2str(ToSave.Parameters.EditRightMaxShift));


if isfield(ToSave.Parameters,'CheckboxBroadbandShuffling')
    set(handles.CheckboxBroadbandShuffling,'Value',ToSave.Parameters.CheckboxBroadbandShuffling);
else
    set(handles.CheckboxBroadbandShuffling,'Value',0);
end

BroadbandClickShuffling=get(handles.CheckboxBroadbandShuffling,'Value');
PlayingNoise=get(handles.ButtonNoiseStop,'Enable');
if BroadbandClickShuffling
    set(handles.SliderNoiseFrequency,'Enable','off');
elseif strcmp(PlayingNoise,'on')
    set(handles.SliderNoiseFrequency,'Enable','off');
else
    set(handles.SliderNoiseFrequency,'Enable','on');
end

currString=strcat('White noise resampling (',num2str(round(get(handles.SliderWhiteNoiseFrequency,'Value'))),' Hz)');
set(handles.TextWhiteNoiseFrequency,'String',currString)
currString=strcat('White noise - Click noise ratio (',num2str(round(get(handles.SliderNoiseRatio,'Value')*100)),'%)');
set(handles.TextNoiseRatio,'String',currString)
currString=strcat('Noise volume (',num2str(round(get(handles.SliderNoiseVolume,'Value')*100)),'%)');
set(handles.TextNoiseVolume,'String',currString)
currString=strcat('Noise resampling (',num2str(round(get(handles.SliderNoiseFrequency,'Value'))),'Hz)');
set(handles.TextNoiseFrequency,'String',currString)

cla(handles.AxesClick)
plot(handles.AxesClick,handles.MyVar.AudioTrackTs,handles.MyVar.AudioTrack,'b')

hold(handles.AxesClick,'on')
plot(handles.AxesClick,handles.MyVar.ClickTrackTs,handles.MyVar.ClickTrack,'r')

set(handles.ButtonSaveAudio,'Enable','on')
set(handles.ButtonSaveAudioWav,'Enable','on')
set(handles.TestNoiseStart,'Enable','on')
set(handles.ButtonNoiseStart,'Enable','on')

set(handles.ButtonPlayRecorded,'Enable','on')
set(handles.ButtonCutClick,'Enable','on')
set(handles.ButtonPlayClick,'Enable','on')

set(handles.CheckboxBroadbandShuffling,'Enable','on');

guidata(hObject, handles);

% --- Executes on button press in ButtonSaveAudioWav.
function ButtonSaveAudioWav_Callback(hObject, eventdata, handles)
% hObject    handle to ButtonSaveAudioWav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles.MyVar,'ClickTrack')
    return
end

MeanRandDelay=mean([str2double(get(handles.EditMinInterClick,'String')) str2double(get(handles.EditMaxInterClick,'String'))]);
PlaysRate=get(handles.SliderNoiseFrequency,'Value');
AudioCut=handles.MyVar.ClickTrack;
FixedDelay=round(str2double(get(handles.EditFixedInterClick,'String')));%1;
MeanTotDelay=MeanRandDelay+FixedDelay;
nSecondiPerCicloNoise=(str2double(get(handles.EditSecNoiseCycle,'String')));%10;

%nEventi=1000;
%nEventi=round(((handles.MyVar.AcquisitionRate+size(AudioCut,1)*2)./PlaysRate./MeanRandDelay));
%nEventi=round(((handles.MyVar.AcquisitionRate+size(AudioCut,1))/MeanTotDelay));
%nEventi=round(((handles.MyVar.AcquisitionRate*nSecondiPerCicloNoise+size(AudioCut,1))/MeanTotDelay)*handles.MyVar.AcquisitionRate/PlaysRate);
nEventi=round(((handles.MyVar.AcquisitionRate*nSecondiPerCicloNoise+size(AudioCut,1))/MeanTotDelay)*PlaysRate/handles.MyVar.AcquisitionRate);


RandomDelay=(randi([str2double(get(handles.EditMinInterClick,'String')) str2double(get(handles.EditMaxInterClick,'String'))],[1 nEventi]));


clear BuiltAudio

BuiltAudio1(1:(sum(RandomDelay)+FixedDelay*nEventi+size(AudioCut,1)-1))=0;
BuiltAudio2(1:(sum(RandomDelay)+FixedDelay*nEventi+size(AudioCut,1)-1))=0;

handles.MyVar.SpatialShuffling.Min=-str2num(get(handles.EditLeftMaxShift,'String'));
handles.MyVar.SpatialShuffling.Max=str2num(get(handles.EditRightMaxShift,'String'));

RandomIntensities=1-(rand(1,nEventi).*str2num(get(handles.EditMaximumVolumeReduction,'String'))./100);
RandomLocations=round(((rand(1,nEventi).*(handles.MyVar.SpatialShuffling.Min-handles.MyVar.SpatialShuffling.Max))-handles.MyVar.SpatialShuffling.Min)./2);


for counter=1:nEventi
    currStart=(sum(RandomDelay(1:counter))+FixedDelay*counter);
    currEnd=currStart+size(AudioCut,1)-1;
    
    currRandomLocation=RandomLocations(counter);
    
    %if get(handles.CheckRandomizeClicksVolume,'Value')==1
        if currRandomLocation<0
            currAudioCut1=AudioCut(1:end+currRandomLocation);
            currAudioCut2=AudioCut(1-currRandomLocation:end);
        elseif currRandomLocation>0
            currAudioCut1=AudioCut(1+currRandomLocation:end);
            currAudioCut2=AudioCut(1:end-currRandomLocation);
        else
            currAudioCut1=AudioCut;
            currAudioCut2=AudioCut;
        end
        BuiltAudio1(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio1(currStart:currEnd-abs(currRandomLocation))+currAudioCut1'*RandomIntensities(counter);
        BuiltAudio2(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio2(currStart:currEnd-abs(currRandomLocation))+currAudioCut2'*RandomIntensities(counter);
        
    %else
    %    if currRandomLocation<0
    %        currAudioCut1=AudioCut(1:end+currRandomLocation);
    %        currAudioCut2=AudioCut(1-currRandomLocation:end);
    %    elseif currRandomLocation>0
    %        currAudioCut1=AudioCut(1+currRandomLocation:end);
    %        currAudioCut2=AudioCut(1:end-currRandomLocation);
    %    else
    %        currAudioCut1=AudioCut;
    %        currAudioCut2=AudioCut;
    %    end
    %    BuiltAudio1(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio1(currStart:currEnd-abs(currRandomLocation))+currAudioCut1';
    %    BuiltAudio2(1,currStart:currEnd-abs(currRandomLocation))=BuiltAudio2(currStart:currEnd-abs(currRandomLocation))+currAudioCut2';
    %    
    %end
end
BuiltAudio1(end-size(AudioCut,1):end)=[];
BuiltAudio1(1:size(AudioCut,1))=[];
BuiltAudio2(end-size(AudioCut,1):end)=[];
BuiltAudio2(1:size(AudioCut,1))=[];

BuiltAudio=[BuiltAudio1;BuiltAudio2];

BuiltAudioBackup=BuiltAudio;
PlayRate=96000;
RoundPlayRate=round(PlayRate/4);

%tmpTrack=BuiltAudio;
%tmpTrack=tmpTrack-min(tmpTrack);
%tmpTrack=tmpTrack/max(tmpTrack)*2;
%BuiltAudio=tmpTrack*get(handles.SliderNoiseVolume,'Value')-1;

%NoiseRatio=get(handles.SliderNoiseRatio,'Value');
%BuiltAudio=BuiltAudio*(NoiseRatio)+wgn(1,size(BuiltAudio,2),1)*(1-NoiseRatio);

% 
% set(handles.SliderNoiseFrequency,'Enable','off')
% set(handles.SliderNoiseVolume,'Enable','off')
% set(handles.SliderNoiseRatio,'Enable','off')
% set(handles.SliderWhiteNoiseFrequency,'Enable','off')
% 



PlayRateClick=round(get(handles.SliderNoiseFrequency,'Value'));
PlayRateWhiteNoise=round(get(handles.SliderWhiteNoiseFrequency,'Value'));
NoiseRatio=get(handles.SliderNoiseRatio,'Value');
TmpClick=BuiltAudioBackup;

% Get broadband click shuffling
BroadbandClickShuffling=get(handles.CheckboxBroadbandShuffling,'Value');

% Check the lenght of the noise audiotrack
SizeCheckValue=PlayRate*PlayRateClick/gcd(PlayRate,PlayRateClick);

% Resample the click-noise audiotrack
if BroadbandClickShuffling
    if (SizeCheckValue<2^31)
        TmpClickNew1=resample(TmpClick',PlayRate,PlayRate/10*10)';
        TmpClickNew2=resample(TmpClick',PlayRate,PlayRate/10*12)';
        TmpClickNew3=resample(TmpClick',PlayRate,PlayRate/10*14)';
        TmpClickNew4=resample(TmpClick',PlayRate,PlayRate/10*16)';
        TmpClickNew5=resample(TmpClick',PlayRate,PlayRate/10*18)';
        TmpClickNew6=resample(TmpClick',PlayRate,PlayRate/10*20)';
        TmpClickNew7=resample(TmpClick',PlayRate,PlayRate/10*8)';
        TmpClickNew8=resample(TmpClick',PlayRate,PlayRate/10*6)';
        TmpClickNew9=resample(TmpClick',PlayRate,PlayRate/10*5)';
        TmpClickNew10=resample(TmpClick',PlayRate,PlayRate/10*4)';
        TmpClickNew11=resample(TmpClick',PlayRate,PlayRate/10*3)';
    else
        TmpClickNew1=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*10)';
        TmpClickNew2=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*12)';
        TmpClickNew3=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*14)';
        TmpClickNew4=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*16)';
        TmpClickNew5=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*18)';
        TmpClickNew6=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*20)';
        TmpClickNew7=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*8)';
        TmpClickNew8=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*6)';
        TmpClickNew9=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*5)';
        TmpClickNew10=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*4)';
        TmpClickNew11=resample(TmpClick',RoundPlayRate,RoundPlayRate/10*3)';
    end
    tmpWinSize=size(TmpClickNew6,2);
    TmpClickNew=[TmpClickNew11(:,1:tmpWinSize) + TmpClickNew10(:,1:tmpWinSize) + TmpClickNew9(:,1:tmpWinSize) + TmpClickNew8(:,1:tmpWinSize) + TmpClickNew7(:,1:tmpWinSize) + TmpClickNew6(:,1:tmpWinSize) + TmpClickNew5(:,1:tmpWinSize) + TmpClickNew4(:,1:tmpWinSize) + TmpClickNew3(:,1:tmpWinSize) + TmpClickNew2(:,1:tmpWinSize) + TmpClickNew1(:,1:tmpWinSize)];
    
else
    if (SizeCheckValue<2^31)
        TmpClickNew=resample(TmpClick',PlayRate,PlayRateClick)';
    else
        TmpClickNew=resample(TmpClick',RoundPlayRate,round(PlayRateClick/4))';
    end
end


range = max(TmpClickNew(:)) - min(TmpClickNew(:));
TmpClickNew = (TmpClickNew - min(TmpClickNew(:))) / range;
TmpClickNew = 2 * TmpClickNew - 1;
TmpClickNew=TmpClickNew*(NoiseRatio);

WhiteNoiseLenght=round(size(TmpClickNew,2)/PlayRate*PlayRateWhiteNoise);
TmpWhiteNoise=wgn(1,WhiteNoiseLenght,1);

SizeCheckValue=PlayRate*PlayRateWhiteNoise/gcd(PlayRate,PlayRateWhiteNoise);
if (SizeCheckValue<2^31)
    TmpWhiteNoise=resample(TmpWhiteNoise,PlayRate,PlayRateWhiteNoise);
else
    TmpWhiteNoise=resample(TmpWhiteNoise,RoundPlayRate,round(PlayRateWhiteNoise/4));
end

range = max(TmpWhiteNoise(:)) - min(TmpWhiteNoise(:));
TmpWhiteNoise = (TmpWhiteNoise - min(TmpWhiteNoise(:))) / range;
TmpWhiteNoise = 2 * TmpWhiteNoise - 1;
TmpWhiteNoise=TmpWhiteNoise*(1-NoiseRatio);
MinLenght=min([size(TmpClickNew,2) size(TmpWhiteNoise,2)]);
BuiltAudio=TmpClickNew(1,1:MinLenght)+TmpWhiteNoise(1,1:MinLenght);

tmpTrack=BuiltAudio;
tmpTrack=tmpTrack-min(tmpTrack);
tmpTrack=tmpTrack/max(tmpTrack)*2;
BuiltAudio=tmpTrack*get(handles.SliderNoiseVolume,'Value')-1;

[file,path,indx] = uiputfile({'*.wav'});

if isequal(file,0)
    return
end
audiowrite(fullfile(path,file),BuiltAudio,PlayRate)



function EditRightMaxShift_Callback(hObject, eventdata, handles)
% hObject    handle to EditRightMaxShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditRightMaxShift as text
%        str2double(get(hObject,'String')) returns contents of EditRightMaxShift as a double


% --- Executes during object creation, after setting all properties.
function EditRightMaxShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditRightMaxShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditLeftMaxShift_Callback(hObject, eventdata, handles)
% hObject    handle to EditLeftMaxShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditLeftMaxShift as text
%        str2double(get(hObject,'String')) returns contents of EditLeftMaxShift as a double


% --- Executes during object creation, after setting all properties.
function EditLeftMaxShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditLeftMaxShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditMaximumVolumeReduction_Callback(hObject, eventdata, handles)
% hObject    handle to EditMaximumVolumeReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditMaximumVolumeReduction as text
%        str2double(get(hObject,'String')) returns contents of EditMaximumVolumeReduction as a double


% --- Executes during object creation, after setting all properties.
function EditMaximumVolumeReduction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditMaximumVolumeReduction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditSecTestNoiseCycle_Callback(hObject, eventdata, handles)
% hObject    handle to EditSecTestNoiseCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditSecTestNoiseCycle as text
%        str2double(get(hObject,'String')) returns contents of EditSecTestNoiseCycle as a double


% --- Executes during object creation, after setting all properties.
function EditSecTestNoiseCycle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSecTestNoiseCycle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckboxBroadbandShuffling.
function CheckboxBroadbandShuffling_Callback(hObject, eventdata, handles)
% hObject    handle to CheckboxBroadbandShuffling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BroadbandClickShuffling=get(handles.CheckboxBroadbandShuffling,'Value');
PlayingNoise=get(handles.ButtonNoiseStop,'Enable');
if BroadbandClickShuffling
    set(handles.SliderNoiseFrequency,'Enable','off');
elseif strcmp(PlayingNoise,'on')
    set(handles.SliderNoiseFrequency,'Enable','off');
else
    set(handles.SliderNoiseFrequency,'Enable','on');
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of CheckboxBroadbandShuffling
