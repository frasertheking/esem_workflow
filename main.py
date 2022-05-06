#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""main.py
   This main runfile facilitates multiple sets of scripts used in the enumation of Earth system model 
   (ESM) output using neural networks (NN) and gaussian process (GP) regression. An example using CESM 
   output run at f19 resolution with pre-industrial cam/clm and prescribed ice/ocn inputs is provided. 

    INPUTS: A set of N runs of M output fields from an ESM and a corresponding set of N perturbed
            parameter values used for each run. 

   This can, however, be run on your own CESM model output by changing the paths. The program is split 
   into three primary components which can be configured based on the problem context:

   1) Preprocessing of ESM output into a format compatiable with the emulators
   		- Based on code written by John Virgin
   2) Integration with Duncan's ESEM which provides both NN and GP models
   		- https://gmd.copernicus.org/articles/14/7659/2021/gmd-14-7659-2021.html
   3) Linking to Christopher G. Fletcher's adapted R code for GP emulation
   		- https://acp.copernicus.org/articles/18/17529/2018/

    Example data is currently hosted on the University of Waterloo's Manabe server. For access to this
    data, please reach out to Chris Fletcher (chris.fletcher@uwaterloo.ca). It is recommended to just
    run CESM on your own however to generate your own test output if you do not have access.
	
    For more information about this workflow, please reach out to Fraser King (fdmking@uwaterloo.ca).
"""

##### Library imports
import sys,os
sys.path.append('cesm_preprocess')
import numpy as np
import pandas as pd
import F1850_Process_vars as pre
import cnn_tests as cnn
import netCDF4 as nc
from sklearn.model_selection import train_test_split

##### Globals
SEED = 42
SST = 'sst2k'
RES = 'f19'
EXAMPLE_DATA = '/mnt/data/users/fdmking/esem_test_data'
PARAMS = '/mnt/data/users/fdmking/esem_test_data/Params_100case_9vals.csv'
CASE_NAME = 'F1850_UQ2019-05-27-13-22_SO4x3_sst2k.'


##### Preprocess CESM (used in gp code afterwards)
pre.run_preprocessinig(RES, SST, EXAMPLE_DATA)
print("Data preprocessing complete")


##### Load PARAM values
param_df = pd.read_csv(PARAMS)
total_cases = len(param_df)
print("Total cases", total_cases)


##### Create input file combining perturbed parameter values and CESM output fields
data = []
for index, row in param_df.iterrows():
    print("On row", index)
    ds = nc.Dataset(EXAMPLE_DATA + '/f19/' + CASE_NAME + str(index+1) + '/archive/atm/hist/mean.nc')
    data.append([row['x1'], row['x2'], row['x3'], row['x4'], row['x5'], row['x6'], row['x7'], row['x8'], row['x9'], ds['AEROD_v'][0][:], ds['CLDLOW'][0][:], (ds['FSNT'][0][:]-ds['FLNT'][0][:]), ds['LWCF'][0][:], ds['PRECT'][0][:], ds['QRL'][0][0][:], ds['SWCF'][0][:]]) 


##### Save data to final input dataframe for ESEM
final_df = pd.DataFrame(data=data, columns=['x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8', 'x9', 'AOD', 'CLDL', 'FNET', 'LWCF', 'PRECT', 'QRL', 'SWCF'])
final_df.to_csv('output/model_inputs.csv')
X = final_df[['x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8', 'x9']]
y = final_df[['AOD', 'CLDL', 'FNET', 'LWCF', 'PRECT', 'QRL', 'SWCF']]


##### Split data for models
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=SEED)
cnn.run_cnn(X_train, X_test, y_train, y_test)

print("ESEM test complete.")


