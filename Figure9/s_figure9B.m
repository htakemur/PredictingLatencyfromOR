function s_figure9B

% Create scatter plot of C1 peak latency in left and right visual field
% stimulation (high contrast, lower visual field)
% This script aims to reproduce Figure 9B in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. 
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% Under Review at eNeuro.

% Hiromasa Takemura, NICT CiNet BIT

% Load C1 peak latency data
load ../Data/C1_latency_alltrials.mat

% Set tick label
xtick = [60 80 100];
ytick = [60 80 100];%degree

% Plot C1 peak latency on left LVF/high contrast (horizontal axis) and
% right LVF/high contrast (vertical axis)
scatter(transpose(latency_v1(6,:)),transpose(latency_v1(8,:)),'MarkerEdgeColor',[0 0 0]);
xlim([60 100])
ylim([60 100])
set(gca, 'tickdir', 'out', 'box', 'off', 'xtick',xtick, 'ytick',ytick);
xlabel('C1 latency (ms, Left Visual Field)');
ylabel('C1 latency (ms, Right Visual Field)');
hold on

% Since subjects S9/S13, S12/S15 are identical in this case, we overlay S9 and S12 as a
% filled dot. 
scatter(transpose(latency_v1(6,9)),transpose(latency_v1(8,9)),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
hold on
scatter(transpose(latency_v1(6,12)),transpose(latency_v1(8,12)),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
axis square


