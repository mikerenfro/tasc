%--function to produce plots based on pop box selection
function  plot_controller(handles)
plt_select = handles.result.plt_select;
switch  plt_select
    case 1
    plt_force_CMOD_interp2_int(handles.testdata, handles.result, handles.interp);
    %plt_force_CMOD_fea(handles.testdata, handles.result)
    handles.plotcount = 1;
    case 2
    %stress-CMOD;
    plt_stress_CMOD_interp_int(handles.testdata, handles.result, handles.interp)
    handles.plotcount = 2; 
    case 3
    plt_J_CMOD_fea_int(handles.result)
    handles.plotcount = 3;
    case 4
    plt_Jel_Jt_phi_fea_int(handles.result)
    handles.plotcount = 4;
    case 5
    %T/S_ys vs phi;
    plt_normT_phi_fea_int(handles.result)
    handles.plotcount = 5;
    case 6
    %K vs phi;
    plt_K_phi_fea_int(handles.result, handles.interp)
    handles.plotcount = 6;
    case 7
    %crit phi location;
    handles.plotcount = 7;
    plt_J_T_norm_phi_fea_int(handles.result);
    case 8
    %crack_sketch;
    plt_sketch_crack_interp_int(handles.result)
    handles.plotcount = 8;
    case 9
    %EPFM_deformation;
    plt_deform_epfm_fea_int(handles.result)
    handles.plotcount = 9;
    %*update* *V1.0.2* 06/6/14
    %Add crack front conditions plot
    case 10
    %Crack front conditions;
    plt_crk_front_condition_int(handles.result, handles.interp)
    handles.plotcount = 10;
    
end