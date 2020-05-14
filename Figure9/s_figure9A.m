function s_figure9A
% (1) Calculate correlation of optic radiation tissue properties across
% hemispheres. 
% (2) Create a bar plot of correlation with confidence interval (estimated by bootstrapping). 
% This script aims to reproduce Figure 9A in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. (2020)
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% eNeuro.

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
clear all_profile

% Load data from right OR
load ../Data/Right_OR_tractoproperty.mat

% Average metrics along OR. For dMRI metric, we average data across two
% runs.
index_mean_RH(:,1) = (mean(all_profile.fa1(11:90,:),1) + mean(all_profile.fa2(11:90,:),1))/2;
index_mean_RH(:,2) = (mean(all_profile.md1(11:90,:),1) + mean(all_profile.md2(11:90,:),1))/2;
index_mean_RH(:,3) = mean(all_profile.qt1(11:90,:),1);
index_mean_RH(:,4) = (mean(all_profile.odi1(11:90,:),1) + mean(all_profile.odi2(11:90,:),1))/2;
index_mean_RH(:,5) = (mean(all_profile.icvf1(11:90,:),1) + mean(all_profile.icvf2(11:90,:),1))/2;

% Compute correlation and estimate 95% confidence interval using
% bootstrapping
for i = 1:5
[r_mri(i)] = corr(index_mean_LH(:,i),index_mean_RH(:,i));
rhos10000{i} = bootstrp(10000, 'corr', index_mean_LH(:,i), index_mean_RH(:,i));
rhos10000_order{i} = sort(rhos10000{i}, 'ascend');
lowest(i) = rhos10000_order{i}(250);
highest(i) = rhos10000_order{i}(9750);
end

% Plot bars
bar(r_mri,'FaceColor',[0 0 0]);
hold on
er = errorbar(1:5, r_mri, (r_mri - lowest), (highest - r_mri),'LineWidth',2);
er.Color = 'red';
er.LineStyle = 'none';
ylabel('Inter-hemisphere correlation (R)','fontsize',10);
ylim([0 1]);
ytick = [0 0.5 1];
set(gca,'XTickLabel',{'FA','MD','qT1','ODI','ICVF'},'fontsize',10);
set(gca, 'tickdir', 'out', 'box', 'off',  'ytick',ytick);