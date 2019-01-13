%function to perform interpolation between values in result structure
%to determine solution for given E/Sys, n, a/c, and a/B
%interpolation scheme based on CMOD matching
%11/20/12 - Modify code to also calcualte interpolated sigma_far
%----------------------------------------------------------------%
function [Tmp,Tmp2,Tmp3,Tmp4,Final] = interp_solution_SCGui_CMOD_log_int(input,result,aB_pick,ac_pick,n_pick,E_pick)
%choose the number of load step increments for interpolation
n_steps = 20;
%choose the number of phi increments for interploated solution
n_phi = 45; % eg. 90/45 = 2 degrees; solution every 2 degrees
%--------------------------------------------------------------
%--------------------------------------------------------------
%end of inputs
%--------------------------------------------------------------
%--------------------------------------------------------------
%find appropriate index values for E, n, a/c and a/B arrays based
%on choices for E, n, a/c and a/B
ac_index = find(input.ac_array >= ac_pick,1,'first');
aB_index = find(input.aB_array >= aB_pick,1,'first');
n_index = find(input.n_array >= n_pick,1,'first');
E_index = find(input.E_array >= E_pick,1,'first');
%if the index =1, adjust the index to 2 to allow 2 sets to be picked
%to interpolate between in the following code
if ac_index == 1
    ac_index = 2;
end
%
if aB_index == 1
    aB_index = 2;
end
%
if n_index == 1
    n_index = 2;
end
%
if E_index == 1
    E_index = 2;
end
%
ac_bounds = [input.ac_array(ac_index-1) input.ac_array(ac_index)];
aB_bounds = [input.aB_array(aB_index-1) input.aB_array(aB_index)];
n_bounds = [input.n_array(n_index-1) input.n_array(n_index)];
E_bounds = [input.E_array(E_index-1) input.E_array(E_index)];
%pick 16 result sets from result(a/B,a/C,n,E) database (i,j,k,l) index
%letters A,B,C,D refer to 4 geometry combinations
% numbers 1,2,3,4 refer to 4 material combinations
Tmp(1,1) = result(aB_index-1,ac_index-1,n_index-1,E_index-1).fea; %A1
Tmp(1,2) = result(aB_index-1,ac_index,n_index-1,E_index-1).fea; %B1
Tmp(1,3) = result(aB_index,ac_index-1,n_index-1,E_index-1).fea; %C1
Tmp(1,4) = result(aB_index,ac_index,n_index-1,E_index-1).fea; %D1
%%%%
Tmp(2,1) = result(aB_index-1,ac_index-1,n_index-1,E_index).fea; %A2
Tmp(2,2) = result(aB_index-1,ac_index,n_index-1,E_index).fea; %B2
Tmp(2,3) = result(aB_index,ac_index-1,n_index-1,E_index).fea; %C2
Tmp(2,4) = result(aB_index,ac_index,n_index-1,E_index).fea; %D2
%%%%
Tmp(3,1) = result(aB_index-1,ac_index-1,n_index,E_index-1).fea; %A3
Tmp(3,2) = result(aB_index-1,ac_index,n_index,E_index-1).fea; %B3
Tmp(3,3) = result(aB_index,ac_index-1,n_index,E_index-1).fea; %C3
Tmp(3,4) = result(aB_index,ac_index,n_index,E_index-1).fea; %D3
%%%%
Tmp(4,1) = result(aB_index-1,ac_index-1,n_index,E_index).fea; %A4
Tmp(4,2) = result(aB_index-1,ac_index,n_index,E_index).fea; %B4
Tmp(4,3) = result(aB_index,ac_index-1,n_index,E_index).fea; %C4
Tmp(4,4) = result(aB_index,ac_index,n_index,E_index).fea; %D4
%------------------------------------------------------
%now calculate far stress and net stress for each set
%and see which set has the minimum Sfar and Snet
k = 1;
for i = 1:4
    for j = 1:4
        Tmp(i,j).A = Tmp(i,j).width*Tmp(i,j).B;
        Tmp(i,j).An = Tmp(i,j).A - 3.141592*Tmp(i,j).a*Tmp(i,j).c/2;
        Tmp(i,j).A_ratio = Tmp(i,j).An/Tmp(i,j).A;
        Tmp(i,j).A_ratio_inv = Tmp(i,j).A/Tmp(i,j).An;
        Tmp(i,j).net_stress = Tmp(i,j).A_ratio_inv*Tmp(i,j).St_far;
        Tmp(i,j).max_net_stress = Tmp(i,j).net_stress(length(Tmp(i,j).net_stress));
        Tmp(i,j).max_far_stress = Tmp(i,j).St_far(length(Tmp(i,j).St_far));
        Tmp(i,j).max_CMOD = Tmp(i,j).CMOD(length(Tmp(i,j).CMOD));
        max_net_stress(k) = Tmp(i,j).max_net_stress; %#ok<AGROW>
        max_far_stress(k) = Tmp(i,j).max_far_stress; %#ok<AGROW>
        max_CMOD(k) = Tmp(i,j).max_CMOD; %#ok<AGROW>
        k = k+1;
    end
