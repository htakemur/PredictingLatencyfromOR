function s_figure2B

% Create box plot for normalized C1 peak amplitude in each stimulus condition.
% This script aims to reproduce Figure 2B in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. (2020)
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% eNeuro, 7(4), ENEURO.0545-19.2020; DOI: https://doi.org/10.1523/ENEURO.0545-19.2020 

% Hiromasa Takemura, NICT CiNet BIT

% Load data
load ../Data/C1_dipole_timecourse.mat
load ../Data/C1_latency_alltrials.mat

% Calculate normalized amplitude (normalized to the baseline)
for j = 1:20
    for i = 1:8
        baseline_mean = mean(timecourse(j, 1:200, i)); % Calculate mean amplitude in the baseline period (-200 to -1 ms; before stimulus onset)
        baseline_std = std(timecourse(j, 1:200, i),0,2); % Standard deviation of response amplitude in the baseline period
        C1_amplitude(i,j) = timecourse(j, (latency_v1(i,j)+199), i); % Pick amplitude at peak C1 latency
        C1_amplitude_norm(i,j) = (C1_amplitude(i,j) - baseline_mean)/baseline_std; % Normalize amplitude
    end
end

% Average amplitude in left and right visual field stimulation
amplitude_plot(1,:) = (C1_amplitude_norm(3,:) + C1_amplitude_norm(1,:))./2; %UVF, low contrast
amplitude_plot(2,:) = (C1_amplitude_norm(4,:) + C1_amplitude_norm(2,:))./2; %LVF, low contrast
amplitude_plot(3,:) = (C1_amplitude_norm(7,:) + C1_amplitude_norm(5,:))./2; %UVF, high contrast
amplitude_plot(4,:) = (C1_amplitude_norm(8,:) + C1_amplitude_norm(6,:))./2; %LVF, high contrast

% Set tick label
ytick = [0 15 30 45];
h1.ylim(1) = 0; % Y axis, the minimum limit
h1.ylim(2) = 45; % Y axis, the maximum limit

% Creat Box Plot
boxplot(transpose(amplitude_plot))
set(gca,'XTickLabel',{'UVF/low-contrast','LVF/low-contrast','UVF/high-contrast','LVF/high-contrast'},'fontsize',10);
set(gca, 'tickdir', 'out', 'box', 'off',  'ylim', h1.ylim,'ytick',ytick);

ylabel('Normalized C1 peak amplitude (s.d. from baseline)','fontsize',10);
