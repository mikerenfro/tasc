function varargout = tasc(varargin)
% TASC M-file for tasc.fig
%      TASC, by itself, creates a new TASC or raises the existing
%      singleton*.
%
%      H = TASC returns the handle to a new TASC or the handle to
%      the existing singleton*.
%
%      TASC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TASC.M with the given input arguments.
%
%      TASC('Property','Value',...) creates a new TASC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tasc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tasc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tasc

% Last Modified by GUIDE v2.5 27-Sep-2013 09:02:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tasc_OpeningFcn, ...
    'gui_OutputFcn',  @tasc_OutputFcn, ...
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


% --- Executes just before tasc is made visible.
function tasc_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tasc (see VARARGIN)

% Choose default command line output for tasc
handles.output = hObject;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*update* *V1.0.1* 01/31/14
%Insert a question dialogue box to force the user to accept the NASA open
%source agreement before using TASC
%
%First check to see if the TASC_lic.txt file exists in the TASC directory
%If the file exists then the license has already been agreed to and the
%dialogue window is bypassed.
lic_status = exist('TASC_lic.txt','file');
if lic_status ~= 2
    %
    lic_quest = questdlg(['I have read and accept the terms of the NASA Open'...
        'Source Agreement included in the TASC distribution package'], ...
        'NASA Open Source Agreement', ...
        'Yes','No','Yes');
    % Handle response
    nosa = 0;
    switch lic_quest
        case 'Yes'
            nosa = 1;
        case 'No'
            nosa = 2;
        case 'Cancel'
            nosa = 2;
    end
    %if the user chooses Yes, then write the TASC_lic.txt file in the TASC
    %directory
    if nosa == 1
        nosa_lic_file = fopen('TASC_lic.txt','w');
        fprintf(nosa_lic_file,'%s\t','File used to demonstrate that the NASA Open Source Agreement has been accepted.');
        fclose(nosa_lic_file);
    end
    %if the user does not choose Yes, then close TASC GUI
    if nosa ~= 1
        errordlg('Exiting TASC')
        delete(gcf)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%dummy vals%
handles.testdata.CMOD = 0;
handles.testdata.force = 0;
handles.result.tear_load = [];
handles.fea_props.base_index = [];
handles.interp.cb_test_predict = 0;
handles.result.tear_angle = [];
handles.result.eval_test = 0;
handles.result.predict_test = 0;
handles.interp.err_factor = 5.0; %default %error on force for given CMOD
%%%%%%%%%%%%%%%%%%%%%%%%%
%set units values
set(handles.menu_units_us, 'Checked', 'On');
set(handles.menu_units_SI, 'Checked', 'Off');
set(handles.panel_units, 'Title', 'US Units');
set(handles.txt_units1, 'String', 'in, kip, ksi');
set(handles.txt_units2, 'String', 'in-lb/in^2, ksi-in^0.5');
%set flag that designates US units
handles.result.units = 1;
%set proper strings for plot axes
handles.result.force_str = 'Force (kip)';
handles.result.CMOD_str = 'CMOD (in)';
handles.result.stress_str = 'Stress (ksi)';
handles.result.J_str = 'J (in-lb/in^{2})';
handles.result.K_str = 'K (ksi-in^{0.5})';
handles.result.length_str = 'length (in)';
%set conversion factors
%force factor
handles.interp.ff = 1.0;
%J factor
handles.interp.jf = 1.0;
%%%%%%%%%%%%%%%%%%%%%%%%%
%insert NASA logo picture
%*********************************************************
axes(handles.ax_logo);
imshow('tasc_nasa_icon.jpg') %uses image toolbox
%image(mesh_image.cdata);
%*********************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%turn off some features unless test data is present
set(handles.pb_i_load_testdata, 'Enable', 'Off');
set(handles.et_i_testdata_filename, 'Enable', 'Off');
set(handles.et_i_tear_angle, 'Enable', 'Off');
set(handles.et_i_tear_force, 'Enable', 'Off');
set(handles.et_err_factor, 'Enable', 'Off');
%turn off some features unless pre-test prediction is on
set(handles.et_crit_Jc, 'Enable', 'Off');
set(handles.et_crit_phi, 'Enable', 'Off');
%set some switches
set(handles.pop_se_strain_type, 'value', 2);
handles.save_path = [];
%set default figure save type based on PC or MAC platform and update plot
%save type munu accordingly
if ispc
    handles.figure_save_type = 'Metafiles';
    set(handles.menu_emf, 'Checked', 'On');
    set(handles.menu_jpeg, 'Checked', 'Off');
    set(handles.menu_tiff, 'Checked', 'Off');
else
    handles.figure_save_type = 'TIFFs';
    set(handles.menu_emf, 'Checked', 'Off');
    set(handles.menu_emf, 'Enable', 'Off');
    set(handles.menu_jpeg, 'Checked', 'Off');
    set(handles.menu_tiff, 'Checked', 'On');
end
%set the plot selection tool to off until final solution is computed
%set(handles.pop_plot_select, 'enable', 'off');
% %get correct path to solution database
%%
handles.interp.interp_data_path = fileparts(which('tasc'));
handles.interp.interpDataName = [filesep 'interp_solution_database.mat']; %generic path

%handles.interp.interpDataName = '\interp_solution_database.mat'; %path
%for windows computers
%handles.interp.interpDataName = '/interp_solution_database.mat';% path
%for MAC

handles.interp.interpFullFileName = strcat(handles.interp.interp_data_path,...
    handles.interp.interpDataName);
handles.interp.interp_data = load(handles.interp.interpFullFileName);

%set default file name
% str_name = strcat(handles.in.sp_code, '_interp');
% set(handles.et_i_soln_name, 'string',str_name );
%set se plot defaults
set(handles.cb_i_props_data, 'Value', 1);
% set(handles.cb_i_props_data, 'Enable', 'Off');
%set extrapolation options
set(handles.et_i_extrap_cmod, 'String', '');
set(handles.et_i_extrap_cmod, 'Enable', 'Off');
set(handles.txt_i_extrap_CMOD, 'Enable', 'Off');
%
%turn off working light
set(handles.txt_working, 'Enable', 'Off');
%
%pull fea props out of "props" structure
%handles.fea_props = handles.props.fea_props;

