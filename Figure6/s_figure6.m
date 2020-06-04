function s_figure6

% (1) Perform model prediction using a subset of MRI parameters, tract
% length or cortical thickness of the V1. 
% (2) Create a bar plot for model prediction performance with bootstrapped
% confidence interval.
% This script aims to reproduce Figure 6 in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. (2020)
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% eNeuro.

% Hiromasa Takemura, NICT CiNet BIT

%% Load parameters for model prediction

% Load data from left OR
load ../Data/Left_OR_tractproperty.mat

% Average metrics along OR. For dMRI metric, we average data across two
% runs.
index_mean_LH(:,1) = (mean(all_profile.fa1(11:90,:),1) + mean(all_profile.fa2(11:90,:),1))/2;
index_mean_LH(:,2) = (mean(all_profile.md1(11:90,:),1) + mean(all_profile.md2(11:90,:),1))/2;
index_mean_LH(:,3) = (mean(all_profile.odi1(11:90,:),1) + mean(all_profile.odi2(11:90,:),1))/2;
index_mean_LH(:,4) = (mean(all_profile.icvf1(11:90,:),1) + mean(all_profile.icvf2(11:90,:),1))/2;
index_mean_LH(:,5) = mean(all_profile.qt1(11:90,:),1);

clear all_profile

% Load data from right OR
load  ../Data/Right_OR_tractoproperty.mat

% Average metrics along OR. For dMRI metric, we average data across two
% runs.
index_mean_RH(:,1) = (mean(all_profile.fa1(11:90,:),1) + mean(all_profile.fa2(11:90,:),1))/2;
index_mean_RH(:,2) = (mean(all_profile.md1(11:90,:),1) + mean(all_profile.md2(11:90,:),1))/2;
index_mean_RH(:,3) = (mean(all_profile.odi1(11:90,:),1) + mean(all_profile.odi2(11:90,:),1))/2;
index_mean_RH(:,4) = (mean(all_profile.icvf1(11:90,:),1) + mean(all_profile.icvf2(11:90,:),1))/2;
index_mean_RH(:,5) = mean(all_profile.qt1(11:90,:),1);

% Average across hemisphere to create OR variable for predicting C1 peak
% latency
index_mean_LR = (index_mean_LH + index_mean_RH)./2;

% Load OR Streamline length, left hemisphere
load ../Data/Left_OR_tractlength.mat
tractmean_LH = tractmean;

% Load OR Streamline length, right hemisphere
load ../Data/Right_OR_tractlength.mat
tractmean_RH = tractmean;

% Average across hemispheres
tractlength = (tractmean_LH + tractmean_RH)./2;

% Load V1 Cortical Thickness
load ../Data/V1_thickness.mat

% Load C1 Peak Latency
load ../Data/C1_latency_alltrials.mat

% Sort C1 peak latency data and collect data from high contrast, lower
% visual field condition
for kk = 1:20
    latency_v1_HCD(1,kk) = latency_v1(6,kk); %Left LVF, high contrast
    latency_v1_HCD(2,kk) = latency_v1(8,kk); %Right LVF, high contrast  
end

% Average latency across left and right visual field
latency_test = mean(latency_v1_HCD,1);

%% NODDI + qT1 model
x(:,1) = index_mean_LR(:,3);
x(:,2) = index_mean_LR(:,4);
x(:,3) = index_mean_LR(:,5);

% Try one-leave-out cross-validation
for ik = 1:20
    x_cv = x;
    x_cv(ik, :) = [];
   latency_cv = latency_test;
   latency_cv(:,ik) = [];
   mdl_cv{ik} = fitlm(x_cv,transpose(latency_cv));
   predict_y(ik,1) = mdl_cv{ik}.Coefficients.Estimate(1) + mdl_cv{ik}.Coefficients.Estimate(2)*x(ik,1) + mdl_cv{ik}.Coefficients.Estimate(3)*x(ik,2) + mdl_cv{ik}.Coefficients.Estimate(4)*x(ik,3);
end

% Calculate cross-validated R
[corr_mdlcv_orig(1)] = corr(predict_y(:,1), transpose(latency_test));
clear x x_cv mdl_cv

%% DTI + qT1 model
x(:,1) = index_mean_LR(:,1);
x(:,2) = index_mean_LR(:,2);
x(:,3) = index_mean_LR(:,5);

% Try one-leave-out cross-validation
for ik = 1:20
    x_cv = x;
    x_cv(ik, :) = [];
   latency_cv = latency_test;
   latency_cv(:,ik) = [];
   mdl_cv{ik} = fitlm(x_cv,transpose(latency_cv));
   predict_y(ik,2) = mdl_cv{ik}.Coefficients.Estimate(1) + mdl_cv{ik}.Coefficients.Estimate(2)*x(ik,1) + mdl_cv{ik}.Coefficients.Estimate(3)*x(ik,2) + mdl_cv{ik}.Coefficients.Estimate(4)*x(ik,3);
end

