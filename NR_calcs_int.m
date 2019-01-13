function KI = NR_calcs_int(a,two_c,two_W,t,sigma_m,sigma_b,phi)

%--------------------------------------------------------------------------
% 11-24-09
% Calculates and plots KI for a surface crack in a flat plate - Uses the
% Updated Newman-Raju equations.
% -------------------------------------------------------------------------

% -- Define geometry of specimen and crack
c = two_c / 2;
W = two_W / 2;

phi = phi / 360 * 2 * pi;

% -- Employ the Newman-Raju equations
KI = zeros(size(phi));

%for i = 1:19
for i = 1:length(phi)
    
    Q = 1 + 1.464 * ((a/c)^1.65);
    
    M1 = 1.13 - 0.09 * (a/c);
    M2 = -0.54 + 0.89 / (0.2 + (a/c));
    M3 = 0.5 - 1 / (0.65 + (a/c)) + 14 * (1.0 - (a/c))^24;
    
    f_phi = ((a/c)^2 * (cos(phi(i)))^2 + (sin(phi(i)))^2)^0.25;
    f_wb = sqrt(sec(pi() * c / (2*W) * sqrt(a/t)));
    ft1 = 1+(0.38*(a/c)*(a/t)*((c/W)^2)*cos(phi(i)));
    f_wt = ft1*(sqrt(sec(pi() * c / (2*W) * sqrt(a/t*(1-0.6*sin(phi(i)))))));
    g = 1 + (0.1 + 0.35 * (a/t)^2) * (1 - sin(phi(i)))^2;
    
    Ft = (M1 + M2 * (a/t)^2 + M3 * (a/t)^4) * f_phi * f_wt * g;
    Fb = (M1 + M2 * (a/t)^2 + M3 * (a/t)^4) * f_phi * f_wb * g;
    
    G1 = -1.22 - 0.12 * (a/c);
    G2 = 0.55 - 1.05 * (a/c)^0.75 + 0.47 * (a/c)^1.5;
    
    H1 = 1 - 0.34 * (a/t) - 0.11 * (a/c) * (a/t);
    H2 = 1 + G1 * (a/t) + G2 * (a/t)^2;
    p = 0.2 + (a/c) + 0.6 * (a/t);
    
    H = H1 + (H2 - H1) * (sin(phi(i)))^p;
    
    KI(i) = (sigma_m*Ft + (H * sigma_b*Fb)) * sqrt(pi() * a / Q);
    
end