if isempty(handles.fea_props.base_index) || (handles.fea_props.length_base_table == 0)
    %if needed set zero value for s-e table data initially for logic check in plotting
    handles.fea_props.base_se(1,1) = 0;
end

%only execute the following code if no errors are present
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %create Linear Plus Power Law (LPPL) stress-strain plot
    %set strain axis to total strain
    
    axes(handles.ax_i_se_plot);
    [handles]= get_interp_values_int(handles);
    %get_interp_values_int(handles);
    plt_lppl_int(handles);
    
    % %-----------------------------------------------------------------
    % %-----------------------------------------------------------------
    %perform initial estimates of load-CMOD response
    %and plot P-CMOD estimate
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    [handles]= get_interp_values_int(handles);
    
    %%
    %perform calcs and make plot
    %create P-CMOD plot
    if handles.interp.ErrorFound == 0
        axes(handles.ax_i_cmod_plot);
        %%%%%%%%%%%%%%
        %call function to run interpolation and return results in same format
        %as FEA results format
        handles.result.fea = [];
        [handles.result.fea]= interp_solution_fea_int(handles.interp);
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
        %%%%%%%%%%%%%%
    end
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
end
%-------------------------------------------------------------------------
%turn off existing directory warning
warning off MATLAB:MKDIR:DirectoryExists
%-----------------------------------------------------------------

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes tasc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tasc_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_i_solve_save.
function pb_i_solve_save_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pb_i_solve_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles]= get_interp_values_int(handles);
%turn on plot selection tool
%set(handles.pop_plot_select, 'enable', 'on');
%turn on working light
set(handles.txt_working, 'Enable', 'On');
set(handles.txt_ready, 'Enable', 'Off');
%tell code to update gui to show working light
drawnow();
%call function to run interpolation and return results in same format
%as FEA results format
handles.result.fea = [];
[handles.result.fea]= interp_solution_fea_int(handles.interp);
if handles.interp.cb_test_predict == 1
    [handles.result]= pretest_predict(handles.result);
    if handles.result.predict_flag == 1
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %assignin('base', 'handles_w_interp', handles);
        %create proper plot
        plot_controller(handles)
    end
else
    %perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %assignin('base', 'handles_w_interp', handles);
end
%--------------------------------------------------------------
%make Interp_Files folder to store Interpolated FE analysis files in
current_path = cd;
if isempty(handles.save_path)
    mkdir(current_path, 'Solution_Files');
    cd Solution_Files;
    FEA_path = cd;
