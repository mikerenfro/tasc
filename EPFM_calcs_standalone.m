%-----------------------------------------------------------------
% function to perform EPFM calculations after
% reading in EPFM FEA results
%-----------------------------------------------------------------

function [handles]= EPFM_calcs_standalone(handles)
%set units conversion factors
%force factor
ff = handles.interp.ff;
%J factor
jf = handles.interp.jf;
%
%define variables
tear_load_type = 2; % 2 for tension loading, 3 for bending loading
a = handles.result.fea.a;
c = handles.result.fea.c;
width = handles.result.fea.width;
B = handles.result.fea.B;
num_steps = handles.result.fea.num_steps;
%St = handles.result.fea.St_far;
if strcmp(handles.result.fea.moment_flag, 'no')
    St = handles.result.fea.St_far;
else
    St = handles.result.fea.S_bend;
end
reac_force = handles.result.fea.reac_force;
Jt = handles.result.fea.Jtotal_Avg;
Jel = handles.result.fea.Jel_EPFM;
CMOD = handles.result.fea.CMOD;
phi = handles.result.fea.Phi;
Sys = handles.interp.Sys;
E = handles.interp.E;
e_ys = Sys/E;
% nu = handles.result.fea.crack_nu;
Jtear_calc_method = 2; %CMOD MATCHING

CK = E/Sys;
CJa = 15;
CJb = (1/20)*E/Sys+50;
err_factor = handles.interp.err_factor; %default 5% error factor on load
%change from percent to decimal
err_factor = err_factor/100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate characteristic lengths
%for a surface crack in a flat plate
phi = phi';
%change the last value of phi = 90 deg to slightly smaller number
%to avoid numerical singularity
phi(end) = phi(end)*0.9999;
x_phi = c.*cosd(phi);
y_phi = a.*sind(phi);
m = y_phi.*c^2./(x_phi.*a^2);
x_int = x_phi-a^2.*cosd(phi)./c;
x_top = x_phi+(B-y_phi)./m;
y_side = y_phi+m.*(B-x_phi);
xe = zeros(length(phi),1);
ye = zeros(length(phi),1);
r_phi_a = zeros(length(phi),1);
r_phi_b = zeros(length(phi),1);
x_cja = zeros(1, length(phi));
y_cja = zeros(1, length(phi));
x_cjb = zeros(1, length(phi));
y_cjb = zeros(1, length(phi));
for i = 1:length(phi)
    if x_top(i) >= width/2
        xe(i) = width/2;
        ye(i) = y_side(i);
    else
        xe(i) = x_top(i);
        ye(i) = B;
    end
    r_phi_a(i) = ((x_phi(i)-x_int(i))^2+y_phi(i)^2)^(0.5);
    r_phi_b(i) = ((xe(i)-x_phi(i))^2+(ye(i)-y_phi(i))^2)^(0.5);
    %Calculate specimen size needed to meet length scale requirements
    theta = atan(y_phi(i)/(x_phi(i)-x_int(i)));
    dxb = CJb*Jt(i,num_steps)./(Sys*1000)*cos(theta);
    dyb = CJb*Jt(i,num_steps)./(Sys*1000)*sin(theta);
    x_cjb(i) = x_phi(i)+dxb;
    y_cjb(i) = y_phi(i)+dyb;
    %
    dxa = CJa*Jt(i,num_steps)./(Sys*1000)*cos(theta);
    dya = CJa*Jt(i,num_steps)./(Sys*1000)*sin(theta);
    x_cja(i) = x_phi(i)-dxa;
    y_cja(i) = y_phi(i)-dya;
end
%calculate deformation factors "M" for all phi and load steps
%matrix is width = steps and height = fea phi increments
M_lefm_a = zeros(length(phi), num_steps);
M_lefm_b = zeros(length(phi), num_steps);
M_epfm_a = zeros(length(phi), num_steps);
M_epfm_b = zeros(length(phi), num_steps);
for i=1:length(phi)
    %note "1000" factor is to get J units from in-lb/in^2 to kip-lb/in^2
    M_lefm_a(i,:) = 1000*r_phi_a(i)*Sys*e_ys./Jt(i,:).*jf;
    M_lefm_b(i,:) = 1000*r_phi_b(i)*Sys*e_ys./Jt(i,:).*jf;
    M_epfm_a(i,:) = 1000*r_phi_a(i)*Sys./Jt(i,:).*jf;
    M_epfm_b(i,:) = 1000*r_phi_b(i)*Sys./Jt(i,:).*jf;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%determine if EPFM validity criteria is met for all phi and load steps
