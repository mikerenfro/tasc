function [in]= read_input_ntrp_file

[FileName,PathName] = uigetfile({'*.ntrp'},'Select File');
if FileName == 0
    return;
end

if ~strcmpi(FileName(end-4:end), '.ntrp')
    
    errordlg('This file is not a interpolation input.  File name must end with: ''*.ntrp''',...
        'File Error');
    return;
end

FullFileName = strcat(PathName,FileName);
in.save_path = PathName;
fileprefix = FileName(1:end-5);
in.result.fea.FileName = fileprefix;
% [Text] = textread(FullFileName, '%[^\n]');
fid = fopen(FullFileName, 'rt');
ts = textscan(fid, '%[^\r\n]');
Text = ts{1};
in.interp.cb_test_predict = 0;
in.interp.cb_eval_test = 0;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%deterimine units type
units_index = strncmp('*units', Text, 6);
units_type = sscanf(Text{units_index},'%*s %s');
if strcmp(units_type, 'SI')
    in.result.units = 2;
else
    in.result.units = 1;
end
%read geometry values section
two_c_index = strncmp('*2c', Text, 3);
a_index = strncmp('*a', Text, 2);
B_index = strncmp('*B', Text, 2);
W_index = strncmp('*W', Text, 2);
%
in.interp.two_c = sscanf(Text{two_c_index},'%*s %f');
in.interp.a = sscanf(Text{a_index},'%*s %f');
in.interp.W = sscanf(Text{W_index},'%*s %f');
in.interp.B = sscanf(Text{B_index},'%*s %f');
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read material properties section
base_index = strncmp('*material', Text, 9);
end_index = strncmp('*end_material', Text, 13);
fea_props.base_index = base_index;
se_index = strncmp('*stress', Text, 7);
fea_props.se_index = se_index;
%read base metal properties
if ~isempty(base_index)
    E_index = strncmp('*E', Text, 2);
    fea_props.base_E = sscanf(Text{E_index},'%*s %f');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %added these lines 3/8/12 to assist in interpolation routine
    fea_props.FileName = FileName;
    fea_props.FullFileName = FullFileName;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fea_props.length_base_table = end_index-se_index-1;
    
    %
    if ~isempty(se_index)
        for i = 1:fea_props.length_base_table
            %             fea_props.base_se(i,1) = sscanf(Text{base_index+2+i},'%f , %*f');
            %             fea_props.base_se(i,2) = sscanf(Text{base_index+2+i},'%*f , %f');
            %use textscan to allow reading of tab, space, or comma delimited
            %data
            fea_props.base_se_cell(i,1) = textscan(Text{se_index+i},'%f %*f', 'delimiter', ',');
            fea_props.base_se_cell(i,2) = textscan(Text{se_index+i},'%*f %f', 'delimiter', ',');
            %pull out of cell array
            fea_props.base_se(i,1) = fea_props.base_se_cell{i,1};
            fea_props.base_se(i,2) = fea_props.base_se_cell{i,2};
            
        end
    else
        Sys_index = strncmp('*Sys', Text, 4);
        n_index = strncmp('*n', Text, 2);
        fea_props.Sys_NotTable = sscanf(Text{Sys_index},'%*s %f');
        fea_props.n = sscanf(Text{n_index},'%*s %f');
        fea_props.base_se(1,1) = 0;
        fea_props.base_se(1,2) = 0;
    end
    
end
in.fea_props = fea_props;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read pre-test prediction section
pretest_index = strncmp('*pretest', Text, 8);
if ~isempty(pretest_index)
    Jc_index = strncmp('*Jc', Text, 3);
    phi_crit_index = strncmp('*phi_crit', Text, 9);
    in.result.crit_Jc = sscanf(Text{Jc_index},'%*s %f');
    in.result.crit_phi = sscanf(Text{phi_crit_index},'%*s %f');
    in.interp.cb_test_predict = 1;
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read test evaluation section
test_eval_index = strncmp('*test_eval', Text, 10);
if ~isempty(test_eval_index)
    force_index = strncmp('*tear_force', Text, 11);
    phi_index = strncmp('*tear_phi', Text, 9);
    data_index = strncmp('*CMOD', Text, 5);
    end_data_index = strncmp('*end_test_data', Text, 14);
    data_length = end_data_index-data_index-1;
    for i = 1:data_length
        %in.testdata.CMOD(i) = sscanf(Text{data_index+i},'%f %*f');
        %in.testdata.force(i) = sscanf(Text{data_index+i},'%*f %f');
        %use textscan to allow reading of tab, space, or comma delimited
        %data
        in.testdata.CMOD_cell(i) = textscan(Text{data_index+i},'%f %*f', 'delimiter', ',');
        in.testdata.force_cell(i) = textscan(Text{data_index+i},'%*f %f', 'delimiter', ',');
        %pull out of cell array
        in.testdata.CMOD(i) = in.testdata.CMOD_cell{i};
        in.testdata.force(i) = in.testdata.force_cell{i};
    end
    in.result.tear_load = sscanf(Text{force_index},'%*s %f');
    in.result.tear_angle = sscanf(Text{phi_index},'%*s %f');
    in.interp.cb_eval_test = 1;
    in.testdata.testdata_filename = FileName;
end
%%
%turn off pre test prediciton if both test prediciton and test evaluation
%data are present
if in.interp.cb_test_predict == 1 && in.interp.cb_eval_test == 1
    in.interp.cb_test_predict = 0;
end
end

