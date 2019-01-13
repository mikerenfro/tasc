function plt_stress_CMOD_interp_int(testdata, result, interp)

% Get data from Result to plot easier
Sys = interp.Sys;
err_factor = interp.err_factor/100; %change to decimal from percent
CMOD = testdata.CMOD;
force = testdata.force;
% tear_CMOD_analysis  = result.fea.tear_CMOD_analysis;
a = result.fea.a;
c = result.fea.c;
width = result.fea.width;
B = result.fea.B;
%far area
af = B*width;
%net area
an = af-pi*a*2*c/4;
%set units conversion factors
%force factor
ff = interp.ff;
%far stress factor
fsf = (1/af)/ff;

%get data necessary to draw 5% error bands at tear CMOD
tear_force = result.tear_load;
str3 = 'Test Tearing Point';
rpl_string = [num2str(err_factor*100, '%2.1f'), '% Error Limits'];
str4 = rpl_string;
% load_type = testdata.load_type;
% Sinner = testdata.Sinner;
% Souter = testdata.Souter;
% tear_CMOD_analysis = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fea_force = result.fea.reac_force;
%fea_force = fea_force';

fea_CMOD = result.fea.CMOD;
%add 0 initial points to force and CMOD records
fea_force = [0.0 fea_force];
fea_CMOD = [0.0 fea_CMOD];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(fea_CMOD, fea_force*fsf,'-or');
hold on
%check to see if test data exists
if length(force) > 2
    plot(CMOD, force*fsf,'-b');
    legend_type = 1;
end
str2 = 'Test Record';
str1 = 'Interpolated Result';
%y_label = 'Stress (stress)';
ylabel(result.stress_str);
xlabel(result.CMOD_str);
%    legend_type = 3;
%     legend_text = {str1, str2};
%     legend(legend_text, 'Location', 'SouthEast');
%---------------------------------------------------------------
%tear point calculation and plot
%check to see if a tear force value exists
% if   tear_CMOD_analysis ~= 0 && interp.cb_eval_test == 1
%
%      tear_CMOD = result.tear_CMOD;
if ~isempty(tear_force)
    [val,ind] = max(force);
    [C,I] = min(abs(force(1:ind)-tear_force));
    if (val >= tear_force || C <= val*0.01 )
        legend_type = 2;
        trunc_force = force(1:ind);
        trunc_CMOD  = CMOD(1:ind);
        tear_CMOD = interp1(trunc_force(I-10:end),trunc_CMOD(I-10:end),tear_force,'pchip');
        
        plot(tear_CMOD, tear_force*fsf,'sk', 'MarkerFaceColor','m','MarkerSize', 8);
        %create and plot error bands
        
        x = tear_CMOD;
        y = tear_force;
        %     err_factor = 0.05;
        yn = y-err_factor*y;
        yp = y+err_factor*y;
        x_lim = [x x];
        y_lim = [yn*fsf yp*fsf];
        plot(x_lim, y_lim, ':g');
        %draw ends to error bands
        bf = 0.02;
        x_bandP = x+bf*x;
        x_bandN = x-bf*x;
        Band1_x = [x_bandN x_bandP];
        Band1_y = [yn*fsf yn*fsf];
        Band2_x = [x_bandN x_bandP];
        Band2_y = [yp*fsf yp*fsf];
        plot(Band1_x, Band1_y, '-g');
        plot(Band2_x, Band2_y, '-g');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %*update* *V1.0.1* 02/04/14
    %write tearing J_phi value on plot
    if result.fea.J_tear_phi(1) ~= 0
        J_tear = result.fea.J_tear_phi;
        %get phi index of nearest phi result
        [~,I] = min(abs(result.fea.Phi-result.tear_angle));
        Jstr = num2str(J_tear(I), '%10.2f');
        Jstr = strcat('J_{phi} = ',Jstr);
        text(0.95*max(fea_CMOD),0.4*max(fea_force*fsf),Jstr,'HorizontalAlignment',...
            'right','FontSize',12, 'BackgroundColor','w');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
if ~isempty(tear_force) && interp.cb_test_predict == 1
    legend_type = 2;
    tear_CMOD = result.tear_CMOD;
    plot(tear_CMOD, tear_force*fsf,'sk', 'MarkerFaceColor','m','MarkerSize', 8);
    plot([tear_CMOD tear_CMOD],[0 tear_force*fsf],'--k');
    plot([0 tear_CMOD],[tear_force*fsf tear_force*fsf],'--k');
    forcestr = num2str(tear_force*fsf, '%9.2f');
    forcestr = strcat('Predicted Stress = ',forcestr);
    text(.95*max(fea_CMOD),0.3*max(fea_force*fsf),forcestr,'HorizontalAlignment',...
        'right','FontSize',12, 'BackgroundColor','w');
    CMODstr = num2str(tear_CMOD, '%2.4f');
    CMODstr = strcat('Predicted CMOD = ',CMODstr);
    text(.95*max(fea_CMOD),0.2*max(fea_force*fsf),CMODstr,'HorizontalAlignment',...
        'right','FontSize',12, 'BackgroundColor','w');
    
end
if length(force) < 2
    legend_type = 3;
end
%---------------------------------------------------------------
switch legend_type
    case 1
        legend_text = {str1, str2};
    case 2
        legend_text = {str1, str2, str3, str4};
    case 3
        legend_text = {str1};
end
legend(legend_text, 'Location', 'SouthEast');
%---------------------------------------------------------------
if interp.cmod_axis_flag == 1
    xlim([interp.xlim_cmod]);
    ylim([interp.ylim_cmod]);
else
    xlim('auto');
    ylim('auto');
end
%create horizontal lines at far field and net section yield
xdat = [0 max(fea_CMOD)];
ydat1 = [Sys, Sys];
ydat2 = ydat1.*(an/af);
plot(xdat, ydat1, '--b');
plot(xdat, ydat2, '-.c');
text(fea_CMOD(2),ydat1(1),'Section Yield','HorizontalAlignment',...
    'left','FontSize',10, 'BackgroundColor','w');
text(fea_CMOD(2),ydat2(1),'Net Section Yield','HorizontalAlignment',...
    'left','FontSize',10, 'BackgroundColor','w');
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%     %print figure to emf file and save fig file
%     filename = strcat(FilePrefix, '_CMOD_Force');
%     print_file = strcat(pathname, '\', filename);
%     print(gcf,'-dmeta','-r300',print_file);
%     FigFile = strcat(print_file, '.fig');
%     saveas(gcf, FigFile);