EPFM_valid_a = cell(length(phi), num_steps);
for i=1:length(phi)
    for j=1:num_steps
        if M_epfm_a(i,j) >= CJa
            EPFM_valid_a{i,j} = 'yes';
        else
            EPFM_valid_a{i,j} = 'no';
        end
    end
end
%
EPFM_valid_b = cell(length(phi), num_steps);
for i=1:length(phi)
    for j=1:num_steps
        if M_epfm_b(i,j) >= CJb
            EPFM_valid_b{i,j} = 'yes';
        else
            EPFM_valid_b{i,j} = 'no';
        end
    end
end
%
%%
%*****************************************************************
%NOTE on Jan 1, 2012 I changed the interpolation method from "cubic" to
%"linear" for the interp routines in this section.  This will result in a
%small change in the interpolated values for J.  I felt more confident the
%linear relationship between J-CMOD and I felt that the linear interp would
%not give me any unwanted suprises.
%*****************************************************************
%interpolate to find the values of J-phi for
%FEA CMOD = Test tear CMOD or FEA load = tear load
test_CMOD = handles.testdata.CMOD;
test_force = handles.testdata.force;
%
%initalize values to zero for logical check later when plotting
handles.result.fea.J_tear_phi = 0;
handles.result.fea.Jel_tear_phi = 0;
if handles.interp.cb_test_predict ~= 1
    handles.result.tear_CMOD = 0;
end
handles.result.fea.tear_CMOD_analysis = 0;
handles.result.fea.tear_reac_force_analysis = 0;
handles.result.fea.tear_moment_analysis = 0;
handles.result.fea.x_cjb_tear = 0;
handles.result.fea.y_cjb_tear = 0;
handles.result.fea.x_cja_tear = 0;
handles.result.fea.y_cja_tear = 0;
handles.result.fea.M_lefm_a_tear = 0;
handles.result.fea.M_lefm_b_tear = 0;
handles.result.fea.M_epfm_a_tear = 0;
handles.result.fea.M_epfm_b_tear = 0;
handles.result.fea.EPFM_valid_a_tear = 0;
handles.result.fea.EPFM_valid_b_tear = 0;
handles.result.fea.J_T_norm_tear = 0;
handles.result.fea.tear_loc_tear = 0;
%
%if bending problem convert tearing moment to force
%to use in test data table interp. to find tear CMOD
if (strcmp(handles.result.fea.moment_flag, 'yes')...
        && handles.testdata.Souter ~= 0 ...
        && handles.testdata.Sinner ~= 0 ...
        && handles.in.tear_load_type == 3)
    tear_force = 4*handles.result.tear_load/...
        (handles.testdata.Souter-handles.testdata.Sinner);
    %convert moment reactions from FEM to forces
    moment = handles.result.fea.moment;
    for j = 1:length(moment)
        reac_force(j) = 4.*moment(j)./(handles.testdata.Souter-handles.testdata.Sinner);
    end
