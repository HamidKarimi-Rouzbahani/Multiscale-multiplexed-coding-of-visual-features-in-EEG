%% Plotting
clc;
clear all
close all
for partid=[1:16]
    load(sprintf(['AutoCorr_Parameters_Subj_%02i.mat'],partid))
    Taus(:,:,:,partid)=taus;
    Taus(Taus<0 | Taus>0.2)=nan;
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

% figure
% data=rmoutliers(squeeze(nanmean(nanmean(nanmean(Taus(:,:,occip_chans,:),1),2),3)))*1000;
% oc=bar(0.8,nanmean(data),0.2,'r');
% hold on;
% errorbar(0.8,nanmean(data),nanstd(data)/sqrt(size(data,1)),"LineStyle","none","Color","k")
%
% data=rmoutliers(squeeze(nanmean(nanmean(nanmean(Taus(:,:,cent_chans,:),1),2),3)))*1000;
% cn=bar(1,nanmean(data),0.2,'g');
% hold on;
% errorbar(1,nanmean(data),nanstd(data)/sqrt(size(data,1)),"LineStyle","none","Color","k")
%
% data=rmoutliers(squeeze(nanmean(nanmean(nanmean(Taus(:,:,frnt_chans,:),1),2),3)))*1000;
% fr=bar(1.2,nanmean(data),0.2,'b');
% hold on;
% errorbar(1.2,nanmean(data),nanstd(data)/sqrt(size(data,1)),"LineStyle","none","Color","k")
% grid on
%
% xlim([0.5 1.5])
% ylim([0 50])
% legend([fr cn oc],{'Peri-frontal','Peri-central','Peri-occipital'},'location','northwest')
% ylabel('Time Scale (ms)')
% xticks([])
% xticklabels([])

addpath(genpath('F:\RESEARCH\Hamid\Multicentre dataset\Scripts\bayesFactor-master'))
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
boxplot(data_for_box,'Whisker',1.5,'color','k');
xticks([tics])
xticklabels([{'Occipital','Central','Frontal'}])
grid on
xlim([0 max(tics)+1])
plot([0 max(tics)+1],[0.5 0.5],'--k','linewidth',2);
ylabel('Time scale (ms)')
box off
set(gca,'TickDir','out','Fontsize',16)
%% ground topoplot
topoplot(ones(127,1),'chanlocss.locs','maplimits',[0 10],'electrodes','labels','efontsize',14,'electcolor',[1 1 1],'headcolor',[0 0 0]);


%% Plotting by ROI
figure
titles={'Orientation','Frequency','Color','Contrast'};
for info_type=[1:4]
    subplot(2,2,info_type)
    for cond=1:4
        data=rmoutliers(squeeze(nanmean(Taus(info_type,cond,occip_chans,:),3)))*1000;
        oc=bar(cond-0.2,nanmean(data),0.2,'r')
        hold on;
        errorbar(cond-0.2,nanmean(data),nanstd(data)/sqrt(size(data,1)),"LineStyle","none","Color","k")
        
        data=rmoutliers(squeeze(nanmean(Taus(info_type,cond,cent_chans,:),3)))*1000;
        cn=bar(cond,nanmean(data),0.2,'FaceColor','g')
        errorbar(cond,nanmean(data),nanstd(data)/sqrt(size(data,1)),"LineStyle","none","Color","k")
        
        data=rmoutliers(squeeze(nanmean(Taus(info_type,cond,frnt_chans,:),3)))*1000;
        fr=bar(cond+0.2,nanmean(data),0.2,'FaceColor','b')
        errorbar(cond+0.2,nanmean(data),nanstd(data)/sqrt(size(data,1)),"LineStyle","none","Color","k")
        
    end
    grid on
    xlim([0.5 4.5])
    ylim([0 50])
    title(titles(info_type))
    xticks([1 2 3 4])
    if info_type==1
        conds={'22.5','67','112','157'};
    elseif info_type==2
        conds={'0.010','0.025','0.040','0.055'};
    elseif info_type==3
        conds={'1','2','3','4'};
    elseif info_type==4
        conds={'0.9','0.7','0.5','0.3'};
    end
    xticklabels(conds)
    if info_type==1
        legend([fr cn oc],{'Peri-frontal','Peri-central','Peri-occipital'},'location','northwest')
    end
    ylabel('Time Scale (ms)')
end

%% Each feature
close all
clc
titles={'Orientation','Frequency','Colour','Contrast'};
tics=[1:2:8];
% chans=occip_chans;
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
%     xlim([0 max(tics)+1])
    ylim([10 55])
    combs=nchoosek([1:4],2);
    for comb=1:length(combs)
        bfs(comb)=bf.ttest(data(:,combs(comb,1)),data(:,combs(comb,2)));
    end
    bfs
end



