%--function to get all curent values from FEA GUI
% and perform error check on inputs
function [handles]= get_interp_values_int(handles)
%function get_interp_values(handles)
%set the plot selection tool to off until final solution is computed
%set(handles.pop_plot_select, 'value', 1);
%set(handles.pop_plot_select, 'enable', 'off');
handles.result.plt_select = (get(handles.pop_plot_select,   'Value'));
handles.interp.err_factor = str2double(get(handles.et_err_factor,   'String'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.interp.two_c = str2double(get(handles.et_i_2c,   'String'));
handles.interp.a = str2double(get(handles.et_i_a,   'String'));
handles.interp.W = str2double(get(handles.et_i_W,   'String'));
handles.interp.B = str2double(get(handles.et_i_B,   'String'));
handles.interp.E = str2double(get(handles.et_i_E,   'String'));
handles.interp.Sys = str2double(get(handles.et_i_Sys,   'String'));
handles.interp.n = str2double(get(handles.et_i_n,   'String'));
handles.interp.filename = (get(handles.et_i_soln_name,   'String'));
%set interp.solution metd == 1 for avg CMOD method or ==2 for min stress
%method
handles.interp.solution_mthd = 1; %average CMOD interpolation method
%handles.interp.solution_mthd = get(handles.pop_solution_mthd, 'value');
%get plot variables
handles.interp.se_axis_flag = get(handles.cb_fix_se_axes, 'value');
handles.interp.cmod_axis_flag = get(handles.cb_fix_axes_cmod, 'value');
handles.interp.se_data_plot_flag = get(handles.cb_i_props_data, 'value');
handles.interp.cb_eval_test = get(handles.cb_eval_test, 'value');
handles.interp.se_axes_type_flag = get(handles.pop_se_scale, 'value');
handles.interp.se_strain_type_flag = get(handles.pop_se_strain_type, 'value');
handles.interp.extrap_flag = get(handles.cb_extrap_soln, 'value');
if handles.interp.extrap_flag == 1
    handles.interp.extrap_factor = str2double(get(handles.et_i_extrap_cmod,   'String'));
end
%get test evaluation variables
 handles.interp.cb_eval_test = get(handles.cb_eval_test, 'value');
 if handles.interp.cb_eval_test == 1
     handles.result.tear_load = str2double(get(handles.et_i_tear_force,   'String'));
     handles.result.tear_angle = str2double(get(handles.et_i_tear_angle,   'String'));
%  else
%      handles.result.tear_load = [];
%      handles.result.tear_angle = [];
%      handles.testdata.CMOD = 0;
%      handles.testdata.force = 0;
%      handles.testdata.testdata_filename = [];
 end
 %get pre-test prediction variables
 handles.interp.cb_test_predict = get(handles.cb_test_predict, 'value');
 if handles.interp.cb_test_predict == 1
    handles.result.crit_Jc = str2double(get(handles.et_crit_Jc,   'String'));
    handles.result.crit_phi = str2double(get(handles.et_crit_phi,   'String'));
 else
     handles.result.crit_Jc = [];
    handles.result.crit_phi = [];
 end
%get save plots check box value
 handles.interp.cb_save_plots = get(handles.cb_save_plots, 'value');
%%
%perform error checking on inputs
ErrorFound = 0;
%Error Fields - Color Red
if handles.interp.cb_test_predict == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check crit Jc
    jc = handles.result.crit_Jc;
    if (jc <= 0 || isnan(jc) || isempty(jc))
        set(handles.et_crit_Jc, 'BackgroundColor', [0.86  0.275  0.275]);
        ErrorFound = 1;
    else
        set(handles.et_crit_Jc, 'BackgroundColor', 'w');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check crit angle
    ta = handles.result.crit_phi;
    if (ta <= 0 || isnan(ta) || isempty(ta))
        set(handles.et_crit_phi, 'BackgroundColor', [0.86  0.275  0.275]);
        ErrorFound = 1;
    else
        set(handles.et_crit_phi, 'BackgroundColor', 'w');
    end
    %ensure angle is between 0 and 90
    if (ta <= 0 || ta > 90)
        set(handles.et_crit_phi, 'BackgroundColor', [0.86  0.275  0.275]);
        er_box = errordlg('Crit. angle only valid for 0 < phi <= 90');
        ErrorFound = 1;
%     else
%         set(handles.et_i_tear_angle, 'BackgroundColor', 'w');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if handles.interp.cb_eval_test == 1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check tear force
    tf = handles.result.tear_load;
    if (tf <= 0 || isnan(tf) || isempty(tf))
        set(handles.et_i_tear_force, 'BackgroundColor', [0.86  0.275  0.275]);
        ErrorFound = 1;
    else
        set(handles.et_i_tear_force, 'BackgroundColor', 'w');
    end
    %ensure tear force is not greater than test data limit
    td = handles.testdata.force;
    if (length(td) > 1) && (tf > max(td)*1.0) 
        set(handles.et_i_tear_force, 'BackgroundColor', [0.86  0.275  0.275]);
        er_box = errordlg('Tear force is greater than max. force in test record. Enter a smaller value.');
        ErrorFound = 1;
%     else
%         set(handles.et_i_tear_force, 'BackgroundColor', 'w');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check tear angle
    ta = handles.result.tear_angle;
    if (ta <= 0 || isnan(ta) || isempty(ta))
        set(handles.et_i_tear_angle, 'BackgroundColor', [0.86  0.275  0.275]);
        ErrorFound = 1;
    else
        set(handles.et_i_tear_angle, 'BackgroundColor', 'w');
    end
    %ensure angle is between 0 and 90
    if (ta <= 0 || ta > 90)
        set(handles.et_i_tear_angle, 'BackgroundColor', [0.86  0.275  0.275]);
        er_box = errordlg('Tear angle only valid for 0 < phi <= 90');
        ErrorFound = 1;
%     else
%         set(handles.et_i_tear_angle, 'BackgroundColor', 'w');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check test data
    td = handles.testdata.force;
    if ( length(td)== 1)
        set(handles.et_i_testdata_filename, 'BackgroundColor', [0.86  0.275  0.275]);
        ErrorFound = 1;
    else
        set(handles.et_i_testdata_filename, 'BackgroundColor', 'w');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %check error factor
    ef = handles.interp.err_factor;
    if (ef <= 0 || isnan(ef) || isempty(ef))
        set(handles.et_err_factor, 'BackgroundColor', [0.86  0.275  0.275]);
        ErrorFound = 1;
    else
        set(handles.et_err_factor, 'BackgroundColor', 'w');
    end
    %ensure error factor is between 0 and 100
    if (ef <= 0 || ef > 100)
        set(handles.et_err_factor, 'BackgroundColor', [0.86  0.275  0.275]);
        er_box = errordlg('Percent error factor only valid for 0 < error_factor <= 100');
        ErrorFound = 1;
    else
        set(handles.et_err_factor, 'BackgroundColor', 'w');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check 2c
tc = handles.interp.two_c;
if (tc <= 0 || isnan(tc) || isempty(tc))
    set(handles.et_i_2c, 'BackgroundColor', [0.86  0.275  0.275]);
    ErrorFound = 1;
else
    set(handles.et_i_2c, 'BackgroundColor', 'w');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check a
ca = handles.interp.a;
if (ca <= 0 || isnan(ca) || isempty(ca))
    set(handles.et_i_a, 'BackgroundColor', [0.86  0.275  0.275]);
    ErrorFound = 1;
else
    set(handles.et_i_a, 'BackgroundColor', 'w');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check W
cw = handles.interp.W;
if (cw <= 0 || isnan(cw) || isempty(cw))
    set(handles.et_i_W, 'BackgroundColor', [0.86  0.275  0.275]);
    ErrorFound = 1;
else
    set(handles.et_i_W, 'BackgroundColor', 'w');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check B
cb = handles.interp.B;
if (cb <= 0 || isnan(cb) || isempty(cb))
    set(handles.et_i_B, 'BackgroundColor', [0.86  0.275  0.275]);
    ErrorFound = 1;
else
    set(handles.et_i_B, 'BackgroundColor', 'w');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check E
ce = handles.interp.E;
if (ce <= 0 || isnan(ce) || isempty(ce))
    set(handles.et_i_E, 'BackgroundColor', [0.86  0.275  0.275]);
    ErrorFound = 1;
else
    set(handles.et_i_E, 'BackgroundColor', 'w');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check Sys
cs = handles.interp.Sys;
if (cs <= 0 || isnan(cs) || isempty(cs))
    set(handles.et_i_Sys, 'BackgroundColor', [0.86  0.275  0.275]);
    ErrorFound = 1;
else
    set(handles.et_i_Sys, 'BackgroundColor', 'w');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check n
cn = handles.interp.n;
if (cn <= 0 || isnan(cn) || isempty(cn))
    set(handles.et_i_n, 'BackgroundColor', [0.86  0.275  0.275]);
    ErrorFound = 1;
else
    set(handles.et_i_n, 'BackgroundColor', 'w');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check extrap factor
if handles.interp.extrap_flag == 1
cf = handles.interp.extrap_factor;
    if ( isnan(cf) || isempty(cf)) 
        set(handles.et_i_extrap_cmod, 'BackgroundColor', [0.86  0.275  0.275]);
        ErrorFound = 1;
    else
        set(handles.et_i_extrap_cmod, 'BackgroundColor', 'w');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check a/c, a/B, E/Sys and n to make sure values are within solution space
ac = handles.interp.a/handles.interp.two_c*2;
aB = handles.interp.a/handles.interp.B;
ESys = handles.interp.E/handles.interp.Sys;
%
cn = handles.interp.n;
if cn < 3.0 || cn > 20.0
    ErrorFound = 1;
    set(handles.et_i_n, 'BackgroundColor', [0.86  0.275  0.275]);
    er_box = errordlg('Interpolation is only valid for 3.0 <= n <= 20');
else if ErrorFound == 0;
    set(handles.et_i_n, 'BackgroundColor', 'w');
    end
end
%
if ac < 0.2 || ac > 1.0
    ErrorFound = 1;
    set(handles.et_i_a, 'BackgroundColor', [0.86  0.275  0.275]);
    set(handles.et_i_2c, 'BackgroundColor', [0.86  0.275  0.275]);
    er_box = errordlg('Interpolation is only valid for 0.2 <= a/c <= 1.0');
else if ErrorFound == 0;
    set(handles.et_i_a, 'BackgroundColor', 'w');
    set(handles.et_i_2c, 'BackgroundColor', 'w');
    end
end
%
if aB < 0.2 || aB > 0.80
    ErrorFound = 1;
    set(handles.et_i_a, 'BackgroundColor', [0.86  0.275  0.275]);
    set(handles.et_i_B, 'BackgroundColor', [0.86  0.275  0.275]);
    er_box = errordlg('Interpolation is only valid for 0.2 <= a/B <= 0.8');
else if ErrorFound == 0;
    set(handles.et_i_a, 'BackgroundColor', 'w');
    set(handles.et_i_B, 'BackgroundColor', 'w');
    end
end
%
if ESys < 100 || ESys > 1000
    ErrorFound = 1;
    set(handles.et_i_E, 'BackgroundColor', [0.86  0.275  0.275]);
    set(handles.et_i_Sys, 'BackgroundColor', [0.86  0.275  0.275]);
    er_box = errordlg('Interpolation is only valid for 100 <= E/Sys <= 1000');
else if ErrorFound == 0;
    set(handles.et_i_E, 'BackgroundColor', 'w');
    set(handles.et_i_Sys, 'BackgroundColor', 'w');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check to see if everything is correct
%If so let them continue
if (ErrorFound > 0)
    set(handles.pb_i_solve_save, 'Enable', 'Off');
else
    set(handles.pb_i_solve_save, 'Enable', 'On');
end
handles.interp.ErrorFound = ErrorFound;
end