else
    tear_force = handles.result.tear_load;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%only do the next set of code if the tear force data exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if handles.interp.cb_eval_test == 1
    %find maximum value and index max value of test force
    %truncate test force data to ensure not matching CMOD values to unloading
    %data
    %tear_CMOD and tear_force are the test data force and CMOD at tearing
    [val,ind] = max(test_force);
    [C,I] = min(abs(test_force(1:ind)-tear_force));
    if (val >= tear_force || C <= val*0.01 )
        trunc_force = test_force(1:ind);
        trunc_CMOD  = test_CMOD(1:ind);
        tear_CMOD = interp1(trunc_force(I-10:end),trunc_CMOD(I-10:end),tear_force,'linear');
        %%%%%%%%%%%%%%
        %Now determine which method to use to calculate J at tearing and apply the
        %appropriate logic
        %if Jtear_calc_method = 1 use "L bracket method of min of CMOD or Force
        %if Jtear_calc_method = 2 calc J at CMOD tearing
        if Jtear_calc_method == 1
            %determine Min CMOD to use in interploation routine by calculating
            %FEA CMOD corresponding to tearing load and comparing to tear_CMOD
            %from test data.  This way we do not allow load or CMOD to exceed
            %max. tear values
            
            CMOD_FEA_TearLoad = interp1(reac_force,CMOD,tear_force,'linear','extrap');
            tear_CMOD_analysis = min(tear_CMOD, CMOD_FEA_TearLoad);
            tear_reac_force_analysis = interp1(CMOD,reac_force,tear_CMOD_analysis,'linear','extrap');
        else
            %calculate J at CMOD tearing
            tear_CMOD_analysis = tear_CMOD;
            tear_reac_force_analysis = interp1(CMOD,reac_force,tear_CMOD_analysis,'linear','extrap');
        end
        if (strcmp(handles.result.fea.moment_flag, 'yes')...
                && handles.testdata.Souter ~= 0 ...
                && handles.testdata.Sinner ~= 0 ...
                && handles.in.tear_load_type == 3)
            tear_moment_analysis = (handles.testdata.Souter-handles.testdata.Sinner)*...
                tear_reac_force_analysis/4;
            handles.result.fea.tear_moment_analysis = tear_moment_analysis;
        end
        % use GoAhead variable to determine if calculated values for FEA CMOD and
        % force at tearing are in validity limits
        GoAhead = 0;
        if Jtear_calc_method == 1 && tear_CMOD_analysis <= tear_CMOD*1.01...
                && tear_CMOD_analysis >= (1-err_factor)*tear_CMOD...
                && tear_reac_force_analysis <= tear_force*1.01...
                && tear_reac_force_analysis >= (1-err_factor)*tear_force
            GoAhead = 1;
        elseif Jtear_calc_method == 2 && tear_CMOD_analysis <= tear_CMOD*1.01...
                && tear_reac_force_analysis <= tear_force*(1+err_factor)...
                && tear_reac_force_analysis >= (1-err_factor)*tear_force
            GoAhead = 1;
        end
        
        if GoAhead == 1
            J_tear_phi = zeros(1,length(phi));
            Jel_tear_phi = zeros(1,length(phi));
            x_cja_tear = zeros(1,length(phi));
            y_cja_tear = zeros(1,length(phi));
            x_cjb_tear = zeros(1,length(phi));
            y_cjb_tear = zeros(1,length(phi));
            M_lefm_a_tear = zeros(1,length(phi));
            M_lefm_b_tear = zeros(1,length(phi));
            M_epfm_a_tear = zeros(1,length(phi));
            M_epfm_b_tear = zeros(1,length(phi));
            EPFM_valid_a_tear = cell(1,length(phi));
            EPFM_valid_b_tear = cell(1,length(phi));
            for i = 1:length(phi)
                %if necessary allow 1% CMOD extrapolation to calculate J tear
                if max(CMOD)*1.01 >= tear_CMOD
                    J_tear_phi(i) = interp1(CMOD,Jt(i,:),tear_CMOD_analysis,'linear','extrap');
                    Jel_tear_phi(i) = interp1(CMOD,Jel(i,:),tear_CMOD_analysis,'linear','extrap');
                else
                    J_tear_phi(i) = interp1(CMOD,Jt(i,:),tear_CMOD_analysis,'linear',0);
                    Jel_tear_phi(i) = interp1(CMOD,Jel(i,:),tear_CMOD_analysis,'linear',0);
                end
                %calculate length scales for tearing load
                %Calculate specimen size needed to meet length scale requirements
                theta = atan(y_phi(i)/(x_phi(i)-x_int(i)));
                dxbt = CJb*J_tear_phi(i)./(Sys*1000)*cos(theta);
                dybt = CJb*J_tear_phi(i)./(Sys*1000)*sin(theta);
                x_cjb_tear(i) = x_phi(i)+dxbt;
                y_cjb_tear(i) = y_phi(i)+dybt;
                %
                dxat = CJa*J_tear_phi(i)./(Sys*1000)*cos(theta);
                dyat = CJa*J_tear_phi(i)./(Sys*1000)*sin(theta);
                x_cja_tear(i) = x_phi(i)-dxat;
                y_cja_tear(i) = y_phi(i)-dyat;
                
                %note "1000" factor is to get J units from in-lb/in^2 to kip-lb/in^2
                M_lefm_a_tear(i) = 1000*r_phi_a(i)*Sys*e_ys./J_tear_phi(i).*jf;
                M_lefm_b_tear(i) = 1000*r_phi_b(i)*Sys*e_ys./J_tear_phi(i).*jf;
                M_epfm_a_tear(i) = 1000*r_phi_a(i)*Sys./J_tear_phi(i).*jf;
                M_epfm_b_tear(i) = 1000*r_phi_b(i)*Sys./J_tear_phi(i).*jf;
                
                if M_epfm_a_tear(i) >= CJa
                    EPFM_valid_a_tear{i} = 'yes';
                else
                    EPFM_valid_a_tear{i} = 'no';
                end
                
                if M_epfm_b_tear(i) >= CJb
                    EPFM_valid_b_tear{i} = 'yes';
                else
                    EPFM_valid_b_tear{i} = 'no';
                end
            end
            handles.result.fea.J_tear_phi = J_tear_phi;
            handles.result.fea.Jel_tear_phi = Jel_tear_phi;
            handles.result.fea.x_cjb_tear = x_cjb_tear;
            handles.result.fea.y_cjb_tear = y_cjb_tear;
            handles.result.fea.x_cja_tear = x_cja_tear;
            handles.result.fea.y_cja_tear = y_cja_tear;
            handles.result.tear_CMOD = tear_CMOD;
            handles.result.fea.tear_CMOD_analysis = tear_CMOD_analysis;
            handles.result.fea.tear_reac_force_analysis = tear_reac_force_analysis;
            handles.result.fea.M_lefm_a_tear = M_lefm_a_tear;
            handles.result.fea.M_lefm_b_tear = M_lefm_b_tear;
            handles.result.fea.M_epfm_a_tear = M_epfm_a_tear;
            handles.result.fea.M_epfm_b_tear = M_epfm_b_tear;
            handles.result.fea.EPFM_valid_a_tear = EPFM_valid_a_tear;
            handles.result.fea.EPFM_valid_b_tear = EPFM_valid_b_tear;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if handles.interp.cb_test_predict == 1
    tear_CMOD_analysis = handles.result.tear_CMOD;
    tear_reac_force_analysis = handles.result.tear_load;
    for i = 1:length(phi)
        J_tear_phi(i) = interp1(CMOD,Jt(i,:),tear_CMOD_analysis,'linear',0);
        Jel_tear_phi(i) = interp1(CMOD,Jel(i,:),tear_CMOD_analysis,'linear',0);
        
        %calculate length scales for tearing load
        %Calculate specimen size needed to meet length scale requirements
        theta = atan(y_phi(i)/(x_phi(i)-x_int(i)));
        dxbt = CJb*J_tear_phi(i)./(Sys*1000)*cos(theta);
        dybt = CJb*J_tear_phi(i)./(Sys*1000)*sin(theta);
        x_cjb_tear(i) = x_phi(i)+dxbt;
        y_cjb_tear(i) = y_phi(i)+dybt;
        %
        dxat = CJa*J_tear_phi(i)./(Sys*1000)*cos(theta);
        dyat = CJa*J_tear_phi(i)./(Sys*1000)*sin(theta);
        x_cja_tear(i) = x_phi(i)-dxat;
        y_cja_tear(i) = y_phi(i)-dyat;
        
        %note "1000" factor is to get J units from in-lb/in^2 to kip-lb/in^2
        M_lefm_a_tear(i) = 1000*r_phi_a(i)*Sys*e_ys./J_tear_phi(i).*jf;
        M_lefm_b_tear(i) = 1000*r_phi_b(i)*Sys*e_ys./J_tear_phi(i).*jf;
        M_epfm_a_tear(i) = 1000*r_phi_a(i)*Sys./J_tear_phi(i).*jf;
        M_epfm_b_tear(i) = 1000*r_phi_b(i)*Sys./J_tear_phi(i).*jf;
        
        if M_epfm_a_tear(i) >= CJa
            EPFM_valid_a_tear{i} = 'yes';
        else
            EPFM_valid_a_tear{i} = 'no';
        end
        
        if M_epfm_b_tear(i) >= CJb
            EPFM_valid_b_tear{i} = 'yes';
        else
            EPFM_valid_b_tear{i} = 'no';
        end
        
        
    end
    handles.result.fea.J_tear_phi = J_tear_phi;
    handles.result.fea.Jel_tear_phi = Jel_tear_phi;
    handles.result.fea.x_cjb_tear = x_cjb_tear;
    handles.result.fea.y_cjb_tear = y_cjb_tear;
    handles.result.fea.x_cja_tear = x_cja_tear;
    handles.result.fea.y_cja_tear = y_cja_tear;
    %handles.result.tear_CMOD = tear_CMOD;
    handles.result.fea.tear_CMOD_analysis = tear_CMOD_analysis;
    handles.result.fea.tear_reac_force_analysis = tear_reac_force_analysis;
    handles.result.fea.M_lefm_a_tear = M_lefm_a_tear;
    handles.result.fea.M_lefm_b_tear = M_lefm_b_tear;
    handles.result.fea.M_epfm_a_tear = M_epfm_a_tear;
    handles.result.fea.M_epfm_b_tear = M_epfm_b_tear;
    handles.result.fea.EPFM_valid_a_tear = EPFM_valid_a_tear;
    handles.result.fea.EPFM_valid_b_tear = EPFM_valid_b_tear;
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate constraint corrected tearing location estimate using the
%phi location where the equation J/Jmax*(T/Sys+1) is maximum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%call normalized T-Stress caculation function and calculate norm. T vs. Phi
% for all phi
aB = a/B;
ac = a/c;
for i=1:length(phi)
    handles.result.fea.norm_T_stress(i) = T_stress_calc_int(aB,phi(i),...
        ac,tear_load_type);
