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

%% Three distinct temporal scales
clc
close all
start_span=50;
end_span=350;
titles={'Orientation','Frequency','Colour','Contrast'};
winds=[1:10];
conds={'2','6','10','14','18','22','26','38','50','74'};
cl=cool;
indx_cols=round(linspace(1,size(cl,1),length(conds)));
cols=cl(indx_cols(winds),:);
zoom_margins=[0.5 0.52;0.6 0.65;0.56 0.62; 0.56 0.62];
min_y=0.48;
max_y=0.66;
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
        s(w)=plot(times,nanmean(data),'LineWidth',1,'color',cols(w,:));
        plot([-0 500],[nanmean(nanmean(data(:,100:end),2)) nanmean(nanmean(data(:,100:end),2))],'color',cols(w,:),'linestyle','--')
        [~,time_max_1(i,w)]=max(nanmean(data));
        plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[min_y max_y],'color',cols(w,:),'linestyle','--')
    end
    rectangle('Position',[80 zoom_margins(i,1) 70 zoom_margins(i,2)-zoom_margins(i,1)])
    legend([s(1) s(2) s(3) s(4) s(5) s(6) s(7) s(8) s(9) s(10)],[conds{winds(1)} ' ms'],[conds{winds(2)} ' ms'],[conds{winds(3)} ' ms'],[conds{winds(4)} ' ms'],[conds{winds(5)} ' ms'],[conds{winds(6)} ' ms'],[conds{winds(7)} ' ms'],[conds{winds(8)} ' ms'],[conds{winds(9)} ' ms'],[conds{winds(10)} ' ms']);
    ylim([min_y max_y])
    xlim([-100 500])
    box off
    grid on
    title(titles{i});
    ylabel('Decoding accuracy')
    set(gca,'TickDir','out','XMinorTick','on','Fontsize',15)
    
    % Chance BF
    figure
    w=0;
    for wind=winds
        w=w+1;
        subplot(size(winds,2),1,w)
        data=squeeze(nanmean(accuracies(:,i,wind,start_span:end_span,:),5));
        for t=1:size(data,2)
            Effects(t)=bf.ttest(squeeze(data(:,t)),squeeze(nanmean(data(:,1:50),2)));
        end
        up_thresh=3;
        down_thresh=1/up_thresh;
        marksize = 3.5;
        Null_color=[0 0 0];
        g=0;
        for t=1:length(Effects)
            if Effects(t)>=up_thresh
                stem(times(t),log10(Effects(t)),'Color',cols(w,:),'MarkerEdgeColor',cols(w,:),'MarkerFaceColor','k','MarkerSize',marksize)
                g=g+1;
            elseif Effects(t)<up_thresh && Effects(t)>=down_thresh
                stem(times(t),log10(Effects(t)),'Color',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1],'MarkerSize',marksize)
            elseif Effects(t)<down_thresh
                stem(times(t),log10(Effects(t)),'Color',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',Null_color,'MarkerSize',marksize)
            end
            hold on;
        end
        plot([times(time_max_1(i,w)) times(time_max_1(i,w))],[-2 6],'color',cols(w,:),'linestyle','--')
        grid on
        %         ylabel('BF (Log)')
        ylim([-2 6])
        plot([0 0],[-2 6],'--k','linewidth',1);
        box off
        set(gca,'TickDir','out','XMinorTick','on','Fontsize',10)
    end
    %             xlabel('Time (ms)')
end