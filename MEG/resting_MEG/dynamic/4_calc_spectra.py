"""Calculate spectra

"""


import numpy as np
import pickle
import os

from osl_dynamics.data import Data
from osl_dynamics.analysis import spectral



data = Data('npy',n_jobs=8)

data = data.trim_time_series(sequence_length=200, n_embeddings=15)

alp = pickle.load(open('results/6_modes/run23/inf_params/alp.pkl','rb'))

f, psd = spectral.regression_spectra(data=data, alpha=alp, sampling_frequency=250, return_coef_int=True, 
                                     window_length=500, step_size=250, frequency_range=[1,80], n_jobs=8, calc_coh=False)

np.save('/home/mtrubshaw/Documents/ALS_dyn/dynamic/dynemo_runs_new/results/6_modes/run23/spectra/f.npy',f)
np.save('/home/mtrubshaw/Documents/ALS_dyn/dynamic/dynemo_runs_new/results/6_modes/run23/spectra/psd.npy',psd)
