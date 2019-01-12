function plt_J_CMOD_fea_int(result)

% Get data from Result to plot easier

Jt = result.fea.Jtotal_Avg;
phi_fea = result.fea.Phi;
tear_CMOD_analysis  = result.fea.tear_CMOD_analysis;
CMOD = result.fea.CMOD;
Jel = result.fea.Jel_EPFM;
predict_test = result.predict_test;
eval_test = result.eval_test;

%x_str = 'CMOD (in)';

%find phi result closest to phi_tear
%if tear_CMOD_analysis ~= 0
if predict_test == 1 || eval_test == 1 ;
    phi_tear = result.tear_angle;
else
    phi_tear = 30.0; %set equal to 30 deg. for generic plot without test data
end
    [C,I] = min(abs(phi_fea-phi_tear));
    phi_str = num2str(phi_fea(I), '%5.2f');
    %calculate LEFM CMOD values corresponding to FEA load values for each step
    if strcmp(result.fea.moment_flag, 'no')
        fea_force = result.fea.reac_force;
    else
        fea_force = result.fea.moment;
    end

for i = 1:size(fea_force,2)
    LEFM_CMOD(i) = CMOD(1)*fea_force(i)/fea_force(1);
end
% factor = 3.0;
% tmp_LEFM_CMOD = LEFM_CMOD.*factor;
% tmp_Jel = Jel.*factor^2;
%create plots
plot(CMOD,Jel(I,:),'--or','MarkerFaceColor','r')
   ylabel(result.J_str);
    xlabel(result.CMOD_str); 
%    title('J_{total} and J_{elastic} vs. CMOD - FEA');
    hold on
    
 plot(CMOD,Jt(I,:),'-sr','MarkerFaceColor','r')
 str1 = strcat('J_{el} \phi =', phi_str);
 str2 = strcat('J_{total} \phi =', phi_str);
 str3 = 'J_{el} \phi = 90.0';
 str4 = 'J_{total} \phi = 90.0';
 str5 = 'Tearing CMOD';
 str6 = strcat('LEFM \phi =', phi_str);
 %
%*update* *V1.0.2* 06/10/14
%change phi = 90 results to gray color
 L = size(phi_fea,2);
 plot(CMOD,Jel(L,:),'--o','color', [.7,.7,.7])
 plot(CMOD,Jt(L,:),'-s','color', [.7,.7,.7])
%  plot(CMOD,Jel(L,:),'--ob')
%  plot(CMOD,Jt(L,:),'-sb')
 %plot LEFM based solution
 %plot(LEFM_CMOD,Jel(I,:),':+g')
 
 if tear_CMOD_analysis ~= 0
    x = [tear_CMOD_analysis tear_CMOD_analysis];
    y2 = max(max(Jt(I,:), Jt(L,:)));
    y = [0 y2];
    plot(x,y,'--k');
     legend_text = {str1, str2, str3, str4, str5};
     %legend_text = {str1, str2, str3, str4, str6, str5};
else
    legend_text = {str1, str2, str3, str4};
    %legend_text = {str1, str2, str3, str4, str6};
 end

    legend(legend_text, 'Location', 'NorthWest');
   hold off
   

 


   