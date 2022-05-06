#!/bin/bash


declare -a ENSM=("ens02" "ens03" "ens04" "ens05" "ens06" "ens07" "ens08" "ens09" "ens10")
declare -a VARS_CAM=("CLDLOW" "PRECT" "TREFHT" "PSL" "SWCF" "LWCF" "FNET")

for j in $(seq 0 8); do
  CLM_PATH=/mnt/data/users/sraj/metrics_final_cam5_${ENSM[j]}
  for run_path in ${CLM_PATH}/*; do
    run_name=$(basename $run_path)
    mkdir -p ${CLM_PATH}/${run_name}_final
    MRO_PATH=${CLM_PATH}/${run_name}_final
    for i in $(seq 0 6); do
      file_list1=$(ls ${run_path}/*std_ratio_${VARS_CAM[i]}*)
      file_list2=$(ls ${run_path}/*mean_diff_${VARS_CAM[i]}*)
      file_list3=$(ls ${run_path}/*corr_${VARS_CAM[i]}*)
      cdo ensmean ${file_list1} ${MRO_PATH}/std_ratio_mean_${VARS_CAM[i]}_annual_clim.nc
      cdo ensstd ${file_list1} ${MRO_PATH}/std_ratio_std_${VARS_CAM[i]}_annual_clim_std.nc
      cdo ensmean ${file_list2} ${MRO_PATH}/mean_diff_mean_${VARS_CAM[i]}_annual_clim.nc
      cdo ensstd ${file_list2} ${MRO_PATH}/mean_diff_std_${VARS_CAM[i]}_annual_clim_std.nc
      cdo ensmean ${file_list3} ${MRO_PATH}/corr_mean_${VARS_CAM[i]}_annual_clim.nc
      cdo ensstd ${file_list3} ${MRO_PATH}/corr_std_${VARS_CAM[i]}_annual_clim_std.nc
    done
  done
done  