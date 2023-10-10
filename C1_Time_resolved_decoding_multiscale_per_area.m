% This script performs the multiscale decoding using the
% preprocessed data for 3 regions of interest separately
    % It first loads loads the data
    % Then it selects the trials specific to each condition
    % Than balances the number of trial across conditions which are decoded
    % Then randomises the trials across te experiment
    % Finally it decodes the data using a sliding time window with
    % different lengths

% INPUTS: preprocessed data from C0_Preprocessing
% OUTPUTS: decoded data used by the following for statistical testing and
% plotting
    % P1_Ploting_time_resolved_decoding_per_area
%% 
clc;
clear all;
close all;
addpath(genpath('F:\Toolbox\eeglab2021.1'))
% three regions of interests (frontal, central and occipital) are determined using electrode data
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
chans{1}=occip_chans;
chans{2}=cent_chans;
chans{3}=frnt_chans;

for partid=[1:16]
    load(sprintf('F:/RESEARCH/Hamid/Features_EEG/derivatives/hamid_preproc/sub-%02i_task-rsvp_500HZ_Notched_ICAed.mat',partid),'EEG_epoch')
    eventlist=tdfread(sprintf('F:/RESEARCH/Hamid/Features_EEG/sub-%02i/eeg/sub-%02i_task-rsvp_events.tsv',partid,partid));
    %% Parameters
    trls=1:length(eventlist.onset);
    trls_all=zeros(1,length(trls));
    trls_all([eventlist.soaduration==0.15])=1; % keep only long SOA trials from the data
    spans=[200:600]; % windows of analysis (refers to -200 to 600 relative to stimulus onset)

    for chann=1:3 % decoding is performed for 3 distinct regions of interest consisting of occipital; central and frontal 
        channels=chans{chann};

        %% Decoding of information
        for info_type=[1:4]
            %% find the trials for each feature
            conditions =[0:3]; % eahc features has 4 conditions
            cnd=0;
            trls_sel=repmat(trls_all,[length(conditions) 1]);
            trl=0;
            X=nan(10500,length(channels),401);
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
                for indx=indX
                    trl=trl+1;
                    X(trl,1:length(channels),:)=squeeze(EEG_epoch.data(channels,spans,indx));
                    Y(trl,1)=cnd;
                end
            end
            clearvars tmp_data
            %% Removing nans from trials matrix
            t=any(isnan(X),2);
            X(t(:,1,1), :,:) = [];

            %% Balancing the number of trials across classes
            c=0;
            for i=unique(Y)'
                c=c+1;
                counts(c)=sum(Y==i);
            end
            min_obs=min(counts);
            XX=[];
            YY=[];
            c=0;
            for i=unique(Y)'
                c=c+1;
                sel_samples=randsample(find(Y==i),min_obs);
                XX=vertcat(XX,X(sel_samples,:,:));
                YY=vertcat(YY,Y(sel_samples));
            end
            Y=YY;
            X=XX;
            %% Randomising trials' order
            randnums=randsample([1:length(Y)],length(Y));
            Y=Y(randnums);
            X=X(randnums,:,:);
            clearvars t YY XX
            display(['Subj #',num2str(partid),' loaded!, Info = ',num2str(info_type),  ', Trls = ',num2str(size(X,1))])
            %% Decoding
            windows=[1 3 5 7 9 11 13 19 25 37]; % * 2ms: 10 windows with different lengths for decoding
            w=0;
            for wind=windows
                w=w+1;
                for time=ceil(max(windows)/2):size(X,3)-ceil(max(windows)/2) % sliding across the trial and decoding the data
                    combinations=nchoosek(unique(Y),2);
                    for comb=1:size(combinations,1)
                        time_span=time-floor(wind/2):time+floor(wind/2);
                        Xready=[nanmean(X(Y==combinations(comb,1),:,time_span),3);nanmean(X(Y==combinations(comb,2),:,time_span),3)];
                        Yready=[Y(Y==combinations(comb,1));Y(Y==combinations(comb,2))];
                        
                        % using an LDA classifier for decoding
                        Classifier_Model = fitcdiscr(Xready,Yready,'DiscrimType','pseudoLinear');

                        % performing 10-fold cross-validation
                        cvmodel = crossval(Classifier_Model);
                        L = kfoldLoss(cvmodel);
                        accuracy(info_type,w,time,comb)=1-L;
                        clearvars Xready Yready
                    end
                end
                [partid chann info_type wind]
            end
            chan_labels={'Occipital','Central','Frontal'};
            clearvars X Y Xready Yready
            % saving the decoding results
            save(['F:\RESEARCH\Hamid\MultiScale\',sprintf(['Decoding_data_8windows_Nobslin_trlsEq_',chan_labels{chann},'_subj_%02i.mat'],partid)],'accuracy')
        end
    end
    clearvars accuracy
end