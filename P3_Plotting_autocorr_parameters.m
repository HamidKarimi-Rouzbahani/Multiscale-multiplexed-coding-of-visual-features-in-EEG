% This script plots ACF-based estimated time scales across the scalp
% and uses Bayesian Analysis to compare them: Figure 5

% INPUTS: C1_Time_resolved_decoding_multiscale
% OUTPUTS: NA (images)
%% Plot topoplot (Figure 5A)
clc;
clear all
close all
addpath(genpath('F:\RESEARCH\Hamid\CB\bayesFactor-master'))
topoplot(ones(127,1),'chanlocss.locs','maplimits',[0 10],'electrodes','labels','efontsize',14,'electcolor',[1 1 1],'headcolor',[0 0 0]);

%% Plotting Taus across ROIs (Figure 5B)
figure;
for partid=[1:16]
    load(sprintf(['AutoCorr_Parameters_Subj_%02i.mat'],partid))
    Taus(:,:,:,partid)=taus;
    Taus(Taus<0 | Taus>0.2)=nan;% remove negative and >200ms Taus
end
load('channel_locations.mat')
f=0;
c=0;
o=0;
for i=1:length(chanlocs)
    if contains(chanlocs(i).labels,'FC')
        f=f+1;
        frnt_chans(f)=i;
    end
    if contains(chanlocs(i).labels,'CP')
        c=c+1;
        cent_chans(c)=i;
    end
    if contains(chanlocs(i).labels,'O') && ~contains(chanlocs(i).labels,'P')
        o=o+1;
        occip_chans(o)=i;
    end
end
all_chans=1:length(chanlocs);



chans{1}=occip_chans;
chans{2}=cent_chans;
chans{3}=frnt_chans;
conds=[1 2;1 3;2 3];
for cond=1:3
    bfs(cond)=bf.ttest(squeeze(nanmean(nanmean(nanmean(Taus(:,:,chans{conds(cond,1)},:),1),2),3)),squeeze(nanmean(nanmean(nanmean(Taus(:,:,chans{conds(cond,2)},:),1),2),3)));
end
bfs
tics=[1:2:6];
data(:,1)=(squeeze(nanmean(nanmean(nanmean(Taus(:,:,chans{1},:),1),2),3)))*1000;
data(:,2)=(squeeze(nanmean(nanmean(nanmean(Taus(:,:,chans{2},:),1),2),3)))*1000;
data(:,3)=(squeeze(nanmean(nanmean(nanmean(Taus(:,:,chans{3},:),1),2),3)))*1000;
c=0;
data_for_box=nan(16,5);
cols=[1 0 0;0 1 0;0 0 1;0 0 0];
for t=tics
    c=c+1;
    x=t.*ones(1,16);
    data_for_box(:,t)=squeeze(data(:,c));
    swarmchart(x,data(:,c)','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.3);
    hold on;
end
boxplot(data_for_box,'Whisker',inf,'color','k');
xticks([tics])
xticklabels([{'Occipital','Central','Frontal'}])
grid on
xlim([0 max(tics)+1])
ylabel('Time scale (ms)')
box off
set(gca,'TickDir','out','Fontsize',16)

%% Each feature (Figure 5C)
figure
titles={'Orientation','Frequency','Colour','Contrast'};
tics=[1:2:8];
chans=[1:127]; % all channels
for info_type=[1:4]
    figure;
    for cond=1:4
        data(:,cond)=(squeeze(nanmean(Taus(info_type,cond,chans,:),3)))*1000;
   end
    data_for_box=nan(16,7);
    c=0;
    for t=tics
        c=c+1;
        x=t.*ones(1,16);
        data_for_box(:,t)=squeeze(data(:,c));
        swarmchart(x,data(:,c)','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.3);
        hold on;
    end
    boxplot(data_for_box,'Whisker',1.5,'color','k');
    set(gca,'TickDir','out','Fontsize',20)
    if info_type==1
        conds={'22.5','67','112','157'};
    elseif info_type==2
        conds={'0.010','0.025','0.040','0.055'};
    elseif info_type==3
        conds={'1','2','3','4'};
    elseif info_type==4
        conds={'0.9','0.7','0.5','0.3'};
    end
        xticks([tics])
    xticklabels(conds)
    title(titles{info_type})
    grid on
    ylabel('Time scale (ms)')
    box off
    ylim([10 55])
    combs=nchoosek([1:4],2);
    for comb=1:length(combs)
        bfs(comb)=bf.ttest(data(:,combs(comb,1)),data(:,combs(comb,2)));
    end
    bfs
end