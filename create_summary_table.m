%program to take the SC J analysis result database and create concise
%summary tables in text and excel format
function create_summary_table(result, interp)
%------------***********************--------------------------
%set some variables
file_name = char(result.fea.FileName);
% tear_load_type = 2; %tension loading
a = result.fea.a;
c = result.fea.c;
w = result.fea.width;
B = result.fea.B;
% num_steps = result.fea.num_steps;
if strcmp(result.fea.moment_flag, 'no')
    St = result.fea.St_far;
else
    St = result.fea.S_bend;
end
% reac_force = result.fea.reac_force;
Jt = result.fea.Jtotal_Avg;
% Jel = result.fea.Jel_EPFM;
CMOD = result.fea.CMOD;
phi = result.fea.Phi;
norm_T_stress = result.fea.norm_T_stress;
Sys = interp.Sys;
E = interp.E;
n = interp.n;
% e_ys = Sys/E;
E_over_Sys = E/Sys;
nu = result.fea.crack_nu;
% Jtear_calc_method = 2; %CMOD MATCHING
% CK = result.fea.CK;
% CJa = result.fea.CJa;
% CJb = result.fea.CJb;
% err_factor = interp.err_factor;
%set units conversion factors
%force factor
ff = interp.ff;
ac = a/c;
aB = a/B;
J_tear = result.fea.J_tear_phi;
Jel_tear = result.fea.Jel_tear_phi;
% CMOD_tear = result.tear_CMOD;
%J to K conversion factor
JKF = E/(1-nu^2)*1000;
%choose the number of load step increments for table
n_steps = result.fea.num_steps;
%n_steps = 20;
% spacer = 1/n_steps;
% final_spacing = [spacer:spacer:1]';
%choose the number of phi increments for table
% n_phi = 45; % eg. 90/45 = 2 degrees; solution every 2 dtableegrees
%select phi increment of 2 degrees for results
%reset phi increment to same increment for each set
%for interpolated solution
% phi_inc = 90/n_phi;
% interp_phi = (0:phi_inc:90);
% initialize loop counter for output to screen
% LoopCount = 1;
%loop through the results and create the required table values
%create table values in table(i,j,k,l) structure
%%
%%
%create unique index # for each solution
%a/B,a/c,n,E/Sys .... eg. 0.2_0.5_6_500
aB_ind = num2str(aB, '%3.2f');
ac_ind = num2str(ac, '%3.2f');
n_ind = num2str(n, '%2.0f');
E_ind = num2str(E, '%4.0f');
table.index_name = strcat(aB_ind, '_',...
    ac_ind, '_', n_ind, '_', E_ind);



