% This script preprocesses the raw EEG data provided at https://openneuro.org/datasets/ds004357/versions/1.0.0
    % It first loads the data from the original dataset
    % Then it notch filters the data at 50, 100 and 150Hz followed by high (0.05) and low-pass (200 Hz) filterng and
    % down-sampling (to 500 Hz)
    % Then it applies ICA to find and remove components which are related to
    % eye-movement artefacts
    % Finally it epochs (-600 to 600 ms relative to stimulus onset) and saves the data

% INPUTS: data from the original dataset
% OUTPUTS: epoched data to be used by:
    % C1_Time_resolved_decoding_multiscale
    % C1_Time_resolved_decoding_multiscale_per_area
    % and C2_Autocorr_calculation
%%
clc;
clear all;
close all;
partid=1; % participant IDs from 1 to 16
% Adding EEGLAB for data loading and preprocessing
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


%% ICA
% run ICA algorithm
OUT_EEG = pop_runica(EEG_cont);
EEG = iclabel(OUT_EEG);
% plotting to check ICs
plotting_ICs=1;
if plotting_ICs==1
    artefact_labels=EEG.etc.ic_classification.ICLabel.classes;
    figure;
    c=0;
    for i=2:6
        plot(EEG.etc.ic_classification.ICLabel.classifications(:,i),'linewidth',2);
        hold on;
    end
    grid on;
    legend(artefact_labels(2:6),'location','northwest')
end

% find the IC with maximum level of artefact
%         [~,max_eye_artf]=max(EEG.etc.ic_classification.ICLabel.classifications(:, 3));

stop_and_check_components_visually
pop_viewprops(EEG, 0); % to see component properties
% we have selected the following ICs to be removed from each of the
% subjects

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

% Now reject the artefactual components (here [1 2 4] are selected for subject #16)
EEG_cont = pop_subcomp( EEG, [1 2 4]);
clearvars OUT_EEG EEG EEG_raw EEG

% remove unneeded data to reduce saving space
EEG_cont.icawinv=[];
EEG_cont.icasphere=[];
EEG_cont.icaweights=[];
EEG_cont.icachansind=[];

%% create epochs
EEG_epoch = pop_epoch(EEG_cont, {'E  1'}, [-0.600 0.600]);

% removing unnecessary data to save space
EEG_epoch.epoch=[];
EEG_epoch.event=[];
EEG_epoch.urevent=[];
save(sprintf('F:/RESEARCH/Hamid/Features_EEG/derivatives/hamid_preproc/sub-%02i_task-rsvp_500HZ_Notched_ICAed.mat',partid),'EEG_epoch','-v7.3')
clearvars -except partid ica_applied
partid
