clc;
clear all;
close all;
ica_applied=1; %apply ICA (1) or not (0)
for partid=[1:16] 
    
    addpath(genpath('F:\Toolbox\eeglab2021.1'))
    eeglab
    pop_editoptions('option_savetwofiles', 0);
    
    % load EEG file
    EEG_raw = pop_loadbv(sprintf('F:/RESEARCH/Hamid/Features_EEG/sub-%02i/eeg/',partid), sprintf('sub-%02i_task-rsvp_eeg.vhdr',partid));
    EEG_raw = eeg_checkset(EEG_raw);
    EEG_raw.setname = partid;
    EEG_raw = eeg_checkset(EEG_raw);
    
    % notch filter
    EEG_raw = pop_eegfiltnew(EEG_raw, 49,51,[],1);
    EEG_raw = pop_eegfiltnew(EEG_raw, 99,101,[],1);
    EEG_raw = pop_eegfiltnew(EEG_raw, 149,151,[],1);
    
    % high pass filter
    EEG_raw = pop_eegfiltnew(EEG_raw, 0.05,[]);
    
    % low pass filter
    EEG_raw = pop_eegfiltnew(EEG_raw, [],200);
    
    % downsample
    EEG_cont = pop_resample(EEG_raw, 500);
    EEG_cont = eeg_checkset(EEG_cont);
    
    if ica_applied==1
        OUT_EEG = pop_runica(EEG_cont);
        EEG = iclabel(OUT_EEG);
%         ICA_info=EEG.etc.ic_classification.ICLabel;
        plotting_ICA=1;
        if plotting_ICA==1
            artefact_labels=EEG.etc.ic_classification.ICLabel.classes;
            figure;
            c=0;
            for i=2:6
                c=c+1;
                plots(c)=plot(EEG.etc.ic_classification.ICLabel.classifications(:,i),'linewidth',2);
                hold on;
            end
            grid on;
            legend(artefact_labels(2:6),'location','northwest')
        end
%         [~,max_eye_artf]=max(EEG.etc.ic_classification.ICLabel.classifications(:, 3));
        %% increase partid
        stop_toc_check_components
        pop_viewprops(EEG, 0); % to see component properties
        % 1: 2,3 8
        % 2: 38
        % 3: 8 9 12
        % 4: 1 3
        % 5: 8 16
        % 6: 15
        % 7: 4 11
        % 8: 8 22
        % 9: 16 17
        % 10: 11 30
        % 11: 3 4
        % 12: 6 11
        % 13: 1 4 8
        % 14: 1 2
        % 15: 12 13 18
        % 16: 1 2 4
        EEG_cont = pop_subcomp( EEG, [1 2 4]);
        clearvars OUT_EEG EEG EEG_raw EEG
        EEG_cont.icawinv=[];
        EEG_cont.icasphere=[];
        EEG_cont.icaweights=[];
        EEG_cont.icachansind=[];
    end    
    % pop_saveset(EEG_cont,contfn);
    %% create epochs
    EEG_epoch = pop_epoch(EEG_cont, {'E  1'}, [-0.600 0.600]);
    
    EEG_epoch.epoch=[];
    EEG_epoch.event=[];
    EEG_epoch.urevent=[];
    if ica_applied==1
        save(sprintf('F:/RESEARCH/Hamid/Features_EEG/derivatives/hamid_preproc/sub-%02i_task-rsvp_500HZ_Notched_ICAed.mat',partid),'EEG_epoch','-v7.3')
    else
        save(sprintf('F:/RESEARCH/Hamid/Features_EEG/derivatives/hamid_preproc/sub-%02i_task-rsvp_500HZ_Notched.mat',partid),'EEG_epoch','-v7.3')
    end
    clearvars -except partid ica_applied
    [partid]
end
