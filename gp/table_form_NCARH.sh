#!/bin/bash

declare -a ENSM=("ens02" "ens03" "ens04" "ens05" "ens06" "ens07" "ens08" "ens09" "ens10")

for j in $(seq 0 8); do
  CLM_PATH=/mnt/data/users/sraj/metrics_final_cam5_${ENSM[j]}
  MC_PATH=/mnt/data/users/sraj/metrics_regional_csv_final/cam5_${ENSM[j]}
  for run_path in ${CLM_PATH}/*_txt; do
    if [ ${run_path: -16:-10} = "arctic" ]; then
     file_list1=$(ls ${run_path}/*std_ratio_mean*)
     file_list2=$(ls ${run_path}/*std_ratio_std*)
     file_list3=$(ls ${run_path}/*mean_diff_mean*)
     file_list4=$(ls ${run_path}/*mean_diff_std*)
     file_list5=$(ls ${run_path}/*corr_mean*)
     file_list6=$(ls ${run_path}/*corr_std*)
     paste -d ',' ${file_list1} ${file_list2} > ${MC_PATH}/arctic/std_ratio.csv
     paste -d ',' ${file_list3} ${file_list4} > ${MC_PATH}/arctic/mean_diff.csv
     paste -d ',' ${file_list5} ${file_list6} > ${MC_PATH}/arctic/corr.csv
    elif [ ${run_path: -22:-10} = "extratropics" ]; then
     file_list1=$(ls ${run_path}/*std_ratio_mean*)
     file_list2=$(ls ${run_path}/*std_ratio_std*)
     file_list3=$(ls ${run_path}/*mean_diff_mean*)
     file_list4=$(ls ${run_path}/*mean_diff_std*)
     file_list5=$(ls ${run_path}/*corr_mean*)
     file_list6=$(ls ${run_path}/*corr_std*)
     paste -d ',' ${file_list1} ${file_list2} > ${MC_PATH}/extratropics/std_ratio.csv
     paste -d ',' ${file_list3} ${file_list4} > ${MC_PATH}/extratropics/mean_diff.csv
     paste -d ',' ${file_list5} ${file_list6} > ${MC_PATH}/extratropics/corr.csv
    elif [ ${run_path: -17:-10} = "tropics" ]; then
     file_list1=$(ls ${run_path}/*std_ratio_mean*)
     file_list2=$(ls ${run_path}/*std_ratio_std*)
     file_list3=$(ls ${run_path}/*mean_diff_mean*)
     file_list4=$(ls ${run_path}/*mean_diff_std*)
     file_list5=$(ls ${run_path}/*corr_mean*)
     file_list6=$(ls ${run_path}/*corr_std*)
     paste -d ',' ${file_list1} ${file_list2} > ${MC_PATH}/tropics/std_ratio.csv
     paste -d ',' ${file_list3} ${file_list4} > ${MC_PATH}/tropics/mean_diff.csv
     paste -d ',' ${file_list5} ${file_list6} > ${MC_PATH}/tropics/corr.csv
   fi
  done
done


  

  