% This script calcualtes the autocorrelation function  (ACF) for every trial of each
% condition and saves it in a structure to be used in Python to estimate
% parameters of exponential decay function
    % It first loads loads the data
    % Then calcualtes the ACF
    % Then balances the number of trial across conditions which are decoded
    % Then saves it in .mat format 

% INPUTS: preprocessed data from C0_Preprocessing
% OUTPUTS: Autocorrelation time series ready for fitting of exponential
% decay function using the following script:
    % C3_Autocorr_tau_estimation
%%
clc;
clear all;
close all;
addpath(genpath('F:\Toolbox\eeglab2021.1'))
for partid=[1:16]
    
    % loading the data
    load(sprintf('F:/RESEARCH/Hamid/Features_EEG/derivatives/hamid_preproc/sub-%02i_task-rsvp_500HZ_Notched_ICAed.mat',partid),'EEG_epoch')
    eventlist=tdfread(sprintf('F:/RESEARCH/Hamid/Features_EEG/sub-%02i/eeg/sub-%02i_task-rsvp_events.tsv',partid,partid));

    %% Parameters
    channels=[1:127]; % all channels
    trls=1:length(eventlist.onset);
    trls_all=zeros(1,length(trls));
    trls_all([eventlist.soaduration==0.15])=1; % keep only long SOA trials
    spans=[300:375]; % windows of analysis (refers to 0ms to 150ms relative to stimulus onset)

    %% Caclulating the autocorrelation function 
    for info_type=[1:4] % Going over the four features of stimulus
        conditions =[0:3]; % four conditions within each feature
        trls_sel=repmat(trls_all,[length(conditions) 1]);
        cnd=0;
        features_tmp=[];
        for cond=conditions
            cnd=cnd+1;
            if info_type==1 % orientation
                trls_sel(cnd,[eventlist.f_ori~=cond])=0;
            elseif info_type==2 % spatial freq
                trls_sel(cnd,[eventlist.f_sf~=cond])=0;
            elseif info_type==3 % color
                trls_sel(cnd,[eventlist.f_color~=cond])=0;
            elseif info_type==4 % contrast
                trls_sel(cnd,[eventlist.f_contrast~=cond])=0;
            end
            indX=find(trls_sel(cnd,:)==1);
            
            %% ACF calculation per each trial
            trl=0;
            for indx=indX
                trl=trl+1;
                for ch=channels
                    [tmp,~] = xcorr(squeeze(EEG_epoch.data(ch,spans,indx)),'unbiased');
                    auto_corr(info_type,cnd,ch,trl,:)=tmp;
                end
            end
            [partid info_type cnd]
        end
    end
    % saving the data
    save(sprintf(['AutoCorr_unbiasedlong_SOA_subj_all_channels_%02i.mat'],partid),'auto_corr','-v7.3')
    clearvars auto_corr
end
%% Preparing the autocorrelations for parameterestimation in Python
clc;
clear all
close all
for partid=[1:16]
    load(sprintf(['AutoCorr_unbiasedlong_SOA_subj_all_channels_%02i.mat'],partid),'auto_corr')
    auto_corr_summrzd=auto_corr(:,:,:,:,[76:150]); % only keeping 75 delays
    save(sprintf(['AutoCorr_Summrzd_unbiased_long_SOA_subj_all_channels_%02i.mat'],partid),'auto_corr_summrzd')
end
