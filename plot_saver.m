%--function to produce plot and save picture files
function  plot_saver(handles)
%set some variables
output_dir = [];
output_dir = cd;
output_dir = strcat(output_dir, '\');
FigPrefix = handles.FilenamePrefix;
figure_save_type = handles.figure_save_type;
%figure_save_type = 'Metafiles';% options are 'Metafiles' 'Bitmaps' 'JPEGs' 'PNGs' 'TIFFs'
%start making and saving plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
force_CMOD_fig = figure( 'Name','force_CMOD',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'force_CMOD';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_force_CMOD_interp2_int(handles.testdata, handles.result, handles.interp);
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stress_CMOD_fig = figure( 'Name','stress_CMOD',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'stress_CMOD';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_stress_CMOD_interp_int(handles.testdata, handles.result, handles.interp)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J_CMOD_fig = figure( 'Name','J_CMOD',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'J_CMOD';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_J_CMOD_fea_int(handles.result)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
J_phi_fig = figure( 'Name','J_phi',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'J_phi';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_Jel_Jt_phi_fea_int(handles.result)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
normT_phi_fig = figure( 'Name','normT_phi',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'normTstress_phi';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_normT_phi_fea_int(handles.result)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K_phi_fig = figure( 'Name','K_phi',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'K_phi';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_K_phi_fea_int(handles.result, handles.interp)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
crit_phi_predict_fig = figure( 'Name','crit_phi_predict',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'crit_phi_predict';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_J_T_norm_phi_fea_int(handles.result);
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
crack_sketch_fig = figure( 'Name','crack_sketch_predict',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'crack_sketch';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_sketch_crack_interp_int(handles.result)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deform_limits_fig = figure( 'Name','deform_limits',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'deform_limits';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_deform_epfm_fea_int(handles.result)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stress_strain_inputs_fig = figure( 'Name','stress_strain_inputs',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'stress_strain_inputs';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_lppl_int(handles);
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*update* *V1.0.2* 06/6/14
%Add crack front conditions plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
crack_front_cond_fig = figure( 'Name','crack_front_condition',...
                         'NumberTitle','off','color', 'w', 'visible', 'off');
figname = [];
figname2 = [];
figname = 'crack_front_condition';
figname2 = strcat(FigPrefix,'_',figname);
%create plot
plt_crk_front_condition_int(handles.result, handles.interp)
%
set(gcf, 'PaperUnits','inches', 'PaperSize', [6.5 4.5],...
        'PaperOrientation', 'portrait',...
        'PaperPosition',[.25 .25 6.0 4] );


    print_file = [output_dir figname2];

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
  
close(gcf);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%end function
 end