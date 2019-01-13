function plt_crk_front_condition_int(result, interp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*update* *V1.0.2* 06/6/14
%new plot for V1.0.2
%plot crack front deformation and constraint conditions
%Get data from Result and interp for plotting
predict_test = result.predict_test;
eval_test = result.eval_test;
if predict_test == 1 || eval_test == 1
    phi_tear = result.tear_angle;
else
    phi_tear = 30.0; %set equal to 30 deg. for generic plot without test data
end
Sys = interp.Sys;
if strcmp(result.fea.moment_flag, 'no')
    St = result.fea.St_far;
else
    St = result.fea.S_bend;
end
num_steps = result.fea.num_steps;
norm_T_stress = result.fea.norm_T_stress;
%calculate T/Sys vs phi for all load steps
for i=1:num_steps
    ToverSys(i,:) = norm_T_stress.*St(i)./Sys; %#ok<AGROW>
end

% Jt = result.fea.Jtotal_Avg;
phi_fea = result.fea.Phi;
%Jel = result.fea.Jel_EPFM;
M_epfm_a = result.fea.M_epfm_a;
M_epfm_b = result.fea.M_epfm_b;
CK = result.fea.CK;
CJa = result.fea.CJa;
CJb = result.fea.CJb;
M_epfm_a_tear = result.fea.M_epfm_a_tear;
M_epfm_b_tear = result.fea.M_epfm_b_tear;
%J_tear_phi = result.fea.J_tear_phi;
%Jel_tear_phi = result.fea.Jel_tear_phi;
%calc percent J plastic
%Jpl_per = 100*(Jt-Jel)./Jt;
%find phi result closest to phi_tear
[~,I] = min(abs(phi_fea-phi_tear));
phi_str = num2str(phi_fea(I), '%5.2f');

%semilogy(ToverSys(:,I), (1./M_epfm_a(I,:)),'-ob')
plot(ToverSys(:,I), (1./M_epfm_a(I,:)),'-ob')
xlabel('T-Stress/\sigma_{ys}');
ylabel('J/(r*\sigma_{ys}) = 1/C');
%    title('EPFM Deformation Measure - FEA');
hold on

%semilogy(ToverSys(:,I), (1./M_epfm_b(I,:)),'-or','MarkerFaceColor','r')
plot(ToverSys(:,I), (1./M_epfm_b(I,:)),'-or','MarkerFaceColor','r')
str1 = strcat('r_{\phia} \phi =', phi_str);
str2 = strcat('r_{\phib} \phi =', phi_str);
str3 = 'r_{\phia} \phi = 90.0';
str4 = 'r_{\phib} \phi = 90.0';
str5 = '1/C_K';
str6 = '1/C_{Ja}';
str7 = '1/C_{Jb}';
str8 = 'Tearing Load';
L = size(phi_fea,2);
%semilogy(ToverSys(:,L),(1./M_epfm_a(L,:)),'-sb')
%semilogy(ToverSys(:,L), (1./M_epfm_b(L,:)),'-sr','MarkerFaceColor','r')
%plot(ToverSys(:,L),(1./M_epfm_a(L,:)),'-sb')
plot(ToverSys(:,L),(1./M_epfm_a(L,:)),'-s','color', [.7,.7,.7])
%plot(ToverSys(:,L), (1./M_epfm_b(L,:)),'-sr','MarkerFaceColor','r')
plot(ToverSys(:,L), (1./M_epfm_b(L,:)),'-s','color', [.7,.7,.7],'MarkerFaceColor',[.7,.7,.7])
min1 = min(ToverSys(:,I));
min2 = min(ToverSys(:,L));
min3 = -1.0;
mini =[min1,min2,min3];
minimum = min(mini);
max1 = max(ToverSys(:,I));
max2 = max(ToverSys(:,L));
max3 = 0.5;
maxi = [max1,max2,max3];
maximum = max(maxi);
y = [1/CK 1/CK];
x = [minimum maximum];
y2 = [1/CJa 1/CJa];
y3 = [1/CJb 1/CJb];
% semilogy(x,y,':k')
% semilogy(x,y2,'--b')
% semilogy(x,y3,'-.r')
plot(x,y,':k')
plot(x,y2,'--b')
plot(x,y3,'-.r')
if M_epfm_a_tear ~= 0
    y3 = [1./M_epfm_a_tear(I)  1./M_epfm_b_tear(I) ];
    T_Sys_tear = result.fea.T_stress_tear./Sys;
    x3 = [T_Sys_tear(I)  T_Sys_tear(I) ];
    %semilogx(x3,y3,'pk', 'MarkerFaceColor','g','MarkerSize', 11);
    plot(x3,y3,'pk', 'MarkerFaceColor','g','MarkerSize', 11);
    legend_text = {str1, str2, str3, str4, str5, str6, str7, str8};
else
    legend_text = {str1, str2, str3, str4, str5, str6, str7};
end
legend(legend_text, 'Location', 'NorthEast');
%set(gca,'XLim',[1 Inf])
%set(gca,'YLim',[0 maximum*1.05])
hold off
