function plt_K_phi_fea_int(result, interp)

% Get data from Result to plot easier
%force factor
ff = interp.ff;
%J factor
jf = interp.jf;
if result.units == 2 %SI units length factor for NR calc dimensions
    lf = 1/1000;
else 
    lf = 1;
end
%
St = result.fea.St_far;
Sb = result.fea.S_bend;
a = result.fea.a;
c = result.fea.c;
width = result.fea.width;
B = result.fea.B;
E = interp.E;
nu = 0.30;
%J to K factor
JKF = E/(1-nu^2)*1000;
phi_fea = result.fea.Phi;
Jt = result.fea.Jtotal_Avg;
Jel = result.fea.Jel_EPFM;
num_steps = result.fea.num_steps;
J_tear = result.fea.J_tear_phi;
Jel_tear = result.fea.Jel_tear_phi;
CMOD_tear = result.tear_CMOD;
tear_CMOD_analysis  = result.fea.tear_CMOD_analysis;
if ~isempty(result.tear_angle)
    phi_tear = result.tear_angle;
else
    phi_tear = 30.0; %set equal to 30 deg. for generic plot without test data
end
%find phi result closest to phi_tear
[C,I] = min(abs(phi_fea-phi_tear));
%phi_str = num2str(phi_fea(I), '%5.2f');
phi_str = num2str(phi_tear, '%5.2f');

plot(phi_fea,((Jel(:,num_steps).*JKF).^0.5)./1000,'--ob')
   ylabel(result.K_str);
    xlabel('\phi (deg.)'); 
%    title('J_{total} and J_{elastic} vs. \phi at max. load - FEA');
    hold on
    
 plot(phi_fea,((Jt(:,num_steps).*JKF).^0.5)./1000,'-sb','MarkerFaceColor','b')
 str1 = 'K_J_{el} Final Step';
 str2 = 'K_J_{total} Final Step';
 str3 = 'K_J_{el} @ Tear Point';
 str4 = 'K_J_{total} @ Tear Point';
 str5 = strcat('tear location at \phi =', phi_str);
 str6 = 'Newman-Raju Eq.';
% create line at phi = phi tear
x = [phi_tear phi_tear];
y = [0 max(((Jt(:,num_steps).*JKF).^0.5))./1000*1.02];


 if J_tear(1) ~= 0
     plot(phi_fea,((Jel_tear.*JKF).^0.5)./1000,'--dr')
     plot(phi_fea,((J_tear.*JKF).^0.5)./1000,'-^r','MarkerFaceColor','r')
     plot(x,y,'--k');
     %calc tear stress assuming tension
     St_tear = (result.tear_load/(B*width))/ff;
      %plot Newman Raju K solution
        KI_final = NR_calcs_int(a*lf,2*c*lf,width*lf,B*lf,...
        St_tear,0,phi_fea);
        plot(phi_fea,KI_final, '-.k', 'MarkerSize', 10);

     legend_text = {str1, str2, str3, str4, str5, str6};
 else if isempty(result.tear_angle)
     %plot(x,y,'--k');
      %plot Newman Raju K solution
        KI_final = NR_calcs_int(a*lf,2*c*lf,width*lf,B*lf,...
        St(end),Sb(end),phi_fea);
        plot(phi_fea,KI_final, '-.k');
     legend_text = {str1, str2, str6};
 else
     plot(x,y,'--k');
      %plot Newman Raju K solution
        KI_final = NR_calcs_int(a*lf,2*c*lf,width*lf,B*lf,...
        St(end),Sb(end),phi_fea);
        plot(phi_fea,KI_final, '-.k');
     legend_text = {str1, str2, str5, str6};
     end
      
 end


 ylim([0 inf])  
    legend(legend_text, 'Location', 'best');
   hold off
 
   
   %print figure to emf file and save fig file    
%     filename = strcat(FilePrefix, '_Jk');
%     print_file = strcat(pathname, '\', filename);
%     print(gcf,'-dmeta','-r300',print_file);
%     FigFile = strcat(print_file, '.fig');
%     saveas(gcf, FigFile);