% This script plots the multiscale time-resolved decoding results (also does the Bayesian Analyses)
% for each area: Supplementary Figure 4 

% INPUTS: C1_Time_resolved_decoding_multiscale_per_area
% OUTPUTS: NA (images)
%% 
clc
clear all;
close all;
p=0;
chann=1; % 1= occipital; 2=central; 3=frontal
chan_labels={'Occipital','Central','Frontal'};

for partid=[1:16]
    p=p+1;        
        load(sprintf(['Decoding_data_8windows_Nobslin_trlsEq_',chan_labels{chann},'_subj_%02i.mat'],partid),'accuracy')
        accuracies(p,:,:,:,:)=accuracy;
end
addpath(genpath('F:\RESEARCH\Hamid\CB\bayesFactor-master'))
times=[-100:2:500];
%% Three distinct temporal scales (insets in the image)
clc
close all
start_span=50;
end_span=350;
titles={'Orientation','Frequency','Colour','Contrast'};
winds=[2 6 9];
conds={'2','6','10','14','18','22','26','38','50','74'};
cl=cool;
indx_cols=round(linspace(1,size(cl,1),length(conds)));
cols=cl(indx_cols(winds),:);
if chann==1
    zoom_margins=[0.5 0.52;0.55 0.6;0.53 0.57;0.53 0.57];
elseif chann==2
    zoom_margins=[0.5 0.51;0.51 0.55;0.51 0.53;0.51 0.53];
elseif chann==3
    zoom_margins=[0.5 0.51;0.5 0.52;0.5 0.51;0.5 0.51];
