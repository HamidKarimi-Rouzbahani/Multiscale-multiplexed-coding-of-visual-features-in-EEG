# This script estimates for every trial the parameters of an exponential decay 
# function fitted to the autocorrelation function obtained from each simulated trial
    # It first loads loads the simulated data
    # Then fits the exponential decay function to it and estimates the parameters
    # Then it evaluates the goodness of fit
    # finally it saves the data in Matlab .mat format to be used for plotting

# INPUTS: autocorrelation time series data from C5_Evaluating_decoding_vs_ACF_estimations.m
# OUTPUTS: the parameters of exponential decay function fitted to ACF and the goodness of fit used by:
    # CP2_Evaluating_decoding_vs_ACF_estimations.m


# Importing the necessary libraries
import scipy.io
from scipy.io import savemat
import numpy as np
import scipy.optimize

dataload_path = 'F:/RESEARCH/Hamid/MultiScale/'
tmp = scipy.io.loadmat(dataload_path+'Simulated_autocorr.mat')
data=tmp.get("auto_corr")

    # preparing some variables for fitting
cond=np.array(list(range(0, data.shape[0])))
ch=np.array(list(range(0, data.shape[1])))
xs=np.array(list(range(1, data.shape[2]+1)))
p0 = (300, .1, 50) # m, t, b start with values near those we expect

    # definiing the exponential decay function to be called in the code
def monoExp(x, m, t, b):
    return m * np.exp(-t * x) + b

    # preparing some empty variables to be filled with parameters for saving
taus=np.zeros(shape= (data.shape[0],data.shape[1]))
rSquared_all=np.zeros(shape= (data.shape[0],data.shape[1]))
ys_estim=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2]))
ys_used=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2]))

    # looping over the four features, its conditions and channels
for i in cond:
        for k in ch:
            
            ys=data[i,k,:]
            
            
            # perform the fit
            try:
                params, cv = scipy.optimize.curve_fit(monoExp, xs, ys, p0)
                m, t, b = params
            except:
                t=float("nan")

            sampleRate = 1 # Hz
            tauSec = (1 / t) / sampleRate            
            taus[i,k]=tauSec
            print(tauSec)

            # determine quality of the fit
            squaredDiffs = np.square(ys - monoExp(xs, m, t, b))

            squaredDiffsFromMean = np.square(ys - np.mean(ys))
            rSquared = 1 - np.sum(squaredDiffs) / np.sum(squaredDiffsFromMean)
            rSquared_all[i,k]=rSquared
            ys_estim[i,k,:]=monoExp(xs, m, t, b)
            ys_used[i,k,:]=data[i,k,:]
            
mdic={"taus": taus,"data_estim": ys_estim,"data": ys_used,"rSquared_all": rSquared_all}
   # saving the data
savemat(dataload_path+'Simulated_AutoCorr_Parameters.mat', mdic)
        
        