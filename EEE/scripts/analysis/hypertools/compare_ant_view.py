import hypertools as hyp
import numpy as np
import scipy
import pandas as pd
from scipy.linalg import toeplitz
from copy import copy
import os
import glob

datapath = "C:\\Users\\bgrau\\Dropbox (Dartmouth College)\\2023_Graul_EEE\\Analyses\\ieeg\\sub_01\\ant_view\\RTA_pos_ant.csv"

data = np.loadtxt(datapath, delimiter=',')
df = pd.DataFrame(data)

print(df.head())

geo = hyp.plot(df)