end
%find the smallest max. net, far stress, and CMOD.
net_stress_limit = min(max_net_stress);
far_stress_limit = min(max_far_stress);
minimum_CMOD = min(max_CMOD);
maximum_CMOD = max(max_CMOD);
avg_CMOD = (minimum_CMOD + maximum_CMOD)/2;
% %calculate the load increments based on
% %the number of load steps and log 10 spacing
% %use log spacing to get more load interp. at final loads
% spacing = log10(1:(9/n_steps):10)';
% dif_vect = diff(spacing);
% check = sum(dif_vect); %differences sum to 1?
% final_spacing = spacing(2:end); % drop first 0
%uniform spacing code
spacer = 1/n_steps;
final_spacing = (spacer:spacer:1)';
%plot(final_spacing,'rx');
%ylim([0 1]);
%net_stress_inc = net_stress_limit*final_spacing;
%far_stress_inc = far_stress_limit*final_spacing;
CMOD_inc = avg_CMOD*final_spacing;
%%
%code to extrap solutions to CMOD_avg value if max CMOD in solution set
%is less than that value
for i = 1:4
    for j = 1:4
        if Tmp(i,j).max_CMOD < avg_CMOD
            %fit Power law Power2 function to last 5 data points
            xdata = Tmp(i,j).CMOD(end-4:end)';
            ydata = Tmp(i,j).net_stress(end-4:end)';
            ydata2 = Tmp(i,j).St_far(end-4:end)';
            %code below uses CF toolbox
            plFit = fit(xdata, ydata,'power2');
            plFit2 = fit(xdata, ydata2,'power2');
            %create 5 points to extend data from end point to avg_CMOD
            spaceIT = (avg_CMOD-Tmp(i,j).max_CMOD)/5;
            lengthIT = length(Tmp(i,j).CMOD);
            for k = 1:4
                %add new CMOD point
                Tmp(i,j).CMOD(lengthIT + k) = Tmp(i,j).max_CMOD+ spaceIT*k;
                %calculate new net stress point using Power2 fit
                Tmp(i,j).net_stress(lengthIT + k) = plFit(Tmp(i,j).CMOD(lengthIT + k));
                Tmp(i,j).St_far(lengthIT + k) = plFit2(Tmp(i,j).CMOD(lengthIT + k));
                %                 %interpolate to calc new Jtotal and Jel values
                for l = 1:length(Tmp(i,j).Phi)
                    X = Tmp(i,j).CMOD(1:lengthIT + k-1);
                    Y = Tmp(i,j).Jtotal_Avg(l,1:lengthIT + k-1);
                    Yel = Tmp(i,j).Jel_EPFM(l,1:lengthIT + k-1);
                    Xi = Tmp(i,j).CMOD(lengthIT + k);
                    Tmp(i,j).Jtotal_Avg(l,lengthIT + k) = interp1(X,Y,Xi,'linear','extrap' );
                    Tmp(i,j).Jel_EPFM(l,lengthIT + k) = interp1(X,Yel,Xi,'linear','extrap' );
                end
            end
            %add on last point at exactly the avg CMOD value
            lengthIT = length(Tmp(i,j).CMOD);
            Tmp(i,j).CMOD(lengthIT + 1) = avg_CMOD;
            Tmp(i,j).net_stress(lengthIT + 1) = plFit(Tmp(i,j).CMOD(lengthIT + 1));
            Tmp(i,j).St_far(lengthIT + 1) = plFit2(Tmp(i,j).CMOD(lengthIT + 1));
            %interpolate to calc new Jtotal and Jel values
            for l = 1:length(Tmp(i,j).Phi)
                X = Tmp(i,j).CMOD(1:lengthIT);
                Y = Tmp(i,j).Jtotal_Avg(l,1:lengthIT);
                Yel = Tmp(i,j).Jel_EPFM(l,1:lengthIT);
                Xi = Tmp(i,j).CMOD(lengthIT + 1);
                Tmp(i,j).Jtotal_Avg(l,lengthIT + 1) = interp1(X,Y,Xi,'linear','extrap' );
                Tmp(i,j).Jel_EPFM(l,lengthIT + 1) = interp1(X,Yel,Xi,'linear','extrap' );
            end
        end
    end
