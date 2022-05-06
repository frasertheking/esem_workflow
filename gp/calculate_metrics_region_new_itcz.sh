#!/bin/bash

CAM_PATH=/mnt/data/models/NCAR-CESM/cesm1_0_4/PPE/f19
ERA_PATH=/mnt/data/obs/Reanalysis/ERA-5/Yearly/

declare -a VARS_CAM=("CLDLOW" "PRECT" "TREFHT" "PSL" "SWCF" "LWCF" "FNET")
declare -a VARS_ERA=("lcc" "mtpr" "t2m" "msl" "tsr" "ttrc" "tsr")
declare -a VARS_ERA_FILE=("lcc_annual_climo.nc" "mtpr_annual_climo_daily.nc" "t2m_annual_climo.nc" "msl_annual_climo.nc" "swcf_annual_climo.nc" "lwcf_annual_climo.nc" "fnet_annual_climo.nc")


# Loop through CAM data
for run_path in ${CAM_PATH}/*_annual_clim; do
  run_name=$(basename $run_path)
  mkdir -p /mnt/data/users/sraj/regional_observations/${run_name}_tropics_metrics
  mkdir -p /mnt/data/users/sraj/regional_observations/${run_name}_northern_extratropics_metrics
  mkdir -p /mnt/data/users/sraj/regional_observations/${run_name}_arctic_metrics
  mkdir -p /mnt/data/users/sraj/regional_observations/${run_name}_tempv
  TOBS_PATH=/mnt/data/users/sraj/regional_observations/${run_name}_tropics_metrics
  NEOBS_PATH=/mnt/data/users/sraj/regional_observations/${run_name}_northern_extratropics_metrics
  AOBS_PATH=/mnt/data/users/sraj/regional_observations/${run_name}_arctic_metrics
  TEMP_PATH=/mnt/data/users/sraj/regional_observations/${run_name}_tempv
  for file in ${run_path}/*; do
    if [ ${file: -7} = "clim.nc" ]; then
     year=${file: -19:-15}
	   echo ""
	   echo ""
	   echo "Working on year ${year}..."
	   echo ""
	   echo ""
	   for i in $(seq 0 3); do 
				# Correlations
				cdo -b F64 -selvar,${VARS_CAM[i]} ${file} ${TEMP_PATH}/temp_var_${i}.nc 

				# Fix units for this case
				if [ ${VARS_CAM[i]} = "PRECT" ]; then
					cdo -b F64 mulc,86400000 ${TEMP_PATH}/temp_var_${i}.nc ${TEMP_PATH}/prect_temp_var_${i}.nc 
					cdo -b F64 remapbil,${ERA_PATH}${VARS_ERA_FILE[i]} ${TEMP_PATH}/prect_temp_var_${i}.nc ${TEMP_PATH}/remapped_temp_var_${i}.nc 
					
				else
					cdo -b F64 remapbil,${ERA_PATH}${VARS_ERA_FILE[i]} ${TEMP_PATH}/temp_var_${i}.nc ${TEMP_PATH}/remapped_temp_var_${i}.nc 
				fi	
				
				cdo -b F64 -fldcor -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[i]} -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_${i}.nc ${TOBS_PATH}/corr_${VARS_CAM[i]}_${year}.nc 
				cdo -b F64 -sub -fldmean -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_${i}.nc -fldmean -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[i]} ${TOBS_PATH}/mean_diff_${VARS_CAM[i]}_${year}.nc 
				cdo -b F64 -div -fldstd -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_${i}.nc -fldstd -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[i]} ${TOBS_PATH}/std_ratio_${VARS_CAM[i]}_${year}.nc 

        cdo -b F64 -fldcor -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[i]} -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_${i}.nc ${NEOBS_PATH}/corr_${VARS_CAM[i]}_${year}.nc 
        cdo -b F64 -sub -fldmean -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_${i}.nc -fldmean -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[i]} ${NEOBS_PATH}/mean_diff_${VARS_CAM[i]}_${year}.nc 
        cdo -b F64 -div -fldstd -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_${i}.nc -fldstd -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[i]} ${NEOBS_PATH}/std_ratio_${VARS_CAM[i]}_${year}.nc 
        
        cdo -b F64 -fldcor -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[i]} -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_${i}.nc ${AOBS_PATH}/corr_${VARS_CAM[i]}_${year}.nc 
        cdo -b F64 -sub -fldmean -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_${i}.nc -fldmean -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[i]} ${AOBS_PATH}/mean_diff_${VARS_CAM[i]}_${year}.nc 
        cdo -b F64 -div -fldstd -selvar,${VARS_CAM[i]} -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_${i}.nc -fldstd -selvar,${VARS_ERA[i]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[i]} ${AOBS_PATH}/std_ratio_${VARS_CAM[i]}_${year}.nc 
	   done	
   elif [ ${file: -7} = "SWCF.nc" ]; then
    year=${file: -27:-23}
    pos=4
    echo ""
	  echo ""
	  echo "Working on year ${year}..."
	  echo ""
	  echo ""
	  cdo remapbil,${ERA_PATH}${VARS_ERA_FILE[pos]} -selyear,${year} ${file} ${TEMP_PATH}/remapped_temp_var_swcf.nc 
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FSNT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_swcf.nc ${TOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FSNT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_swcf.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${TOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FSNT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_swcf.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${TOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc
                        
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FSNT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_swcf.nc ${NEOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FSNT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_swcf.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${NEOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FSNT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_swcf.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${NEOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc
                        
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FSNT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_swcf.nc ${AOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FSNT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_swcf.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${AOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FSNT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_swcf.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${AOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc
   elif [ ${file: -7} = "LWCF.nc" ];	then
    year=${file: -27:-23}
    pos=5
    echo ""
	  echo ""
	  echo "Working on year ${year}..."
	  echo ""
	  echo ""
	  cdo remapbil,${ERA_PATH}${VARS_ERA_FILE[pos]} -selyear,${year} ${file} ${TEMP_PATH}/remapped_temp_var_lwcf.nc 
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FLUT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_lwcf.nc ${TOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FLUT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_lwcf.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${TOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FLUT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_lwcf.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${TOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc 
                        
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FLUT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_lwcf.nc ${NEOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FLUT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_lwcf.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${NEOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FLUT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_lwcf.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${NEOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc
                        
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FLUT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_lwcf.nc ${AOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FLUT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_lwcf.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${AOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FLUT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_lwcf.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${AOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc 
                        
   elif [ ${file: -7} = "FNET.nc" ];	then
    year=${file: -27:-23}
    pos=6
    echo ""
	  echo ""
	  echo "Working on year ${year}..."
	  echo ""
	  echo ""
	  cdo remapbil,${ERA_PATH}${VARS_ERA_FILE[pos]} -selyear,${year} ${file} ${TEMP_PATH}/remapped_temp_var_fnet.nc 
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FSNT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_fnet.nc ${TOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FSNT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_fnet.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${TOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FSNT" -sellonlatbox,-180,180,-30,30 ${TEMP_PATH}/remapped_temp_var_fnet.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,-30,30 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${TOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc 
                        
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FSNT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_fnet.nc ${NEOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FSNT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_fnet.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${NEOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FSNT" -sellonlatbox,-180,180,30,60 ${TEMP_PATH}/remapped_temp_var_fnet.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,30,60 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${NEOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc 
                        
                        cdo -b F64 -fldcor -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} -selvar,"FSNT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_fnet.nc ${AOBS_PATH}/corr_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -sub -fldmean -selvar,"FSNT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_fnet.nc -fldmean -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${AOBS_PATH}/mean_diff_${VARS_CAM[pos]}_${year}.nc 
                        cdo -b F64 -div -fldstd -selvar,"FSNT" -sellonlatbox,-180,180,60,90 ${TEMP_PATH}/remapped_temp_var_fnet.nc -fldstd -selvar,${VARS_ERA[pos]} -selyear,${year} -sellonlatbox,-180,180,60,90 ${ERA_PATH}${VARS_ERA_FILE[pos]} ${AOBS_PATH}/std_ratio_${VARS_CAM[pos]}_${year}.nc 
   fi
  done
done
				
echo "DONE"
