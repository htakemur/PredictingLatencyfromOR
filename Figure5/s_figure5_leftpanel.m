function s_figure5_leftpanel

% (1) Perform prediction for C1 peak latency (upper visual field/lower contrast) from optic radiation data with
% leave-one-out cross validation. 
% (2) Create scatter plot between Measured and Predicted C1 peak latency. 
% This script aims to reproduce Figure 5, left panel in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. 
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% Under Review at eNeuro.

% Hiromasa Takemura, NICT CiNet BIT

% Load data from left OR
load ../Data/Left_OR_tractproperty.mat

% Average metrics along OR. For dMRI metric, we average data across two
% runs.
index_mean_LH(:,1) = (mean(all_profile.fa1(11:90,:),1) + mean(all_profile.fa2(11:90,:),1))/2;
index_mean_LH(:,2) = (mean(all_profile.md1(11:90,:),1) + mean(all_profile.md2(11:90,:),1))/2;
index_mean_LH(:,3) = mean(all_profile.qt1(11:90,:),1);
index_mean_LH(:,4) = (mean(all_profile.odi1(11:90,:),1) + mean(all_profile.odi2(11:90,:),1))/2;
index_mean_LH(:,5) = (mean(all_profile.icvf1(11:90,:),1) + mean(all_profile.icvf2(11:90,:),1))/2;

% Load data from right OR
load  ../Data/Right_OR_tractoproperty.mat

% Average metrics along OR. For dMRI metric, we average data across two
% runs.
index_mean_RH(:,1) = (mean(all_profile.fa1(11:90,:),1) + mean(all_profile.fa2(11:90,:),1))/2;
index_mean_RH(:,2) = (mean(all_profile.md1(11:90,:),1) + mean(all_profile.md2(11:90,:),1))/2;
index_mean_RH(:,3) = mean(all_profile.qt1(11:90,:),1);
index_mean_RH(:,4) = (mean(all_profile.odi1(11:90,:),1) + mean(all_profile.odi2(11:90,:),1))/2;
index_mean_RH(:,5) = (mean(all_profile.icvf1(11:90,:),1) + mean(all_profile.icvf2(11:90,:),1))/2;

% Average across hemisphere to create OR variable for predicting C1 peak
% latency
x = (index_mean_LH + index_mean_RH)./2;

load ../Data/C1_latency_alltrials.mat

% Sort C1 peak latency data and collect data from high contrast, lower
% visual field condition
for kk = 1:20
    latency_v1_LCU(1,kk) = latency_v1(1,kk);
    latency_v1_LCU(2,kk) = latency_v1(3,kk);   
end

% Average latency across left and right visual fie;d
latency_test = nanmedian(latency_v1_LCU,1);

% Try one-leave-out cross-validation
for ik = 1:20
    x_cv = x;
    x_cv(ik, :) = [];
   latency_cv = latency_test;
   latency_cv(:,ik) = [];
   mdl_cv{ik} = fitlm(x_cv,transpose(latency_cv));
   predict_y(ik) = mdl_cv{ik}.Coefficients.Estimate(1) + mdl_cv{ik}.Coefficients.Estimate(2)*x(ik,1) + mdl_cv{ik}.Coefficients.Estimate(3)*x(ik,2) + mdl_cv{ik}.Coefficients.Estimate(4)*x(ik,3) + mdl_cv{ik}.Coefficients.Estimate(5)*x(ik,4)+ mdl_cv{ik}.Coefficients.Estimate(6)*x(ik,5);
end

% Calculate cross-validated R
[corr_mdlcv_orig] = corr(predict_y(:), transpose(latency_test));

% Set panel axis limit
h1.xlim(1) = 60; % X axis, the minimum limit
h1.xlim(2) = 100;% X axis, the maximum limit
h1.ylim(1) = 60; % Y axis, the minimum limit
h1.ylim(2) = 100;  % Y axis, the maximum limit

% Set tick label
xtick = [60 80 100];
ytick = [60 80 100];%degree
fig = figure;
hold on
box off

% Create Scatter plot
plot(latency_test',predict_y, 'Linestyle','none','Marker','o','MarkerEdgeColor','k', 'MarkerFaceColor','none', 'MarkerSize',8);
set(gca, 'tickdir', 'out', 'box', 'off', 'xlim', h1.xlim,'xtick',xtick, 'ylim', h1.ylim,'ytick',ytick);
xlabel('Measured C1 latency (ms)');
ylabel('Predicted C1 latency (ms)');

% Add 95% bootstrap Confidence interval
Critical = 0.05;%critical region
y = predict_y';
x = [ones(size(y)) latency_test'];
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
plot(xfig,y_hat(xfig),'LineWidth',2,'Color','k');