end
if handles.interp.cb_test_predict == 1 || handles.interp.cb_eval_test == 1 && handles.result.fea.tear_CMOD_analysis ~= 0
    tear_stress = (tear_reac_force_analysis/(B*width))/ff;
    handles.result.fea.T_stress_tear = handles.result.fea.norm_T_stress.*tear_stress;
    handles.result.fea.T_over_Sys = handles.result.fea.T_stress_tear./Sys;
    final_stress  = St(end);
    handles.result.fea.T_stress_final = handles.result.fea.norm_T_stress.*final_stress;
    handles.result.fea.T_final_over_Sys = handles.result.fea.T_stress_final./Sys;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %first set NaN values at 0 deg equal to 5 deg values for closed form
    %solution set
    %Phi_cf = handles.result.phi; %closed form solution Phi increment
    Tn_cf = handles.result.fea.T_over_Sys;
    Tn_cf_final = handles.result.fea.T_final_over_Sys;
    %get rid of NaN values for phi < 5 deg. by setting values equal to
    %value immediately past 5 deg.
    [~,I] = min(abs(handles.result.fea.Phi-5));
    for i = 1:I
        Tn_cf(i) = Tn_cf(I+1);
        Tn_cf_final(i) = Tn_cf_final(I+1);
    end
    
    J_T_norm_last = zeros(1,length(handles.result.fea.Phi));
    J_T_norm_tear = zeros(1,length(handles.result.fea.Phi));
    for i = 1:length(handles.result.fea.Phi)
        %T_norm = interp1(Phi_cf,Tn_cf,handles.result.fea.Phi(i));
        T_norm = Tn_cf(i);
        if T_norm < -1.0
            T_factor = 0.0; %Do not let T/Sys go below -1
        elseif T_norm <= 0
            T_factor = 1.0*T_norm+1; %linear T/Sys factor
        else
            T_factor = .25*T_norm+1; %linear T/Sys factor for positive T regions
        end
        T_norm_final = Tn_cf_final(i);
        if T_norm_final < -1.0
            T_factor_final = 0.0; %Do not let T/Sys go below -1
        elseif T_norm_final <= 0
            T_factor_final = 1.0*T_norm_final+1; %linear T/Sys factor
        else
            T_factor_final = .25*T_norm_final+1; %linear T/Sys factor for positive T regions
        end
        
        %      T_factor = -0.20*(T_norm^2)+0.25*(T_norm)+1; %poly factor based on norm opening stress
        J_T_norm_last(i) = Jt(i,end)/max(Jt(:,end))*(T_factor_final);
        if handles.result.fea.J_tear_phi ~= 0
            J_T_norm_tear(i) = J_tear_phi(i)/max(J_tear_phi)*...
                (T_factor);
        end
    end
    [~,ind_l] = max(J_T_norm_last);
    tear_loc_last = phi(ind_l);
    handles.result.fea.J_T_norm_last = J_T_norm_last;
    handles.result.fea.tear_loc_last = tear_loc_last;
    
    if handles.result.fea.J_tear_phi ~= 0
        [~,ind_t] = max(J_T_norm_tear);
        tear_loc_tear = phi(ind_t);
        handles.result.fea.J_T_norm_tear = J_T_norm_tear;
        handles.result.fea.tear_loc_tear = tear_loc_tear;
    end
