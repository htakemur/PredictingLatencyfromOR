function s_figure2A

% Create box plot for C1 peak latency distribution in each stimulus condition.
% This script aims to reproduce Figure 2A in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. (2020)
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% eNeuro, 7(4), ENEURO.0545-19.2020; DOI: https://doi.org/10.1523/ENEURO.0545-19.2020 

% Hiromasa Takemura, NICT CiNet BIT

% Load data
load ../Data/C1_latency_alltrials.mat

% Average Latency between left and right visual field
latency_plot(1,:) =(latency_v1(3,:) + latency_v1(1,:))./2; %UVF, low contrast
latency_plot(2,:) =(latency_v1(4,:) + latency_v1(2,:))./2; %LVF, low contrast 
latency_plot(3,:) =(latency_v1(7,:) + latency_v1(5,:))./2; %UVF, high contrast
latency_plot(4,:) =(latency_v1(8,:) + latency_v1(6,:))./2; %LVF, high contrast

% Calculate summary statistics in each condition
latency_median = median(latency_plot, 2);
latency_std = std(latency_plot, 0, 2);

% Quantify correlation between latency and age
age = [23 26 22 24 25 22 38 28 31 25 23 38 53 22 34 35 29 22 21 31];

for i =1:4
   [r_age(i), p_age(i)] = corr(transpose(age), transpose(latency_plot(i,:))); 
end

% Create box plot
boxplot(transpose(latency_plot))
set(gca,'XTickLabel',{'UVF/low-contrast','LVF/low-contrast','UVF/high-contrast','LVF/high-contrast'},'fontsize',10);
   ylabel('C1 latency (ms)','fontsize',10);
