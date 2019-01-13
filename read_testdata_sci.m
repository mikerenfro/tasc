%--function to read in load - CMOD test data
function [testdata]= read_testdata_sci
[FileName2,PathName2] = uigetfile({'*.txt'},'Select File');
if FileName2 == 0
    return;
end
handles.FullFileName2 = strcat(PathName2,FileName2);
handles.FileName2 = FileName2;
handles.PathName2 = PathName2;
testdata.testdata_filename = FileName2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Text] = textread(handles.FullFileName2, '%[^\n]');
fid = fopen(handles.FullFileName2, 'rt');
ts = textscan(fid, '%[^\r\n]');
Text = ts{1};
% data_index = strmatch('*CMOD', Text);
data_index = find(strncmp('*CMOD',Text,5)==1);
if isempty(data_index)
    errordlg('"*CMOD" keword not found, please import a test data file with the appropriate format');
else
    % end_data_index = strmatch('*end_test_data', Text);
    end_data_index = find(strncmp('*end_test_data',Text,14)==1);
    data_length = end_data_index-data_index-1;
    for i = 1:data_length
        %use textscan to allow reading of tab, space, or comma delimited
        %data
        testdata.CMOD_cell(i) = textscan(Text{data_index+i},'%f %*f', 'delimiter', ',');
        testdata.force_cell(i) = textscan(Text{data_index+i},'%*f %f', 'delimiter', ',');
        %pull out of cell array
        testdata.CMOD(i) = testdata.CMOD_cell{i};
        testdata.force(i) = testdata.force_cell{i};
    end
end
end
