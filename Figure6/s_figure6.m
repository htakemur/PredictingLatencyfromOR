function s_figure6

% Plot tract profile of the optic radiation.
% This script aims to reproduce Figure 6 in a following article: 

% Takemura, H., Yuasa, K. & Amano, K. 
% Predicting neural response latency of the human early visual cortex from MRI-based tissue measurements of the optic radiation.
% Under Review at eNeuro.

% Hiromasa Takemura, NICT CiNet BIT

% Load C1 peak latency in Lower Visual Field, High Contrast Condition
load ../Data/C1_latency_alltrials.mat
for kk = 1:20
    latency_v1_HCD(1,kk) = latency_v1(6,kk);
    latency_v1_HCD(2,kk) = latency_v1(8,kk);   
end

% Average C1 peak latency for left and right visual field stimulation
latency_test = mean(latency_v1_HCD,1);

% Classify subjects into faster and slower C1 peak latency groups
latency_median = median(latency_test);
latency_group_fast = find(latency_test < latency_median);
latency_group_slow = find(latency_test > latency_median);

% Load data from left OR
load ../Data/Left_OR_tractproperty.mat
index_LH(1:80,:,1) = (all_profile.fa1(11:90,:) + all_profile.fa2(11:90,:))/2;
index_LH(1:80,:,2) = (all_profile.md1(11:90,:) + all_profile.md2(11:90,:))/2;
index_LH(1:80,:,3) = (all_profile.odi1(11:90,:) + all_profile.odi2(11:90,:))/2;
index_LH(1:80,:,4) = (all_profile.icvf1(11:90,:) + all_profile.icvf2(11:90,:))/2;

% Load data from right OR
load  ../Data/Right_OR_tractoproperty.mat
index_RH(1:80,:,1) = (all_profile.fa1(11:90,:) + all_profile.fa2(11:90,:))/2;
index_RH(1:80,:,2) = (all_profile.md1(11:90,:) + all_profile.md2(11:90,:))/2;
index_RH(1:80,:,3) = (all_profile.odi1(11:90,:) + all_profile.odi2(11:90,:))/2;
index_RH(1:80,:,4) = (all_profile.icvf1(11:90,:) + all_profile.icvf2(11:90,:))/2;

% Average OR tissue property across hemispheres
index_value = (index_LH + index_RH)./2;

% Perform t-test
for pp = 1:4
[~,p(pp,:),~,tstats{pp}] = ttest2(mean(index_value(:,latency_group_fast,pp),1),mean(index_value(:,latency_group_slow,pp),1));
end

% Plot FA
index_fast_mean = mean(index_value(:,latency_group_fast,1),2);
index_slow_mean = mean(index_value(:,latency_group_slow,1),2);
index_fast_ser = std(index_value(:,latency_group_fast,1),0,2)./sqrt(10);
index_slow_ser = std(index_value(:,latency_group_slow,1),0,2)./sqrt(10);

x = [1:1:80];
plot(x,index_fast_mean,'color',[0 0 1],'LineWidth',5)
hold on
plot(x,index_slow_mean,'color',[1 0 0],'LineWidth',5)
hold on
plot(x,index_fast_ser+index_fast_mean,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_fast_mean-index_fast_ser,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_slow_mean+index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on
plot(x,index_slow_mean-index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on

h1.ylim(1) = 0.3;
h1.ylim(2) = 0.7;
    set(gca,'tickdir','out', ...
        'box','off', ...
        'ylim',h1.ylim)
ylabel('Fractional Anisotropy','fontsize',16);
xlabel('Position','fontsize',16);

% Plot MD
figure(2)
% Diffusivity is now computed in a unit of mm^2/s. 
% It is much easier to visualize in a unit of micrometer^2/msec.
% Therefore, we multiply MD by 1000. 
index_value(:,:,2) = index_value(:,:,2)*1000;
index_fast_mean = mean(index_value(:,latency_group_fast,2),2);
index_slow_mean = mean(index_value(:,latency_group_slow,2),2);
index_fast_ser = std(index_value(:,latency_group_fast,2),0,2)./sqrt(10);
index_slow_ser = std(index_value(:,latency_group_slow,2),0,2)./sqrt(10);

x = [1:1:80];
plot(x,index_fast_mean,'color',[0 0 1],'LineWidth',5)
hold on
plot(x,index_slow_mean,'color',[1 0 0],'LineWidth',5)
hold on
plot(x,index_fast_ser+index_fast_mean,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_fast_mean-index_fast_ser,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_slow_mean+index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on
plot(x,index_slow_mean-index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on
h1.ylim(1) = 0.6;
h1.ylim(2) = 0.8;
    set(gca,'tickdir','out', ...
        'box','off', ...
        'ylim',h1.ylim)
ylabel('Mean Diffusivity','fontsize',16);
xlabel('Position','fontsize',16);

% Plot ODI
figure(3)
index_fast_mean = mean(index_value(:,latency_group_fast,3),2);
index_slow_mean = mean(index_value(:,latency_group_slow,3),2);
index_fast_ser = std(index_value(:,latency_group_fast,3),0,2)./sqrt(10);
index_slow_ser = std(index_value(:,latency_group_slow,3),0,2)./sqrt(10);

x = [1:1:80];
plot(x,index_fast_mean,'color',[0 0 1],'LineWidth',5)
hold on
plot(x,index_slow_mean,'color',[1 0 0],'LineWidth',5)
hold on
plot(x,index_fast_ser+index_fast_mean,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_fast_mean-index_fast_ser,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_slow_mean+index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on
plot(x,index_slow_mean-index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on

h1.ylim(1) = 0.1;
h1.ylim(2) = 0.3;
    set(gca,'tickdir','out', ...
        'box','off', ...
        'ylim',h1.ylim)
ylabel('Orientation Dispersion Index','fontsize',16);
xlabel('Position','fontsize',16);

% Plot ICVF
figure(4)
index_fast_mean = mean(index_value(:,latency_group_fast,4),2);
index_slow_mean = mean(index_value(:,latency_group_slow,4),2);
index_fast_ser = std(index_value(:,latency_group_fast,4),0,2)./sqrt(10);
index_slow_ser = std(index_value(:,latency_group_slow,4),0,2)./sqrt(10);

x = [1:1:80];

plot(x,index_fast_mean,'color',[0 0 1],'LineWidth',5)
hold on
plot(x,index_slow_mean,'color',[1 0 0],'LineWidth',5)
hold on
plot(x,index_fast_ser+index_fast_mean,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_fast_mean-index_fast_ser,'--','color',[0 0 1],'LineWidth',1)
hold on
plot(x,index_slow_mean+index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on
plot(x,index_slow_mean-index_fast_ser,'--','color',[1 0 0],'LineWidth',1)
hold on

h1.ylim(1) = 0.4;
h1.ylim(2) = 0.6;
    set(gca,'tickdir','out', ...
        'box','off', ...
        'ylim',h1.ylim)
ylabel('ICVF','fontsize',16);
xlabel('Position','fontsize',16);