function [fea_props]= read_mat_props

[FileName,PathName] = uigetfile({'*.prop'},'Select File');
if FileName == 0
    return;
end

if ~strcmpi(FileName(end-4:end), '.prop')
    
    errordlg('This file is not a material data file.  File name must end with: ''*.prop''',...
        'File Error');
    return;
end

FullFileName = strcat(PathName,FileName);
% [Text] = textread(FullFileName, '%[^\n]');
fid = fopen(FullFileName, 'rt');
ts = textscan(fid, '%[^\r\n]');
Text = ts{1};
% base_index = strmatch('base', Text);
% haz_index = strmatch('haz', Text);
% weld_index = strmatch('weld', Text);
% end_index = strmatch('end', Text);
base_index = strncmp('base', Text, 4);
haz_index = strncmp('haz', Text, 3);
weld_index = strncmp('weld', Text, 4);
end_index = strncmp('end', Text, 3);
fea_props.base_index = base_index;
fea_props.haz_index = haz_index;
% Sys_index = strmatch('sys', Text);
% Sult_index = strmatch('sult', Text);
Sys_index = strncmp('sys', Text, 3);
Sult_index = strncmp('sult', Text, 4);
%read base metal properties
if ~isempty(base_index)
    fea_props.base_E = sscanf(Text{base_index+1},'%f');
    fea_props.base_nu = sscanf(Text{base_index+2},'%f');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %added these lines 3/8/12 to assist in interpolation routine
    fea_props.Sys_NotTable = sscanf(Text{Sys_index+1},'%f');
    fea_props.Sult_NotTable = sscanf(Text{Sult_index+1},'%f');
    fea_props.FileName = FileName;
    fea_props.FullFileName = FullFileName;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(haz_index)
        fea_props.length_base_table = end_index-base_index-3;
    else
        fea_props.length_base_table = haz_index-base_index-3;
    end
    %
    if (fea_props.length_base_table) > 0
        for i = 1:fea_props.length_base_table
            fea_props.base_se(i,1) = sscanf(Text{base_index+2+i},'%f,%*f');
            fea_props.base_se(i,2) = sscanf(Text{base_index+2+i},'%*f,%f');
        end
    end
    if ~isempty(haz_index)
        %read haz metal properties
        fea_props.haz_E = sscanf(Text{haz_index+1},'%f');
        fea_props.haz_nu = sscanf(Text{haz_index+2},'%f');
        fea_props.length_haz_table = weld_index-haz_index-3;
        if (fea_props.length_haz_table) > 0
            for i = 1:fea_props.length_haz_table
                fea_props.haz_se(i,1) = sscanf(Text{haz_index+2+i},'%f,%*f');
                fea_props.haz_se(i,2) = sscanf(Text{haz_index+2+i},'%*f,%f');
            end
        end
        %read weld metal properties
        fea_props.weld_E = sscanf(Text{weld_index+1},'%f');
        fea_props.weld_nu = sscanf(Text{weld_index+2},'%f');
        fea_props.length_weld_table = end_index-weld_index-3;
        if (fea_props.length_weld_table) > 0
            for i = 1:fea_props.length_weld_table
                fea_props.weld_se(i,1) = sscanf(Text{weld_index+2+i},'%f,%*f');
                fea_props.weld_se(i,2) = sscanf(Text{weld_index+2+i},'%*f,%f');
            end
        end
    end
end
end