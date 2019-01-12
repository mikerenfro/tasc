clear
load('e100_raw.mat','e100_raw');
load('e200_raw.mat','e200_raw');
close all
plot([0 e100_raw.fea.CMOD],[0 e100_raw.fea.St_far]);
hold
plot([0 e200_raw.fea.CMOD],[0 e200_raw.fea.St_far]);
legend('E/\sigma_{ys} = 100', 'E/\sigma_{ys} = 200','location','southeast')
grid
xlabel('CMOD');
ylabel('Far-Field Stress');
title('TASC FEA Inputs (a/c = a/t = 0.6, n = 6)');
axis([0 0.05 0 1.4]);

e100=load('e100.mat');
e150=load('e150.mat');
e200=load('e200.mat');
figure;
plot([0 e100.save_result.fea.CMOD],[0; e100.save_result.fea.St_far])
hold
plot([0 e200.save_result.fea.CMOD],[0; e200.save_result.fea.St_far])
plot([0 e150.save_result.fea.CMOD],[0; e150.save_result.fea.St_far],'--')
legend('E/\sigma_{ys} = 100','E/\sigma_{ys} = 200','E/\sigma_{ys} = 150 (interpolated)','location','southeast')
grid
xlabel('CMOD');
ylabel('Far-Field Stress');
title('TASC Results (a/c = a/t = 0.6, n = 6), after truncation or linear extrapolation')
axis([0 0.05 0 1.4]);

e100_verification=load('e100_verification.mat');
e200_verification=load('e200_verification.mat');
figure;
plot([0 e100_raw.fea.CMOD],[0 e100_raw.fea.St_far]);
hold
plot([0; e100_verification.CMOD],[0; e100_verification.St_far],'o')
plot([0 e200_raw.fea.CMOD],[0 e200_raw.fea.St_far]);
plot([0; e200_verification.CMOD],[0; e200_verification.St_far],'d')
legend('Original TASC Data (E/\sigma_{ys} = 100)',...
    'Reworked (E/\sigma_{ys} = 100)',...
    'Original TASC Data (E/\sigma_{ys} = 200)',...
    'Reworked (E/\sigma_{ys} = 200)',...
    'location','southeast')
grid
xlabel('CMOD');
ylabel('Far-Field Stress');
title('Verification of TASC Results (a/c = a/t = 0.6, n = 6)')
axis([0 0.05 0 1.4]);

e150_verification=load('e150_2_verification.mat');
figure;
plot([0 e100_raw.fea.CMOD],[0 e100_raw.fea.St_far]);
hold
plot([0 e200_raw.fea.CMOD],[0 e200_raw.fea.St_far]);
plot([0 e150.save_result.fea.CMOD],[0; e150.save_result.fea.St_far],'--')
plot([0; e150_verification.CMOD],[0; e150_verification.St_far],'o');
grid
xlabel('CMOD');
ylabel('Far-Field Stress');
title('Verification of TASC Results (a/c = a/t = 0.6, n = 6)')
legend('Original TASC Data (E/\sigma_{ys} = 100)',...
    'Original TASC Data (E/\sigma_{ys} = 200)',...
    'Interpolated TASC Result (E/\sigma_{ys} = 150)',...
    'New FEA Data (E/\sigma_{ys} = 150)',...
    'location','southeast')
