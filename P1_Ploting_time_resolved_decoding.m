% This script plots the multiscale time-resolved decoding results (also does the Bayesian Analyses)
% including Figures 2, 3, 4 and Supplementary Figure 3 and 5 

% INPUTS: C1_Time_resolved_decoding_multiscale
% OUTPUTS: NA (images)
%% loading the data
clc
clear all;
close all;
type=3; % 1= old; 2= new; 3=no-baseline
p=0;
for partid=[1:16]
    p=p+1;
    if type==1 % old
        load(sprintf('Decoding_data_windows_subj_%02i.mat',partid),'accuracy')
    elseif type==2 % new
        load(sprintf('Decoding_data_8windows_bslin_trlsEq_subj_%02i.mat',partid),'accuracy')
    elseif type==3 % no-baseline
        load(sprintf('Decoding_data_8windows_Nobslin_trlsEq_subj_%02i.mat',partid),'accuracy')
    end
    accuracies(p,:,:,:,:)=accuracy;
end
addpath(genpath('F:\RESEARCH\Hamid\CB\bayesFactor-master'))
times=[-100:2:500];

%% Three distinct temporal scales (Figure 2)
clc
close all
start_span=50; % analysis time window (-100: 500ms relative to stimulus onset)
end_span=350;
titles={'Orientation','Frequency','Colour','Contrast'};
winds=[2 6 9];
conds={'2','6','10','14','18','22','26','38','50','74'};
cl=cool;
indx_cols=round(linspace(1,size(cl,1),length(conds)));
cols=cl(indx_cols(winds),:);
zoom_margins=[0.5 0.52;0.6 0.65;0.56 0.62; 0.56 0.62];
min_y=0.48;
max_y=0.66;
for i=1:size(accuracies,2)
    %  Plotting decoding curves
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
    rectangle('Position',[80 zoom_margins(i,1) 70 zoom_margins(i,2)-zoom_margins(i,1)])
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
    %     title('22 vs. 50 ms')
    xlabel('Time (ms)')
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
end

%% Three distinct means Zoomed (Figure 2: zoomed images)
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
    xlim([80 150])
    %     box off
    grid on
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
end

