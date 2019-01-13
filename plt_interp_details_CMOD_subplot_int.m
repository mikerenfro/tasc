function plt_interp_details_CMOD_subplot_int(interp)
%define variables
input = interp.interp_data.input;
res = interp.interp_data.result;
aB_pick = interp.a/interp.B;
ac_pick = interp.a/interp.two_c*2;
n_pick = interp.n;
E_pick = interp.E;
Sys_pick = interp.Sys;
E_Sys_pick = E_pick/Sys_pick;
%perform interpolation
[Tmp,Tmp2,Tmp3,Tmp4,Final] =...
    interp_solution_SCGui_CMOD_log_int(input,res,aB_pick,ac_pick,n_pick,E_Sys_pick);
%interpolate_solution_SCGui_CMOD(input,res,aB_pick,ac_pick,n_pick,E_Sys_pick);
%define plot variables
aB_bounds = Final.aB_bounds;
ac_bounds = Final.ac_bounds;
n_bounds = Final.n_bounds;
E_bounds = Final.E_bounds;
%---------------------------------------------------------
%create plots to check out interpolated solution
%---------------------------------------------------------
%set some plot variables
PathName = cd;
% output_dir = cd;
output_dir = strcat(PathName, filesep);
%output_dir = strcat(PathName, '\Interp_Detail_plots\');
%mkdir(output_dir);
%warning off MATLAB:MKDIR:DirectoryExists
%clear plotspec
plotspec = [];
%create plotspec structure that contains plot variables%%%%%%%%%%%%%%%%
plotspec.XTickLabel = {'0','15','30','45','60','75' '90'};
plotspec.XTick = [0 15 30 45 60 75 90];
plotspec.FontName = 'Arial';
plotspec.Visible = 'on';
plotspec.Color_Axis = [1 1 1];
plotspec.FontSize = 10;
plotspec.Box = 'off';
plotspec.LineWidth = 1.0;
plotspec.GridLineStyle = 'none';
plotspec.TickDir = 'out';
plotspec.TickLength = [0.015 0.025];
plotspec.fig_color = 'w';
plotspec.fig_NumberTitle = 'off';
plotspec.x_FontName = 'Arial Narrow';
plotspec.x_FontWeight = 'normal'; %'Bold';
plotspec.y_FontName = 'Arial Narrow';
plotspec.y_FontWeight = 'normal';%'Bold';
plotspec.legend_location = 'NorthWest';
plotspec.save_fig_files = 'true';
plotspec.save_images = 'true';
%set fig save file type based on computer platform
if ispc
    plotspec.figure_save_type = 'Metafiles';% options are 'Metafiles' 'Bitmaps' 'JPEGs' 'PNGs' 'TIFFs'
else
    plotspec.figure_save_type = 'TIFFs';% options are 'Metafiles' 'Bitmaps' 'JPEGs' 'PNGs' 'TIFFs'
end
%plotspec.figure_save_type = 'TIFFs';% options are 'Metafiles' 'Bitmaps' 'JPEGs' 'PNGs' 'TIFFs'
%
plotspec.Xgrid = 'off';
plotspec.Ygrid = 'off';
plotspec.Marker = {'o'; 's'; 'd'; 'p';'^'; 'v'; '>'; '<';'h';'+'; '*';'x' };
plotspec.MarkerEdgeColor = 'auto'; %'none'
plotspec.MarkerFaceColor = 'none'; % 'auto'
plotspec.MarkerSize = 6;
plotspec.LineStyle = '-' ;%--, :, -., 'none'
plotspec.LineWidth = 0.5;
plotspec.colors =  [0.00  0.00  1.00
    0.00  0.50  0.00
    1.00  0.00  0.00
    0.00  0.75  0.75
    0.75  0.00  0.75
    0.25  0.25  0.25
    0.75  0.25  0.25
    0.95  0.95  0.00
    0.99  0.41  0.23
    0.25  0.25  0.75
    0.75  0.75  0.00
    0.00  1.00  0.00
    0.76  0.57  0.17
    0.54  0.63  0.22
    0.34  0.57  0.92
    1.00  0.10  0.60
    0.88  0.75  0.73
    0.10  0.49  0.47
    0.66  0.34  0.65
    0.75  0.75  0.75];

% save_fig_files = plotspec.save_fig_files;
save_images = plotspec.save_images;
figure_save_type = plotspec.figure_save_type;
markers = { 'o'; 's'; 'd'; '^'; '+'};
%color_it = { 'b'; 'g'; 'r'; 'm'};
color_it = { plotspec.colors(1,:); plotspec.colors(7,:);...
    plotspec.colors(3,:); plotspec.colors(2,:)};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Plot first 16 data sets with interpolated solution
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Compare_16_fig = figure( 'Name','Snet_vs_CMOD',...
    'NumberTitle','off','color', 'w');
axes1 = axes('Parent',Compare_16_fig,...
    'Position',[0.13 0.58 0.335 0.34]);
figname = 'compare_16_subplot';
hold(axes1,'all');
%subplot(2,2,1:2)

plot(Final.int_CMOD, Final.far_stress_inc, '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
%hold on
set(gcf, 'PaperUnits','inches', 'PaperSize', [8.5 11],...
    'PaperOrientation', 'portrait',...
    'PaperPosition',[.25 .25 8.0 10] );
%create legend text based on geometry and material properties
legend_txt = cell(1, 17);
legend_txt{1} = strcat('Interp., ', 'a/B=',...
    num2str(aB_pick, '%4.2f'), ', a/c=', num2str(ac_pick, '%4.2f'),...
    ', n=',num2str(n_pick, '%4.1f'), ', E/','\sigma_{ys}=', num2str(E_Sys_pick, '%5.0f'));
k = 2;
for i = 1:4
    for j = 1:4
        %set plot index for legend text
        if j == 1
            aBplt = 1;
            acplt = 1;
        elseif j == 2
            aBplt = 1;
            acplt = 2;
        elseif j == 3
            aBplt = 2;
            acplt = 1;
        elseif j == 4
            aBplt = 2;
            acplt = 2;
        end
        %-----------------------
        if i == 1
            nplt = 1;
            Eplt = 1;
        elseif i == 2
            nplt = 1;
            Eplt = 2;
        elseif i == 3
            nplt = 2;
            Eplt = 1;
        elseif i == 4
            nplt = 2;
            Eplt = 2;
        end
        legend_txt{k} =  strcat('a/B=',...
            num2str(aB_bounds(aBplt)), ', a/c=', num2str(ac_bounds(acplt)),...
            ', n=',num2str(n_bounds(nplt)), ', E/\sigma_{ys}=', num2str(E_bounds(Eplt)));
        k = k+1;
    end
end
for i = 1:4
    for j = 1:4
        plot(Tmp(i,j).int_CMOD(1), Tmp(i,j).int_far_stress(1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:4
        plot(Tmp(i,j).int_CMOD(5:5:end), Tmp(i,j).int_far_stress(5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:4
        plot(Tmp(i,j).int_CMOD, Tmp(i,j).int_far_stress, 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end
%
%    for i = 1:4
%      for j = 1:4
%  plot(Tmp(i,j).CMOD, Tmp(i,j).net_stress, 'LineStyle', ':',...
%      'LineWidth', 0.1 ,'Marker', markers{5},...
%          'Color', 'c');
%      end
%    end
%  legend_txt{18} = 'Orig. FEA Solutions';
xaxis_label = 'CMOD_{n}';
yaxis_label = '\sigma_{n}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
legend1 = legend(legend_txt, 'Location', 'EastOutside',...
    'FontName', plotspec.x_FontName);
set(legend1,...
    'Position',[0.61 0.58 0.25 0.34]);
% title('Net Section Stress vs. CMOD');
% hold off
%--------------------------------------------------------------
%--------------------------------------------------------------
% Jtotal_CMOD_16_fig = figure( 'Name','Jtotal_vs_CMOD',...
%                          'NumberTitle','off','color', 'w');
subplot1 = subplot(2,2,3,'Parent',Compare_16_fig);
hold(subplot1,'all');
%subplot(2,2,3)
%hold on
plot(Final.int_CMOD, Final.int_Jtotal(end,:),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

for i = 1:4
    for j = 1:4
        plot(Tmp(i,j).int_CMOD(1), Tmp(i,j).int_Jtotal(end,1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:4
        plot(Tmp(i,j).int_CMOD(5:5:end), Tmp(i,j).int_Jtotal(end,5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:4
        plot(Tmp(i,j).int_CMOD, Tmp(i,j).int_Jtotal(end,:), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

%
%    for i = 1:4
%      for j = 1:4
%  plot(Tmp(i,j).CMOD, Tmp(i,j).Jtotal_Avg(end,:), 'LineStyle', ':',...
%      'LineWidth', 0.1 ,'Marker', markers{5},...
%          'Color', 'c');
%      end
%    end
%  legend_txt{18} = 'Orig. FEA Solutions';
% %**********************************************************
%   for i = 1:4
%      for j = 1:4
%  plot(Tmp(i,j).net_stress, Tmp(i,j).Jtotal_Avg(end,:), '-rx')
%  plot(Final.net_stress_inc, Tmp(i,j).int_Jtotal(end,:), '-bs')
%      end
%   end
%  %**********************************************************
%ylim([0, 20])
xaxis_label = 'CMOD_{n}';
yaxis_label = 'J_{n}(\phi=90)x10^{3}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
% legend(legend_txt, 'Location', 'EastOutside');
% title('J_{total} vs. CMOD at phi = 90 deg');
% hold off

%--------------------------------------------------------------
%  Jtotal_phi_16_fig = figure( 'Name','Jtotal_vs_phi',...
%                           'NumberTitle','off','color', 'w');
subplot2 = subplot(2,2,4,'Parent',Compare_16_fig);
hold(subplot2,'all');
set(gca,'XTickLabel',plotspec.XTickLabel,'XTick',plotspec.XTick);
% subplot(2,2,4)
% hold on
plot(Final.interp_phi, Final.int_Jtotal(:,end),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
for i = 1:4
    for j = 1:4
        plot(Final.interp_phi(1), Tmp(i,j).int_Jtotal(1,end), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:4
        plot(Final.interp_phi(end), Tmp(i,j).int_Jtotal(end,end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:4
        plot(Final.interp_phi, Tmp(i,j).int_Jtotal(:,end), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end
%
% %**********************************************************
%   for i = 1:4
%      for j = 1:4
%  %plot(Tmp(i,j).Phi, Tmp(i,j).Jtotal_Avg(:,end), '-rx')
%  plot(Final.interp_phi, Tmp(i,j).int_Jtotal(:,end), '-bs')
%      end
%   end
%  %**********************************************************
%ylim([0, 20])
xlim([0, 90])
xaxis_label = '\phi (deg)';
yaxis_label = 'J_{n}x10^{3} for Last Load Step';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
% legend(legend_txt2, 'Location', 'EastOutside');
% title('J_{total} vs. Phi at last load step');
hold off
if save_images
    print_file = [output_dir figname];
    
    switch figure_save_type
        case 'Metafiles'
            print(gcf,'-dmeta','-r300',print_file);
        case 'Bitmaps'
            print(gcf,'-dbmp' ,'-r300',print_file);
        case 'JPEGs'
            print(gcf,'-djpeg','-r300',print_file);
        case 'PNGs'
            print(gcf,'-dpng' ,'-r300',print_file);
        case 'TIFFs'
            print(gcf,'-dtiff','-r300',print_file);
    end
end
%--------------------------------------------------------------
%--------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Plot next 8 data sets with interpolated solution
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Compare_8_fig = figure( 'Name','Snet_vs_CMOD',...
    'NumberTitle','off','color', 'w');
axes1 = axes('Parent',Compare_8_fig,...
    'Position',[0.13 0.58 0.335 0.34]);
figname = 'compare_8_subplot';
hold(axes1,'all');
%subplot(2,2,1:2)

plot(Final.int_CMOD, Final.far_stress_inc, '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
%hold on
set(gcf, 'PaperUnits','inches', 'PaperSize', [8.5 11],...
    'PaperOrientation', 'portrait',...
    'PaperPosition',[.25 .25 8.0 10] );
%create legend text based on geometry and material properties
legend_txt = cell(1, 9);
legend_txt{1} = strcat('Interp., ', 'a/B=',...
    num2str(aB_pick, '%4.2f'), ', a/c=', num2str(ac_pick, '%4.2f'),...
    ', n=',num2str(n_pick, '%4.1f'), ', E/\sigma_{ys}=', num2str(E_Sys_pick, '%5.0f'));
%set ac_bounds = ac_pick since a/c interpolation is complete
ac_bounds = ac_pick;
k = 2;
for i = 1:4
    for j = 1:2
        %set plot index for legend text
        if j == 1
            aBplt = 1;
            acplt = 1;
        elseif j == 2
            aBplt = 2;
            acplt = 1;
        end
        %-----------------------
        if i == 1
            nplt = 1;
            Eplt = 1;
        elseif i == 2
            nplt = 1;
            Eplt = 2;
        elseif i == 3
            nplt = 2;
            Eplt = 1;
        elseif i == 4
            nplt = 2;
            Eplt = 2;
        end
        legend_txt{k} =  strcat('a/B=',...
            num2str(aB_bounds(aBplt), '%4.2f'), ', a/c=', num2str(ac_bounds(acplt), '%4.2f'),...
            ', n=',num2str(n_bounds(nplt), '%4.1f'), ', E/\sigma_{ys}=', num2str(E_bounds(Eplt), '%5.0f'));
        k = k+1;
    end
end
for i = 1:4
    for j = 1:2
        plot(Tmp2(i,j).int_CMOD(1), Tmp2(i,j).int_far_stress(1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:2
        plot(Tmp2(i,j).int_CMOD(5:5:end), Tmp2(i,j).int_far_stress(5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:2
        plot(Tmp2(i,j).int_CMOD, Tmp2(i,j).int_far_stress, 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

xaxis_label = 'CMOD_{n}';
yaxis_label = '\sigma_{n}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
legend1 = legend(legend_txt, 'Location', 'EastOutside',...
    'FontName', plotspec.x_FontName);
set(legend1,...
    'Position',[0.61 0.58 0.25 0.34]);
%--------------------------------------------------------------
%--------------------------------------------------------------
subplot1 = subplot(2,2,3,'Parent',Compare_8_fig);
hold(subplot1,'all');
plot(Final.int_CMOD, Final.int_Jtotal(end,:),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

for i = 1:4
    for j = 1:2
        plot(Tmp2(i,j).int_CMOD(1), Tmp2(i,j).int_Jtotal(end,1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:2
        plot(Tmp2(i,j).int_CMOD(5:5:end), Tmp2(i,j).int_Jtotal(end,5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:2
        plot(Tmp2(i,j).int_CMOD, Tmp2(i,j).int_Jtotal(end,:), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

%  %**********************************************************
%ylim([0, 20])
xaxis_label = 'CMOD_{n}';
yaxis_label = 'J_{n}(\phi=90)x10^{3}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);

%--------------------------------------------------------------
subplot2 = subplot(2,2,4,'Parent',Compare_8_fig);
hold(subplot2,'all');
set(gca,'XTickLabel',plotspec.XTickLabel,'XTick',plotspec.XTick);
% subplot(2,2,4)
% hold on
plot(Final.interp_phi, Final.int_Jtotal(:,end),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
for i = 1:4
    for j = 1:2
        plot(Final.interp_phi(1), Tmp2(i,j).int_Jtotal(1,end), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:2
        plot(Final.interp_phi(end), Tmp2(i,j).int_Jtotal(end,end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:2
        plot(Final.interp_phi, Tmp2(i,j).int_Jtotal(:,end), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

%  %**********************************************************
%ylim([0, 20])
xlim([0, 90])
xaxis_label = '\phi (deg)';
yaxis_label = 'J_{n}x10^{3} for Last Load Step';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
% legend(legend_txt2, 'Location', 'EastOutside');
% title('J_{total} vs. Phi at last load step');
hold off
if save_images
    print_file = [output_dir figname];
    
    switch figure_save_type
        case 'Metafiles'
            print(gcf,'-dmeta','-r300',print_file);
        case 'Bitmaps'
            print(gcf,'-dbmp' ,'-r300',print_file);
        case 'JPEGs'
            print(gcf,'-djpeg','-r300',print_file);
        case 'PNGs'
            print(gcf,'-dpng' ,'-r300',print_file);
        case 'TIFFs'
            print(gcf,'-dtiff','-r300',print_file);
    end
end

%
% %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% % Plot 4 Temp3 data sets with interpolated solution
% %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Compare_4_fig = figure( 'Name','Snet_vs_CMOD',...
    'NumberTitle','off','color', 'w');
axes1 = axes('Parent',Compare_4_fig,...
    'Position',[0.13 0.58 0.335 0.34]);
figname = 'compare_4_subplot';
hold(axes1,'all');
%subplot(2,2,1:2)

plot(Final.int_CMOD, Final.far_stress_inc, '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
%hold on
set(gcf, 'PaperUnits','inches', 'PaperSize', [8.5 11],...
    'PaperOrientation', 'portrait',...
    'PaperPosition',[.25 .25 8.0 10] );
%create legend text based on geometry and material properties
legend_txt = cell(1, 5);
legend_txt{1} = strcat('Interp., ', 'a/B=',...
    num2str(aB_pick, '%4.2f'), ', a/c=', num2str(ac_pick, '%4.2f'),...
    ', n=',num2str(n_pick, '%4.1f'), ', E/\sigma_{ys}=', num2str(E_Sys_pick, '%5.0f'));
%set ac_bounds = ac_pick since a/c interpolation is complete
%set aB_bounds = ac_pick since a/B interpolation is complete
ac_bounds = ac_pick;
aB_bounds = aB_pick;
k = 2;
for i = 1:4
    for j = 1:1
        %set plot index for legend text
        if j == 1
            aBplt = 1;
            acplt = 1;
        end
        %-----------------------
        if i == 1
            nplt = 1;
            Eplt = 1;
        elseif i == 2
            nplt = 1;
            Eplt = 2;
        elseif i == 3
            nplt = 2;
            Eplt = 1;
        elseif i == 4
            nplt = 2;
            Eplt = 2;
        end
        legend_txt{k} =  strcat('a/B=',...
            num2str(aB_bounds(aBplt), '%4.2f'), ', a/c=', num2str(ac_bounds(acplt), '%4.2f'),...
            ', n=',num2str(n_bounds(nplt), '%4.1f'), ', E/\sigma_{ys}=', num2str(E_bounds(Eplt), '%5.0f'));
        k = k+1;
    end
end
for i = 1:4
    for j = 1:1
        plot(Tmp3(i,j).int_CMOD(1), Tmp3(i,j).int_far_stress(1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:1
        plot(Tmp3(i,j).int_CMOD(5:5:end), Tmp3(i,j).int_far_stress(5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:1
        plot(Tmp3(i,j).int_CMOD, Tmp3(i,j).int_far_stress, 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

xaxis_label = 'CMOD_{n}';
yaxis_label = '\sigma_{n}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
legend1 = legend(legend_txt, 'Location', 'EastOutside',...
    'FontName', plotspec.x_FontName);
set(legend1,...
    'Position',[0.61 0.58 0.25 0.34]);
%--------------------------------------------------------------
%--------------------------------------------------------------
subplot1 = subplot(2,2,3,'Parent',Compare_4_fig);
hold(subplot1,'all');
plot(Final.int_CMOD, Final.int_Jtotal(end,:),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

for i = 1:4
    for j = 1:1
        plot(Tmp3(i,j).int_CMOD(1), Tmp3(i,j).int_Jtotal(end,1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:1
        plot(Tmp3(i,j).int_CMOD(5:5:end), Tmp3(i,j).int_Jtotal(end,5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:1
        plot(Tmp3(i,j).int_CMOD, Tmp3(i,j).int_Jtotal(end,:), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

%  %**********************************************************
%ylim([0, 20])
xaxis_label = 'CMOD_{n}';
yaxis_label = 'J_{n}(\phi=90)x10^{3}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);

%--------------------------------------------------------------
subplot2 = subplot(2,2,4,'Parent',Compare_4_fig);
hold(subplot2,'all');
set(gca,'XTickLabel',plotspec.XTickLabel,'XTick',plotspec.XTick);
% subplot(2,2,4)
% hold on
plot(Final.interp_phi, Final.int_Jtotal(:,end),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
for i = 1:4
    for j = 1:1
        plot(Final.interp_phi(1), Tmp3(i,j).int_Jtotal(1,end), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:1
        plot(Final.interp_phi(end), Tmp3(i,j).int_Jtotal(end,end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:4
    for j = 1:1
        plot(Final.interp_phi, Tmp3(i,j).int_Jtotal(:,end), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

%  %**********************************************************
%ylim([0, 20])
xlim([0, 90])
xaxis_label = '\phi (deg)';
yaxis_label = 'J_{n}x10^{3} for Last Load Step';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
% legend(legend_txt2, 'Location', 'EastOutside');
% title('J_{total} vs. Phi at last load step');
hold off
if save_images
    print_file = [output_dir figname];
    
    switch figure_save_type
        case 'Metafiles'
            print(gcf,'-dmeta','-r300',print_file);
        case 'Bitmaps'
            print(gcf,'-dbmp' ,'-r300',print_file);
        case 'JPEGs'
            print(gcf,'-djpeg','-r300',print_file);
        case 'PNGs'
            print(gcf,'-dpng' ,'-r300',print_file);
        case 'TIFFs'
            print(gcf,'-dtiff','-r300',print_file);
    end
end
% %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% % Plot 2 Temp4 data sets with interpolated solution
% %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Compare_2_fig = figure( 'Name','Snet_vs_CMOD',...
    'NumberTitle','off','color', 'w');
axes1 = axes('Parent',Compare_2_fig,...
    'Position',[0.13 0.58 0.335 0.34]);
figname = 'compare_2_subplot';
hold(axes1,'all');
%subplot(2,2,1:2)

plot(Final.int_CMOD, Final.far_stress_inc, '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
%hold on
set(gcf, 'PaperUnits','inches', 'PaperSize', [8.5 11],...
    'PaperOrientation', 'portrait',...
    'PaperPosition',[.25 .25 8.0 10] );
%create legend text based on geometry and material properties
legend_txt = cell(1, 3);
legend_txt{1} = strcat('Interp., ', 'a/B=',...
    num2str(aB_pick, '%4.2f'), ', a/c=', num2str(ac_pick, '%4.2f'),...
    ', n=',num2str(n_pick, '%4.1f'), ', E/\sigma_{ys}=', num2str(E_Sys_pick, '%5.0f'));
%set ac_bounds = ac_pick since a/c interpolation is complete
%set aB_bounds = ac_pick since a/B interpolation is complete
%set n_bounds = ac_pick since "n" interpolation is complete
ac_bounds = ac_pick;
aB_bounds = aB_pick;
n_bounds = n_pick;
k = 2;
for i = 1:2
    for j = 1:1
        %set plot index for legend text
        if j == 1
            aBplt = 1;
            acplt = 1;
        end
        %-----------------------
        if i == 1
            nplt = 1;
            Eplt = 1;
        elseif i == 2
            nplt = 1;
            Eplt = 2;
        end
        legend_txt{k} =  strcat('a/B=',...
            num2str(aB_bounds(aBplt), '%4.2f'), ', a/c=', num2str(ac_bounds(acplt), '%4.2f'),...
            ', n=',num2str(n_bounds(nplt), '%4.1f'), ', E/\sigma_{ys}=', num2str(E_bounds(Eplt), '%5.0f'));
        k = k+1;
    end
end
for i = 1:2
    for j = 1:1
        plot(Tmp4(i,j).int_CMOD(1), Tmp4(i,j).int_far_stress(1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:2
    for j = 1:1
        plot(Tmp4(i,j).int_CMOD(5:5:end), Tmp4(i,j).int_far_stress(5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:2
    for j = 1:1
        plot(Tmp4(i,j).int_CMOD, Tmp4(i,j).int_far_stress, 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end
%ylim([0, 1.4]);
xaxis_label = 'CMOD_{n}';
yaxis_label = '\sigma_{n}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
legend1 = legend(legend_txt, 'Location', 'EastOutside',...
    'FontName', plotspec.x_FontName);
set(legend1,...
    'Position',[0.61 0.58 0.25 0.34]);
%--------------------------------------------------------------
%--------------------------------------------------------------
subplot1 = subplot(2,2,3,'Parent',Compare_2_fig);
hold(subplot1,'all');
plot(Final.int_CMOD, Final.int_Jtotal(end,:),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)

for i = 1:2
    for j = 1:1
        plot(Tmp4(i,j).int_CMOD(1), Tmp4(i,j).int_Jtotal(end,1), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:2
    for j = 1:1
        plot(Tmp4(i,j).int_CMOD(5:5:end), Tmp4(i,j).int_Jtotal(end,5:5:end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:2
    for j = 1:1
        plot(Tmp4(i,j).int_CMOD, Tmp4(i,j).int_Jtotal(end,:), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

%  %**********************************************************
%ylim([0, 20])
xaxis_label = 'CMOD_{n}';
yaxis_label = 'J_{n}(\phi=90)x10^{3}';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);

%--------------------------------------------------------------
subplot2 = subplot(2,2,4,'Parent',Compare_2_fig);
hold(subplot2,'all');
set(gca,'XTickLabel',plotspec.XTickLabel,'XTick',plotspec.XTick);
% subplot(2,2,4)
% hold on
plot(Final.interp_phi, Final.int_Jtotal(:,end),...
    '-kp','LineWidth',1,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',11)
for i = 1:2
    for j = 1:1
        plot(Final.interp_phi(1), Tmp4(i,j).int_Jtotal(1,end), 'LineStyle', '-', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:2
    for j = 1:1
        plot(Final.interp_phi(end), Tmp4(i,j).int_Jtotal(end,end), 'LineStyle', 'none', 'Marker', markers{i},...
            'Color', color_it{j},'LineWidth', 1);
    end
end
for i = 1:2
    for j = 1:1
        plot(Final.interp_phi, Tmp4(i,j).int_Jtotal(:,end), 'LineStyle', '-', 'Marker', 'none',...
            'Color', color_it{j},'LineWidth', 1);
    end
end

%  %**********************************************************
%ylim([0, 20])
xlim([0, 90])
xaxis_label = '\phi (deg)';
yaxis_label = 'J_{n}x10^{3} for Last Load Step';
xlabel(xaxis_label,'FontName', plotspec.x_FontName, 'FontWeight', plotspec.x_FontWeight);
ylabel(yaxis_label,'FontName', plotspec.y_FontName, 'FontWeight', plotspec.y_FontWeight);
% legend(legend_txt2, 'Location', 'EastOutside');
% title('J_{total} vs. Phi at last load step');
hold off
if save_images
    print_file = [output_dir figname];
    
    switch figure_save_type
        case 'Metafiles'
            print(gcf,'-dmeta','-r300',print_file);
        case 'Bitmaps'
            print(gcf,'-dbmp' ,'-r300',print_file);
        case 'JPEGs'
            print(gcf,'-djpeg','-r300',print_file);
        case 'PNGs'
            print(gcf,'-dpng' ,'-r300',print_file);
        case 'TIFFs'
            print(gcf,'-dtiff','-r300',print_file);
    end
end



end