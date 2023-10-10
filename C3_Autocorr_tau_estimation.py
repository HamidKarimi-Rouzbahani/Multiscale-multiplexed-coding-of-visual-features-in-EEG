# This script estimates for every trial the parameters of an exponential decay 
# function fitted to the autocorrelation function obtained from each trial
    # It first loads loads the data
    # Then fits the exponential decay function to it and estimates the parameters
    # Then it evaluates the goodness of fit
    # finally it saves the data in Matlab .mat format to be used for plotting

# INPUTS: autocorrelation time series data from C2_Calculating_autocors_and_prepararing_for_ACF_estim.m
# OUTPUTS: the parameters of exponential decay function fitted to ACF and the goodness of fit used by:
    # P3_Plotting_autocorr_parameters.m
    
    
# Importing the necessary libraries
import scipy.io
from scipy.io import savemat
import numpy as np
import scipy.optimize

dataload_path = 'F:/RESEARCH/Hamid/MultiScale/'
subjs=np.array(list(range(1, 17))) 


for subj in subjs:
    # loading the data
    tmp = scipy.io.loadmat(dataload_path+'AutoCorr_Summrzd_unbiased_long_SOA_subj_all_channels_'+f"{subj:02}"+'.mat')
    data=tmp.get("auto_corr_summrzd")
    
    # preparing some variables for fitting
    cond=np.array(list(range(0, data.shape[0])))
    sub_cond=np.array(list(range(0, data.shape[1])))
    ch=np.array(list(range(0, data.shape[2])))
    xs=np.array(list(range(1, data.shape[4]+1)))
    p0 = (300, .1, 50) # m, t, b start with values near those we expect

    
    # definiing the exponential decay function to be called in the code
    def monoExp(x, m, t, b):
        return m * np.exp(-t * x) + b
    
    # preparing some empty variables to be filled with parameters for saving
    taus=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2]))
    rSquared_all=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2]))
    ys_estim=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2],75))
    ys_used=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2],75))
    
    # looping over the four features, its conditions and channels
    for i in cond:
        for j in sub_cond:
            for k in ch:
                
                # Averaging the ACFs across all trials within each condition for fitting
                tmp_data=data[i,j,k,:,:]
                ys=tmp_data.mean(0)
                
                
                # perform the fit
                try:
                    params, cv = scipy.optimize.curve_fit(monoExp, xs, ys, p0)
                    m, t, b = params
                except:
                    t=float("nan")

                sampleRate = 500 # Hz
                tauSec = (1 / t) / sampleRate            
                taus[i,j,k]=tauSec
                print(tauSec)

                # determine quality of the fit
                squaredDiffs = np.square(ys - monoExp(xs, m, t, b))
                
                squaredDiffsFromMean = np.square(ys - np.mean(ys))
                rSquared = 1 - np.sum(squaredDiffs) / np.sum(squaredDiffsFromMean)
                rSquared_all[i,j,k]=rSquared
                ys_estim[i,j,k,0:75]=monoExp(xs, m, t, b)
                ys_used[i,j,k,0:75]=ys
                
    print(subj)
    mdic={"taus": taus,"data_estim": ys_estim,"data_orig": ys_used,"rSquared_all": rSquared_all}
    # saving the data
    savemat(dataload_path+'AutoCorr_Parameters_Subj_'+f"{subj:02}"+'.mat', mdic)
            
            