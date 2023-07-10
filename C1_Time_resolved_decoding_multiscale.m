clc;
clear all;
close all;
addpath(genpath('F:\Toolbox\eeglab2021.1'))
SOA=1;
for partid=[1:16]
    tic
    load(sprintf('F:/RESEARCH/Hamid/Features_EEG/derivatives/hamid_preproc/sub-%02i_task-rsvp_500HZ.mat',partid),'EEG_epoch')
    eventlist=tdfread(sprintf('F:/RESEARCH/Hamid/Features_EEG/sub-%02i/eeg/sub-%02i_task-rsvp_events.tsv',partid,partid));
    %% Parameters
    channels=1:127;
    trls=1:length(eventlist.onset);
    trls_all=zeros(1,length(trls));
    if SOA==1
        trls_all([eventlist.soaduration==0.15])=1; % keep only long SOA trials
    elseif SOA==2
        trls_all([eventlist.soaduration==0.05])=1; % keep only short SOA trials
    end
    steps=1;
    spans=[200:steps:600];
    baseline_period=[spans(1):300];
    %% Decoding of information
    for info_type=[1:4]
        conditions =[0:3];
        cnd=0;
        trls_sel=repmat(trls_all,[length(conditions) 1]);
        trl=0;
        X=nan(10500,127,401);
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
                baselining=0;
                if baselining==1
                    % Baselining
                    tmp_data=squeeze(EEG_epoch.data(channels,spans,indx));
                    X(trl,channels,:)=tmp_data-repmat(mean(tmp_data(:,baseline_period),2),[1 size(tmp_data,2)]);
                else
                    X(trl,channels,:)=squeeze(EEG_epoch.data(channels,spans,indx));
                end
                Y(trl,1)=cnd;
            end
        end
        clearvars tmp_data
        %% Removing nans
        t=any(isnan(X),2);
        X(t(:,1,1), :,:) = [];
        %% Balancing the data across classes
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
        %% Randomising observations' order
        randnums=randsample([1:length(Y)],length(Y));
        Y=Y(randnums);
        X=X(randnums,:,:);
        clearvars t YY XX
        display(['Subj #',num2str(partid),' loaded!, Info = ',num2str(info_type),  ', Trls = ',num2str(size(X,1))])
        %% Decoding
        windows=[1 3 5 7 9 11 13 19 25 37]; % * 2ms
        w=0;
        for wind=windows
            w=w+1;
            for time=ceil(max(windows)/2):size(X,3)-ceil(max(windows)/2)
                combinations=nchoosek(unique(Y),2);
                for comb=1:size(combinations,1)
                    time_span=time-floor(wind/2):time+floor(wind/2);
                    Xready=[nanmean(X(Y==combinations(comb,1),:,time_span),3);nanmean(X(Y==combinations(comb,2),:,time_span),3)];
                    Yready=[Y(Y==combinations(comb,1));Y(Y==combinations(comb,2))];
                    
                    Classifier_Model = fitcdiscr(Xready,Yready,'DiscrimType','pseudoLinear');
                    cvmodel = crossval(Classifier_Model);
                    L = kfoldLoss(cvmodel);
                    accuracy(info_type,w,time,comb)=1-L;
                    clearvars Xready Yready
                end
            end
            [partid info_type wind]
        end
        clearvars X Y Xready Yready
        if SOA==1
            save(['/home/uqhkarim/MatlabProjects/EEG_scales/',sprintf('Decoding_data_8windows_Nobslin_trlsEq_subj_%02i.mat',partid)],'accuracy')
        elseif SOA==2
            save(['/home/uqhkarim/MatlabProjects/EEG_scales/',sprintf('Decoding_data_8windows_Nobslin_Ssoa_subj_%02i.mat',partid)],'accuracy')
        end
    end
    clearvars accuracy
    toc
end

%% Initial plotting
p=0;
for partid=[1 6]
    p=p+1;
    load(sprintf('Decoding_data_windows_subj_%02i.mat',partid),'accuracy')
    accuracies(p,:,:,:,:)=accuracy;
end
titles={'Ori','Freq','Col','Cont'};
for i=1:4
    subplot(2,2,i);
    plot(squeeze(nanmean(nanmean(accuracies(:,i,:,50:350,:),5),1))','linewidth',2);
    legend 2 6 10 18 50 100;
    hold on;
    plot([50 350],[0.5 0.5],'--');
    title(titles{i});
end
