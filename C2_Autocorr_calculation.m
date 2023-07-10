clc;
clear all;
close all;
addpath(genpath('F:\Toolbox\eeglab2021.1'))
analysis_loc=2; % 1= 3occipt chans; 2= all channels separately
long_short_SOA=1; % 1=long soa; 2= short soa
for partid=[1:16]
    load(sprintf('F:/RESEARCH/Hamid/Features_EEG/derivatives/hamid_preproc/sub-%02i_task-rsvp_500HZ.mat',partid),'EEG_epoch')
    eventlist=tdfread(sprintf('F:/RESEARCH/Hamid/Features_EEG/sub-%02i/eeg/sub-%02i_task-rsvp_events.tsv',partid,partid));
    %% Parameters
    if analysis_loc==1
        channels=16:18; % only occipital
    elseif analysis_loc==2
        channels=[1:127]; % all channels
    end
    trls=1:length(eventlist.onset);
    trls_all=zeros(1,length(trls));
    if long_short_SOA==1
        chars='long_SOA_';
        trls_all([eventlist.soaduration==0.15])=1; % keep only long SOA trials
    else
        chars='short_SOA_';
        trls_all([eventlist.soaduration==0.05])=1; % keep only long SOA trials
    end
    steps=1;
    spans=[300:steps:600];
    %% Decoding of information
    for info_type=[1:4]
        conditions =[0:3];
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
            trl=0;
            for indx=indX
                trl=trl+1;
                if analysis_loc==1
                    [auto_corr(info_type,cnd,trl,:),~] = xcorr(squeeze(mean(EEG_epoch.data(channels,spans,indx))),'normalized');
                elseif analysis_loc==2
                    for ch=channels
%                         [tmp,~] = xcorr(squeeze(EEG_epoch.data(ch,spans,indx)),'normalized');
                        [tmp,~] = xcorr(squeeze(EEG_epoch.data(ch,spans,indx)),'unbiased');
                        auto_corr(info_type,cnd,ch,trl,:)=tmp(300:400);
                    end
                end
            end
            [partid info_type cnd]
        end
    end
    if analysis_loc==1
        save(sprintf('AutoCorr_subj_%02i.mat',partid),'auto_corr','-v7.3')
    elseif analysis_loc==2
%         save(sprintf(['AutoCorr',chars,'subj_all_channels_%02i.mat'],partid),'auto_corr','-v7.3')
        save(sprintf(['AutoCorr_unbiased',chars,'subj_all_channels_%02i.mat'],partid),'auto_corr','-v7.3')
    end
    clearvars auto_corr
end
stop_here
%% Preparing for python parameter estimation and a sample plotting
clc;
clear all
close all
analysis_loc=2; % 1= 3occipt chans; 2= all channels separately
long_short_SOA=1; % 1=long soa; 2= short soa

if long_short_SOA==1
    chars='long_SOA_';
else
    chars='short_SOA_';
end
for partid=[1:16]
    if analysis_loc==1
        load(sprintf('AutoCorr_subj_%02i.mat',partid),'auto_corr')
    elseif analysis_loc==2
%         load(sprintf(['AutoCorr',chars,'subj_all_channels_%02i.mat'],partid),'auto_corr')
        load(sprintf(['AutoCorr_unbiased',chars,'subj_all_channels_%02i.mat'],partid),'auto_corr')
    end
    data(:,:,:,partid)=squeeze(nanmean(nanmean(auto_corr(:,:,:,:,[1:end]),3),4));
    auto_corr_summrzd=auto_corr(:,:,:,:,[2:76]);
    if analysis_loc==2
%         save(sprintf(['AutoCorr_Summrzd_',chars,'subj_all_channels_%02i.mat'],partid),'auto_corr_summrzd')
        save(sprintf(['AutoCorr_Summrzd_unbiased_',chars,'subj_all_channels_%02i.mat'],partid),'auto_corr_summrzd')
    end
end

%% Plotting a sample
titles={'orients','freqs','colors','contrasts'};
for info_type=[1:4]
    subplot(2,2,info_type)
%         plot(sum(diff(squeeze(nanmean(data(info_type,:,:,:),4)),[],1)))
    for cond=1:4
        for partid=[1:size(data,4)]
            dat_temp=data(info_type,cond,:,partid);
%             dat_temp=dat_temp./max(dat_temp);
        end
        plot(squeeze(nanmean(dat_temp,4)))
        hold on;
    end
    title(titles(info_type))
end
