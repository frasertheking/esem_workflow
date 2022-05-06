# This script calculates the Pierce et al. (2009) skill score for the n=50 training cases with respect to observation.



#setwd("/mnt/data/users/sraj/metrics_regional_csv_final/")
#setwd("/home/sraj/metrics_csv_final/")

ENSM<- c("cmip6","waccm","cam5","cam5_ens02","cam5_ens03","cam5_ens04","cam5_ens05","cam5_ens06","cam5_ens07","cam5_ens08","cam5_ens09","cam5_ens10")
REG<- c("arctic","extratropics","tropics")

for (j in 1:12){
  setwd(paste("/mnt/data/users/sraj/metrics_regional_csv_final/",ENSM[j],"/",sep=""))
  for (i in 1:3){ 
    stdr<- read.csv(paste(REG[i],"/","std_ratio_header.csv",sep= ""),header=T)
    mns<- read.csv(paste(REG[i],"/","mean_diff_header.csv",sep= ""),header=T)
    cors<-  read.csv(paste(REG[i],"/","corr_header.csv",sep= ""),header=T)
    s0list<- read.csv(paste("/mnt/data/users/sraj/metrics_regional_csv_final/","s0_",REG[i],"_final_txt_header.csv",sep=""),header= T)


# Next read the mean, var and cor for this experiment, and extract only the vars we need
#mns=read.csv("mean_diff_cmip6_header.csv",header=T)
#stdr=read.csv("std_ratio_cmip6_header.csv",header=T)
#cors=read.csv("corr_cmip6_header.csv",header=T)
#s0list<- read.csv("/mnt/data/users/sraj/metrics_regional_csv_final/s0_globe_final_txt_header.csv",header= T)

#mns=read.csv("mean_diff_waccm_header.csv",header=T)
#stdr=read.csv("std_ratio_waccm_header.csv",header=T)
#cors=read.csv("corr_waccm_header.csv",header=T)
#s0list<- read.csv("/mnt/data/users/sraj/metrics_regional_csv_final/s0_globe_final_txt_header.csv",header= T)

#mns=read.csv("mean_diff_cam5_header.csv",header=T)
#stdr=read.csv("std_ratio_cam5_header.csv",header=T)
#cors=read.csv("corr_cam5_header.csv",header=T)
#s0list<- read.csv("/mnt/data/users/sraj/metrics_regional_csv_final/s0_globe_final_txt_header.csv",header= T)

#mns=read.csv("globe/mean_diff_header_ppe.csv",header=T)
#stdr=read.csv("globe/std_ratio_header_ppe.csv",header=T)
#cors=read.csv("globe/corr_header_ppe.csv",header=T)
#s0list<- read.csv("s0_globe_final_txt_header.csv",header= T)

#mns=read.csv("arctic/mean_diff_header_ppe.csv",header=T)
#stdr=read.csv("arctic/std_ratio_header_ppe.csv",header=T)
#cors=read.csv("arctic/corr_header_ppe.csv",header=T)
#s0list<- read.csv("s0_arctic_final_txt_header.csv",header= T)

#mns=read.csv("extratropics/mean_diff_header_ppe.csv",header=T)
#stdr=read.csv("extratropics/std_ratio_header_ppe.csv",header=T)
#cors=read.csv("extratropics/corr_header_ppe.csv",header=T)
#s0list<- read.csv("s0_extratropics_final_txt_header.csv",header= T)

#mns=read.csv("tropics/mean_diff_header_ppe.csv",header=T)
#stdr=read.csv("tropics/std_ratio_header_ppe.csv",header=T)
#cors=read.csv("tropics/corr_header_ppe.csv",header=T)
#s0list<- read.csv("s0_tropics_final_txt_header.csv",header= T)

colnames(mns)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")


varlist<- colnames(s0list)  #SS.csv
#varlist<-c("FNET","CLDL","LWCF","PRECT","SWCF") #SS_1.csv
#varlist<-c("FNET","CLDL","LWCF","PSL","PRECT","SWCF")  #SS_2.csv
#varlist<-c("FNET","CLDL","LWCF","PRECT","SWCF","TREFHT") #SS_3.csv




# Loop over variables
count = 1
for (varn in varlist){
  print(paste("******* processing:",varn))
R=cors[[varn]]
sigf=stdr[[varn]]  # ratio of stdevs.
mn=mns[[varn]]
R0=1.0 # max attatinable correlation is 1.0 here
s0=s0list[[varn]] # get the correct reference spatial standard dev.

### Begin skill score calculations
# SS from Pierce et al. (2009) for spaital pattern matching (s0 is spatial std of reference)
# see: <http://www.pnas.org/cgi/data/0900094106/DCSupplemental/Supplemental_PDF#nameddest=STXT>
condb=(R-sigf)^2 # conditional bias
uncondb=(mn/s0)^2 #unconditional bias
SS = R^2 - condb - uncondb


 # write output to data frame: if we're passing through first time, create output
if(count==1){
  outSS=data.frame(x1=SS)
  outCB=data.frame(x1=condb)
  outUCB=data.frame(x1=uncondb)
} else {
  # if output already exist, then column bind current column:
    outSS=cbind(outSS,SS)
    outCB=cbind(outCB,condb)
    outUCB=cbind(outUCB,uncondb)
}
count = count + 1
}
# assign var names to columns
colnames(outSS)=varlist
colnames(outCB)=varlist
colnames(outUCB)=varlist

# calculate mean SS over all variables
outSS$mean=rowMeans(outSS)
outCB$mean=rowMeans(outCB)
outUCB$mean=rowMeans(outUCB)

# write SS output to CSV file
write.csv(outSS,file=paste("~/SS_models/SS_",ENSM[j],"_",REG[i],"_ppe.csv",sep=""),row.names = F)
#write.csv(outSS,file="~/SS_models/SS_1_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_2_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_3_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_cmip6_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_waccm_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_cam5_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_globe_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_arctic_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_extratropics_ppe.csv",row.names = F)
#write.csv(outSS,file="~/SS_models/SS_tropics_ppe.csv",row.names = F)
}
}
  
