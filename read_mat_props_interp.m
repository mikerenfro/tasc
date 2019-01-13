function [fea_props]= read_mat_props_interp

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
%[Text] = textread(FullFileName, '%[^\n]');
fid = fopen(FullFileName, 'rt');
ts = textscan(fid, '%[^\r\n]');
Text = ts{1};

% base_index = strmatch('*material', Text);
% end_index = strmatch('*end_material', Text, 'exact');
base_index = find(strncmp('*material', Text, 9));
end_index = find(strncmp('*end_material', Text, 13));
fea_props.base_index = base_index;
% se_index = strmatch('*stress', Text);
se_index = find(strncmp('*stress', Text, 7));
fea_props.se_index = se_index;
%read base metal properties
if ~isempty(base_index)
    % E_index = strmatch('*E', Text);
    E_index = strncmp('*E', Text, 2);
    fea_props.base_E = sscanf(Text{E_index},'%*s %f');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %added these lines 3/8/12 to assist in interpolation routine
    fea_props.FileName = FileName;
    fea_props.FullFileName = FullFileName;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fea_props.length_base_table = end_index-se_index-1;

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
        % Sys_index = strmatch('*Sys', Text);
        % n_index = strmatch('*n', Text);
        Sys_index = strncmp('*Sys', Text, 4);
        n_index = strncmp('*n', Text, 2);
        fea_props.Sys_NotTable = sscanf(Text{Sys_index},'%*s %f');
        fea_props.n = sscanf(Text{n_index},'%*s %f');
        fea_props.base_se(1,1) = 0;
        fea_props.base_se(1,2) = 0;
    end
end

end