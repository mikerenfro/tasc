function interp_to_fea_compare(interp)
%program to compare interpolated solution to
%a known FEA solution
%first open the *.mat file with the known FEA solution

[FileName1,PathName1] = uigetfile({'*.mat','Matlab data file (*.mat)'},'Select File');
if FileName1 == 0
    return;
end

FullFileName1 = strcat(PathName1,FileName1);
load(FullFileName1,'handles');
%
if get(handles.rb_tension, 'Value')==1
    fea = handles.result.fea;
else
    fea = handles.result_bending.fea;
end
%  aB_pick = fea.a/fea.B;
%  ac_pick = fea.a/fea.c;
W_fea = fea.width;
B_fea = fea.B;
a_fea = fea.a;
c_fea = fea.c;
% l_fea = fea.length;
phi_fea = fea.Phi;
CMOD_fea = fea.CMOD;
St_far_fea = fea.St_far;
St_net_fea = fea.St_net;
J_fea = fea.Jtotal_Avg;
Jel_fea = fea.Jel_EPFM;
Afar_fea = B_fea*W_fea;
Anet_fea = Afar_fea - 3.141592*a_fea*c_fea/2;
force_fea = fea.St_net*Anet_fea;
%interpolation variables
input = interp.interp_data.input;
if get(handles.rb_tension, 'Value')==1
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
%     interpolate_solution_SCGui(input,res,aB_pick,ac_pick,n_pick,E_Sys_pick);
%scale interpolated values to match fea inputs
%+++++++++++++++++++++++++++++++++++++++++++++
%calculate load values from net stress incremental values
Afar_interp = W_pick*B_pick;
Anet_interp = Afar_interp - 3.141592*interp.a*(interp.two_c/2)/2;
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
interp_force = Final.far_stress_inc.*Sys_pick.*Afar_interp;%based on far stress
interp_far_stress = Final.far_stress_inc*Sys_pick;
interp_net_stress = interp_far_stress*(Afar_interp/Anet_interp);
%%%%------------------------------------------------------------------
% interp_A_ratio = Anet_interp/Afar_interp;
%interp_force = Final.far_stress_inc.*Sys_pick.*Afar_interp*(interp_A_ratio/Final.A_ratio);%based on far stress*Area ratio
interp_Jtotal = Final.int_Jtotal.*Sys_pick.*B_pick;
interp_Jel = Final.int_Jel.*Sys_pick.*B_pick;
%+++++++++++++++++++++++++++++++++++++++++++++
%plot comparisons
%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

figure( 'Name','Force_vs_CMOD',...
    'NumberTitle','off','color', 'w');
hold on
plot(interp_CMOD, interp_force, '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

plot(CMOD_fea, force_fea, '-bs')

xlabel('CMOD');
ylabel('Force');
title('Force vs. CMOD');
hold off
%--------------------------------------------------------------

figure( 'Name','Snet_vs_CMOD',...
    'NumberTitle','off','color', 'w');
hold on
plot(interp_CMOD, interp_net_stress, '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

plot(CMOD_fea, St_net_fea, '-bs')

xlabel('CMOD');
ylabel('S_{net}');
title('Net Section Stress vs. CMOD');
hold off
%--------------------------------------------------------------
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

figure( 'Name','Sfar_vs_CMOD',...
    'NumberTitle','off','color', 'w');
hold on
plot(interp_CMOD, interp_far_stress, '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

plot(CMOD_fea, St_far_fea, '-bs')

xlabel('CMOD');
ylabel('S_{far}');
title('Far Field Stress vs. CMOD');
hold off
%---------------------------------------

figure( 'Name','Jtotal_vs_Snet',...
    'NumberTitle','off','color', 'w');
hold on
plot(interp_net_stress, interp_Jtotal(end,:),...
    '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

plot(St_net_fea, J_fea(end,:), '-bs')

xlabel('S_{net}');
ylabel('J_{total}');
title('J_{total} vs. S_{net} at phi = 90 deg');
hold off

%--------------------------------------------------------------
figure( 'Name','Jel_vs_Snet',...
    'NumberTitle','off','color', 'w');
hold on
plot(interp_net_stress, interp_Jel(end,:),...
    '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

plot(St_net_fea, Jel_fea(end,:), '-bs')

xlabel('S_{net}');
ylabel('J_{elastic}');
title('J_{el} vs. S_{net} at phi = 90 deg');
hold off
%--------------------------------------------------------------
figure( 'Name','Jtotal_vs_phi',...
    'NumberTitle','off','color', 'w');
hold on
plot(Final.interp_phi, interp_Jtotal(:,end),...
    '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

plot(phi_fea, J_fea(:,end), '-bs')
plot(phi_fea, J_fea(:,end-1), 'bs')

xlabel('Phi');
ylabel('J_{total}');
title('J_{total} vs. Phi at last load step');
hold off
%--------------------------------------------------------------
figure( 'Name','Jel_vs_phi',...
    'NumberTitle','off','color', 'w');
hold on
plot(Final.interp_phi, interp_Jel(:,end),...
    '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

plot(phi_fea, Jel_fea(:,end), '-bs')
plot(phi_fea, Jel_fea(:,end-1), 'bs')

xlabel('Phi');
ylabel('J_{el}');
title('J_{elastic} vs. Phi at last load step');
hold off
%%
%---------------------------------------------
%interpolate J solution at CMOD = CMOD final of FEA solution
%and create comparision plot
X = interp_CMOD;
Y = interp_Jtotal;
Xi = CMOD_fea(end);
J_at_CMOD = zeros(1,size(Final.interp_phi,2));
for i = 1:size(Final.interp_phi,2)
    J_at_CMOD(i) = interp1(X,Y(i,:),Xi,'linear', 'extrap');
end
%
figure( 'Name','Jtotal_vs_phi_CMOD',...
    'NumberTitle','off','color', 'w');
hold on
plot(Final.interp_phi, interp_Jtotal(:,end),...
    '-kp','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
plot(Final.interp_phi, J_at_CMOD,...
    '-ko','LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',8)

plot(phi_fea, J_fea(:,end), '-bs')
plot(phi_fea, J_fea(:,end-1), '-b+')

xlabel('Phi');
ylabel('J_{total}');
title('J_{total} vs. Phi at last load step');
legend('Interp final step', 'Interp CMOD match', 'FEA final step', 'FEA final-1',...
    'location', 'SouthEast');

hold off

end
