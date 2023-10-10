% This script plots the autocorrelation functions, the exponential decay function
% fitted to them and the goodness of fit (r^2): Supplementary Figures 7 & 8

% INPUTS: C3_Autocorr_tau_estimation
% OUTPUTS: NA (images)
%% Plotting data and fits (Supplementary Figure 7)
clc;
clear all
close all
load('channel_locations.mat')
% Regions of interest
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
titles={'Orientation','Frequency','Color','Contrast'};
ch=occip_chans;
for partid=[1 4 6] % selected subjects to be shown
    figure;
    load(sprintf(['AutoCorr_Parameters_Subj_%02i.mat'],partid))
    c=0;
    for cond=1:4
        for sub_cond=1:4
            c=c+1;
            subplot(4,4,c)
            data_tmp_real=squeeze(nanmean(data_orig(cond,sub_cond,ch,:),3));
            data_tmp_estm=squeeze(nanmean(data_estim(cond,sub_cond,ch,:),3));
            Dat=plot([0:2:148],(data_tmp_real),'.k','markersize',10)          
            hold on;
            Estm=plot([0:2:148],(data_tmp_estm),'Color',[0.8 0.2 0.2],'linewidth',3)
            Tau=squeeze(nanmean(taus(cond,sub_cond,ch),3));
            GoF=squeeze(nanmean(rSquared_all(cond,sub_cond,ch),3));
            ylabel('Autocorrelation')
            xlabel('Time delay (ms)')
            if cond==1
                conds={'22.5','67','112','157'};
            elseif cond==2
                conds={'0.010','0.025','0.040','0.055'};
            elseif cond==3
                conds={'1','2','3','4'};
            elseif cond==4
                conds={'0.9','0.7','0.5','0.3'};
            end
            dots1=plot(0,0,'.w');
            dots2=plot(0,0,'.w');
            if c==1
                legend([Dat Estm dots1 dots2],{'Data','Fit',['Tau = ',sprintf('%.0f',Tau*1000),'ms'],['GoF = ',sprintf('%.2f',GoF)]})
            else
                legend([dots1 dots2],{['Tau = ',sprintf('%.0f',Tau*1000),'ms'],['GoF = ',sprintf('%.2f',GoF)]})
            end
            if partid==1
                ylim([200 500])
            elseif partid==4
                ylim([200 400])                
            elseif partid==6
                ylim([400 600])
            end
            title([titles{cond},': ',conds{sub_cond}])
            box off
            set(gca,'TickDir','out','Fontsize',14)
        end
    end
end
%% Plotting histograms of r-squared (Supplementary Figure 8)
clc
clear all;
close all;
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
titles={'Orientation','Frequency','Color','Contrast'};
for partid=[1 4 6]
    figure;
    load(sprintf(['AutoCorr_Parameters_Subj_%02i.mat'],partid))
    c=0;
    for cond=1:4
        c=c+1;
        subplot(2,2,c)
        histogram(squeeze(nanmean(rSquared_all(cond,:,:),2)),100)
        hold on;
        title([titles{cond}])
        xlabel('Goodness of fit (R^2)')
        ylabel('Number of channels')
        box off
        set(gca,'TickDir','out','Fontsize',24)
    end
end