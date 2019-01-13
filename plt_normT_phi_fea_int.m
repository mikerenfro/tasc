function plt_normT_phi_fea_int(result)

% Get data from Result to plot easier

Tnorm_final = result.fea.T_final_over_Sys;
phi_fea = result.fea.Phi;
% Jt = result.fea.Jtotal_Avg;
% Jel = result.fea.Jel_EPFM;
% num_steps = result.fea.num_steps;
J_tear = result.fea.J_tear_phi;
% Jel_tear = result.fea.Jel_tear_phi;
% CMOD_tear = result.tear_CMOD;
% tear_CMOD_analysis  = result.fea.tear_CMOD_analysis;
if ~isempty(result.tear_angle)
    phi_tear = result.tear_angle;
else
    phi_tear = 30.0; %set equal to 30 deg. for generic plot without test data
end
%find phi result closest to phi_tear
%[C,I] = min(abs(phi_fea-phi_tear));
%phi_str = num2str(phi_fea(I), '%5.2f');
phi_str = num2str(phi_tear, '%5.2f');

plot(phi_fea,Tnorm_final,'-ob')
ylabel('T-Stress/\sigma_{ys}');
xlabel('\phi (deg.)');
%    title('J_{total} and J_{elastic} vs. \phi at max. load - FEA');
hold on

str1 = 'Final Step';
str2 = 'Tear Point';
str3 = strcat('tear location at \phi =', phi_str);
% create line at phi = phi tear
x = [phi_tear phi_tear];
y = [min(Tnorm_final) max(Tnorm_final)];

if J_tear(1) ~= 0
    Tnorm_tear = result.fea.T_over_Sys;
    y = [min(min(Tnorm_final),min(Tnorm_tear)) max(max(Tnorm_final),max(Tnorm_tear))];
    plot(phi_fea,Tnorm_tear,'--sr','MarkerFaceColor','r')
    plot(x,y,'--k');
    legend_text = {str1, str2, str3};
elseif isempty(result.tear_angle)
    %plot(x,y,'--k');
    legend_text = {str1};
else
    plot(x,y,'--k');
    legend_text = {str1, str3};
end

%ylim([0 inf])
legend(legend_text, 'Location', 'best');
hold off

%print figure to emf file and save fig file
%     filename = strcat(FilePrefix, '_Jk');
%     print_file = strcat(pathname, '\', filename);
%     print(gcf,'-dmeta','-r300',print_file);
%     FigFile = strcat(print_file, '.fig');
%     saveas(gcf, FigFile);