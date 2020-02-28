function s_figure2B

% Create scatter plot for test-retest reproducibility of C1 peak latency in high contrast/lower visual field condition.
% This script aims to reproduce Figure 2B in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. 
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% Under Review at eNeuro.

% Hiromasa Takemura, NICT CiNet BIT

load ../Data/C1_latency_testretest.mat

% Find C1 peak latency data in high contrast, lower visual field (odd
% trial)
for kk = 1:20
    latency_v1_HCD(1,kk) = latency_v1(6,kk); % Left Lower Visual Field, High contrast
    latency_v1_HCD(2,kk) = latency_v1(8,kk); % Right Lower Visual Field, High contrast
end

% Average C1 latency in left and right visual field in odd trials
latency_v1_HCD_odd = nanmedian(latency_v1_HCD,1);
clear latency_v1_HCD

% Find C1 peak latency data in high contrast, lower visual field (even
% trial)
for kk = 1:20
    latency_v1_HCD(1,kk) = latency_v1(14,kk); % Left Lower Visual Field, High contrast
    latency_v1_HCD(2,kk) = latency_v1(16,kk); % Right Lower Visual Field, High contrast
end

% Average C1 latency in left and right visual field in even trials
latency_v1_HCD_even = nanmedian(latency_v1_HCD,1);
clear latency_v1_HCD

% Set the limit of scattter plot
h1.xlim(1) = 60; % X axis, the minimum limit
h1.xlim(2) = 100; % X axis, the maximum limit
h1.ylim(1) = 60; % Y axis, the minimum limit
h1.ylim(2) = 100; % Y axis, the maximum limit

% Set tick label
xtick = [60 80 100];
ytick = [60 80 100];%degree

% Draw scatter plot
fig = figure;
hold on
box off
plot(latency_v1_HCD_odd,latency_v1_HCD_even, 'Linestyle','none','Marker','o','MarkerEdgeColor','k', 'MarkerFaceColor','none', 'MarkerSize',8);
set(gca, 'tickdir', 'out', 'box', 'off', 'xlim', h1.xlim,'xtick',xtick, 'ylim', h1.ylim,'ytick',ytick);

% add 95% bootstrap CI
Critical = 0.05;%critical region
y = latency_v1_HCD_even';
x = [ones(size(y)) latency_v1_HCD_odd'];
b = regress(y,x);
yfit = x*b;
repetition = 10000;
[coefficient index] = bootstrp(...
         repetition,@regress,y,x);
xfig = xtick(1):0.001:xtick(end);
for j =1:length(xfig)
    for k = 1:repetition
        y_candi(k) = coefficient(k,2)*xfig(j) + coefficient(k,1);
    end
    y_candi_sort = sort(y_candi);
    y_down(j) = y_candi_sort(repetition*Critical/2);
    y_up(j) = y_candi_sort(repetition*(1-Critical/2));
    clear y_candi
end
plot(xfig,y_down,'c-','LineWidth',0.2)
plot(xfig,y_up,'c-','LineWidth',0.2)
y_hat = @(i) b(2)*i+b(1);
plot(xfig,y_hat(xfig),'Color','k','LineWidth',2);

% Calculate Test-Retest Reproducubility (Correlation Coefficient, R)
[r] = corr(transpose(latency_v1_HCD_odd),transpose(latency_v1_HCD_even));
xlabel('C1 peak latency (odd trials)');
ylabel('C1 peak latency (even trials)');
titlelabel = ['Test-Retest R = ' num2str(r)];
title(titlelabel);