%%
%create cell array of results that can be exported to excel
%and a text file
%*update* *V1.0.1* 02/03/14 - add E, a, and 2C to summary table labels
labels1 = {'index', 'a/B', 'a/c', 'n', 'E/Sys', 'W', 'B', 'Sys', 'E',...
    'a','2c','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
%
%
labels3 = {'**', '**', 'phi' '0', '2', '4', '6', '8', '10',...
    '12','14','16','18','20','22','24','26','28','30',...
    '32','34','36','38','40','42','44','46','48','50',...
    '52','54','56','58','60','62','64','66','68','70',...
    '72','74','76','78','80','82','84','86','88','90'};
%
labels4 = {'step', 'stress', 'CMOD' 'J0', 'J2', 'J4', 'J6', 'J8', 'J10',...
    'J12','J14','J16','J18','J20','J22','J24','J26','J28','J30',...
    'J32','J34','J36','J38','J40','J42','J44','J46','J48','J50',...
    'J52','J54','J56','J58','J60','J62','J64','J66','J68','J70',...
    'J72','J74','J76','J78','J80','J82','J84','J86','J88','J90'};
%
labels5 = {'end', '', '', '', '', '', '', '', '',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
step_vals = 1:1:n_steps;
step_vals = step_vals';
step_str = cell(n_steps, 1);
for ii = 1:n_steps
    step_str{ii,1} = num2str(step_vals(ii), '%3.0f');
end
final_table = {};
%*update* *V1.0.1* 02/03/14 - add E, a, and 2C values to summary table
%
% P_str = {};
% CMOD_str = {};
% Jtotal_str = {};
% comb_table = {};
% labels2 = {};
labels2 = {table.index_name, num2str(aB, '%3.2f'),...
    num2str(ac, '%3.2f'), num2str(n, '%4.2f'),...
    num2str(E_over_Sys, '%5.1f'), num2str(w, '%8.4f'),...
    num2str(B,'%8.4f'), num2str(Sys,'%3.2f'), num2str(E,'%11.2f'),...
    num2str(a,'%10.4f'),num2str((2*c),'%10.4f'),'','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
S_str = cell(n_steps, 1);
for ii = 1:n_steps
    %P_str{ii,1} = num2str(table(i,j,k,l).P(ii), '%10.4f');
    S_str{ii,1} = num2str(St(ii), '%10.4e');
end
CMOD_str = cell(n_steps, 1);
for ii = 1:n_steps
    %CMOD_str{ii,1} = num2str(table(i,j,k,l).CMOD(ii), '%10.5f');
    CMOD_str{ii,1} = num2str(CMOD(ii), '%10.4e');
end
Jtotal_str = cell(n_steps, size(phi,2));
for ii = 1:n_steps
    for jj = 1:size(phi,2)
        %Jtotal_str{ii,jj} = num2str(table(i,j,k,l).Jtotal(ii,jj), '%10.4f');
        Jtotal_str{ii,jj} = num2str(Jt(jj,ii), '%10.4e');
    end
end
%
table.table_data = [step_str S_str CMOD_str Jtotal_str];
table.comb_table = [labels1;labels2;labels3;...
    labels4; table.table_data; labels5];
final_table = [final_table; table.comb_table];
%
%%
%now add normalized T-stress and tear results to bottom of table
T_string = {'', '', 'T/Sigma'};
%get rid of NaN values for phi < 5 deg. by setting values equal to
%value immediately past 5 deg.
[~,I] = min(abs(phi-5));
for i = 1:I
    norm_T_stress(i) = norm_T_stress(I+1);
end
T_vals = cell(1, length(norm_T_stress));
for i = 1:length(norm_T_stress)
    T_vals{i} =  num2str(norm_T_stress(i), '%10.4e');
end
T_table = [T_string T_vals];
final_table = [final_table; labels3; T_table];
%now add tearing point values if available
%string if tearing point is not found
no_tear_str = {'No', 'Tearing', 'Point', 'Values', 'Reported', '', '', '', '',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
end_summ_str = {'end_summary', '', '', '', '', '', '', '', '',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
space_str = {'', '', '', '', '', '', '', '', '',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
if J_tear(1) ~= 0
    J_tear_str1 = {'', '', 'J_tear'};
    T_Sys_str = {'', '', 'T/Sys'};
    KJel_str = {'', '', 'K_Jel'};
    KJtotal_str = {'', '', 'K_Jtotal'};
    tear_summ_str = {'Tearing', 'Point', 'Summary', 'Values', '**', '**', '**', '', '',...
        '','','','','','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','',''};
    tear_summ_str2 = {'Tearing', 'Point', 'Values', 'At', 'Tearing', 'Phi', 'Location', '', '',...
        '','','','','','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','',''};
    %*update* *V1.0.1* 02/03/14 - add r_phi_a and r_phi_b to summary table labels
    tear_lab_str = {'Stress', 'Force', 'CMOD', 'Phi', 'J', 'T/Sys', 'K_Jel', 'K_Jtotal', 'Sigma/Sys',...
        'Ma','Mb','r_phi_a','r_phi_b','','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','',''};
    %get rid of NaN values for phi < 5 deg. by setting values equal to
    %value immediately past 5 deg.
    [~,I] = min(abs(phi-5));
    for i = 1:I
        result.fea.T_over_Sys(i) = result.fea.T_over_Sys(I+1);
    end
    J_tear_str = cell(1,length(J_tear));
    T_Sys_tear_str = cell(1,length(J_tear));
    K_tear_str = cell(1,length(J_tear));
    Kel_tear_str = cell(1,length(J_tear));
    for i = 1:length(J_tear)
        J_tear_str{i} =  num2str(J_tear(i), '%10.4e');
        T_Sys_tear_str{i} =  num2str(result.fea.T_over_Sys(i), '%10.4e');
        K_tear_str{i} =  num2str(((J_tear(i)*JKF)^0.5)/1000, '%10.4e');
        Kel_tear_str{i} =  num2str(((Jel_tear(i)*JKF)^0.5)/1000, '%10.4e');
    end
    J_tear_table = [J_tear_str1 J_tear_str];
    T_Sys_tear_table = [T_Sys_str T_Sys_tear_str];
    KJel_tear_table = [KJel_str Kel_tear_str];
    KJtotal_tear_table = [KJtotal_str K_tear_str];
    %get phi index of nearest phi result
    [~,I] = min(abs(phi-result.tear_angle));
    %create table of strings for tear values
    %*update* *V1.0.1* 02/03/14 - add r_phi_a and r_phi_b to summary table
    tear_phi_str = {num2str(result.fea.tear_reac_force_analysis/(B*w)/ff, '%10.4e'),...
        num2str(result.fea.tear_reac_force_analysis, '%10.4e'),...
        num2str(result.fea.tear_CMOD_analysis, '%10.4e'),...
        num2str(result.tear_angle, '%4.2f'),...
        num2str(J_tear(I), '%10.4e'),...
        num2str(result.fea.T_over_Sys(I), '%10.4e'),...
        Kel_tear_str{I},...
        K_tear_str{I},...
        num2str((result.fea.tear_reac_force_analysis/(B*w)/ff)/Sys, '%4.2f'),...
        num2str(result.fea.M_epfm_a_tear(I), '%10.2f'),...
        num2str(result.fea.M_epfm_b_tear(I), '%10.2f')...
        num2str(result.fea.r_phi_a(I), '%11.3f')...
        num2str(result.fea.r_phi_b(I), '%11.3f')...
        ,'','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','','',...
        '','','','','','','','','',''};
    
    final_table = [final_table; space_str;tear_summ_str; J_tear_table;...
        T_Sys_tear_table; KJel_tear_table; KJtotal_tear_table;...
        %space_str; tear_summ_str2; tear_lab_str;  end_summ_str];
        space_str; tear_summ_str2; tear_lab_str; tear_phi_str; end_summ_str];
else
    final_table = [final_table; space_str; no_tear_str; end_summ_str];
end
%create table with units
if result.units == 1
    ustr = 'US Units';
else
    ustr = 'SI Units';
end
% units_table =  {ustr, result.length_str, result.force_str,...
%     result.stress_str, result.J_str, result.K_str, '', '', '',...
%    '','','','','','','','','','',...
%    '','','','','','','','','','',...
%    '','','','','','','','','','',...
%    '','','','','','','','','',''};
space_str2 = {'', '', '', '', '', '', '', '',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
% units_table =  {ustr space_str2; result.length_str space_str2;...
%     result.force_str space_str2; result.stress_str space_str2;...
%     result.J_str space_str2; result.K_str space_str2};
phi_u_str = 'Phi (deg)';
units_table =  [ustr space_str2
    result.length_str space_str2
    result.force_str space_str2
    result.stress_str space_str2
    result.J_str space_str2
    result.K_str space_str2
    phi_u_str space_str2];
%
end_units_str = {'end_units', '', '', '', '', '', '', '', '',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','','',...
    '','','','','','','','','',''};
final_table = [final_table; space_str; units_table; end_units_str];
%%
%if running on a PC, write final table to excel file
%XlsFilename = 'SC_database_summary.xls';
if ispc
    XlsFilename = strcat(file_name,'.xls');
    warning off MATLAB:xlswrite:AddSheet
    xlswrite(XlsFilename, final_table, 'data_summary');
end
%%
%create txt file of summary results

TxtName = strcat(file_name,'.txt');
%TxtName = 'try.txt';
TXT = fopen(TxtName,'w');
% replace_str = [];
%
%for i = 1:1
for i = 1:size(final_table,1)
    for j = 1:size(final_table,2)
        replace_str = char(final_table(i,j));
        if j ~= size(final_table,2)
            fprintf(TXT,'%s\t',replace_str);
        else
            fprintf(TXT,'%s\r\n',replace_str);
        end
    end
end
fclose(TXT);