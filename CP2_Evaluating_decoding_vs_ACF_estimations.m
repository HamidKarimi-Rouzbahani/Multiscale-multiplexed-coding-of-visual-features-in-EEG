% This script simulates time series to evaluate the method of multiscale 
% time-resolved decoding and the ACF-based estimation of lengths of
% neural codes and plots the results
    % It first generates the simulated data: 50 trials per condition
    % Then calcualtes the ACF
    % Then it performs the decoding 
    % Then it estimates the length of the neural codes usins the ACF-based
    % estimation method
    % Supplementary Figure 6

% INPUTS: NA
% OUTPUTS: Autocorrelation time series ready for estimation of exponential
% decay function used by
    % C3_Autocorr_tau_estimation_sim
%% 1: simulation of time series + calcualting the autocorrelation
clc
clear all
close all
code_lengths=[15 30]; % time scale/length of neural codes; encoding period
cond_len=50; % number of trials generated 
for i=1:100  % total number of trials across the pair of conditions
    if i<cond_len+1
        code_amplitude=4; % amplitude of the code in one condition
    else
        code_amplitude=4.5; % amplitude of the code in the other condition
    end
    
    code_length=code_lengths(1);
    orig_series(1,i,:)=[randn(1,150) code_amplitude+randn(1,code_length) randn(1,50+(50-code_length))];
    % calculation of autocorrelation time series
    [tmp,~] = xcorr(orig_series(1,i,101:end),'unbiased');
    tmp_short(i,:)=squeeze(tmp(1,1,floor(size(tmp,3)/2)+1:end));

    code_length=code_lengths(2);
    orig_series(2,i,:)=[randn(1,150) code_amplitude+randn(1,code_length) randn(1,50+(50-code_length))];
    % calculation of autocorrelation time series
    [tmp,~] = xcorr(orig_series(2,i,101:end),'unbiased');
    tmp_long(i,:)=squeeze(tmp(1,1,floor(size(tmp,3)/2)+1:end));    
end
auto_corr(1,:,:)=tmp_short;
auto_corr(2,:,:)=tmp_long;

subplot(2,2,1)
plot(squeeze(nanmean(orig_series(1,1:cond_len,:))),'--')
hold on;
plot(squeeze(nanmean(orig_series(1,cond_len+1:100,:))),'--')
subplot(2,2,2)
plot(squeeze(nanmean(orig_series(2,1:cond_len,:))))
hold on;
plot(squeeze(nanmean(orig_series(2,cond_len+1:100,:))))

subplot(2,2,3)
plot(squeeze(nanmean(auto_corr(1,1:cond_len,:),2)),'--')
hold on;
plot(squeeze(nanmean(auto_corr(1,cond_len+1:100,:),2)),'--')
subplot(2,2,4)
plot(squeeze(nanmean(auto_corr(2,1:cond_len,:),2)))
hold on;
plot(squeeze(nanmean(auto_corr(2,cond_len+1:100,:),2)))
% save('Simulated_autocorr.mat','auto_corr','orig_series')
%% Decoding
clc
clear all
close all
load('Simulated_autocorr.mat','orig_series')
code_lengths=[15 30]; % length of the decoding window
cond_len=50; % number of trials per condition 
accuracy=nan(2,2,size(orig_series,3));
Yready=[ones(cond_len,1);zeros(cond_len,1)]; % class labels
w=0;
for code_length=code_lengths
    w=w+1;
    for time=floor(code_length/2)+1:size(orig_series,3)-floor(code_length/2)

        % performing two decodings: 
        % one on the time series with shorter and
        Xready=squeeze(nanmean(orig_series(1,:,time-floor(code_length/2):time+floor(code_length/2)),3))';
        Classifier_Model = fitcdiscr(Xready,Yready,'DiscrimType','pseudoLinear');
        cvmodel = crossval(Classifier_Model);
        L = kfoldLoss(cvmodel);
        accuracy(1,w,time)=1-L;
        
        % this one on the time series with the longer code
        Xready=squeeze(nanmean(orig_series(2,:,time-floor(code_length/2):time+floor(code_length/2)),3))';
        Classifier_Model = fitcdiscr(Xready,Yready,'DiscrimType','pseudoLinear');
        cvmodel = crossval(Classifier_Model);
        L = kfoldLoss(cvmodel);
        accuracy(2,w,time)=1-L;
    end
