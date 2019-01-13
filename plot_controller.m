%--function to produce plots based on pop box selection
function plot_controller(handles)
plt_select = handles.result.plt_select;
switch plt_select
    case 1
        plt_force_CMOD_interp2_int(handles.testdata, handles.result, handles.interp);
        %plt_force_CMOD_fea(handles.testdata, handles.result)
    case 2
        %stress-CMOD;
        plt_stress_CMOD_interp_int(handles.testdata, handles.result, handles.interp);
    case 3
        plt_J_CMOD_fea_int(handles.result);
    case 4
        plt_Jel_Jt_phi_fea_int(handles.result);
    case 5
        %T/S_ys vs phi;
        plt_normT_phi_fea_int(handles.result);
    case 6
        %K vs phi;
        plt_K_phi_fea_int(handles.result, handles.interp);
    case 7
        %crit phi location;
        plt_J_T_norm_phi_fea_int(handles.result);
    case 8
        %crack_sketch;
        plt_sketch_crack_interp_int(handles.result);
    case 9
        %EPFM_deformation;
        plt_deform_epfm_fea_int(handles.result);
        %*update* *V1.0.2* 06/6/14
        %Add crack front conditions plot
    case 10
        %Crack front conditions;
        plt_crk_front_condition_int(handles.result, handles.interp);
end
if plt_select >= 1 && plt_select <= 10
    handles.plotcount = plt_select;
end