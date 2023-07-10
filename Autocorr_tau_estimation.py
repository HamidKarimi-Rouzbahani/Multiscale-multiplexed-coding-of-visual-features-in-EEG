

import scipy.io
from scipy.io import savemat
import numpy as np
import scipy.optimize
import matplotlib.pyplot as plt

dataload_path = 'F:/RESEARCH/Hamid/MultiScale/'
subjs=np.array(list(range(1, 17))) #problematic: 2, 4,5
# subjs=np.array(list(range(1, 2)))

for subj in subjs:
    # tmp = scipy.io.loadmat(dataload_path+'AutoCorr_Summrzd_long_SOA_subj_all_channels_'+f"{subj:02}"+'.mat')
    tmp = scipy.io.loadmat(dataload_path+'AutoCorr_Summrzd_unbiased_long_SOA_subj_all_channels_'+f"{subj:02}"+'.mat')
    data=tmp.get("auto_corr_summrzd")
    
    cond=np.array(list(range(0, data.shape[0])))
    sub_cond=np.array(list(range(0, data.shape[1])))
    ch=np.array(list(range(0, data.shape[2])))
    xs=np.array(list(range(1, data.shape[4]+1)))
    p0 = (300, .1, 50) # m, t, b start with values near those we expect
    # p0 = (.2) # start with values near those we expect

    
    def monoExp(x, m, t, b):
        return m * np.exp(-t * x) + b
    # def monoExp(x, t):
    #     return np.exp(-t * x)
    
    taus=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2]))
    rSquared_all=np.zeros(shape= (data.shape[0],data.shape[1],data.shape[2]))
    for i in cond:
        for j in sub_cond:
            for k in ch:
                tmp_data=data[i,j,k,:,:]
                ys=tmp_data.mean(0)
                
                
                # perform the fit
                try:
                    params, cv = scipy.optimize.curve_fit(monoExp, xs, ys, p0)
                    m, t, b = params
                except:
                    t=float("nan")
                # t = params

                sampleRate = 500 # Hz
                tauSec = (1 / t) / sampleRate            
                taus[i-1,j-1,k-1]=tauSec
                print(tauSec)

                # determine quality of the fit
                squaredDiffs = np.square(ys - monoExp(xs, m, t, b))
                # squaredDiffs = np.square(ys - monoExp(xs, t))

                squaredDiffsFromMean = np.square(ys - np.mean(ys))
                rSquared = 1 - np.sum(squaredDiffs) / np.sum(squaredDiffsFromMean)
                rSquared_all[i-1,j-1,k-1]=rSquared
    print(subj)
    mdic={"taus": taus,"rSquared_all": rSquared_all}
    savemat(dataload_path+'AutoCorr_Parameters_Subj_'+f"{subj:02}"+'.mat', mdic)
            
            