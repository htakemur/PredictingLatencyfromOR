function s_figure2A

% Create box plot for C1 peak latency distribution in each stimulus condition.
% This script aims to reproduce Figure 2A in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. 
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% Under Review at eNeuro.

% Hiromasa Takemura, NICT CiNet BIT

% Load data
load ../Data/C1_latency_alltrials.mat

% Average Latency between left and right visual field
latency_plot(1,:) =(latency_v1(3,:) + latency_v1(1,:))./2;
latency_plot(2,:) =(latency_v1(4,:) + latency_v1(2,:))./2;
latency_plot(3,:) =(latency_v1(7,:) + latency_v1(5,:))./2;
latency_plot(4,:) =(latency_v1(8,:) + latency_v1(6,:))./2;

% Create box plot
boxplot(transpose(latency_plot))
set(gca,'XTickLabel',{'UVF/LowContrast','LVF/LowContrast','UVF/HighContrast','LVF/HighContrast'},'fontsize',10);
   ylabel('C1 latency (ms)','fontsize',10);