% Calculate cross-validated R
[corr_mdlcv_orig(2)] = corr(predict_y(:,2), transpose(latency_test));
clear x x_cv mdl_cv

%% DTI + NODDI model
x(:,1) = index_mean_LR(:,1);
x(:,2) = index_mean_LR(:,2);
x(:,3) = index_mean_LR(:,3);
x(:,4) = index_mean_LR(:,4);

% Try one-leave-out cross-validation
for ik = 1:20
    x_cv = x;
    x_cv(ik, :) = [];
   latency_cv = latency_test;
   latency_cv(:,ik) = [];
   mdl_cv{ik} = fitlm(x_cv,transpose(latency_cv));
   predict_y(ik,3) = mdl_cv{ik}.Coefficients.Estimate(1) + mdl_cv{ik}.Coefficients.Estimate(2)*x(ik,1) + mdl_cv{ik}.Coefficients.Estimate(3)*x(ik,2) + mdl_cv{ik}.Coefficients.Estimate(4)*x(ik,3)+ mdl_cv{ik}.Coefficients.Estimate(5)*x(ik,4);
end

% Calculate cross-validated R
[corr_mdlcv_orig(3)] = corr(predict_y(:,3), transpose(latency_test));
clear x x_cv mdl_cv

%% Full model
x = index_mean_LR;
% Try one-leave-out cross-validation
for ik = 1:20
    x_cv = x;
    x_cv(ik, :) = [];
   latency_cv = latency_test;
   latency_cv(:,ik) = [];
   mdl_cv{ik} = fitlm(x_cv,transpose(latency_cv));
   predict_y(ik,4) = mdl_cv{ik}.Coefficients.Estimate(1) + mdl_cv{ik}.Coefficients.Estimate(2)*x(ik,1) + mdl_cv{ik}.Coefficients.Estimate(3)*x(ik,2) + mdl_cv{ik}.Coefficients.Estimate(4)*x(ik,3) + mdl_cv{ik}.Coefficients.Estimate(5)*x(ik,4) + mdl_cv{ik}.Coefficients.Estimate(6)*x(ik,5);
end

% Calculate cross-validated R
[corr_mdlcv_orig(4)] = corr(predict_y(:,4), transpose(latency_test));
clear x x_cv mdl_cv

%% Full + tract length model
x(:,1:5) = index_mean_LR;
x(:,6) = tractlength;

% Try one-leave-out cross-validation
for ik = 1:20
    x_cv = x;
    x_cv(ik, :) = [];
   latency_cv = latency_test;
   latency_cv(:,ik) = [];
   mdl_cv{ik} = fitlm(x_cv,transpose(latency_cv));
   predict_y(ik,5) = mdl_cv{ik}.Coefficients.Estimate(1) + mdl_cv{ik}.Coefficients.Estimate(2)*x(ik,1) + mdl_cv{ik}.Coefficients.Estimate(3)*x(ik,2) + mdl_cv{ik}.Coefficients.Estimate(4)*x(ik,3) + mdl_cv{ik}.Coefficients.Estimate(5)*x(ik,4) + mdl_cv{ik}.Coefficients.Estimate(6)*x(ik,5) + mdl_cv{ik}.Coefficients.Estimate(7)*x(ik,6);
end

% Calculate cross-validated R
[corr_mdlcv_orig(5)] = corr(predict_y(:,5), transpose(latency_test));
clear x x_cv mdl_cv

%% Full + V1 CT model
x(:,1:5) = index_mean_LR;
x(:,6) = transpose(mean_v1_thickness);

% Try one-leave-out cross-validation
for ik = 1:20
    x_cv = x;
    x_cv(ik, :) = [];
   latency_cv = latency_test;
   latency_cv(:,ik) = [];
   mdl_cv{ik} = fitlm(x_cv,transpose(latency_cv));
   predict_y(ik,6) = mdl_cv{ik}.Coefficients.Estimate(1) + mdl_cv{ik}.Coefficients.Estimate(2)*x(ik,1) + mdl_cv{ik}.Coefficients.Estimate(3)*x(ik,2) + mdl_cv{ik}.Coefficients.Estimate(4)*x(ik,3) + mdl_cv{ik}.Coefficients.Estimate(5)*x(ik,4) + mdl_cv{ik}.Coefficients.Estimate(6)*x(ik,5) + mdl_cv{ik}.Coefficients.Estimate(7)*x(ik,6);
end

% Calculate cross-validated R
[corr_mdlcv_orig(6)] = corr(predict_y(:,6), transpose(latency_test));
clear x x_cv mdl_cv


%% Plot bar graph
bar(corr_mdlcv_orig,'FaceColor',[0 0 0]);
hold on
set(gca,'XTickLabel',{'NODDI+qT1','DTI+qT1','DTI+NODDI','Full','Full+tract length','Full+V1 CT'},'fontsize',10);
ylabel('Model performance (Cross-validated R)','fontsize',10);
set(gca, 'tickdir', 'out', 'box', 'off');
