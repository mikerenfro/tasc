%Function to run interpolation and return results in same format
%as FEA results format
function [fea] = interp_solution_fea_int(interp)
%set units conversion factors
%force factor
ff = interp.ff;
%J factor
jf = interp.jf;
%
input = interp.interp_data.input;

if interp.rb_tension==1
    res = interp.interp_data.result;
else
    res = interp.interp_data.result_bending;
end
aB_pick = interp.a/interp.B;
ac_pick = interp.a/interp.two_c*2;
n_pick = interp.n;
E_pick = interp.E;
Sys_pick = interp.Sys;
E_Sys_pick = E_pick/Sys_pick;
W_pick = interp.W;
B_pick = interp.B;
S_in_pick = interp.S_in;
S_out_pick = interp.S_out;
%perform interpolation
if interp.solution_mthd == 1
    [~,~,~,~,Final] =...
        interp_solution_SCGui_CMOD_log_int(input,res,aB_pick,ac_pick,n_pick,E_Sys_pick);
    %interpolate_solution_SCGui_CMOD(input,res,aB_pick,ac_pick,n_pick,E_Sys_pick);
else
    [~,~,~,~,Final] =...
        interpolate_solution_SCGui(input,res,aB_pick,ac_pick,n_pick,E_Sys_pick);
end
% [Tmp,Tmp2,Tmp3,Tmp4,Final] =...
%     interpolate_solution_SCGui_CMOD(input,res,aB_pick,ac_pick,n_pick,E_Sys_pick);
%calculate load values from net stress incremental values
Afar_interp = W_pick*B_pick;
% Anet_interp = Afar_interp - 3.141592*interp.a*(interp.two_c/2)/2;
%scale values to match test specimen size
interp_CMOD = Final.int_CMOD*B_pick;
%%%%------------------------------------------------------------------
%code to base force and stress values off of interpolated net stress
%interp_force = Final.net_stress_inc.*Sys_pick.*Anet_interp;%based on net stress
%interp_net_stress = Final.net_stress_inc*Sys_pick;
%%% May 14, 2012
%%%change code to calculate far stress based on current geometry W,B etc.
%%%interp_far_stress = Final.far_stress_inc*Sys_pick;
%interp_far_stress = interp_net_stress*(Anet_interp/Afar_interp);
%%%%------------------------------------------------------------------
%%%%------------------------------------------------------------------
%code to base force and stress values off of interpolated far stress
if interp.rb_tension==1
    interp_far_stress = Final.far_stress_inc*Sys_pick;
    interp_force = interp_far_stress.*Afar_interp;%based on far stress
else
    interp_far_stress = Final.far_stress_inc*Sys_pick;
    Ixx = W_pick*(B_pick^3)/12;
    interp_moment = (interp_far_stress*Ixx)/(B_pick/2);
    interp_force = 4*interp_moment/(S_out_pick-S_in_pick);
end
% interp_net_stress = interp_far_stress*(Afar_interp/Anet_interp);
%%%%------------------------------------------------------------------
% interp_A_ratio = Anet_interp/Afar_interp;
%interp_force = Final.far_stress_inc.*Sys_pick.*Afar_interp*(interp_A_ratio/Final.A_ratio);%based on far stress*Area ratio
interp_Jtotal = Final.int_Jtotal.*Sys_pick.*B_pick;
interp_Jel = Final.int_Jel.*Sys_pick.*B_pick;
%
NameString = strcat('a/B = ',num2str(aB_pick),', a/c = ',num2str(ac_pick));
%fea.interp.interp_force = interp.interp_force;
%----------------------------------------------
%add values to "fea" cell array
fea.Jtotal_Avg = interp_Jtotal.*jf;
fea.Jel_Avg = [];
fea.Jel_EPFM = interp_Jel.*jf;
fea.Kavg = [];
fea.TstressAvg = [];
%add values to "fea" cell array
if interp.rb_tension == 1
    fea.moment_flag = 'no';
    %set dummy bending stress to zero
    fea.S_bend = 0;
    fea.St_far = interp_far_stress;
    fea.BCstring = 'Disp';
else
    fea.moment_flag = 'no';
    fea.St_far = 0;
    fea.S_bend = interp_far_stress;
    fea.BCString = 'Traction';
end
fea.CharStress = max(interp_far_stress); % assume max far stress for now
fea.reac_force=interp_force';
fea.reac_force=fea.reac_force.*ff;
fea.CMOD=interp_CMOD;
fea.half_CMOD=fea.CMOD./2;
fea.CMOD_node= 1; %dummy value
fea.NameString=NameString;
fea.FileName= char(interp.filename);
fea.analy_type='EPFM';
fea.num_steps=Final.n_steps;
fea.a = interp.a;
fea.c = interp.two_c/2;
fea.width = interp.W;
fea.B = interp.B;
fea.length = 2*interp.W; % L = 2*W for all interpolated solutions
fea.num_mat = 1;
fea.crack_E = interp.E;
fea.crack_nu = 0.30;
fea.Phi=Final.interp_phi;
%values from input file if available
fea.inp_exists = 'yes';
fea.BCvalue = [];
fea.base_E_fea = interp.E;
fea.base_nu_fea = 0.30;
fea.haz_E_fea = [];
fea.haz_nu_fea = [];
fea.weld_E_fea = [];
fea.weld_nu_fea = [];
fea.base_se_fea = [Sys_pick, n_pick]; %include Sys and n for LPPL model
fea.haz_se_fea = [];
fea.weld_se_fea = [];
%add flag to show that solution is interpolated solution
fea.interp_exists = 1;
%----------------------------------------------
%if extrapolation is requested perfom additional interpolations to
%extrapolate solution to desired CMOD
if interp.extrap_flag == 1
    extrap_cmod_val = fea.CMOD(end)*interp.extrap_factor;
    fea.extrap_cmod_val = extrap_cmod_val;
    fea.num_steps = fea.num_steps+1;
    extrap_j = zeros(size(fea.Phi));
    extrap_jel = zeros(size(fea.Phi));
    for i = 1:length(fea.Phi)
        X = fea.CMOD;
        Xi = extrap_cmod_val;
        Y = fea.Jtotal_Avg(i,:);
        Y2 = fea.Jel_EPFM(i,:);
        extrap_j(i)= interp1(X,Y,Xi,'linear','extrap' );
        extrap_jel(i)= interp1(X,Y2,Xi,'linear','extrap' );
    end
    extrap_j = extrap_j';
    extrap_jel = extrap_jel';
    fea.Jtotal_Avg = [fea.Jtotal_Avg, extrap_j];
    fea.Jel_EPFM = [fea.Jel_EPFM, extrap_jel];
    %
    Y3 = fea.St_far;
    Y4 = fea.reac_force;
    %perform F = a*x^b + c power law fit to force CMOD data
    %use last 5 points for fit
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xdata = X(end-4:end)';
    ydata = Y4(end-4:end)';
    %%%%%%%%%%%%%%%%%%%%%
    %code below uses Curve Fiting toolbox
    pl_fit = fit(xdata, ydata,'power2');
    extrap_reac_force = pl_fit(Xi);
    %calculate area (mult_factor) to convert force to stress so only have
    %to do perform one curve fit
    mult_factor = Y3(1)/Y4(1);
    extrap_St_far = mult_factor*extrap_reac_force;
    fea.St_far = [fea.St_far; extrap_St_far];
    fea.reac_force = [fea.reac_force, extrap_reac_force];
    fea.CMOD = [fea.CMOD, Xi];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end