end
figure
subplot(1,2,1)
plot(squeeze(accuracy(1,:,:))')
legend short long
nanmax(squeeze(accuracy(1,:,151:end))')
nanmean(squeeze(accuracy(1,:,151:end))')
subplot(1,2,2)
plot(squeeze(accuracy(2,:,:))')
legend short long
nanmax(squeeze(accuracy(2,:,151:end))')
nanmean(squeeze(accuracy(2,:,151:end))')
% save('Simulation_decoding.mat','accuracy')
%% Plotting the original data, decoding results, and the estimated time scales (Supplementary figure 6)
clc
clear all
close all
% loading the data
load('Simulated_autocorr.mat','orig_series')
load('Simulation_decoding.mat','accuracy');
load('Simulated_AutoCorr_Parameters.mat')
cond_len=50;
times=[-100:149];
font_size=22;
figure
subplot(3,2,1)
plot(times,squeeze(nanmean(orig_series(1,1:cond_len,:),2)),'color',[0.8 0.2 0.2],'linewidth',3)
hold on;
plot(times,squeeze(nanmean(orig_series(1,cond_len+1:100,:),2)),'color',[0.2 0.2 0.8],'linewidth',3)
plot([times(1) times(end)],[0 0],'--k')
plot([0 0],[0 4.5],'--k')
xticklabels([])
title('Shorter (timescale) codes: 15ms')
ylabel('Amplitude (a.u.)')
box off
legend({'Condition_1','Condition_2'},'location','northwest')
set(gca,'TickDir','out','XMinorTick','on','Fontsize',font_size)

subplot(3,2,2)
plot(times,squeeze(nanmean(orig_series(2,1:cond_len,:),2)),'color',[0.8 0.2 0.2],'linewidth',3)
hold on;
plot(times,squeeze(nanmean(orig_series(2,cond_len+1:100,:),2)),'color',[0.2 0.2 0.8],'linewidth',3)
plot([times(1) times(end)],[0 0],'--k')
plot([0 0],[0 4.5],'--k')
title('Longer (timescale) codes: 30ms')
xticklabels([])
ylabel('Amplitude (a.u.)')
box off
legend({'Condition_1','Condition_2'},'location','northwest')
set(gca,'TickDir','out','XMinorTick','on','Fontsize',font_size)

subplot(3,2,3)
cl=cool;
indx_cols=round(linspace(1,size(cl,1),10));
cols=cl(indx_cols([4 8]),:);
times=[-100:149];
dec1=plot(times,squeeze(accuracy(1,1,:)),'color',cols(1,:),'linewidth',3)
hold on;
dec2=plot(times,squeeze(accuracy(1,2,:)),'color',cols(2,:),'linewidth',3)
plot([times(1) times(end)],[0.5 0.5],'--k')
plot([0 0],[0.25 1],'--k')
xlabel('Time (ms)')
ylabel({'Decoding';'accuracy'})
box off
legend([dec1 dec2],{['Window = 15ms'],['Window = 30ms']},'location','northwest')
set(gca,'TickDir','out','XMinorTick','on','Fontsize',font_size)

subplot(3,2,4)
dec1=plot(times,squeeze(accuracy(2,1,:)),'color',cols(1,:),'linewidth',3)
hold on;
dec2=plot(times,squeeze(accuracy(2,2,:)),'color',cols(2,:),'linewidth',3)
plot([times(1) times(end)],[0.5 0.5],'--k')
plot([0 0],[0.25 1],'--k')
xlabel('Time (ms)')
ylabel({'Decoding';'accuracy'})
box off
legend([dec1 dec2],{['Window = 15ms'],['Window = 30ms']},'location','northwest')
set(gca,'TickDir','out','XMinorTick','on','Fontsize',font_size)


subplot(3,2,5)
times=[0:149];
dat1=plot(times,squeeze(nanmean(data(1,1:cond_len,:),2)),'.','Color',[0.8 0.2 0.2],'markersize',15)
hold on;
dat2=plot(times,squeeze(nanmean(data(1,cond_len+1:end,:),2)),'.','Color',[0.2 0.2 0.8],'markersize',15)
estm1=plot(times,squeeze(nanmean(data_estim(1,1:cond_len,:),2)),'Color',[0.8 0.2 0.2],'linewidth',3)
estm2=plot(times,squeeze(nanmean(data_estim(1,cond_len+1:end,:),2)),'Color',[0. 0.2 0.8],'linewidth',3)
legend([dat1 dat2 estm1 estm2],{'Data condition_1','Data condition_2',['Tau condition_1= ',sprintf('%.2f',nanmean(taus(1,1:cond_len),2)),'ms'],['Tau condition_2= ',sprintf('%.2f',nanmean(taus(1,cond_len+1:end),2)),'ms']})
xlim([0 150])
xlabel('Time delay (ms)')
ylabel('Autocorrelation')
box off
set(gca,'TickDir','out','XMinorTick','on','Fontsize',font_size)

subplot(3,2,6)
dat1=plot(times,squeeze(nanmean(data(2,1:cond_len,:),2)),'.','Color',[0.8 0.2 0.2],'markersize',15)
hold on;
dat2=plot(times,squeeze(nanmean(data(2,cond_len+1:end,:),2)),'.','Color',[0.2 0.2 0.8],'markersize',15)
estm1=plot(times,squeeze(nanmean(data_estim(2,1:cond_len,:),2)),'Color',[0.8 0.2 0.2],'linewidth',3)
estm2=plot(times,squeeze(nanmean(data_estim(2,cond_len+1:end,:),2)),'Color',[0.2 0.2 0.8],'linewidth',3)
legend([dat1 dat2 estm1 estm2],{'Data condition_1','Data condition_2',['Tau condition_1= ',sprintf('%.2f',nanmean(taus(2,1:cond_len),2)),'ms'],['Tau condition_2= ',sprintf('%.2f',nanmean(taus(2,cond_len+1:end),2)),'ms']})
xlim([0 150])
xlabel('Time delay (ms)')
ylabel('Autocorrelation')
box off
set(gca,'TickDir','out','XMinorTick','on','Fontsize',font_size)


