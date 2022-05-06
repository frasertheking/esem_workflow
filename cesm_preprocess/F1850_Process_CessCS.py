#!/usr/bin/env python

import numpy as np
import glob
from natsort import natsorted
import math
import pandas as pd
import netCDF4 as nc
import sys
import scipy.stats as stats
import collections as c

res = sys.argv[1]

if res == 'f45':
    Source_dir = '/scratch/c/cgf/jgvirgin/cesm1_0_4/runs/'
    Case_name = 'f.e10.F1850.f45_f45.Child.'
    ref_SST_path = '/scratch/c/cgf/jgvirgin/cesm1_0_4/inputdata/ocn/docn7/SSTDATA/sst_HadOIBl_bc_4x5_clim_pi_c101028.nc'
    per_SST_path = '/scratch/c/cgf/jgvirgin/cesm1_0_4/inputdata/ocn/docn7/SSTDATA/sst+2K_HadOIBl_bc_4x5_clim_pi_c101028.nc'
    start_ind = 1
elif res == 'f19':
    Source_dir = '/praid/users/jgvirgin/PPE/runs/f19/'
    Case_name = 'F1850_UQ2019-05-27-13-22_SO4x3_'
    start_ind = 0
elif res == 'f09':
    Source_dir = '/scratch/c/cgf/jgvirgin/cesm1_0_4/runs/'
    Case_name = 'f.e10.F1850.f09_f09.Child.'
    ref_SST_path = '/scratch/c/cgf/jgvirgin/cesm1_0_4/inputdata/ocn/docn7/SSTDATA/sst_HadOIBl_bc_0.9x1.25_clim_pi_c101028.nc'
    per_SST_path = '/scratch/c/cgf/jgvirgin/cesm1_0_4/inputdata/ocn/docn7/SSTDATA/sst+2K_HadOIBl_bc_0.9x1.25_clim_pi_c101028.nc'
    start_ind = 1
else:
    print('case resolution incompatible')
    raise ValueError

index_no = np.arange(1, 101)
#convert integers to strings for reading in
index_str = [str(inter) for inter in index_no]

print('calculate delta SST...')

ref_SST = np.mean(np.squeeze(nc.Dataset(ref_SST_path).variables['SST_cpl']),axis=0)
per_SST = np.mean(np.squeeze(nc.Dataset(per_SST_path).variables['SST_cpl']),axis=0)

lat = np.squeeze(nc.Dataset(ref_SST_path).variables['lat'])
print('latitude length - ', lat.shape)
lon = np.squeeze(nc.Dataset(ref_SST_path).variables['lon'])
print('longitude length - ', lon.shape)

y = lat*np.pi/180
coslat = np.cos(y)
coslat = np.tile(coslat, (lon.size, 1)).T

dSST = np.average((per_SST-ref_SST),weights=coslat)
print('dSST value = ',dSST)

ref_FSNT = c.OrderedDict()
ref_FLNT = c.OrderedDict()
ref_FNET = c.OrderedDict()

k2_FSNT = c.OrderedDict()
k2_FLNT = c.OrderedDict()
k2_FNET = c.OrderedDict()

dFNET = c.OrderedDict()

Cess = c.OrderedDict()

for i in range(len(index_str)):

    print('on case number ',index_str[i])
    
    path_ref = natsorted(glob.glob(Source_dir+Case_name+'sstref.JGV.'+index_str[i]+'/archive/atm/hist/'+Case_name+'sstref.JGV.'+index_str[i]+'.cam2.h0*'))[start_ind:]
    path_2k = natsorted(glob.glob(Source_dir+Case_name+'sst2k.JGV.'+index_str[i]+'/archive/atm/hist/'+Case_name+'sst2k.JGV.'+index_str[i]+'.cam2.h0*'))[start_ind:]

    nc_data_ref = nc.MFDataset(path_ref)
    nc_data_2k = nc.MFDataset(path_2k)

    ref_FSNT[index_str[i]] = np.mean(nc_data_ref.variables['FSNT'][:], axis=0)
    ref_FLNT[index_str[i]] = np.mean(nc_data_ref.variables['FLNT'][:], axis=0)
    ref_FNET[index_str[i]] = ref_FSNT[index_str[i]]-ref_FLNT[index_str[i]]
    ref_FNET[index_str[i]] = np.average(ref_FNET[index_str[i]],weights=coslat)

    k2_FSNT[index_str[i]] = np.mean(nc_data_2k.variables['FSNT'][:], axis=0)
    k2_FLNT[index_str[i]] = np.mean(nc_data_2k.variables['FLNT'][:], axis=0)
    k2_FNET[index_str[i]] = k2_FSNT[index_str[i]]-k2_FLNT[index_str[i]]
    k2_FNET[index_str[i]] = np.average(k2_FNET[index_str[i]], weights=coslat)

    dFNET[index_str[i]] = k2_FNET[index_str[i]]-ref_FNET[index_str[i]]
    Cess[index_str[i]] = -dSST/dFNET[index_str[i]]
    
    print('dFNET value = ', dFNET[index_str[i]], '\n')
    print('Cess CS value = ', Cess[index_str[i]],'\n')

    print('next case... \n')
print('done')


#turn the nested dictionary in a dataframe
df_Cess = pd.Series(Cess)
df_FNET = pd.Series(dFNET)

df_Cess = df_Cess.round(3)
df_FNET = df_FNET.round(3)

print(df_Cess)

#save it!
print('Saving output')
df_Cess.to_csv(res+'_Cess.csv', index=False)
df_FNET.to_csv(res+'_dFNET.csv', index=False)
print('Done!')
