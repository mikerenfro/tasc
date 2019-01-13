%program to take the SC J analysis result database and create concise
%summary tables in text and excel format
function create_inputs_ntrp(result, interp, testdata)
%------------***********************--------------------------
%get the file name
file_name = char(result.fea.FileName);
%header data
txt_cell{1,1} = '%-----Interpolation Analysis Input File-----%';
txt_cell{2,1} = '%-----File generated from solution inputs-----%';
txt_cell{3,1} = '%words proceeded with * are keywords for the';
txt_cell{4,1} = '%text scanning program';
%write units string
if result.units == 1
    ustr = 'US';
else
    ustr = 'SI';
end
txt_cell{5,1} = '%---Set Units----% (options are SI or US)';
replace_str = ['*units ' ustr];
txt_cell{6,1} = replace_str;
%write geometry values
% tear_load_type = 2; %tension loading
a = result.fea.a;
c = result.fea.c;
two_c = 2*c;
w = result.fea.width;
B = result.fea.B;
txt_cell{7,1} = '%---Geometry Values----%';
replace_str = ['*2c ' num2str(two_c,'%10.4f')];
txt_cell{8,1} = replace_str;
replace_str = ['*a ' num2str(a,'%10.4f')];
txt_cell{9,1} = replace_str;
replace_str = ['*W ' num2str(w,'%10.4f')];
txt_cell{10,1} = replace_str;
replace_str = ['*B ' num2str(B,'%10.4f')];
txt_cell{11,1} = replace_str;
%write material property values
Sys = interp.Sys;
E = interp.E;
n = interp.n;
txt_cell{12,1} = '%---Material Properties----%';
txt_cell{13,1} = '*material';
replace_str = ['*E ' num2str(E,'%10.2f')];
txt_cell{14,1} = replace_str;
replace_str = ['*Sys ' num2str(Sys,'%10.2f')];
txt_cell{15,1} = replace_str;
replace_str = ['*n ' num2str(n,'%10.2f')];
txt_cell{16,1} = replace_str;
txt_cell{17,1} = '*end_material';
%
%write test prediction values
if interp.cb_test_predict == 1
    Jc = result.crit_Jc;
    crit_phi = result.crit_phi;
    txt_cell{18,1} = '%---Pre-test Predicion Values----%';
    txt_cell{19,1} = '*pretest';
    replace_str = ['*Jc ' num2str(Jc,'%10.3f')];
    txt_cell{20,1} = replace_str;
    replace_str = ['*phi_crit ' num2str(crit_phi,'%10.3f')];
    txt_cell{21,1} = replace_str;
end
%
%write test analysis values
if interp.cb_eval_test == 1
    tear_load = result.tear_load;
    tear_angle = result.tear_angle;
    force = testdata.force;
    CMOD = testdata.CMOD;
    size_data = length(force);
    txt_cell{18,1} = '%---Test Evaluation----%';
    txt_cell{19,1} = '*test_eval';
    replace_str = ['*tear_force ' num2str(tear_load,'%10.3f')];
    txt_cell{20,1} = replace_str;
    replace_str = ['*tear_phi ' num2str(tear_angle,'%10.3f')];
    txt_cell{21,1} = replace_str;
    txt_cell{22,1} = '*CMOD	Force';
    for j = 1:size_data
        replace_str = [num2str(CMOD(j),'%14.6f'), '  ' num2str(force(j),'%14.4f')];
        txt_cell{22+j,1} = replace_str;
    end
    txt_cell{22+size_data+1,1} = '*end_test_data';
end


%%
%create txt file with *.ntrp input data

TxtName = strcat(file_name,'_inputs.ntrp');
%TxtName = 'try.txt';
TXT = fopen(TxtName,'w');
% replace_str = [];
%
for i = 1:length(txt_cell)
    replace_str = char(txt_cell(i,1));
    fprintf(TXT,'%s\r\n',replace_str);
end
fclose(TXT);
end
