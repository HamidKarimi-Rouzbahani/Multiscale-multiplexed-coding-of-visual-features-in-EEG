% This script plots the time point when the decoding curves reached their
% first peak acorss the four fearues (Supplementary Figure 2)

% INPUTS: C1_Time_resolved_decoding_multiscale
% OUTPUTS: NA (images)
%% Loading the data
clc
clear all;
close all;
addpath(genpath('F:\RESEARCH\Hamid\CB\bayesFactor-master'))
p=0;
for partid=[1:16]
    p=p+1;
    load(sprintf('Decoding_data_8windows_Nobslin_trlsEq_subj_%02i.mat',partid),'accuracy')
    accuracies(p,:,:,:,:)=accuracy;
end

%% Decoding/time scale tuning curves to extract the peak from
clc;
close all
time_window= 100:350; % The whole time
titles={'Orientation','Frequency','Colour','Contrast'};
for p=1:16
    for info=1:4
        for wind=1:size(accuracies,3)
            [max_value(p,info,wind),maxes_time(p,info,wind)]=max(squeeze(nanmean(accuracies(p,info,wind,time_window,:),5)));
        end
        for wind=1:size(accuracies,3)
            norm_data(p,info,wind)=(max_value(p,info,wind)-min(max_value(p,info,:)))./(max(max_value(p,info,:))-min(max_value(p,info,:)));
        end
    end
end
% four types of information
for info=1:4
    [~,max_timescale_ind(info)]=max(nanmean(norm_data(:,info,:)));
end

figure;
c=0;
cols=[1 0 0;0.4 0.6 0.3;0 0 1;0 0 0];
data_for_later=nan(16,4);
tics=1:4;
for info=1:4
    data_max_time=squeeze(maxes_time(:,info,max_timescale_ind(info)))*2;
    outliers(:,info)=isoutlier(data_max_time); % removing outliers from data
end
for info=1:4
    data_max_time=squeeze(maxes_time(:,info,max_timescale_ind(info)))*2;
    datas_tmp=(data_max_time(sum(outliers')==0));
    x=info.*ones(1,length(datas_tmp));
    data_for_later(1:length(datas_tmp),info)=datas_tmp;
    data_all(1:length(data_max_time),info)=data_max_time;
    swarmchart(x,datas_tmp','MarkerFaceColor',cols(info,:),'MarkerEdgeColor',cols(info,:),'MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.3);
    hold on;
end
boxplot(data_for_later,'Whisker',inf,'color','k');
xticks([1:4])
xticklabels(titles)
grid on
xlim([0 max(tics)+1])
ylabel('Time to peak of decoding (ms)')
ylim([80 210])
box off
set(gca,'TickDir','out','Fontsize',16)

[nanmean(data_for_later) ; nanstd(data_for_later)]

combins=nchoosek([1:4],2);
for comb=1:size(combins,1)
    ind1=combins(comb,1);
    ind2=combins(comb,2);
    bfs(comb)=bf.ttest(data_for_later(:,ind1),data_for_later(:,ind2));
end
bfs