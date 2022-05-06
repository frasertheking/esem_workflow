
ENSM<- c("cmip6","waccm","cam5",cam5_ens02","cam5_ens03","cam5_ens04","cam5_ens05","cam5_ens06","cam5_ens07","cam5_ens08","cam5_ens09","cam5_ens10")
setwd("/mnt/data/users/sraj/metrics_regional_csv_final/")
REG<- c("arctic","extratropics","tropics")
for (i in 1:3){ 
std_ratio<- read.csv(paste(REG[i],"/","std_ratio.csv",sep= ""),header=FALSE)
mean_diff<- read.csv(paste(REG[i],"/","mean_diff.csv",sep= ""),header=FALSE)
corr<-  read.csv(paste(REG[i],"/","corr.csv",sep= ""),header=FALSE)

colnames_metrics_std_ratio<- c("CLDLOW_std_ratio_mean","FNET_std_ratio_mean",
                     "LWCF_std_ratio_mean","PRECT_std_ratio_mean",
                     "PSL_std_ratio_mean","SWCF_std_ratio_mean",
                     "TREFHT_std_ratio_mean","CLDLOW_std_ratio_std",
                     "FNET_std_ratio_std","LWCF_std_ratio_std",
                     "PRECT_std_ratio_std","PSL_std_ratio_std",
                     "SWCF_std_ratio_std","TREFHT_std_ratio_std")
colnames_metrics_mean_diff<- c("CLDLOW_mean_diff_mean","FNET_mean_diff_mean",
                               "LWCF_mean_diff_mean","PRECT_mean_diff_mean",
                               "PSL_mean_diff_mean","SWCF_mean_diff_mean",
                               "TREFHT_mean_diff_mean","CLDLOW_mean_diff_std",
                               "FNET_mean_diff_std","LWCF_mean_diff_std",
                               "PRECT_mean_diff_std","PSL_mean_diff_std",
                               "SWCF_mean_diff_std","TREFHT_mean_diff_std")
colnames_metrics_corr<- c("CLDLOW_corr_mean","FNET_corr_mean",
                          "LWCF_corr_mean","PRECT_corr_mean",
                          "PSL_corr_mean","SWCF_corr_mean",
                          "TREFHT_corr_mean","CLDLOW_corr_std",
                          "FNET_corr_std","LWCF_corr_std",
                          "PRECT_corr_std","PSL_corr_std",
                          "SWCF_corr_std","TREFHT_corr_std")

colnames(std_ratio)<- colnames_metrics_std_ratio
colnames(mean_diff)<- colnames_metrics_mean_diff
colnames(corr)<- colnames_metrics_corr

write.csv(corr,paste(REG[i],"/","corr_header.csv",sep= ""),row.names=FALSE)
write.csv(mean_diff,paste(REG[i],"/","mean_diff_header.csv",sep= ""),row.names=FALSE)
write.csv(std_ratio,paste(REG[i],"/","std_ratio_header.csv",sep= ""),row.names=FALSE)
}
  
