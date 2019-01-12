 function plt_J_T_norm_phi_fea_int(result)

% Get data from Result to plot easier
phi_fea = result.fea.Phi;
phi_tear = result.tear_angle;
J_T_norm_tear = result.fea.J_T_norm_tear;
J_T_norm_last = result.fea.J_T_norm_last;
tear_loc_tear = result.fea.tear_loc_tear;
phi_str_tear = num2str(tear_loc_tear, '%5.2f');
tear_loc_last = result.fea.tear_loc_last;
phi_str_last = num2str(tear_loc_last, '%5.2f');
J_tear = result.fea.J_tear_phi;
predict_test = result.predict_test;
eval_test = result.eval_test;

Jt = result.fea.Jtotal_Avg;
%find phi corresponding to Jmax for each load step
for i=1:size(Jt,2)
    [val,ind] = max(Jt(:,i));
    phi_jmax(i) = phi_fea(ind);  
end
num_steps = result.fea.num_steps;
if predict_test == 1 || eval_test == 1 ;
    %find phi result closest to phi_tear
    [C,I] = min(abs(phi_fea-phi_tear));
    %phi_str = num2str(phi_fea(I), '%5.2f');
    phi_str = num2str(phi_tear, '%5.2f');
    
    str1 = strcat('tear location at \phi =', phi_str);
 str2 = 'Final Analysis Step';
 str3 = strcat('Final step predicted tear at \phi =', phi_str_last);
 str4 = 'Analysis Tear Point';
 str5 = strcat('Tear point predicted tear at \phi =', phi_str_tear);
 str6 = '5% deviation from max.';
% create line at phi = phi tear
x = [phi_tear phi_tear];
y = [0 max(max(J_T_norm_last),max(J_T_norm_tear))*1.02];
     plot(x,y,'--k');
     hold on

plot(phi_fea,J_T_norm_last,'--ob')
   ylabel('J/J_{max}*(T/Sys+1) or J/J_{max}*(0.25*T/Sys+1)');
    xlabel('\phi (deg.)'); 
%    title('Estimation of Tearing Phi Location - FEA');

x = [tear_loc_last tear_loc_last];
     plot(x,y,'--b');

  if J_tear(1) ~= 0
     plot(phi_fea,J_T_norm_tear,'--dr','MarkerFaceColor','r')
     x = [tear_loc_tear tear_loc_tear]; 
     plot(x,y,'--r');
     five_per = 0.95*max(J_T_norm_tear);
      plot([0,90],[five_per,five_per],':g');
     legend_text = {str1, str2, str3, str4, str5, str6};
 else
     five_per = 0.95*max(J_T_norm_last);
      plot([0,90],[five_per,five_per],':g');
     legend_text = {str1, str2, str3,str6}; 
  end
  %write text indicating Phi at Jmax
  %txtstring = num2str(phi_jmax(14), '% 5.2f');
%   txtstring = num2str(phi_jmax(end), '% 5.2f');
%   txtstring = strcat('Final \phi at J_{max} = ',txtstring); 
%   text(2,.1,txtstring,'HorizontalAlignment',...
%     'left','FontSize',10, 'BackgroundColor','w');
%  hold off
    legend(legend_text, 'Location', 'SouthEast');
   hold off
else
    plot(phi_fea,J_T_norm_last,'--ob')
    hold on
   ylabel('J/J_{max}*(T/Sys+1) or J/J_{max}*(0.25*T/Sys+1)');
    xlabel('\phi (deg.)');
     str2 = 'Final Analysis Step';
     str3 = strcat('Final step predicted tear at \phi =', phi_str_last);
    x = [tear_loc_last tear_loc_last];
    y = [0 max(J_T_norm_last)*1.02];
     plot(x,y,'--b');
   legend_text = {str2, str3};
   legend(legend_text, 'Location', 'SouthEast');
   hold off
end
 

   
   %print figure to emf file and save fig file    
%     filename = strcat(FilePrefix, '_Jk');
%     print_file = strcat(pathname, '\', filename);
%     print(gcf,'-dmeta','-r300',print_file);
%     FigFile = strcat(print_file, '.fig');
%     saveas(gcf, FigFile);