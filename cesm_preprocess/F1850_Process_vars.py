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


def m(x, w):
    """Weighted Mean"""
    return np.sum(x * w) / np.sum(w)


def cov(x, y, w):
    """Weighted Covariance"""
    return np.sum(w * (x - m(x, w)) * (y - m(y, w))) / np.sum(w)


def corr(x, y, w):
    """Weighted Correlation"""
    return cov(x, y, w) / np.sqrt(cov(x, x, w) * cov(y, y, w))

def run_preprocessing(res, sst, example_data):
    if res == 'f45':
        Source_dir = '/scratch/c/cgf/jgvirgin/cesm1_0_4/runs/'
        Case_name = 'f.e10.F1850.f45_f45.Child.'+sst+'.JGV.'
        Parent_case = 'f.e10.F1850.f45_f45.Parent.JGV.2'
        Parent_ind = 84
        start_ind = 1
    elif res == 'f19':
        Source_dir = example_data + '/f19/'
        Case_name = 'F1850_UQ2019-05-27-13-22_SO4x3_'+sst+'.'
        Parent_case = 'F1850_UQ2019-05-27-13-22_SO4x3_'+sst+'.101'
        Parent_ind = 0
        start_ind = 0
    elif res == 'f09':
        Source_dir = '/scratch/c/cgf/jgvirgin/cesm1_0_4/runs/'
        Case_name = 'f.e10.F1850.f09_f09.PPE_Child_PiCon.'+sst+'.JGV.'
        Parent_case = 'f.e10.F1850.f09_f09.Parent.JGV.2'
        Parent_ind = 84
        start_ind = 1
    else:
        print('case resolution incompatible')
        raise ValueError

    Parent_dir = Source_dir+Parent_case+'/archive/atm/hist/'
    print('Parent directory - ', Parent_dir)
    index_no = np.arange(1, 101)
    #convert integers to strings for reading in
    index_str = [str(inter) for inter in index_no]

    #variables of interest
    var = ['AEROD_v', 'SHFLX', 'LHFLX', 'CLDLOW', 'FLNT',
           'FSNT', 'LWCF', 'SWCF', 'PRECL', 'PRECC', 'QRL']

    print('Calculating Parent case metrics first')

    Parent_data = c.OrderedDict()
    Parent_mn = c.OrderedDict()
    Parent_std = c.OrderedDict()
    Parent_var = c.OrderedDict()

    print(Parent_dir)
    print(Source_dir)

    parent_files = natsorted(glob.glob(Parent_dir+Parent_case+'.cam2.h0*'))[:]
    print('number of files in parent case -', len(parent_files))
    #print('list files - \n', parent_files)
    Parent_nc = nc.MFDataset(parent_files)

    lat = np.squeeze(Parent_nc.variables['lat'])
    print('latitude length - ',lat.shape)
    lon = np.squeeze(Parent_nc.variables['lon'])
    print('longitude length - ',lon.shape)

    y = lat*np.pi/180
    coslat = np.cos(y)
    coslat = np.tile(coslat, (lon.size, 1)).T

    for v in range(len(var)):
        Parent_data[var[v]] = np.mean(Parent_nc.variables[var[v]][Parent_ind:], axis=0)

    Parent_data['FNET'] = Parent_data['FSNT']-Parent_data['FLNT']
    Parent_data['PRECT'] = (Parent_data['PRECC']+Parent_data['PRECL'])*86400.*1000
    Parent_data['CLDL'] = Parent_data['CLDLOW']*100
    Parent_data['QRL'] = np.mean(Parent_data['QRL']*86400, axis=0)

    Parent_data.pop('PRECC')
    Parent_data.pop('PRECL')
    Parent_data.pop('CLDLOW')

    for keys in Parent_data.keys():
        Parent_mn[keys] = np.average(Parent_data[keys], weights=coslat)
        Parent_var[keys] = np.average(
            (Parent_data[keys]-Parent_mn[keys])**2, weights=coslat)

        if keys == 'FNET':
            Parent_std[keys] = math.sqrt(Parent_var['FLNT']+Parent_var['FSNT'])
        else:
            Parent_std[keys] = math.sqrt(np.average(
                (Parent_data[keys]-Parent_mn[keys])**2, weights=coslat))


    print('default model processing finished \n moving onto PPE processing... ')

    Data = c.OrderedDict()
    Data_mn = c.OrderedDict()
    Data_diff = c.OrderedDict()
    Data_std = c.OrderedDict()
    Data_var = c.OrderedDict()
    Data_r = c.OrderedDict()

    SS = c.OrderedDict()
    for i in range(len(index_str)):

        print('on case number ', index_str[i])

        path = natsorted(glob.glob(Source_dir+Case_name +
                                   index_str[i]+'/archive/atm/hist/'+Case_name+index_str[i]+'.cam2.h0*'))[start_ind:]
        #print('list files - \n', path)
        print('number of files in child case -', len(path))
        nc_data = nc.MFDataset(path)

        #dictionary layer two, interior keys will be variables of interest
        Data[index_str[i]] = c.OrderedDict()
        Data_mn[index_str[i]] = c.OrderedDict()
        Data_diff[index_str[i]] = c.OrderedDict()
        Data_std[index_str[i]] = c.OrderedDict()
        Data_var[index_str[i]] = c.OrderedDict()
        Data_r[index_str[i]] = c.OrderedDict()
        SS[index_str[i]] = c.OrderedDict()

        print('read in data... \n')
        for v in range(len(var)):
            #im skipping the first month here because the sims ran for 3 years and one month
            Data[index_str[i]][var[v]] = np.mean(nc_data.variables[var[v]][:], axis=0)

        Data[index_str[i]]['FNET'] = Data[index_str[i]]['FSNT']-Data[index_str[i]]['FLNT']
        Data[index_str[i]]['PRECT'] = (Data[index_str[i]]['PRECC']+Data[index_str[i]]['PRECL'])*86400*1000
        Data[index_str[i]]['CLDL'] = Data[index_str[i]]['CLDLOW']*100
        Data[index_str[i]]['QRL'] = np.mean(Data[index_str[i]]['QRL']*86400, axis=0)

        Data[index_str[i]].pop('PRECC')
        Data[index_str[i]].pop('PRECL')
        Data[index_str[i]].pop('CLDLOW')

        print('Calculate spatial means/standard devs, and Skill score. \n')
        for keys in Data[index_str[i]].keys():

            Data_mn[index_str[i]][keys] = np.average(
                Data[index_str[i]][keys], weights=coslat)
            Data_var[index_str[i]][keys] = np.average(
                (Data[index_str[i]][keys]-Data_mn[index_str[i]][keys])**2, weights=coslat)

            Data_diff[index_str[i]][keys] = Data_mn[index_str[i]][keys] - Parent_mn[keys]

            if keys == 'FNET':
                Data_std[index_str[i]][keys] = math.sqrt(
                    Data_var[index_str[i]]['FLNT']+Data_var[index_str[i]]['FSNT'])
            else:
                Data_std[index_str[i]][keys] = math.sqrt(np.average(
                    (Data[index_str[i]][keys]-Data_mn[index_str[i]][keys])**2, weights=coslat))

            Data_r[index_str[i]][keys] = corr(
                Data[index_str[i]][keys], Parent_data[keys], coslat)

            SS[index_str[i]][keys] = Data_r[index_str[i]][keys]**2 -\
                ((Data_r[index_str[i]][keys]-(Data_std[index_str[i]][keys]/Parent_std[keys]))**2) -\
                (((Data_mn[index_str[i]][keys] -
                   Parent_mn[keys])/Parent_mn[keys])**2)

        SS[index_str[i]].pop('SHFLX')
        SS[index_str[i]].pop('LHFLX')
        #SS[index_str[i]].pop('FLNT')
        #SS[index_str[i]].pop('FSNT')
        SS[index_str[i]].pop('FNET')
        SS[index_str[i]].pop('AEROD_v')
        SS[index_str[i]]['Mean'] = np.mean(list(SS[index_str[i]].values()))

        print('next case... \n')
    print('done')


    #turn the nested dictionary in a dataframe
    df_SS = pd.DataFrame(SS).T.reset_index().drop(columns=['index'])
    df_GAM = pd.DataFrame(Data_mn).T.reset_index().drop(columns=['index'])
    df_diff = pd.DataFrame(Data_diff).T.reset_index().drop(columns=['index'])
    df_GAS = pd.DataFrame(Data_std).T.reset_index().drop(columns=['index'])
    df_r = pd.DataFrame(Data_r).T.reset_index().drop(columns=['index'])

    print(df_GAM)

    df_SS = df_SS.round(3)
    df_GAM = df_GAM.round(3)
    df_diff = df_diff.round(3)
    df_GAS = df_GAS.round(3)
    df_r = df_r.round(3)

    #save it!
    print('Saving output')
    df_SS.to_csv('output/'+res+'_'+sst+'_skills.csv', index=False)
    df_GAM.to_csv('output/'+res+'_'+sst+'_glob_ann_mn.csv', index=False)
    df_diff.to_csv('output/'+res+'_'+sst+'_glob_ann_diff.csv', index=False)
    df_GAS.to_csv('output/'+res+'_'+sst+'_glob_ann_std.csv', index=False)
    df_r.to_csv('output/'+res+'_'+sst+'_ann_cor.csv', index=False)
    print('Done!')