else
    final_stress  = St(end);
    handles.result.fea.T_stress_final = handles.result.fea.norm_T_stress.*final_stress;
    handles.result.fea.T_final_over_Sys = handles.result.fea.T_stress_final./Sys;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %first set NaN values at 0 deg equal to 5 deg values for closed form
    %solution set
    %Phi_cf = handles.result.phi; %closed form solution Phi increment
    Tn_cf_final = handles.result.fea.T_final_over_Sys;
    %get rid of NaN values for phi < 5 deg. by setting values equal to
    %value immediately past 5 deg.
    [~,I] = min(abs(handles.result.fea.Phi-5));
    for i = 1:I
        Tn_cf_final(i) = Tn_cf_final(I+1);
    end
    
    J_T_norm_last = zeros(1,length(handles.result.fea.Phi));
    for i = 1:length(handles.result.fea.Phi)
        T_norm_final = Tn_cf_final(i);
        if T_norm_final < -1.0
            T_factor_final = 0.0; %Do not let T/Sys go below -1
        elseif T_norm_final <= 0
            T_factor_final = 1.0*T_norm_final+1; %linear T/Sys factor
        else
            T_factor_final = .25*T_norm_final+1; %linear T/Sys factor for positive T regions
        end
        %      T_factor = -0.20*(T_norm^2)+0.25*(T_norm)+1; %poly factor based on norm opening stress
        J_T_norm_last(i) = Jt(i,end)/max(Jt(:,end))*(T_factor_final);
    end
    [~,ind_l] = max(J_T_norm_last);
    tear_loc_last = phi(ind_l);
    handles.result.fea.J_T_norm_last = J_T_norm_last;
    handles.result.fea.tear_loc_last = tear_loc_last;
    
    
