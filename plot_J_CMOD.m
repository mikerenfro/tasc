clear
close all
load('interp_solution_database.mat');
sizes=zeros(length(result(:)),1);

for i=1:length(sizes)
    sizes(i)=length(result(i).fea.St_far);
end
figure(1);
hist(sizes,10:40);
xlabel('Number of time steps');
ylabel('Number of models');
%%
sample_fraction=0.1;
indices=randperm(length(result(:)),sample_fraction*length(result(:)));
for i=indices
    % fprintf('Model %d has %d steps\n',i,length(result(i).fea.CMOD));
    figure(2);
    % subplot(2,1,1);
    CMOD = result(i).fea.CMOD;
    % J_criteria = mean(result(i).fea.Jtotal_Avg(result(i).fea.Phi>45,:));
    J_criteria = result(i).fea.Jtotal_Avg(end,:);

%     last_20pct=(round(0.8*length(CMOD))+1):length(CMOD);
%     prev_20pct=(round(0.6*length(CMOD))+1):round(0.8*length(CMOD));
    last_20pct = find(CMOD>=0.8*max(CMOD));
    prev_20pct = find(CMOD>=0.6*max(CMOD) & CMOD<0.8*max(CMOD));
    remainder = find(CMOD<0.6*max(CMOD));
    tbl = table(CMOD.', J_criteria.', 'VariableNames', {'CMOD', 'J'});
    lm1 = fitlm(tbl(last_20pct,:), 'linear');
    lm2 = fitlm(tbl(prev_20pct,:), 'linear');

    % plot([0 result(i).fea.CMOD], [0 result(i).fea.Jtotal_Avg(end,:)],'o-')
    plot([0 CMOD(remainder)], [0 J_criteria(remainder)],'o', ...
        CMOD(prev_20pct), J_criteria(prev_20pct), 's', ...
        CMOD(last_20pct), J_criteria(last_20pct), 'd')
    % plot([0 result(i).fea.CMOD], [0 result(i).fea.St_far],'o-')
    title(sprintf('Model %d: %s', i, result(i).fea.FileName), 'interpreter', 'none');
    % ylabel('J(\phi=90)');
    ylabel('|J_{Total}(\phi=90)|');
    % ylabel('\sigma');
    xlabel('CMOD');
    
%     P1=polyfit(CMOD(last_20pct),J_criteria(last_20pct),1);
%     P2=polyfit(CMOD(last_40pct),J_criteria(last_40pct),1);
    hold on;
%     plot(CMOD, P1(1)*CMOD+P1(2),'--');
%     plot(CMOD, P2(1)*CMOD+P2(2),'r');
    plot(CMOD, lm2.Coefficients.Estimate(2)*CMOD+lm2.Coefficients.Estimate(1));
    plot(CMOD, lm1.Coefficients.Estimate(2)*CMOD+lm1.Coefficients.Estimate(1),'--');
    legend('0-60% of range', '61-80% of range', '81-100% of range','Linear fit (61-80% of range)', 'Linear fit (81-100% of range)','Location','Southeast');
    pct_change = (1-lm2.Coefficients.Estimate(2)/lm1.Coefficients.Estimate(2))*100;
    fprintf('Change in slope = %.1f%%\n',pct_change);
    if abs(pct_change)<5
        modelfilename = sprintf('model%03d.png',i);
        title(sprintf('Model %d: %s, %.1f%% change in slope', i, result(i).fea.FileName), pct_change, 'interpreter', 'none');
        print('-dpng', modelfilename);
    end
    hold off;
    pause;
end