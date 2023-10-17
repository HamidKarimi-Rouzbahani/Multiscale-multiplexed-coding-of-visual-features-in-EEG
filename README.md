# Multiscale-multiplexed-coding-of-visual-features-in-EEG
Multiscale multiplexed coding of visual features in EEG

This repository shares the programming scripts used for the following manuscript:

Karimi-Rouzbahani, H. (2023). Evidence for multiscale multiplexed representation of visual features in EEG. doi: https://doi.org/10.1101/2023.07.09.548296

This is the readme file for the scripts used to conduct the analyses.

The analyis scripts are the ones whose file names start with Cx, x referring the order of use from preprocessing the data to plotting the final figures. The Px files plot the figures and the CPx files are contain simulated analyses and plotting of the results.

The analyses which are coded in Matlab (majority) which uses EEGLAB (eeglab2021.1) which can be downloaded freely at (https://sccn.ucsd.edu/eeglab/index.php) and the Bayes Factor toolbox developed by Bart Krekelberg (https://klabhub.github.io/bayesFactor/)

There are also two scripts which are coded in Python which are used for curve fitting which was missing from the Matlab installation that the author was using at the time of running the analyses.

I provide below a short description of each of the scripts used in the current manuscript. More details can be found within each script.


**C0_Preprocessing.m**
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


**C1_Time_resolved_decoding_multiscale.m**
% This script performs the multiscale decoding using the
% preprocessed data
    % It first loads loads the data
    % Then it selects the trials specific to each condition
    % Than balances the number of trial across conditions which are decoded
    % Then randomises the trials across te experiment
    % Finally it decodes the data using a sliding time window with
    % different lengths

% INPUTS: preprocessed data from C0_Preprocessing
% OUTPUTS: output data used by the following for statistical testing and
% plotting
    % P1_Ploting_time_resolved_decoding
    % P1_Ploting_time_resolved_decoding_supplem
    % P2_Ploting_peak_differences
    

**C1_Time_resolved_decoding_multiscale_per_area.m**
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


**C2_Calculating_autocors_and_prepararing_for_ACF_estim.m**
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


**C3_Autocorr_tau_estimation.py**    
% This script estimates for every trial the parameters of an exponential decay 
% function fitted to the autocorrelation function obtained from each trial
    % It first loads loads the data
    % Then fits the exponential decay function to it and estimates the parameters
    % Then it evaluates the goodness of fit
    % finally it saves the data in Matlab .mat format to be used for plotting

% INPUTS: autocorrelation time series data from C2_Calculating_autocors_and_prepararing_for_ACF_estim.m
% OUTPUTS: the parameters of exponential decay function fitted to ACF and the goodness of fit used by:
    % P3_Plotting_autocorr_parameters.m
    
    
**C3_Autocorr_tau_estimation_sim.py**
% This script estimates for every trial the parameters of an exponential decay 
% function fitted to the autocorrelation function obtained from each simulated trial
    % It first loads loads the simulated data
    % Then fits the exponential decay function to it and estimates the parameters
    % Then it evaluates the goodness of fit
    % finally it saves the data in Matlab .mat format to be used for plotting

% INPUTS: autocorrelation time series data from C5_Evaluating_decoding_vs_ACF_estimations.m
% OUTPUTS: the parameters of exponential decay function fitted to ACF and the goodness of fit used by:
    % CP2_Evaluating_decoding_vs_ACF_estimations.m

   
**CP1_Decoding_window_time_constant_simulations.m**
% This script performs two simulations:
    % 1: simulation of a time series with indication of different length of
    % decoding window + plotting
    % 2: simulation of three decay functions with different levels of decay
    % constant (Tau) + plotting
    % Figures 1C and 1D

% INPUTS: NA
% OUTPUTS: NA (images)


**CP2_Evaluating_decoding_vs_ACF_estimations.m**
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


**P1_Ploting_time_resolved_decoding.m**
% This script plots the multiscale time-resolved decoding results (also does the Bayesian Analyses)
% including Figures 2, 3, 4 and Supplementary Figure 3 and 5 

% INPUTS: C1_Time_resolved_decoding_multiscale
% OUTPUTS: NA (images)


**P1_Ploting_time_resolved_decoding_per_area.m**
% This script plots the multiscale time-resolved decoding results (also does the Bayesian Analyses)
% for each area: Supplementary Figure 4 

% INPUTS: C1_Time_resolved_decoding_multiscale_per_area
% OUTPUTS: NA (images)


**P1_Ploting_time_resolved_decoding_supplem.m**
% This script plots the multiscale time-resolved decoding results (also does the Bayesian Analyses)
% for all 10 time scales: Supplementary Figure 1

% INPUTS: C1_Time_resolved_decoding_multiscale
% OUTPUTS: NA (images)


**P2_Ploting_peak_differences.m**
% This script plots the time point when the decoding curves reached their
% first peak acorss the four fearues (Supplementary Figure 2)

% INPUTS: C1_Time_resolved_decoding_multiscale
% OUTPUTS: NA (images)


**P3_Plotting_autocorr_parameters.m**
% This script plots ACF-based estimated time scales across the scalp
% and uses Bayesian Analysis to compare them: Figure 5

% INPUTS: C1_Time_resolved_decoding_multiscale
% OUTPUTS: NA (images)


**P4_Plotting_ACF_and_Fits.m**
% This script plots the autocorrelation functions, the exponential decay function
% fitted to them and the goodness of fit (r^2): Supplementary Figures 7 & 8

% INPUTS: C3_Autocorr_tau_estimation
% OUTPUTS: NA (images)