end
%%
%reset phi increment to same increment for each set
%for interpolated solution
phi_inc = 90/n_phi;
interp_phi = (0:phi_inc:90);
%interpolate J_total and J_elastic vs phi solutions for all
%load steps based on the new phi spacing
for i = 1:4
    for j = 1:4
        for k = 1:size(Tmp(i,j).Jtotal_Avg,2)
            X = Tmp(i,j).Phi;
            Y = Tmp(i,j).Jtotal_Avg(:,k);
            Yel = Tmp(i,j).Jel_EPFM(:,k);
            Xi = interp_phi;
            Tmp(i,j).Jtotal(:,k) = interp1(X,Y,Xi,'linear','extrap' );
            Tmp(i,j).Jel(:,k) = interp1(X,Yel,Xi,'linear','extrap' );
        end
    end
end
%Now interpolate results from current CMOD steps to new CMOD step space
for i = 1:4
    for j = 1:4
        for k = 1:length(CMOD_inc)
            %net stress corresponding to CMOD increment
            Y = Tmp(i,j).net_stress;
            Y2 = Tmp(i,j).St_far;
            X = Tmp(i,j).CMOD;
            Xi = CMOD_inc(k);
            Tmp(i,j).int_net_stress(k) = interp1(X,Y,Xi,'linear','extrap');
            Tmp(i,j).int_far_stress(k) = interp1(X,Y2,Xi,'linear','extrap');
            %calculate reaction force corresponding to net stress increment
            Tmp(i,j).int_reac_force(k) = Tmp(i,j).int_far_stress(k)*Tmp(i,j).A;
            Tmp(i,j).int_reac_force_net(k) = Tmp(i,j).int_net_stress(k)*Tmp(i,j).An;
            Tmp(i,j).CMOD_inc(k) = CMOD_inc(k);
            %write to int_CMOD variable for old plotting framework
            Tmp(i,j).int_CMOD(k) = CMOD_inc(k);
        end
        
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*update* *V1.0.2* 06/5/14
%Add zeros column (or value) to CMOD and J data at "zero" load step time to ensure
%proper interpolation for the first new CMOD load increment for FEA data
%sets that have initial CMOD values less than the new 20 increment CMOD
%step 1 values
%added or modified rows 201-214
%Calculate Jtotal and Jel corresponding to CMOD increment
for i = 1:4
    for j = 1:4
        for k = 1:length(CMOD_inc)
            X = interp_phi';
            Xi = interp_phi';
            Y = [0.0, Tmp(i,j).CMOD];
            Z = [zeros(size(Tmp(i,j).Jtotal,1),1), Tmp(i,j).Jtotal];
            Zel = [zeros(size(Tmp(i,j).Jel,1),1), Tmp(i,j).Jel];
            Z = Z';
            Zel = Zel';
            Yi = CMOD_inc(k);
            Tmp(i,j).int_Jtotal(:,k) = interp2(X,Y,Z,Xi,Yi,'linear');
            Tmp(i,j).int_Jel(:,k) = interp2(X,Y,Zel,Xi,Yi,'linear');
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%assignin('base', 'Tmp', Tmp);
%%
%-----------------------------------------------------------
%now have 16 model results prepared for interpolation between
%solutions to get to final result
%-----------------------------------------------------------
%first interpolate between the geometry values for a given
%set of material properties
%this will reduce the 16 data sets to 8 data sets and then to 4 data sets
%-----------------------------------------------------------
%-----------perform a/c interpolation--------------------------
%interpolate to get the Jtotal and Jelastic solutions
for i = 1:4
    for k = 1:length(CMOD_inc)
        X = ac_bounds';
        Xi = ac_pick;
        Y = interp_phi;
        Z = [Tmp(i,1).int_Jtotal(:,k) Tmp(i,2).int_Jtotal(:,k)];
        Z2 = [Tmp(i,3).int_Jtotal(:,k) Tmp(i,4).int_Jtotal(:,k)];
        Zel = [Tmp(i,1).int_Jel(:,k) Tmp(i,2).int_Jel(:,k)];
        Z2el = [Tmp(i,3).int_Jel(:,k) Tmp(i,4).int_Jel(:,k)];
        Yi = interp_phi;
        Tmp2(i,1).int_Jtotal(:,k) = interp2(X,Y,Z,Xi,Yi,'linear'); %#ok<AGROW>
        Tmp2(i,2).int_Jtotal(:,k) = interp2(X,Y,Z2,Xi,Yi,'linear'); %#ok<AGROW>
        Tmp2(i,1).int_Jel(:,k) = interp2(X,Y,Zel,Xi,Yi,'linear'); %#ok<AGROW>
        Tmp2(i,2).int_Jel(:,k) = interp2(X,Y,Z2el,Xi,Yi,'linear'); %#ok<AGROW>
    end