else
    save_path = handles.save_path;
    mkdir(save_path, 'Solution_Files');
    gotodir = strcat(save_path, filesep, 'Solution_Files');
    %gotodir = strcat(save_path, '\', 'Solution_Files');
    cd(gotodir);
    %cd Solution_Files;
    FEA_path = cd;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check to see if file exists
%InterpPrefix = char(handles.interp.filename);
InterpFileName = char(handles.result.fea.FileName);
handles.FilenamePrefix = InterpFileName;
InterpFileName = strcat(InterpFileName, '.mat');
CheckName = InterpFileName;
full_CheckName = strcat(FEA_path, filesep, CheckName);
%full_CheckName = strcat(FEA_path,'\',CheckName);
elt_status = exist(full_CheckName,'file');
choice = 'yes';
if(elt_status == 2)
    choice = questdlg('Interpolation file exists. Overwrite files?','File overwrite?', ...
        'yes', 'no','yes');
end
if strcmp(choice, 'yes')
    %--------------------------------------------------------------
    %save interpolated results in mat file
    %only save result variable to save file space (gets rid of interpolation
    %solution space)
    save_result = handles.result; %#ok<NASGU>
    save (InterpFileName, 'save_result' );
    create_summary_table(handles.result, handles.interp)
    %save (InterpFileName);
    %create and save a *ntrp file that captures the analysis input values
    create_inputs_ntrp(handles.result, handles.interp, handles.testdata)
    
end
cd(current_path);
%save plots if check box is selected
if handles.interp.cb_save_plots == 1
    current_path = cd;
    if isempty(handles.save_path)
        mkdir(current_path, 'Plot_Files');
        cd Plot_Files;
        handles.plotsave_directory = cd;
        plot_saver(handles)
    else
        save_path = handles.save_path;
        mkdir(save_path, 'Plot_Files');
        gotodir = strcat(save_path, filesep, 'Plot_Files');
        cd(gotodir);
        handles.plotsave_directory = cd;
        plot_saver(handles)
    end
    cd(current_path);
end
%assignin('base', 'handles_w_interp', handles);
%turn off working light
set(handles.txt_working, 'Enable', 'Off');
set(handles.txt_ready, 'Enable', 'On');
guidata(hObject, handles);



function et_i_soln_name_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_soln_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_soln_name as text
%        str2double(get(hObject,'String')) returns contents of et_i_soln_name as a double


% --- Executes during object creation, after setting all properties.
function et_i_soln_name_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_soln_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_i_import_props.
function pb_i_import_props_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pb_i_import_props (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%clear existing values

%
[handles.fea_props] = read_mat_props_interp;
set(handles.et_i_E, 'string', num2str(handles.fea_props.base_E, '%9.2f'));
set(handles.et_i_props_filename, 'string',handles.fea_props.FileName);
%set(handles.et_i_Sys, 'string', num2str(handles.fea_props.Sys_NotTable, '%9.2f'));
%set(handles.et_i_Sys, 'string', num2str(handles.fea_props.base_se(1,1), '%9.2f'));
if ~isempty(handles.fea_props.base_index) && isempty(handles.fea_props.se_index)
    Sys = handles.fea_props.Sys_NotTable;
    n = handles.fea_props.n;
    set(handles.et_i_Sys, 'string', num2str(Sys, '%9.2f'));
    set(handles.et_i_n, 'string', num2str(n, '%9.2f'));
    EoverSys = handles.fea_props.base_E/Sys;
    rpl_string = ['E/Sys = ',num2str(EoverSys, '%7.2f')];
    set(handles.txt_i_EoverSys, 'string', rpl_string);
end

%if stress strain data exists in props file, try to estimate Sys and n
%for LPPL model
if ~isempty(handles.fea_props.base_index) && ~isempty(handles.fea_props.se_index)
    %estimate Sys value by averaging first 3 points in table
    est_Sys = (handles.fea_props.base_se(3,1)+handles.fea_props.base_se(2,1)+...
        handles.fea_props.base_se(1,1))/3;
    set(handles.et_i_Sys, 'string', num2str(est_Sys, '%9.2f'));
    %perform linear polyfit in log space to estimate n
    for i = 1:size(handles.fea_props.base_se,1)
        total_e(i) = handles.fea_props.base_se(i,1)/handles.fea_props.base_E+...
            handles.fea_props.base_se(i,2); %#ok<AGROW>
    end
    total_e = total_e';
    [dat_vals, ~] = polyfit(log10(total_e), log10(handles.fea_props.base_se(:,1)),1);
    n = 1/dat_vals(1);
    if n > 20
        n = 20;
    end
    if n < 3
        n = 3;
    end
    set(handles.et_i_n, 'string', num2str(n, '%5.2f'));
    E = str2double(get(handles.et_i_E, 'String'));
    Sys = str2double(get(handles.et_i_Sys, 'String'));
    EoverSys = E/Sys;
    rpl_string = ['E/Sys = ',num2str(EoverSys, '%7.2f')];
    set(handles.txt_i_EoverSys, 'string', rpl_string);
end

%update plot
[handles]= get_interp_values_int(handles);

set(handles.cb_i_props_data, 'Enable', 'On');
axes(handles.ax_i_se_plot);
plt_lppl_int(handles);
%----------------------------------
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    %perform calcs and make plot
    axes(handles.ax_i_cmod_plot);
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
end
guidata(hObject, handles);


function et_i_2c_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_2c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_2c as text
%        str2double(get(hObject,'String')) returns contents of et_i_2c as a double
%
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    % %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    % else
    %  set(handles.et_i_2c, 'BackgroundColor', [0.86  0.275  0.275]);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_2c_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_2c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_i_a_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_a as text
%        str2double(get(hObject,'String')) returns contents of et_i_a as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    drawnow();
    % else
    %     set(handles.et_i_a, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_a_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_i_W_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_W (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_W as text
%        str2double(get(hObject,'String')) returns contents of et_i_W as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    drawnow();
    % else
    %     set(handles.et_i_W, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_W_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_W (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_i_B_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_B as text
%        str2double(get(hObject,'String')) returns contents of et_i_B as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %assignin('base', 'handles_w_interp', handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    drawnow();
    % else
    %     set(handles.et_i_B, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_B_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_adv_opt_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to menu_adv_opt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_FEA_compare_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_FEA_compare (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles]= get_interp_values_int(handles);
interp_to_fea_compare(handles.interp)
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_interp_details_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_interp_details (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles]= get_interp_values_int(handles);
% navigate to correct directory for plot saving
%make Interp_Files folder to store Interpolated FE analysis files in
current_path2 = cd;
if isempty(handles.save_path)
    mkdir(current_path2, 'Interp_Detail_plots');
    %cd Interp_Detail_plots;
    detail_path = strcat(current_path2, filesep, 'Interp_Detail_plots');
else
    save_path2 = handles.save_path;
    mkdir(save_path2, 'Interp_Detail_plots');
    warning off MATLAB:MKDIR:DirectoryExists
    detail_path = strcat(save_path2, filesep, 'Interp_Detail_plots');
    %cd(gotodir2);
    %cd Solution_Files;
end
%
plt_interp_details_CMOD_subplot_int(handles.interp, detail_path);
%
cd(current_path2)
guidata(hObject, handles);

function et_i_E_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_E as text
%        str2double(get(hObject,'String')) returns contents of et_i_E as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    E = str2double(get(handles.et_i_E, 'String'));
    Sys = str2double(get(handles.et_i_Sys, 'String'));
    EoverSys = E/Sys;
    rpl_string = ['E/Sys = ',num2str(EoverSys, '%7.2f')];
    set(handles.txt_i_EoverSys, 'string', rpl_string);
    %update plots
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    % else
    %     set(handles.et_i_E, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_E_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_i_Sys_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_Sys (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_Sys as text
%        str2double(get(hObject,'String')) returns contents of et_i_Sys as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    
    %update E/Sys
    E = str2double(get(handles.et_i_E, 'String'));
    Sys = str2double(get(handles.et_i_Sys, 'String'));
    EoverSys = E/Sys;
    rpl_string = ['E/Sys = ',num2str(EoverSys, '%7.2f')];
    set(handles.txt_i_EoverSys, 'string', rpl_string);
    %update plots
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn of working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    % else
    %     set(handles.et_i_Sys, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_Sys_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_Sys (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_i_n_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_n as text
%        str2double(get(hObject,'String')) returns contents of et_i_n as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    
    %update plots
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    % else
    %     set(handles.et_i_n, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_n_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_i_props_filename_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_props_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_props_filename as text
%        str2double(get(hObject,'String')) returns contents of et_i_props_filename as a double


% --- Executes during object creation, after setting all properties.
function et_i_props_filename_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_props_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_i_reset_se_axes.
function pb_i_reset_se_axes_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pb_i_reset_se_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_se_plot);
plt_lppl_int(handles);
axis auto
guidata(hObject, handles);


% --- Executes on selection change in pop_se_scale.
function pop_se_scale_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pop_se_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_se_scale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_se_scale
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_se_plot);
%get current limit values
handles.interp.xlim_se = xlim;
handles.interp.ylim_se = ylim;
plt_lppl_int(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pop_se_scale_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to pop_se_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pop_se_strain_type.
function pop_se_strain_type_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pop_se_strain_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_se_strain_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_se_strain_type
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_se_plot);
%get current limit values
handles.interp.xlim_se = xlim;
handles.interp.ylim_se = ylim;
plt_lppl_int(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_se_strain_type_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to pop_se_strain_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_i_props_data.
function cb_i_props_data_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cb_i_props_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_i_props_data
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_se_plot);
%get current limit values
handles.interp.xlim_se = xlim;
handles.interp.ylim_se = ylim;
plt_lppl_int(handles);
guidata(hObject, handles);





% --- Executes on button press in pb_i_reset_cmod_axes.
function pb_i_reset_cmod_axes_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pb_i_reset_cmod_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_cmod_plot);
%%%%%%%%%%%%%%
%call function to run interpolation and return results in same format
%as FEA results format
handles.result.fea = [];
[handles.result.fea]= interp_solution_fea_int(handles.interp);
%perform EPFM calculation
[handles]= EPFM_calcs_standalone(handles);
%create proper plot
plot_controller(handles)
%%%%%%%%%%%%%%
axis auto
guidata(hObject, handles);


% --- Executes on button press in cb_fix_axes_cmod.
function cb_fix_axes_cmod_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cb_fix_axes_cmod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_fix_axes_cmod
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_cmod_plot);
%get current limit values
handles.interp.xlim_cmod = xlim;
handles.interp.ylim_cmod = ylim;
%%%%%%%%%%%%%%
%call function to run interpolation and return results in same format
%as FEA results format
handles.result.fea = [];
[handles.result.fea]= interp_solution_fea_int(handles.interp);
%perform EPFM calculation
[handles]= EPFM_calcs_standalone(handles);
%create proper plot
plot_controller(handles)
%%%%%%%%%%%%%%
guidata(hObject, handles);


% --- Executes on button press in cb_fix_se_axes.
function cb_fix_se_axes_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cb_fix_se_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_fix_se_axes
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_se_plot);
%get current limit values
handles.interp.xlim_se = xlim;
handles.interp.ylim_se = ylim;
plt_lppl_int(handles);
guidata(hObject, handles);


% --- Executes on button press in cb_extrap_soln.
function cb_extrap_soln_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cb_extrap_soln (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_extrap_soln
%turn on working light
set(handles.txt_working, 'Enable', 'On');
set(handles.txt_ready, 'Enable', 'Off');
%tell code to update gui to show working light
drawnow();
[handles]= get_interp_values_int(handles);
if handles.interp.extrap_flag == 1
    
    set(handles.et_i_extrap_cmod, 'Enable', 'On');
    set(handles.txt_i_extrap_CMOD, 'Enable', 'On');
    set(handles.et_i_extrap_cmod, 'String', '1.05');
    %extrap_factor = str2double(get(handles.et_i_extrap_cmod,   'String'));
    %
    [handles]= get_interp_values_int(handles);
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %extrap_cmod_val = handles.result.fea.CMOD(end)*handles.interp.extrap_factor;
    extrap_cmod_val = handles.result.fea.extrap_cmod_val;
    rpl_string2 = ['Extrap. CMOD = ',num2str(extrap_cmod_val, '%8.5f')];
    set(handles.txt_i_extrap_CMOD, 'String', rpl_string2);
    axes(handles.ax_i_cmod_plot);
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    %handles.result.fea = [];
    %[handles.result.fea]= interp_solution_fea_int(handles.interp);
    %      perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %%%%%%%%%%%%%
else
    set(handles.et_i_extrap_cmod, 'String', '');
    set(handles.et_i_extrap_cmod, 'Enable', 'Off');
    set(handles.txt_i_extrap_CMOD, 'Enable', 'Off');
    [handles]= get_interp_values_int(handles);
    axes(handles.ax_i_cmod_plot);
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %%%%%%%%%%%%%%
end
%turn off working light
set(handles.txt_working, 'Enable', 'Off');
set(handles.txt_ready, 'Enable', 'On');
guidata(hObject, handles);


function et_i_extrap_cmod_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_extrap_cmod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_extrap_cmod as text
%        str2double(get(hObject,'String')) returns contents of et_i_extrap_cmod as a double
%turn on working light
set(handles.txt_working, 'Enable', 'On');
set(handles.txt_ready, 'Enable', 'Off');
%tell code to update gui to show working light
drawnow();
[handles]= get_interp_values_int(handles);
%only let extrap factor be from 1.0 to 1.5
if handles.interp.extrap_factor < 1
    set(handles.et_i_extrap_cmod, 'value', 1.01);
    set(handles.et_i_extrap_cmod, 'String', '1.01');
    handles.interp.extrap_factor = 1.01;
    errordlg('Extrapolation is only allowed for 1.0 < factor <= 2.0');
elseif handles.interp.extrap_factor > 2.0
    set(handles.et_i_extrap_cmod, 'value', 2.0);
    set(handles.et_i_extrap_cmod, 'String', '2.0');
    handles.interp.extrap_factor = 2.0;
    errordlg('Extrapolation is only allowed for 1.0 <= factor <= 2.0');
end
%call function to run interpolation and return results in same format
%as FEA results format
handles.result.fea = [];
[handles.result.fea]= interp_solution_fea_int(handles.interp);
%extrap_cmod_val = handles.result.fea.CMOD(end)*handles.interp.extrap_factor;
extrap_cmod_val = handles.result.fea.extrap_cmod_val;
rpl_string2 = ['Extrap. CMOD = ',num2str(extrap_cmod_val, '%8.5f')];
set(handles.txt_i_extrap_CMOD, 'String', rpl_string2);
axes(handles.ax_i_cmod_plot);
%%%%%%%%%%%%%%
%call function to run interpolation and return results in same format
%as FEA results format
%       handles.result.fea = [];
%       [handles.result.fea]= interp_solution_fea_int(handles.interp);
%perform EPFM calculation
[handles]= EPFM_calcs_standalone(handles);
%create proper plot
plot_controller(handles)
%%%%%%%%%%%%%%
%turn off working light
set(handles.txt_working, 'Enable', 'Off');
set(handles.txt_ready, 'Enable', 'On');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function et_i_extrap_cmod_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_extrap_cmod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on selection change in pop_solution_mthd.
% function pop_solution_mthd_Callback(hObject, eventdata, handles)
% % hObject    handle to pop_solution_mthd (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Hints: contents = cellstr(get(hObject,'String')) returns pop_solution_mthd contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from pop_solution_mthd
% [handles]= get_interp_values_int(handles);
% axes(handles.ax_i_cmod_plot);
%   %get current limit values
%   handles.interp.xlim_cmod = xlim;
%   handles.interp.ylim_cmod = ylim;
% plt_force_CMOD_interp(handles.testdata, handles.result, handles.interp);
% guidata(hObject, handles);
%
% % --- Executes during object creation, after setting all properties.
% function pop_solution_mthd_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to pop_solution_mthd (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
%
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end



function et_i_tear_force_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_tear_force (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_tear_force as text
%        str2double(get(hObject,'String')) returns contents of et_i_tear_force as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    set(handles.et_i_tear_force, 'BackgroundColor', 'w');
    % %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    % else
    %  set(handles.et_i_tear_force, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function et_i_tear_force_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_tear_force (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_i_tear_angle_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_i_tear_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_tear_angle as text
%        str2double(get(hObject,'String')) returns contents of et_i_tear_angle as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    set(handles.et_i_tear_angle, 'BackgroundColor', 'w');
    % %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    % else
    %  set(handles.et_i_tear_angle, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function et_i_tear_angle_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_tear_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_i_load_testdata.
function pb_i_load_testdata_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pb_i_load_testdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.testdata.CMOD = [];
handles.testdata.force = [];
handles.testdata.testdata_filename = [];
[handles.testdata]= read_testdata_sci;
set(handles.et_i_testdata_filename, 'string', handles.testdata.testdata_filename);
%if no errors update P-CMOD plot and interpolation
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    set(handles.et_i_testdata_filename, 'BackgroundColor', 'w');
    % %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
end
guidata(hObject, handles);


function et_i_testdata_filename_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_testdata_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_i_testdata_filename as text
%        str2double(get(hObject,'String')) returns contents of et_i_testdata_filename as a double


% --- Executes during object creation, after setting all properties.
function et_i_testdata_filename_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_i_testdata_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_eval_test.
function cb_eval_test_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cb_eval_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_eval_test
[handles]= get_interp_values_int(handles);
if handles.interp.cb_eval_test == 1
    %turn on some features
    handles.result.eval_test = 1;
    set(handles.pb_i_load_testdata, 'Enable', 'On');
    set(handles.et_i_testdata_filename, 'Enable', 'On');
    set(handles.et_i_tear_angle, 'Enable', 'On');
    set(handles.et_i_tear_force, 'Enable', 'On');
    set(handles.et_err_factor, 'Enable', 'On');
    set(handles.cb_test_predict, 'value', 0);
    %turn off some features
    set(handles.et_crit_Jc, 'Enable', 'Off');
    set(handles.et_crit_phi, 'Enable', 'Off');
    set(handles.et_crit_Jc, 'string', '');
    set(handles.et_crit_phi, 'string', '');
else
    %turn off some features unless test data is present
    handles.result.predict_test = 0;
    handles.result.eval_test = 0;
    set(handles.pb_i_load_testdata, 'Enable', 'Off');
    set(handles.et_i_testdata_filename, 'Enable', 'Off');
    set(handles.et_i_tear_angle, 'Enable', 'Off');
    set(handles.et_i_tear_force, 'Enable', 'Off');
    set(handles.et_err_factor, 'Enable', 'Off');
    set(handles.et_i_testdata_filename, 'string', '');
    set(handles.et_i_tear_angle, 'string', '');
    set(handles.et_i_tear_force, 'string', '');
    %clear out some values if not performing test evaluation
    handles.result.tear_load = [];
    handles.result.tear_angle = [];
    handles.testdata.CMOD = 0;
    handles.testdata.force = 0;
    handles.testdata.testdata_filename = [];
    
end
%if no errors update P-CMOD plot and interpolation
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    % %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
end

guidata(hObject, handles);


% --- Executes on selection change in pop_plot_select.
function pop_plot_select_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pop_plot_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_plot_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_plot_select
[handles]= get_interp_values_int(handles);
axes(handles.ax_i_cmod_plot);
%create proper plot
plot_controller(handles)
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function pop_plot_select_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to pop_plot_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_crit_Jc_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_crit_Jc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_crit_Jc as text
%        str2double(get(hObject,'String')) returns contents of et_crit_Jc as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %get force and CMOD corresponding to choice of crit J and Phi
    [handles.result]= pretest_predict(handles.result);
    if handles.result.predict_flag == 1
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %assignin('base', 'handles_w_interp', handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function et_crit_Jc_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_crit_Jc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function et_crit_phi_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_crit_phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_crit_phi as text
%        str2double(get(hObject,'String')) returns contents of et_crit_phi as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %get force and CMOD corresponding to choice of crit J and Phi
    [handles.result]= pretest_predict(handles.result);
    if handles.result.predict_flag == 1
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %assignin('base', 'handles_w_interp', handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function et_crit_phi_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_crit_phi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_test_predict.
function cb_test_predict_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cb_test_predict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_test_predict
[handles]= get_interp_values_int(handles);
if handles.interp.cb_test_predict == 1
    handles.result.predict_test = 1;
    %turn off some features unless test data is present
    set(handles.et_crit_Jc, 'Enable', 'On');
    set(handles.et_crit_phi, 'Enable', 'On');
    set(handles.cb_eval_test, 'value', 0);
    handles.testdata.CMOD = 0;
    handles.testdata.force = 0;
    handles.testdata.testdata_filename = [];
    %turn off some features unless test data is present
    set(handles.pb_i_load_testdata, 'Enable', 'Off');
    set(handles.et_i_testdata_filename, 'Enable', 'Off');
    set(handles.et_i_tear_angle, 'Enable', 'Off');
    set(handles.et_i_tear_force, 'Enable', 'Off');
    set(handles.et_err_factor, 'Enable', 'Off');
    set(handles.et_i_testdata_filename, 'string', '');
    set(handles.et_i_tear_angle, 'string', '');
    set(handles.et_i_tear_force, 'string', '');
else
    %turn off some features unless test data is present
    handles.result.predict_test = 0;
    handles.result.eval_test = 0;
    handles.result.tear_load = [];
    handles.result.tear_angle = [];
    set(handles.et_crit_Jc, 'Enable', 'Off');
    set(handles.et_crit_phi, 'Enable', 'Off');
    set(handles.et_crit_Jc, 'string', '');
    set(handles.et_crit_phi, 'string', '');
    %if no errors update P-CMOD plot and interpolation
    [handles]= get_interp_values_int(handles);
    if handles.interp.ErrorFound == 0
        % %turn on working light
        set(handles.txt_working, 'Enable', 'On');
        set(handles.txt_ready, 'Enable', 'Off');
        %tell code to update gui to show working light
        drawnow();
        axes(handles.ax_i_cmod_plot);
        %get current limit values
        handles.interp.xlim_cmod = xlim;
        handles.interp.ylim_cmod = ylim;
        %%%%%%%%%%%%%%
        %call function to run interpolation and return results in same format
        %as FEA results format
        handles.result.fea = [];
        [handles.result.fea]= interp_solution_fea_int(handles.interp);
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
        %%%%%%%%%%%%%%
        %turn off working light
        set(handles.txt_working, 'Enable', 'Off');
        set(handles.txt_ready, 'Enable', 'On');
    end
end

guidata(hObject, handles);



function et_err_factor_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to et_err_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of et_err_factor as text
%        str2double(get(hObject,'String')) returns contents of et_err_factor as a double
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    %perform EPFM calculation
    [handles]= EPFM_calcs_standalone(handles);
    %create proper plot
    plot_controller(handles)
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    drawnow();
    % else
    %     set(handles.et_i_a, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function et_err_factor_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to et_err_factor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_units_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to menu_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_units_us_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_units_us (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_units_us, 'Checked', 'On');
set(handles.menu_units_SI, 'Checked', 'Off');
set(handles.panel_units, 'Title', 'US Units');
set(handles.txt_units1, 'String', 'in, kip, ksi');
set(handles.txt_units2, 'String', 'in-lb/in^2, ksi-in^0.5');
%set flag that designates US units
handles.result.units = 1;
%set proper strings for plot axes
handles.result.force_str = 'Force (kip)';
handles.result.CMOD_str = 'CMOD (in)';
handles.result.stress_str = 'Stress (ksi)';
handles.result.J_str = 'J (in-lb/in^{2})';
handles.result.K_str = 'K (ksi-in^{0.5})';
handles.result.length_str = 'length (in)';
%set conversion factors
%force factor
handles.interp.ff = 1.0;
%J factor
handles.interp.jf = 1.0;
%update plots and data%%%%%%%%%%%%%%%%%%%%%%%%%
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %assignin('base', 'handles_w_interp', handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    drawnow();
    % else
    %     set(handles.et_i_B, 'BackgroundColor', [0.86  0.275  0.275]);
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_units_SI_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_units_SI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_units_us, 'Checked', 'Off');
set(handles.menu_units_SI, 'Checked', 'On');
set(handles.panel_units, 'Title', 'SI Units');
set(handles.txt_units1, 'String', 'mm, kN, MPa');
set(handles.txt_units2, 'String', 'kJ/m^2, MPa-m^0.5');
%set flag that designates SI units
handles.result.units = 2;
%set proper strings for plot axes
handles.result.force_str = 'Force (kN)';
handles.result.CMOD_str = 'CMOD (mm)';
handles.result.stress_str = 'Stress (MPa)';
handles.result.J_str = 'J (kJ/m^{2})';
handles.result.K_str = 'K (MPa-m^{0.5})';
handles.result.length_str = 'length (mm)';
%set conversion factors
%force factor
handles.interp.ff = 1.0/1000;
%J factor
handles.interp.jf = 1.0/1000;
%update plots and data%%%%%%%%%%%%%%%%%%%%%%%%%
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %assignin('base', 'handles_w_interp', handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    drawnow();
    % else
    %     set(handles.et_i_B, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_read_input_file_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_read_input_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.in = [];
[handles.in]= read_input_ntrp_file;
%clear out some values
set(handles.et_i_props_filename, 'string','');
set(handles.cb_eval_test, 'value', 0);
%turn off some features unless test data is present
set(handles.pb_i_load_testdata, 'Enable', 'Off');
set(handles.et_i_testdata_filename, 'Enable', 'Off');
set(handles.et_i_tear_angle, 'Enable', 'Off');
set(handles.et_i_tear_force, 'Enable', 'Off');
set(handles.et_err_factor, 'Enable', 'Off');
set(handles.et_i_testdata_filename, 'string', '');
set(handles.et_i_tear_angle, 'string', '');
set(handles.et_i_tear_force, 'string', '');
set(handles.cb_test_predict, 'value', 0);
%turn off some features
set(handles.et_crit_Jc, 'Enable', 'Off');
set(handles.et_crit_phi, 'Enable', 'Off');
set(handles.et_crit_Jc, 'string', '');
set(handles.et_crit_phi, 'string', '');

set(handles.et_i_2c,   'String', '');
set(handles.et_i_a,   'String','' );
set(handles.et_i_W,   'String', '');
set(handles.et_i_B,   'String', '');
set(handles.et_i_soln_name,   'String', '');
set(handles.et_i_E, 'string', '');
set(handles.txt_i_EoverSys, 'string', '');
set(handles.et_i_Sys, 'string', '');
set(handles.et_i_n, 'string', '');
handles.testdata.CMOD = 0;
handles.testdata.force = 0;
handles.result.tear_load = [];
handles.fea_props.base_index = [];
handles.interp.cb_test_predict = 0;
handles.result.tear_angle = [];
handles.result.eval_test = 0;
handles.result.predict_test = 0;
%
%set default save path to same location as ntrp file
handles.save_path = handles.in.save_path;
%set up units values
handles.result.units = handles.in.result.units;
if handles.result.units == 1
    set(handles.menu_units_us, 'Checked', 'On');
    set(handles.menu_units_SI, 'Checked', 'Off');
    set(handles.panel_units, 'Title', 'US Units');
    set(handles.txt_units1, 'String', 'in, kip, ksi');
    set(handles.txt_units2, 'String', 'in-lb/in^2, ksi-in^0.5');
    %set flag that designates US units
    handles.result.units = 1;
    %set proper strings for plot axes
    handles.result.force_str = 'Force (kip)';
    handles.result.CMOD_str = 'CMOD (in)';
    handles.result.stress_str = 'Stress (ksi)';
    handles.result.J_str = 'J (in-lb/in^{2})';
    handles.result.K_str = 'K (ksi-in^{0.5})';
    handles.result.length_str = 'length (in)';
    %set conversion factors
    %force factor
    handles.interp.ff = 1.0;
    %J factor
    handles.interp.jf = 1.0;
else
    set(handles.menu_units_us, 'Checked', 'Off');
    set(handles.menu_units_SI, 'Checked', 'On');
    set(handles.panel_units, 'Title', 'SI Units');
    set(handles.txt_units1, 'String', 'mm, kN, MPa');
    set(handles.txt_units2, 'String', 'kJ/m^2, MPa-m^0.5');
    %set flag that designates SI units
    handles.result.units = 2;
    %set proper strings for plot axes
    handles.result.force_str = 'Force (kN)';
    handles.result.CMOD_str = 'CMOD (mm)';
    handles.result.stress_str = 'Stress (MPa)';
    handles.result.J_str = 'J (kJ/m^{2})';
    handles.result.K_str = 'K (MPa-m^{0.5})';
    handles.result.length_str = 'length (mm)';
    %set conversion factors
    %force factor
    handles.interp.ff = 1.0/1000;
    %J factor
    handles.interp.jf = 1.0/1000;
end

%%%%%%%%%%%%%%%%%%%%%
%%%
set(handles.et_i_2c,   'String', handles.in.interp.two_c);
set(handles.et_i_a,   'String',handles.in.interp.a );
set(handles.et_i_W,   'String', handles.in.interp.W);
set(handles.et_i_B,   'String', handles.in.interp.B);
set(handles.et_i_soln_name,   'String', handles.in.result.fea.FileName);
%%%%%%%%%%%%%%%%%%%%%
%assign material properties
set(handles.et_i_E, 'string', num2str(handles.in.fea_props.base_E, '%9.2f'));
handles.fea_props.base_E = handles.in.fea_props.base_E;
handles.fea_props.base_index = handles.in.fea_props.base_index;
handles.fea_props.length_base_table = handles.in.fea_props.length_base_table;
handles.fea_props.base_se = handles.in.fea_props.base_se;
handles.fea_props.se_index = handles.in.fea_props.se_index;
%set(handles.et_i_props_filename, 'string',in.handles.fea_props.FileName);
%set(handles.et_i_Sys, 'string', num2str(handles.fea_props.Sys_NotTable, '%9.2f'));
%set(handles.et_i_Sys, 'string', num2str(handles.fea_props.base_se(1,1), '%9.2f'));
if ~isempty(handles.fea_props.base_index) && isempty(handles.fea_props.se_index)
    Sys = handles.in.fea_props.Sys_NotTable;
    n = handles.in.fea_props.n;
    set(handles.et_i_Sys, 'string', num2str(Sys, '%9.2f'));
    set(handles.et_i_n, 'string', num2str(n, '%9.2f'));
    EoverSys = handles.fea_props.base_E/Sys;
    rpl_string = ['E/Sys = ',num2str(EoverSys, '%7.2f')];
    set(handles.txt_i_EoverSys, 'string', rpl_string);
end

%if stress strain data exists in props file, try to estimate Sys and n
%for LPPL model
if ~isempty(handles.fea_props.base_index) && ~isempty(handles.fea_props.se_index)
    %estimate Sys value by averaging first 3 points in table
    est_Sys = (handles.fea_props.base_se(3,1)+handles.fea_props.base_se(2,1)+...
        handles.fea_props.base_se(1,1))/3;
    set(handles.et_i_Sys, 'string', num2str(est_Sys, '%9.2f'));
    %perform linear polyfit in log space to estimate n
    for i = 1:size(handles.fea_props.base_se,1)
        total_e(i) = handles.fea_props.base_se(i,1)/handles.fea_props.base_E+...
            handles.fea_props.base_se(i,2); %#ok<AGROW>
    end
    total_e = total_e';
    [dat_vals, ~] = polyfit(log10(total_e), log10(handles.fea_props.base_se(:,1)),1);
    n = 1/dat_vals(1);
    if n > 20
        n = 20;
    end
    if n < 3
        n = 3;
    end
    set(handles.et_i_n, 'string', num2str(n, '%5.2f'));
    E = str2double(get(handles.et_i_E, 'String'));
    Sys = str2double(get(handles.et_i_Sys, 'String'));
    EoverSys = E/Sys;
    rpl_string = ['E/Sys = ',num2str(EoverSys, '%7.2f')];
    set(handles.txt_i_EoverSys, 'string', rpl_string);
end
%%%%%%%%%%%%%%%%%%%%%
%check for test prediction data
handles.interp.cb_test_predict = handles.in.interp.cb_test_predict;
if handles.interp.cb_test_predict == 1
    set(handles.cb_test_predict, 'value', 1);
    handles.result.predict_test = 1;
    handles.interp.cb_test_predict = 1;
    %turn off some features unless test data is present
    set(handles.et_crit_Jc, 'Enable', 'On');
    set(handles.et_crit_phi, 'Enable', 'On');
    set(handles.cb_eval_test, 'value', 0);
    handles.testdata.CMOD = 0;
    handles.testdata.force = 0;
    handles.testdata.testdata_filename = [];
    set(handles.cb_eval_test, 'value', 0);
    %turn off some features unless test data is present
    set(handles.pb_i_load_testdata, 'Enable', 'Off');
    set(handles.et_i_testdata_filename, 'Enable', 'Off');
    set(handles.et_i_tear_angle, 'Enable', 'Off');
    set(handles.et_i_tear_force, 'Enable', 'Off');
    set(handles.et_err_factor, 'Enable', 'Off');
    set(handles.et_i_testdata_filename, 'string', '');
    set(handles.et_i_tear_angle, 'string', '');
    set(handles.et_i_tear_force, 'string', '');
    %set some values
    set(handles.et_crit_Jc,   'String', handles.in.result.crit_Jc);
    set(handles.et_crit_phi,   'String', handles.in.result.crit_phi);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check for test evaluation data
handles.interp.cb_eval_test = handles.in.interp.cb_eval_test;
if handles.interp.cb_eval_test == 1
    set(handles.cb_eval_test, 'value', 1);
    handles.result.eval_test = 1;
    set(handles.pb_i_load_testdata, 'Enable', 'On');
    set(handles.et_i_testdata_filename, 'Enable', 'On');
    set(handles.et_i_tear_angle, 'Enable', 'On');
    set(handles.et_i_tear_force, 'Enable', 'On');
    set(handles.et_err_factor, 'Enable', 'On');
    set(handles.cb_test_predict, 'value', 0);
    %turn off some features
    set(handles.et_crit_Jc, 'Enable', 'Off');
    set(handles.et_crit_phi, 'Enable', 'Off');
    set(handles.et_crit_Jc, 'string', '');
    set(handles.et_crit_phi, 'string', '');
    %set some values
    set(handles.et_i_tear_force,   'String', handles.in.result.tear_load);
    set(handles.et_i_tear_angle,   'String', handles.in.result.tear_angle);
    handles.testdata.force = handles.in.testdata.force;
    handles.testdata.CMOD = handles.in.testdata.CMOD;
    handles.testdata.testdata_filename = handles.in.testdata.testdata_filename;
    set(handles.et_i_testdata_filename, 'string', handles.testdata.testdata_filename);
    set(handles.cb_test_predict, 'value', 0);
end

%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
%now perform error checks, analysis, and make plots
%assignin('base', 'handles_w_interp', handles);
[handles]= get_interp_values_int(handles);
if handles.interp.ErrorFound == 0
    % %turn on working light
    set(handles.txt_working, 'Enable', 'On');
    set(handles.txt_ready, 'Enable', 'Off');
    %tell code to update gui to show working light
    drawnow();
    axes(handles.ax_i_se_plot);
    %get current limit values
    handles.interp.xlim_se = xlim;
    handles.interp.ylim_se = ylim;
    plt_lppl_int(handles);
    
    axes(handles.ax_i_cmod_plot);
    %get current limit values
    handles.interp.xlim_cmod = xlim;
    handles.interp.ylim_cmod = ylim;
    %%%%%%%%%%%%%%
    %call function to run interpolation and return results in same format
    %as FEA results format
    handles.result.fea = [];
    [handles.result.fea]= interp_solution_fea_int(handles.interp);
    if handles.interp.cb_test_predict == 1
        [handles.result]= pretest_predict(handles.result);
        if handles.result.predict_flag == 1
            %perform EPFM calculation
            [handles]= EPFM_calcs_standalone(handles);
            %assignin('base', 'handles_w_interp', handles);
            %create proper plot
            plot_controller(handles)
        end
    else
        %perform EPFM calculation
        [handles]= EPFM_calcs_standalone(handles);
        %create proper plot
        plot_controller(handles)
    end
    %%%%%%%%%%%%%%
    %turn off working light
    set(handles.txt_working, 'Enable', 'Off');
    set(handles.txt_ready, 'Enable', 'On');
    %tell code to update gui to show working light
    % else
    %  set(handles.et_i_2c, 'BackgroundColor', [0.86  0.275  0.275]);
end
guidata(hObject, handles);


% --- Executes on button press in cb_save_plots.
function cb_save_plots_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to cb_save_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_save_plots


% --- Executes on button press in pb_choose_folder.
function pb_choose_folder_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to pb_choose_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st_path = cd;
if isempty(handles.save_path)
    handles.save_path = uigetdir(st_path,'Choose Directory for Output Data Location');
else
    st_path = char(handles.save_path);
    handles.save_path = uigetdir(st_path,'Choose Directory for Output Data Location');
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_plot_save_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to menu_plot_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_emf_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_emf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.figure_save_type = 'Metafiles';
set(handles.menu_emf, 'Checked', 'On');
set(handles.menu_jpeg, 'Checked', 'Off');
set(handles.menu_tiff, 'Checked', 'Off');
guidata(hObject, handles);
% --------------------------------------------------------------------
function menu_jpeg_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_jpeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.figure_save_type = 'JPEGs';
set(handles.menu_emf, 'Checked', 'Off');
set(handles.menu_jpeg, 'Checked', 'On');
set(handles.menu_tiff, 'Checked', 'Off');
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_tiff_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to menu_tiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.figure_save_type = 'TIFFs';
set(handles.menu_emf, 'Checked', 'Off');
set(handles.menu_jpeg, 'Checked', 'Off');
set(handles.menu_tiff, 'Checked', 'On');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ax_logo_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to ax_logo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ax_logo
% axes(hObject)
% imshow('tasc_nasa_icon.jpg');
% guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_show_SC_image_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to menu_show_SC_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%open a fig window and show a picture of the SC geometry
SC_fig = figure( 'Name','Show_SC_fig',...
    'NumberTitle','off','color', 'w');
axes_SC = axes('Parent',SC_fig);
axes(axes_SC);
imshow('SC_picture.jpg','InitialMagnification',35) %uses image toolbox
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_user_manual_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to menu_user_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ispc
    winopen('TASC_manual.pdf');
else
    open('TASC_manual.pdf');
end
guidata(hObject, handles);
