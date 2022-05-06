#!/bin/bash


declare -a ENSM=("ens02" "ens03" "ens04" "ens05" "ens06" "ens07" "ens08" "ens09" "ens10")
declare -a VARS_CAM=("CLDLOW" "PRECT" "TREFHT" "PSL" "SWCF" "LWCF" "FNET")

for j in $(seq 0 8); do
  CLM_PATH=/mnt/data/users/sraj/metrics_final_cam5_${ENSM[j]}
  for run_path in ${CLM_PATH}/*_final; do
    run_name=$(basename $run_path)
    mkdir -p ${CLM_PATH}/${run_name}_txt
    MTRO_PATH=${CLM_PATH}/${run_name}_txt
    for i in $(seq 0 6); do
      file1=$(ls ${run_path}/*std_ratio_mean_${VARS_CAM[i]}*)
      file2=$(ls ${run_path}/*std_ratio_std_${VARS_CAM[i]}*)
      file3=$(ls ${run_path}/*mean_diff_mean_${VARS_CAM[i]}*)
      file4=$(ls ${run_path}/*mean_diff_std_${VARS_CAM[i]}*)
      file5=$(ls ${run_path}/*corr_mean_${VARS_CAM[i]}*)
      file6=$(ls ${run_path}/*corr_std_${VARS_CAM[i]}*)
      run_name1=$(basename ${file1})
      run_name2=$(basename ${file2})
      run_name3=$(basename ${file3})
      run_name4=$(basename ${file4})
      run_name5=$(basename ${file5})
      run_name6=$(basename ${file6})
      cdo output ${file1} > ${MTRO_PATH}/${run_name1}.txt
      cdo output ${file2} > ${MTRO_PATH}/${run_name2}.txt
      cdo output ${file3} > ${MTRO_PATH}/${run_name3}.txt
      cdo output ${file4} > ${MTRO_PATH}/${run_name4}.txt
      cdo output ${file5} > ${MTRO_PATH}/${run_name5}.txt
      cdo output ${file6} > ${MTRO_PATH}/${run_name6}.txt
    done
  done
done    