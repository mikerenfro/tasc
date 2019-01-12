%Function to use crit Jc and phi values to perform pretest prediction for
%test tearing load and CMOD
function [result]= pretest_predict(result)
%flag to signify sucessful prediction for program logic
result.predict_flag = 0;
%get some needed values
Jc = result.crit_Jc;
phi_tear = result.crit_phi;
Jt = result.fea.Jtotal_Avg;
phi_fea = result.fea.Phi;
fea_force = result.fea.reac_force;
fea_CMOD = result.fea.CMOD;
%find the phi result closest to crit phi
[C,I] = min(abs(phi_fea-phi_tear));
%make sure the Jc value is not greater than the max Jc in the data set
max_J = max(Jt(I,:));
if Jc <= max_J
   result.predict_flag = 1;
   X = Jt(I,:);
   Y = fea_force;
   Xi = Jc;
   result.tear_load = interp1(X,Y,Xi,'linear');
   X = Jt(I,:);
   Y = fea_CMOD;
   Xi = Jc;
   result.tear_CMOD = interp1(X,Y,Xi,'linear');
   result.tear_angle = phi_tear;
else
    er_box = errordlg('Crit. J value is larger than max. J(crit_phi).  Pick smaller value of J crit.');
    
end

end
%