%% Combined time scales decoding (Figure 4)
close all
clearvars -except marksize stepping accuracies titles times
min_y=0.48;
max_y=0.66;
start_span=50;
end_span=350;
colouring=1;
scales=[2 6 10 14 18 22 26 38 50 74];
for i=1:4
    data=squeeze(nanmean(accuracies(:,i,:,start_span:end_span,:),5));
    data_meaned=squeeze(nanmean(data));
    for t=1:size(data_meaned,2)
        [dec_max(t),scale_max(t)]=max(data_meaned(:,t));
        data_stded(t)=nanstd(squeeze(data(:,scale_max(t),t)));
        for subj=1:size(data,1)
            [~,scale_max_subj(subj,t)]=max(data(subj,:,t));
        end
    end
    for subj=1:size(data,1)
        for scl=1:10
            norm_data(subj,i,scl) = sum(scale_max_subj(subj,times>0)==scl)./(length(scale_max_subj(subj,times>0)));
        end
    end
    
    [~,time_max_1]=max(dec_max);
    [~,time_max_2]=max(dec_max(131:end));
    if colouring==0

    else
        figure;
        subplot(2,1,1)
        cl=cool;
        indx_cols=round(linspace(1,size(cl,1),size(data,2)));
        time_max_2=time_max_2+131;
        for t=1:length(scale_max)-1
            fill(times([t,t+1,t+1,t]),[min_y min_y max_y max_y],cl(indx_cols(scale_max(t)),:),'EdgeColor','none','facealpha',0.5);
            hold on;
        end
        
        f=shadedErrorBar(times,dec_max,data_stded./sqrt(size(data,1)),'lineprops',{'k','markerfacecolor','k','LineWidth',2},'transparent',0);
        ylim([min_y max_y])
        xlim([-100 500])
        hold on;
        plot([-100 500],[0.5 0.5],'--k','linewidth',2);
        plot([0 0],[min_y max_y],'--k','linewidth',2);
        box off
        set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
        grid on
        ylabel('Decoding accuracy')
        ticks=[2,6,10,14,18,22,26,38,50,74];
        tick_positions=linspace(0,2,length(ticks));
        colormap cool
        colb=colorbar('Ticks',tick_positions,...
            'TickLabels',{num2str(ticks')},'fontsize',12);
        ylabel(colb,'Time scale (ms)');
        
        subplot(2,1,2)
        for t=1:size(data,3)
            Effects(t)=(bf.ttest(squeeze(data(:,scale_max(t),t)),squeeze(nanmean(data(:,scale_max(t),1:50),3))));
        end
        up_thresh=6;
        down_thresh=1/up_thresh;
        Null_color=[0 0 0];
        g=0;
        for t=1:stepping:length(Effects)
            if Effects(t)>=up_thresh
                stem(times(t),log10(Effects(t)),'Color','k','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',marksize)
                g=g+1;
            elseif Effects(t)<up_thresh && Effects(t)>=down_thresh
                stem(times(t),log10(Effects(t)),'Color',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'MarkerSize',marksize)
            elseif Effects(t)<down_thresh
                stem(times(t),log10(Effects(t)),'Color',[0 0 0],'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',marksize)
            end
            hold on;
        end
        plot([0 0],[-2 6],'--k','linewidth',2);
        grid on
        xlabel('Time (ms)')
        ylabel('BF (Log)')
        ylim([-2 6])
        colormap cool
        colb=colorbar('Ticks',tick_positions,...
            'TickLabels',{num2str(ticks')},'fontsize',12);
        ylabel(colb,'Time scale (ms)');
        box off
        xlim([-100 500])
        set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
    end
end
%% Plotting Percentages (Supplementary Figure 5)
figure;
cl=cool;
scales=[2 6 10 14 18 22 26 38 50 74];
cols=[1 0 0;0.4 0.6 0.3;0 0 1;0 0 0];
for i=1:4
    s(i)=shadedErrorBar(1:length(scales),nanmean(squeeze(norm_data(:,i,:))),nanstd(squeeze(norm_data(:,i,:)))./sqrt(size(squeeze(norm_data(:,i,:)),1)),'lineprops',{'Linewidth',2},'transparent',1);
    s(i).mainLine.Color = cols(i,:);
    s(i).patch.FaceColor = cols(i,:);
    s(i).edge(1,1).Color = cols(i,:);
    s(i).edge(1,2).Color = cols(i,:);
    hold on;
end
xticks([1:length(scales)])
xticklabels([])
yticks([0:0.1:.3])
grid on
xlim([1 length(scales)])
yticklabels([num2str([0:0.1:.3]')])
ylabel('Proportion of time samples')
titles={'Orientation','Frequency','Colour','Contrast'};
lgnd=legend([s(1).mainLine s(2).mainLine s(3).mainLine ...
    s(4).mainLine],{titles{1,1},titles{1,2},titles{1,3},titles{1,4}},'location','north');
set(lgnd,'color','none');
box off
set(gca,'TickDir','out','Fontsize',15)
ticks=[2,6,10,14,18,22,26,38,50,74];
tick_positions=linspace(0,2,length(ticks));
colormap cool
colb=colorbar('Ticks',tick_positions,...
    'TickLabels',{num2str(ticks')},'fontsize',15,'location','southoutside');
ylabel(colb,'Time scale (ms)');
%% Time scale scatter (Figure 3B and 3C)
clc;
close all
titles={'Orientation','Frequency','Colour','Contrast'};
cols=[1 0 0;0.4 0.6 0.3;0 0 1;0 0 0];
window_to_analyse{1}=100:180; % First peak 0:160ms
window_to_analyse{2}=100:350; % The whole time
windows={'Whole(0:+500ms)','Feed-forward(0:+160ms)','Recurrent(+160:+500ms)'};

% type=2; % 1=maximum; 2=mean
for type=1:2
    if type==1
        time_window= window_to_analyse{1};
        low_mult=0.97;
        high_mult=1.05;
    elseif type==2
        time_window= window_to_analyse{2};
        low_mult=0.99;
        high_mult=1.02;
    end
    for p=1:16
        for i=1:4
            for wind=1:size(accuracies,3)
                if type==1
                    [data(p,i,wind),maxes_time(p,i,wind)]=max(squeeze(nanmean(accuracies(p,i,wind,time_window,:),5)));
                else
                    data(p,i,wind)=mean(squeeze(nanmean(accuracies(p,i,wind,time_window,:),5)));
                end
            end
        end
    end
    for i=1:4
        figure;
        cl=cool;
        tics=[1:2:20];
        xs=linspace(min(tics)-1,max(tics)+1,256);
        data_min=nanmin(nanmin(squeeze(data(:,i,:))));
        data_max=nanmax(nanmax(squeeze(data(:,i,:))));
        data_mean=nanmean(nanmean(squeeze(data(:,i,:))));
        if type==1
            ys=[data_min*low_mult data_min*low_mult data_max*high_mult data_max*high_mult];
        else
            ys=[data_min*low_mult data_min*low_mult data_max*high_mult data_max*high_mult];
        end
        hold on;
        
        scales=[2 6 10 14 18 22 26 38 50 74];
        c=0;
        data_for_box=nan(16,20);
        for t=tics
            c=c+1;
            x=t.*ones(1,16);           
            data_for_box(:,t)=squeeze(data(:,i,c));
            swarmchart(x,squeeze(data(:,i,c))','MarkerFaceColor',cols(i,:),'MarkerEdgeColor',cols(i,:),'MarkerFaceAlpha',0.3,'MarkerEdgeAlpha',0.3);
            hold on;
        end
        boxplot(data_for_box,'Whisker',inf,'color','k');
        
        combins=nchoosek([2 6 9],2);
        for comb=1:size(combins,1)
            bfs(comb)=bf.ttest(data(:,i,combins(comb,1)),data(:,i,combins(comb,2)));
        end
        bfs
        
        xticks([tics])
        xticklabels([])
        grid on
        xlim([0 max(tics)+1])
        plot([0 max(tics)+1],[0.5 0.5],'--k','linewidth',2);
        ylabel('Decoding accuracy')
        if type==1
            title('Peak of decoding')
        else
            title('Average of decoding')
        end
        box off
        set(gca,'TickDir','out','Fontsize',16)
        title(titles{i})
        ylim([data_min*low_mult data_max*high_mult])
        
        
        ticks=[2,6,10,14,18,22,26,38,50,74];
        tick_positions=(tics./20);
        colormap cool
        colb=colorbar('Ticks',tick_positions,...
            'TickLabels',{num2str(ticks')},'fontsize',16,'location','southoutside');
        ylabel(colb,'Time scale (ms)');
    end
end

%% Decoding/time scale tuning curves (Figure 3A)
clc;
close all
type=1; % 1=maximum; 2=mean
for type=1:2
    subplot(1,2,type)
    cl=cool;
    xs=linspace(1,10,256);
    ys=[0 0 1 1];
    
    titles={'Orientation','Frequency','Colour','Contrast'};
    
    cols=[1 0 0;0.4 0.6 0.3;0 0 1;0 0 0];
    
    window_to_analyse{1}=100:350; % The whole time
    window_to_analyse{2}=100:180; % First peak 0:160ms
    window_to_analyse{3}=181:350; % Second peak and after 160:500ms
    windows={'Whole(0:+500ms)','Feed-forward(0:+160ms)','Recurrent(+160:+500ms)'};
    if type==1
        time_window= window_to_analyse{2};
    elseif type==2
        time_window= window_to_analyse{1};
    end
    for p=1:16
        for i=1:4
            for wind=1:size(accuracies,3)
                if type==1
                    [data(p,i,wind),maxes_time(p,i,wind)]=max(squeeze(nanmean(accuracies(p,i,wind,time_window,:),5)));
                else
                    data(p,i,wind)=mean(squeeze(nanmean(accuracies(p,i,wind,time_window,:),5)));
                end
            end
            for wind=1:size(accuracies,3)
                norm_data(p,i,wind)=(data(p,i,wind)-min(data(p,i,:)))./(max(data(p,i,:))-min(data(p,i,:)));
            end
        end
    end

    scales=[2 6 10 14 18 22 26 38 50 74];
    for i=1:4
        s(i)=shadedErrorBar(1:length(scales),nanmean(squeeze(norm_data(:,i,:))),nanstd(squeeze(norm_data(:,i,:)))./sqrt(size(squeeze(norm_data(:,i,:)),1)),'lineprops',{'Linewidth',2},'transparent',1);
        s(i).mainLine.Color = cols(i,:);
        s(i).patch.FaceColor = cols(i,:);
        s(i).edge(1,1).Color = cols(i,:);
        s(i).edge(1,2).Color = cols(i,:);
        hold on;
    end
    xticks([1:length(scales)])
    xticklabels([])
    yticks([0:0.1:1])
    grid on
    xlim([1 length(scales)])
    yticklabels([num2str([0:0.1:1]')])
    ylabel('Normalised decoding accuracy')
    if type==1
        title('Peak of decoding')
    else
        title('Average of decoding')
    end
    lgnd=legend([s(1).mainLine s(2).mainLine s(3).mainLine s(4).mainLine],{titles{1,1},titles{1,2},titles{1,3},titles{1,4}},'location','south');
    set(lgnd,'color','none');
    box off
    set(gca,'TickDir','out','Fontsize',15)
    
    ticks=[2,6,10,14,18,22,26,38,50,74];
    tick_positions=linspace(0,2,length(ticks));
    colormap cool
    colb=colorbar('Ticks',tick_positions,...
        'TickLabels',{num2str(ticks')},'fontsize',15,'location','southoutside');
    ylabel(colb,'Time scale (ms)');
end

%% decoding per condition for Supplementary Figure 3
clc
close all
min_y=0.48;
max_y=0.72;
start_span=50;
end_span=350;
titles={'Orientation','Frequency','Colour','Contrast'};
winds=[2 6 9];
conds={'2','6','10','14','18','22','26','38','50','74'};
cl=cool;
indx_cols=round(linspace(1,size(cl,1),length(conds)));
cols=cl(indx_cols(winds),:);
for i=[1:4]
    figure
    combs=[1 2 3;1 4 5;2 4 6;3 5 6];
    for comb=1:4
        subplot(2,2,comb);
        w=0;
        for wind=winds
            w=w+1;
            plot([-100 500],[0.5 0.5],'--k','linewidth',1);
            plot([0 0],[min_y max_y],'--k','linewidth',1);
            hold on;
            data=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,combs(comb,:)),5));
            s(w)=shadedErrorBar(times,nanmean(data),nanstd(data)./sqrt(size(data,1)),'lineprops',{'LineWidth',2},'transparent',1);
            s(w).mainLine.Color = cols(w,:);
            s(w).patch.FaceColor = cols(w,:);
            s(w).edge(1,1).Color = 'none';
            s(w).edge(1,2).Color = 'none';

            plot([-0 500],[nanmean(nanmean(data(:,100:end),2)) nanmean(nanmean(data(:,100:end),2))],'color',cols(w,:),'linestyle','--')
            
            [~,time_max_1(i,w)]=max(nanmean(data));
            plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[min_y max_y],'color',cols(w,:),'linestyle','--')
        end
        legend([s(1).mainLine s(2).mainLine s(3).mainLine],{[conds{winds(1)} ' ms'],[conds{winds(2)} ' ms'],[conds{winds(3)} ' ms']});
        ylim([min_y max_y])
        xlim([-100 500])
        box off
        grid on
        if i==1
            sub_conds={'22.5','67','112','157'};
        elseif i==2
            sub_conds={'0.010','0.025','0.040','0.055'};
        elseif i==3
            sub_conds={'1','2','3','4'};
        elseif i==4
            sub_conds={'0.9','0.7','0.5','0.3'};
        end
        xlabel('Time (ms)')
        title([titles{i},': ',sub_conds{comb}]);
        ylabel('Decoding accuracy')
        set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
    end
end