end
%interpolate to get net and far stress solution
for i = 1:4
    X = ac_bounds';
    Xi = ac_pick;
    Y = [Tmp(i,1).int_net_stress; Tmp(i,2).int_net_stress];
    Y2 = [Tmp(i,3).int_net_stress; Tmp(i,4).int_net_stress];
    Yb = [Tmp(i,1).int_far_stress; Tmp(i,2).int_far_stress];
    Y2b = [Tmp(i,3).int_far_stress; Tmp(i,4).int_far_stress];
    for k = 1:length(CMOD_inc)
        Tmp2(i,1).int_net_stress(k) = interp1(X,Y(:,k),Xi,'linear');
        Tmp2(i,2).int_net_stress(k) = interp1(X,Y2(:,k),Xi,'linear');
        Tmp2(i,1).int_far_stress(k) = interp1(X,Yb(:,k),Xi,'linear');
        Tmp2(i,2).int_far_stress(k) = interp1(X,Y2b(:,k),Xi,'linear');
        Tmp2(i,1).int_CMOD(k) = CMOD_inc(k);
        Tmp2(i,2).int_CMOD(k) = CMOD_inc(k);
    end
end
%%
%-----------------------------------------------------------
%-----------------------------------------------------------
%-----------perform a/B interpolation--------------------------
%reduces the number of solutions to 4 with consistent geometry (a/c, a/B)
%interpolate to get the Jtotal and Jelastic solutions
for i = 1:4
    for k = 1:length(CMOD_inc)
        X = aB_bounds';
        Xi = aB_pick;
        Y = interp_phi;
        Z = [Tmp2(i,1).int_Jtotal(:,k) Tmp2(i,2).int_Jtotal(:,k)];
        Zel = [Tmp2(i,1).int_Jel(:,k) Tmp2(i,2).int_Jel(:,k)];
        Yi = interp_phi;
        Tmp3(i,1).int_Jtotal(:,k) = interp2(X,Y,Z,Xi,Yi,'linear'); %#ok<AGROW>
        Tmp3(i,1).int_Jel(:,k) = interp2(X,Y,Zel,Xi,Yi,'linear'); %#ok<AGROW>
    end
end
%interpolate to get net stress solution
for i = 1:4
    X = aB_bounds';
    Xi = aB_pick;
    Y = [Tmp2(i,1).int_net_stress; Tmp2(i,2).int_net_stress];
    Yb = [Tmp2(i,1).int_far_stress; Tmp2(i,2).int_far_stress];
    for k = 1:length(CMOD_inc)
        Tmp3(i,1).int_net_stress(k) = interp1(X,Y(:,k),Xi,'linear');
        Tmp3(i,1).int_far_stress(k) = interp1(X,Yb(:,k),Xi,'linear');
        Tmp3(i,1).int_CMOD(k) = CMOD_inc(k);
    end
end
%%
%-----------------------------------------------------------
%-----------------------------------------------------------
%-----------perform "n" interpolation--------------------------
%reduces the number of solutions to 2 with consistent geometry (a/c, a/B)
%and consistent hardening "n"
%interpolate to get the Jtotal and Jelastic solutions

for k = 1:length(CMOD_inc)
    X = n_bounds';
    Xi = n_pick;
    Y = interp_phi;
    Z = [Tmp3(1,1).int_Jtotal(:,k) Tmp3(3,1).int_Jtotal(:,k)];
    Z2 = [Tmp3(2,1).int_Jtotal(:,k) Tmp3(4,1).int_Jtotal(:,k)];
    Zel = [Tmp3(1,1).int_Jel(:,k) Tmp3(3,1).int_Jel(:,k)];
    Z2el = [Tmp3(2,1).int_Jel(:,k) Tmp3(4,1).int_Jel(:,k)];
    Yi = interp_phi;
    Tmp4(1,1).int_Jtotal(:,k) = interp2(X,Y,Z,Xi,Yi,'linear');
    Tmp4(2,1).int_Jtotal(:,k) = interp2(X,Y,Z2,Xi,Yi,'linear');
    Tmp4(1,1).int_Jel(:,k) = interp2(X,Y,Zel,Xi,Yi,'linear');
    Tmp4(2,1).int_Jel(:,k) = interp2(X,Y,Z2el,Xi,Yi,'linear');