end
min_y=0.48;
max_y=0.6;
for i=1:size(accuracies,2)
    % Decoding curves
    figure
    w=0;
    for wind=winds
        w=w+1;
        plot([-100 500],[0.5 0.5],'--k','linewidth',1);
        plot([0 0],[min_y max_y],'--k','linewidth',1);
        hold on;
        data=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,:),5));
        s(w)=shadedErrorBar(times,nanmean(data),nanstd(data)./sqrt(size(data,1)),'lineprops',{'LineWidth',2},'transparent',1);
        s(w).mainLine.Color = cols(w,:);
        s(w).patch.FaceColor = cols(w,:);
        s(w).edge(1,1).Color = 'none';
        s(w).edge(1,2).Color = 'none';
        
        [~,time_max_1(i,w)]=max(nanmean(data));
        plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[min_y max_y],'color',cols(w,:),'linestyle','--')
        plot([-0 500],[nanmean(nanmean(data(:,100:end),2)) nanmean(nanmean(data(:,100:end),2))],'color',cols(w,:),'linestyle','--')
    end
    rectangle('Position',[80 zoom_margins(i,1) 100 zoom_margins(i,2)-zoom_margins(i,1)])
    legend([s(1).mainLine s(2).mainLine s(3).mainLine],{[conds{winds(1)} ' ms'],[conds{winds(2)} ' ms'],[conds{winds(3)} ' ms']});
    ylim([min_y max_y])
    xlim([-100 500])
    box off
    grid on
    title(titles{i});
    ylabel('Decoding accuracy')
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)  
    
    % Checking for above-baseline decoding using Bayes factor analysis
    figure
    w=0;
    for wind=winds
        w=w+1;
        subplot(size(winds,2),1,w)
        data=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,:),5));
        for t=1:size(data,2)
            Effects(t)=bf.ttest(squeeze(data(:,t)),squeeze(nanmean(data(:,1:50),2)));
        end
        up_thresh=6;
        down_thresh=1/up_thresh;
        marksize = 4;
        Null_color=[0 0 0];
        stepping=2;
        g=0;
        for t=1:stepping:length(Effects)
            if Effects(t)>=up_thresh
                stem(times(t),log10(Effects(t)),'Color',cols(w,:),'MarkerEdgeColor',cols(w,:),'MarkerFaceColor',cols(w,:),'MarkerSize',marksize)
                g=g+1;
            elseif Effects(t)<up_thresh && Effects(t)>=down_thresh
                stem(times(t),log10(Effects(t)),'Color',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',[1 1 1],'MarkerSize',marksize)
            elseif Effects(t)<down_thresh
                stem(times(t),log10(Effects(t)),'Color',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',Null_color,'MarkerSize',marksize)
            end
            hold on;
        end
        plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[-2 6],'color',cols(w,:),'linestyle','--')
        grid on
        ylabel('BF (Log)')
        ylim([-2 6])
        plot([0 0],[-2 6],'--k','linewidth',1);
        box off
        set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
    end
    xlabel('Time (ms)')
    
    
    % Checking for inter-condition difference using Bayes factor analysis
    figure
    Null_color=[0 0 0];
    subplot(3,1,1)
    wind=2;
    data6=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,:),5));
    wind=6;
    data22=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,:),5));
    wind=9;
    data50=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,:),5));
    for t=1:size(data,2)
        Effects(t)=bf.ttest(squeeze(data6(:,t)),squeeze(data22(:,t)));
    end
    up_thresh=6;
    down_thresh=1/up_thresh;
    g=0;
    for t=1:stepping:length(Effects)
        if Effects(t)>=up_thresh
            stem(times(t),log10(Effects(t)),'Color',nanmean(cols([1 2],:)),'MarkerEdgeColor',nanmean(cols([1 2],:)),'MarkerFaceColor',nanmean(cols([1 2],:)),'MarkerSize',marksize)
            g=g+1;
        elseif Effects(t)<up_thresh && Effects(t)>=down_thresh
            stem(times(t),log10(Effects(t)),'Color',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',[1 1 1],'MarkerSize',marksize)
        elseif Effects(t)<down_thresh
            stem(times(t),log10(Effects(t)),'Color',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',Null_color,'MarkerSize',marksize)
        end
        hold on;
    end
    w=1;
    plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[-2 6],'color',cols(w,:),'linestyle','--')
    w=2;
    plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[-2 6],'color',cols(w,:),'linestyle','--')
    grid on
    ylabel('BF (Log)')
    ylim([-2 6])
    plot([0 0],[-2 6],'--k','linewidth',1);
    box off
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
    
    subplot(3,1,2)
    for t=1:size(data,2)
        Effects(t)=bf.ttest(squeeze(data22(:,t)),squeeze(data50(:,t)));
    end
    g=0;
    for t=1:stepping:length(Effects)
        if Effects(t)>=up_thresh
            stem(times(t),log10(Effects(t)),'Color',nanmean(cols([2 3],:)),'MarkerEdgeColor',nanmean(cols([2 3],:)),'MarkerFaceColor',nanmean(cols([2 3],:)),'MarkerSize',marksize)
            g=g+1;
        elseif Effects(t)<up_thresh && Effects(t)>=down_thresh
            stem(times(t),log10(Effects(t)),'Color',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',[1 1 1],'MarkerSize',marksize)
        elseif Effects(t)<down_thresh
            stem(times(t),log10(Effects(t)),'Color',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',Null_color,'MarkerSize',marksize)
        end
        hold on;
    end
    w=2;
    plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[-2 6],'color',cols(w,:),'linestyle','--')
    w=3;
    plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[-2 6],'color',cols(w,:),'linestyle','--')
    grid on
    ylabel('BF (Log)')
    ylim([-2 6])
    plot([0 0],[-2 6],'--k','linewidth',1);
    box off
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
    subplot(3,1,3)
    grid on
    ylabel('BF (Log)')
    ylim([-2 6])
    plot([0 0],[-2 6],'--k','linewidth',1);
    box off
    xlabel('Time (ms)')
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
end

%% Three distinct means Zoomed
clc
close all
winds=[2 6 9];
conds={'2','6','10','14','18','22','26','38','50','74'};
cl=cool;
indx_cols=round(linspace(1,size(cl,1),length(conds)));
cols=cl(indx_cols(winds),:);
for i=1:size(accuracies,2)
    subplot(2,2,i)
    w=0;
    for wind=winds
        w=w+1;
        data=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,:),5));
        [~,time_max_1(i,w)]=max(nanmean(data));
        plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[-2 6],'color',cols(w,:),'linestyle','--')
        hold on;
        s(w)=shadedErrorBar(times,nanmean(data),nanstd(data)./sqrt(size(data,1)),'lineprops',{'LineWidth',2},'transparent',1);
        s(w).mainLine.Color = cols(w,:);
        s(w).patch.FaceColor = cols(w,:);
        s(w).edge(1,1).Color = 'none';
        s(w).edge(1,2).Color = 'none';
    end
    
    yticks([])
    yticklabels([])
    xticks([])
    xticklabels([])
    ylim(zoom_margins(i,:))
    xlim([80 180])
    %     box off
    grid on
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
end