end

%%
%write data out to handles structure
handles.result.fea.r_phi_a=r_phi_a;
handles.result.fea.r_phi_b=r_phi_b;
handles.result.fea.M_lefm_a=M_lefm_a;
handles.result.fea.M_lefm_b=M_lefm_b;
handles.result.fea.M_epfm_a=M_epfm_a;
handles.result.fea.M_epfm_b=M_epfm_b;
handles.result.fea.x_cjb=x_cjb;
handles.result.fea.y_cjb=y_cjb;
handles.result.fea.x_cja=x_cja;
handles.result.fea.y_cja=y_cja;
handles.result.fea.EPFM_valid_a = EPFM_valid_a;
handles.result.fea.EPFM_valid_b = EPFM_valid_b;
handles.result.fea.CK = CK;
handles.result.fea.CJa = CJa;
handles.result.fea.CJb = CJb;
%If extrapolation is activated update gui extrap CMOD string here
%so will update with any GUI inputchange
if handles.interp.extrap_flag == 1
    rpl_string2 = ['Extrap. CMOD = ',num2str(handles.result.fea.extrap_cmod_val, '%8.5f')];
    set(handles.txt_i_extrap_CMOD, 'String', rpl_string2);
end
%ensure that E/Sys on screen is updated even if material properties are not changed
EoverSys = E/Sys;
rpl_string = ['E/Sys = ',num2str(EoverSys, '%7.2f')];
set(handles.txt_i_EoverSys, 'string', rpl_string);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end