%% Topoplot
addpath(genpath('F:\Toolbox\eeglab2021.1'))
% label={'Fp1';'Fz';'F3';'F7';'FT9';'FC5';'FC1';'C3';'T7';'TP9';'CP5';'CP1';'Pz';'P3';'P7';'O1';'Oz';'O2';'P4';'P8';'TP10';'CP6';'CP2';'Cz';'C4';'T8';'FT10';'FC6';'FC2';'F4';'F8';'Fp2';'AF7';'AF3';'AFz';'F1';'F5';'FT7';'FC3';'C1';'C5';'TP7';'CP3';'P1';'P5';'PO7';'PO3';'POz';'PO4';'PO8';'P6';'P2';'CPz';'CP4';'TP8';'C6';'C2';'FC4';'FT8';'F6';'AF8';'AF4';'F2';'F9';'AFF1h';'FFC1h';'FFC5h';'FTT7h';'FCC3h';'CCP1h';'CCP5h';'TPP7h';'P9';'PPO9h';'PO9';'O9';'OI1h';'PPO1h';'CPP3h';'CPP4h';'PPO2h';'OI2h';'O10';'PO10';'PPO10h';'P10';'TPP8h';'CCP6h';'CCP2h';'FCC4h';'FTT8h';'FFC6h';'FFC2h';'AFF2h';'F10';'AFp1';'AFF5h';'FFT9h';'FFT7h';'FFC3h';'FCC1h';'FCC5h';'FTT9h';'TTP7h';'CCP3h';'CPP1h';'CPP5h';'TPP9h';'POO9h';'PPO5h';'POO1';'POO2';'PPO6h';'POO10h';'TPP10h';'CPP6h';'CPP2h';'CCP4h';'TTP8h';'FTT10h';'FCC6h';'FCC2h';'FFC4h';'FFT8h';'FFT10h';'AFF6h';'AFp2'};
% N=[1:127]';
% angle=[-18;0;-39;-54;-72;-68;-44;-90;-90;-108;-111;-136;180;-141;-126;-162;180;162;141;126;108;111;136;0;90;90;72;69;44;39;54;18;-36;-22;0;-22;-49;-72;-61;-90;-90;-108;-119;-158;-131;-144;-158;180;158;144;131;158;180;119;108;90;90;61;72;49;36;22;22;-54;-8;-17;-55;-80;-71;-135;-102;-119;-126;-135;-144;-162;-171;-172;-138;138;172;171;162;144;135;126;119;102;135;71;80;55;17;8;54;-8;-35;-63;-61;-42;-45;-78;-81;-100;-109;-163;-125;-117;-153;-145;-172;172;145;153;117;125;163;109;100;81;78;45;42;61;63;35;8];
% radius=round([0.500000000000000;0.250000000000000;0.333333333333333;0.500000000000000;0.627777777777778;0.383333333333333;0.172222222222222;0.250000000000000;0.500000000000000;0.627777777777778;0.383333333333333;0.172222222222222;0.250000000000000;0.333333333333333;0.500000000000000;0.500000000000000;0.500000000000000;0.500000000000000;0.333333333333333;0.500000000000000;0.627777777777778;0.383333333333333;0.172222222222222;0;0.250000000000000;0.500000000000000;0.627777777777778;0.383333333333333;0.172222222222222;0.333333333333333;0.500000000000000;0.500000000000000;0.500000000000000;0.411111111111111;0.372222222222222;0.272222222222222;0.411111111111111;0.500000000000000;0.272222222222222;0.127777777777778;0.377777777777778;0.500000000000000;0.272222222222222;0.272222222222222;0.411111111111111;0.500000000000000;0.411111111111111;0.372222222222222;0.411111111111111;0.500000000000000;0.411111111111111;0.272222222222222;0.122222222222222;0.272222222222222;0.500000000000000;0.377777777777778;0.127777777777778;0.272222222222222;0.500000000000000;0.411111111111111;0.500000000000000;0.411111111111111;0.272222222222222;0.627777777777778;0.316666666666667;0.194444444444444;0.344444444444444;0.438888888888889;0.194444444444444;0.0888888888888889;0.316666666666667;0.450000000000000;0.627777777777778;0.561111111111111;0.627777777777778;0.622222222222222;0.561111111111111;0.316666666666667;0.255555555555556;0.255555555555556;0.316666666666667;0.561111111111111;0.622222222222222;0.627777777777778;0.561111111111111;0.627777777777778;0.450000000000000;0.316666666666667;0.0888888888888889;0.194444444444444;0.438888888888889;0.344444444444444;0.194444444444444;0.316666666666667;0.627777777777778;0.438888888888889;0.400000000000000;0.561111111111111;0.450000000000000;0.255555555555556;0.0888888888888889;0.316666666666667;0.561111111111111;0.438888888888889;0.194444444444444;0.194444444444444;0.344444444444444;0.561111111111111;0.561111111111111;0.400000000000000;0.438888888888889;0.438888888888889;0.400000000000000;0.561111111111111;0.561111111111111;0.344444444444444;0.194444444444444;0.194444444444444;0.438888888888889;0.561111111111111;0.316666666666667;0.0888888888888889;0.255555555555556;0.450000000000000;0.561111111111111;0.400000000000000;0.438888888888889],3);
% T=table(N,angle,radius,label);
% writetable(T,'chanlocss.txt','Delimiter','tab');

titles={'Orientation','Frequency','Color','Contrast'};
% max_all=max(max(max(nanmean(Taus,4))));
% min_all=min(min(min(nanmean(Taus,4))));
max_all=80;
min_all=0;

% for subj=1:3
subj=[1:16]
figure;
c=0;
for info_type=1:4
    if info_type==1
        conds={'22.5','67','112','157'};
    elseif info_type==2
        conds={'0.010','0.025','0.040','0.055'};
    elseif info_type==3
        conds={'1','2','3','4'};
    elseif info_type==4
        conds={'0.9','0.7','0.5','0.3'};
    end
    
    for cond=1:4
        c=c+1;
        %         subplot(4,4,c)
        figure
        data=[squeeze(nanmean(Taus(info_type,cond,:,subj),4))*1000];
        out=isoutlier(data);
        data(out)=nan;
        topoplot(data,'chanlocss.locs','maplimits',[min_all max_all],'electrodes','labels');
        %         topoplot(data,'chanlocss.locs');
        title([titles{info_type},': ',conds{cond}])
    end
end
% end
% scatter3([chanlocs.X],[chanlocs.Y],[chanlocs.Z])
