function plt_lppl_int(handles)
%define values to perform lppl calculations

se_table = handles.fea_props.base_se;
n =handles.interp.n;
E = handles.interp.E;
Sys = handles.interp.Sys;
eys = Sys/E;
e_t_l  = [0,eys]';%total strain, linear portion
e_t_nl = eys:.001:.1; %total strain, nonlinear portion
e_t_nl = e_t_nl';
sigma_l = e_t_l.*E;
sigma_nl = Sys.*(e_t_nl/eys).^(1/n);
str1 = 'LPPL Equation';
str2 = 'Data Table';
for i = 1:length(e_t_nl)
    epl(i) = e_t_nl(i) - sigma_nl(i)/E;
end
% %make plots
%do logical test for strain axis type

if handles.interp.se_strain_type_flag == 1

    if handles.interp.se_axes_type_flag == 1
    plot(epl, sigma_nl, '-r');
    else
    loglog(epl, sigma_nl, '-r');
    end
   
    hold on
    legend_text = {str1};
    xlabel('Plastic Strain');
    ylabel(handles.result.stress_str);

    if se_table(1,1) ~= 0 && handles.interp.se_data_plot_flag == 1
        if handles.interp.se_axes_type_flag == 1
        plot(se_table(:,2), se_table(:,1), '--xb');
        else
        loglog(se_table(:,2), se_table(:,1), '--xb');
        end

    legend_text = {str1, str2};
    end
else
    for i = 1:length(e_t_nl)
    e_total(i) = epl(i) + sigma_nl(i)/E;
    end
    if handles.interp.se_axes_type_flag == 1
        plot(e_total, sigma_nl, '-r');
        else
        loglog(e_total, sigma_nl, '-r');
    end
    hold on
    legend_text = {str1};
    xlabel('Strain');
    ylabel(handles.result.stress_str);

    if se_table(1,1) ~= 0 && handles.interp.se_data_plot_flag == 1
        for i = 1:length(se_table)
            se_total(i) = se_table(i,2)+ se_table(i,1)/E;
        end
    if handles.interp.se_axes_type_flag == 1
    plot(se_total, se_table(:,1), '--xb');
    else
    loglog(se_total, se_table(:,1), '--xb');
    end

    legend_text = {str1, str2};
    end
    %plot elastic portions of data
    if handles.interp.se_axes_type_flag == 1
    plot([0 sigma_l(2)/E],[0 sigma_l(2)],'-r')
    else
        loglog([0 sigma_l(2)/E],[0 sigma_l(2)],'-r');
    end
    if se_table(1,1) ~= 0 && handles.interp.se_data_plot_flag == 1
        if handles.interp.se_axes_type_flag == 1
        plot([0 se_table(1,1)/E], [0 se_table(1,1)],'--xb');
        else
            loglog([0 se_table(1,1)/E], [0 se_table(1,1)],'--xb');
        end
    end
end
legend(legend_text, 'Location', 'SouthEast');
if handles.interp.se_axis_flag == 1
    xlim([handles.interp.xlim_se]);
    ylim([handles.interp.ylim_se]);
else
    xlim('auto');
    ylim('auto');
end
hold off
end
