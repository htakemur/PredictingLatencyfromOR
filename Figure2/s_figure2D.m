function s_figure2D

% Create bar plot for test-retest reproducibility of C1 peak latency in each stimulus condition.
% This script aims to reproduce Figure 2D in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. 
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% Under Review at eNeuro.

% Hiromasa Takemura, NICT CiNet BIT

% Load Test-Retest Latency data
load ../Data/C1_latency_testretest.mat

% Sort latency data in each stimulus conditions (odd trials)
for kk = 1:20
    latency_v1_LCU(1,kk) = latency_v1(1,kk);
    latency_v1_LCU(2,kk) = latency_v1(3,kk);
    latency_v1_LCD(1,kk) = latency_v1(2,kk);
    latency_v1_LCD(2,kk) = latency_v1(4,kk);
    latency_v1_HCU(1,kk) = latency_v1(5,kk);
    latency_v1_HCU(2,kk) = latency_v1(7,kk);
    latency_v1_HCD(1,kk) = latency_v1(6,kk);
    latency_v1_HCD(2,kk) = latency_v1(8,kk);   
end

% Average equivalent condition across left and right visual field (odd trials)
latency_v1_odd{1} = nanmedian(latency_v1_LCU,1); %UVF, low contrast
latency_v1_odd{2} = nanmedian(latency_v1_LCD,1); %LVF, low contrast
latency_v1_odd{3} = nanmedian(latency_v1_HCU,1); %UVF, high contrast
latency_v1_odd{4} = nanmedian(latency_v1_HCD,1); %LVF, high contrast
clear latency_v1_LCU latency_v1_LCD latency_v1_HCU latency_v1_HCD

% Sort latency data in each stimulus conditions (even trials)
for kk = 1:20
    latency_v1_LCU(1,kk) = latency_v1(9,kk);
    latency_v1_LCU(2,kk) = latency_v1(11,kk);
    latency_v1_LCD(1,kk) = latency_v1(10,kk);
    latency_v1_LCD(2,kk) = latency_v1(12,kk);
    latency_v1_HCU(1,kk) = latency_v1(13,kk);
    latency_v1_HCU(2,kk) = latency_v1(15,kk);
    latency_v1_HCD(1,kk) = latency_v1(14,kk);
    latency_v1_HCD(2,kk) = latency_v1(16,kk);   
end

% Average equivalent condition across left and right visual field (even trials)
latency_v1_even{1} = nanmedian(latency_v1_LCU,1); %UVF, low contrast 
latency_v1_even{2} = nanmedian(latency_v1_LCD,1); %LVF, low contrast
latency_v1_even{3} = nanmedian(latency_v1_HCU,1); %UVF, high contrast
latency_v1_even{4} = nanmedian(latency_v1_HCD,1); %LVF, high contrast

% Bootstrapping for estimating 95% confidence interval of test-retest R
for i = 1:4
[corr_mdlcv_bar(i)] = corr(transpose(latency_v1_odd{i}), transpose(latency_v1_even{i}));
rhos10000{i} = bootstrp(10000, 'corr', transpose(latency_v1_odd{i}), transpose(latency_v1_even{i}));
rhos10000_order{i} = sort(rhos10000{i}, 'ascend');
lowest(i) = rhos10000_order{i}(250);
highest(i) = rhos10000_order{i}(9750);
end

% Plot Test-Retest Reproducibility (R) in each stimulus condition
bar(corr_mdlcv_bar,'FaceColor',[0 0 0]);
hold on
% Plot 95% Confidence Interval
er = errorbar(1:4, corr_mdlcv_bar, (corr_mdlcv_bar - lowest), (highest - corr_mdlcv_bar),'LineWidth',2);
er.Color = 'red';
er.LineStyle = 'none';
ytick = [0 0.2 0.4 0.6 0.8 1];
set(gca, 'tickdir', 'out', 'box', 'off', 'ytick',ytick);
set(gca,'XTickLabel',{'UVF/LowContrast','LVF/LowContrast','UVF/HighContrast','LVF/HighContrast'},'fontsize',10);
ylabel('Test-Retest reproducibility (R)','fontsize',10);
