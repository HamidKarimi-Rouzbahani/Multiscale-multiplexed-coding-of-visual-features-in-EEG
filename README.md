# Multiscale-multiplexed-coding-of-visual-features-in-EEG
Multiscale multiplexed coding of visual features in EEG

This repository shares the programming scripts used for the following manuscript:

Karimi-Rouzbahani, H., & McGonigal, A. (2023). Generalisability of epileptiform patterns across time and patients. medRxiv, 2023-08. doi: https://doi.org/10.1101/2023.07.09.548296

This is the readme file for the scripts used to conduct the analyses.

The analyis scripts are the ones whose file names start with Cx, x referring the order of use from preprocessing the data to plotting the final figures. The Px files plot the figures and the CPx files are contain simulated analyses and plotting of the results.

The analyses which are coded in Matlab (majority) which uses EEGLAB (eeglab2021.1) which can be downloaded freely at (https://sccn.ucsd.edu/eeglab/index.php) and the Bayes Factor toolbox developed by Bart Krekelberg (https://klabhub.github.io/bayesFactor/)

There are also two scripts which are coded in Python which are used for curve fitting which was missing from the Matlab installation that the author was using at the time of running the analyses.

I provide below a short discription of each of the custom scripts used in the current manuscript - the scripts with C as their initial letter in file name. More details can be found within each script.


#% This script preprocesses the raw EEG data provided at https://openneuro.org/datasets/ds004357/versions/1.0.0
#   % It first loads the data from the original dataset
#    % Then it notch filters the data at 50, 100 and 150Hz followed by high (0.05) and low-pass (200 Hz) filterng and
#    % down-sampling (to 500 Hz)
#    % Then it applies ICA to find and remove components which are related to
#    % eye-movement artefacts
#    % Finally it epochs (-600 to 600 ms relative to stimulus onset) and saves the data

# % INPUTS: data from the original dataset
% OUTPUTS: epoched data to be used by:
    % C1_Time_resolved_decoding_multiscale
    % C1_Time_resolved_decoding_multiscale_per_area
    % and C2_Autocorr_calculation



    
