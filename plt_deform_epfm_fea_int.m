function plt_deform_epfm_fea_int(result)

%plot LEFM deformation limits
% Get data from Result to plot easier
predict_test = result.predict_test;
eval_test = result.eval_test;
if predict_test == 1 || eval_test == 1 ;
    phi_tear = result.tear_angle;
else
    phi_tear = 30.0; %set equal to 30 deg. for generic plot without test data
end
Jt = result.fea.Jtotal_Avg;
phi_fea = result.fea.Phi;
Jel = result.fea.Jel_EPFM;
M_epfm_a = result.fea.M_epfm_a;
M_epfm_b = result.fea.M_epfm_b;
CK = result.fea.CK;
CJa = result.fea.CJa;
CJb = result.fea.CJb;    
M_epfm_a_tear = result.fea.M_epfm_a_tear;
M_epfm_b_tear = result.fea.M_epfm_b_tear;
J_tear_phi = result.fea.J_tear_phi;
Jel_tear_phi = result.fea.Jel_tear_phi;
%calc percent J plastic
Jpl_per = 100*(Jt-Jel)./Jt;
%find phi result closest to phi_tear
[C,I] = min(abs(phi_fea-phi_tear));
phi_str = num2str(phi_fea(I), '%5.2f');

semilogx(M_epfm_a(I,:),Jpl_per(I,:),'-ob')
   ylabel('%J_{plastic}');
    xlabel('r*Sys/J'); 
%    title('EPFM Deformation Measure - FEA');
    hold on
  
 semilogx(M_epfm_b(I,:),Jpl_per(I,:),'-or','MarkerFaceColor','r')
 str1 = strcat('r_{\phia} \phi =', phi_str);
 str2 = strcat('r_{\phib} \phi =', phi_str);
 str3 = 'r_{\phia} \phi = 90.0';
 str4 = 'r_{\phib} \phi = 90.0';
 str5 = 'LEFM Deform Limit, C_K';
 str6 = 'EPFM Deform Limit, C_{Ja}';
 str7 = 'EPFM Deform Limit, C_{Jb}';
 str8 = 'Tearing Load Point';
%*update* *V1.0.2* 06/10/14
%change phi = 90 results to gray color  
 L = size(phi_fea,2);
 semilogx(M_epfm_a(L,:),Jpl_per(L,:),'-s','color', [.7,.7,.7])
 semilogx(M_epfm_b(L,:),Jpl_per(L,:),'-s','color', [.7,.7,.7],'MarkerFaceColor',[.7,.7,.7])
%  semilogx(M_epfm_a(L,:),Jpl_per(L,:),'-sb')
%  semilogx(M_epfm_b(L,:),Jpl_per(L,:),'-sr','MarkerFaceColor','r')
 max1 = max(Jpl_per(I,:));
 max2 = max(Jpl_per(L,:));
 maximum = max(max1,max2);
x = [CK CK];
y = [0 maximum];
x2 = [CJa CJa];
x3 = [CJb CJb];
semilogx(x,y,':k')
semilogx(x2,y,'--b')
semilogx(x3,y,'-.r')
if M_epfm_a_tear ~= 0
    x3 = [M_epfm_a_tear(I)  M_epfm_b_tear(I) ];
    %calc percent J plastic
    Jpl_per_tear = 100*(J_tear_phi-Jel_tear_phi)./J_tear_phi;
    y3 = [Jpl_per_tear(I)  Jpl_per_tear(I) ];
    semilogx(x3,y3,'pk', 'MarkerFaceColor','g','MarkerSize', 11);
    legend_text = {str1, str2, str3, str4, str5, str6, str7, str8};
else
    legend_text = {str1, str2, str3, str4, str5, str6, str7};
end
    legend(legend_text, 'Location', 'NorthEast');
%set(gca,'XLim',[1 Inf])
set(gca,'YLim',[0 maximum*1.05])
   hold off
   

 


   