end

%interpolate to get net stress solution

X = n_bounds';
Xi = n_pick;
Y = [Tmp3(1,1).int_net_stress; Tmp3(3,1).int_net_stress];
Y2 = [Tmp3(2,1).int_net_stress; Tmp3(4,1).int_net_stress];
Yb = [Tmp3(1,1).int_far_stress; Tmp3(3,1).int_far_stress];
Y2b = [Tmp3(2,1).int_far_stress; Tmp3(4,1).int_far_stress];
for k = 1:length(CMOD_inc)
    Tmp4(1,1).int_net_stress(k) = interp1(X,Y(:,k),Xi,'linear');
    Tmp4(2,1).int_net_stress(k) = interp1(X,Y2(:,k),Xi,'linear');
    Tmp4(1,1).int_far_stress(k) = interp1(X,Yb(:,k),Xi,'linear');
    Tmp4(2,1).int_far_stress(k) = interp1(X,Y2b(:,k),Xi,'linear');
    Tmp4(1,1).int_CMOD(k) = CMOD_inc(k);
    Tmp4(2,1).int_CMOD(k) = CMOD_inc(k);
end
%%
%-----------------------------------------------------------
%-----------------------------------------------------------
%-----------perform "E/Sys" interpolation--------------------------
%calculates the final solution with consistent geometry (a/c, a/B)
%and consistent hardening "n", and E/Sys
%interpolate to get the Jtotal and Jelastic solutions

for k = 1:length(CMOD_inc)
    X = E_bounds';
    X = log10(X);
    Xi = log10(E_pick);
    Y = interp_phi;
    %perform interp in log10 space
    Z = [(Tmp4(1,1).int_Jtotal(:,k)) (Tmp4(2,1).int_Jtotal(:,k))];
    Zel = [(Tmp4(1,1).int_Jel(:,k)) (Tmp4(2,1).int_Jel(:,k))];
    Yi = interp_phi;
    Final.int_Jtotal(:,k) = interp2(X,Y,Z,Xi,Yi,'linear');
    Final.int_Jel(:,k) = interp2(X,Y,Zel,Xi,Yi,'linear');
end

%interpolate to get net stress solution

X = E_bounds';
X = log10(X);
Xi = log10(E_pick);
Y = [(Tmp4(1,1).int_net_stress); (Tmp4(2,1).int_net_stress)];
Yb = [(Tmp4(1,1).int_far_stress); (Tmp4(2,1).int_far_stress)];
for k = 1:length(CMOD_inc)
    Final.int_net_stress(k) = interp1(X,Y(:,k),Xi,'linear');
    Final.int_far_stress(k) = interp1(X,Yb(:,k),Xi,'linear');
end

%-----------------------------------------------------------
%-----------------------------------------------------------
%write values to "final" structure for output from function
Final.n_steps = n_steps;
Final.n_phi = n_phi;
Final.ac_index = ac_index;
Final.aB_index = aB_index;
Final.n_index = n_index;
Final.E_index = E_index;
Final.ac_bounds = ac_bounds;
Final.aB_bounds = aB_bounds;
Final.n_bounds = n_bounds;
Final.E_bounds = E_bounds;
Final.net_stress_limit = net_stress_limit;
Final.far_stress_limit = far_stress_limit;
Final.max_net_stress = max_net_stress;
Final.max_far_stress = max_far_stress;
Final.final_spacing = final_spacing;
Final.net_stress_inc = Final.int_net_stress';
Final.far_stress_inc = Final.int_far_stress';
%Final.far_stress_inc = far_stress_inc;
Final.CMOD_inc = CMOD_inc;
Final.int_CMOD = CMOD_inc';
Final.phi_inc = phi_inc;
Final.interp_phi = interp_phi;
%estimate a A_net/A_far ratio for the solution set
k = 1;
for i = 1:4
    for j = 1:4
        A_ratio(k) = Tmp(i,j).A_ratio; %#ok<AGROW>
        k = k+1;
    end
end
Final.A_ratio = mean(A_ratio);
%----------------------------------------------------------
%clearvars -except 'input' 'result'
