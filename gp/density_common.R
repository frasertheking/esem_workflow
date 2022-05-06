
library(DiceKriging)
library(RColorBrewer)
library(MASS)
library(ncdf4)
library(RNetCDF)
library(fields)
library(parallel)
library(randtoolbox)
library(dplyr)
library(sensitivity)
library(googledrive)

pth= "/mnt/data/users/c5fletch/projects/CESM_UQ/fromStrauss/GPmodelling/"
source(paste(pth,'emtools.R',sep=""))
source(paste(pth,'imptools.R',sep=""))
source(paste(pth,'vistools.R',sep=""))
              
# here is where the with new obs data is stored:
datdir_1 <- '/mnt/data/users/sraj/metrics_regional_csv_final/globe/' 
#datdir_1 <- '/mnt/data/users/sraj/metrics_regional_csv_final/arctic/'
#datdir_1 <- '/mnt/data/users/sraj/metrics_regional_csv_final/extratropics/'
#datdir_1 <- '/mnt/data/users/sraj/metrics_regional_csv_final/tropics/'
datdir_2<- '/home/sraj/metrics_csv_final/'
#datdir_2<- '/mnt/data/users/sraj/metrics_regional_csv_final/'
datdir_3<- '/home/sraj/SS_models/'
set.seed(99)

# where to save the plots
plotpath <- '/home/sraj/Fletcher_2022_plots/'


# ---------------------------------------
# cgf: Read all data required for CAM UQ analysis
# ---------------------------------------
setwd(datdir_1)
#
# first read these training data files:
# -read the mean, var and cor for this experiment, and extract only the vars we need
mns=read.csv("mean_diff_header_ppe.csv",header=T)
stdr=read.csv("std_ratio_header_ppe.csv",header=T)
cors=read.csv("corr_header_ppe.csv",header=T)
colnames(mns)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")

setwd(datdir_2)
mns_cmip6<- read.csv("mean_diff_cmip6_header.csv",header=TRUE)
mns_waccm<- read.csv("mean_diff_waccm_header.csv",header=TRUE)
mns_cam5<- read.csv("mean_diff_cam5_header.csv",header=TRUE)
mns_cam5_ens02<- read.csv("mean_diff_cam5_ens02_header.csv",header=TRUE)
mns_cam5_ens03<- read.csv("mean_diff_cam5_ens03_header.csv",header=TRUE)
mns_cam5_ens04<- read.csv("mean_diff_cam5_ens04_header.csv",header=TRUE)
mns_cam5_ens05<- read.csv("mean_diff_cam5_ens05_header.csv",header=TRUE)
mns_cam5_ens06<- read.csv("mean_diff_cam5_ens06_header.csv",header=TRUE)
mns_cam5_ens07<- read.csv("mean_diff_cam5_ens07_header.csv",header=TRUE)
mns_cam5_ens08<- read.csv("mean_diff_cam5_ens08_header.csv",header=TRUE)
mns_cam5_ens09<- read.csv("mean_diff_cam5_ens09_header.csv",header=TRUE)
mns_cam5_ens10<- read.csv("mean_diff_cam5_ens10_header.csv",header=TRUE)

# mns_cmip6<- read.csv("cmip6/arctic/mean_diff_header.csv",header=TRUE)
# mns_waccm<- read.csv("waccm/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5<- read.csv("cam5/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens02<- read.csv("cam5_ens02/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens03<- read.csv("cam5_ens03/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens04<- read.csv("cam5_ens04/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens05<- read.csv("cam5_ens05/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens06<- read.csv("cam5_ens06/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens07<- read.csv("cam5_ens07/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens08<- read.csv("cam5_ens08/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens09<- read.csv("cam5_ens09/arctic/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens10<- read.csv("cam5_ens10/arctic/mean_diff_header.csv",header=TRUE)

# mns_cmip6<- read.csv("cmip6/extratropics/mean_diff_header.csv",header=TRUE)
# mns_waccm<- read.csv("waccm/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5<- read.csv("cam5/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens02<- read.csv("cam5_ens02/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens03<- read.csv("cam5_ens03/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens04<- read.csv("cam5_ens04/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens05<- read.csv("cam5_ens05/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens06<- read.csv("cam5_ens06/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens07<- read.csv("cam5_ens07/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens08<- read.csv("cam5_ens08/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens09<- read.csv("cam5_ens09/extratropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens10<- read.csv("cam5_ens10/extratropics/mean_diff_header.csv",header=TRUE)

# mns_cmip6<- read.csv("cmip6/tropics/mean_diff_header.csv",header=TRUE)
# mns_waccm<- read.csv("waccm/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5<- read.csv("cam5/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens02<- read.csv("cam5_ens02/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens03<- read.csv("cam5_ens03/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens04<- read.csv("cam5_ens04/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens05<- read.csv("cam5_ens05/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens06<- read.csv("cam5_ens06/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens07<- read.csv("cam5_ens07/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens08<- read.csv("cam5_ens08/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens09<- read.csv("cam5_ens09/tropics/mean_diff_header.csv",header=TRUE)
# mns_cam5_ens10<- read.csv("cam5_ens10/tropics/mean_diff_header.csv",header=TRUE)

colnames(mns_cmip6)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_waccm)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens02)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens03)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens04)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens05)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens06)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens07)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens08)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens09)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(mns_cam5_ens10)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")

stdr_cmip6<- read.csv("std_ratio_cmip6_header.csv",header=TRUE)
stdr_waccm<- read.csv("std_ratio_waccm_header.csv",header=TRUE)
stdr_cam5<- read.csv("std_ratio_cam5_header.csv",header=TRUE)
stdr_cam5_ens02<- read.csv("std_ratio_cam5_ens02_header.csv",header=TRUE)
stdr_cam5_ens03<- read.csv("std_ratio_cam5_ens03_header.csv",header=TRUE)
stdr_cam5_ens04<- read.csv("std_ratio_cam5_ens04_header.csv",header=TRUE)
stdr_cam5_ens05<- read.csv("std_ratio_cam5_ens05_header.csv",header=TRUE)
stdr_cam5_ens06<- read.csv("std_ratio_cam5_ens06_header.csv",header=TRUE)
stdr_cam5_ens07<- read.csv("std_ratio_cam5_ens07_header.csv",header=TRUE)
stdr_cam5_ens08<- read.csv("std_ratio_cam5_ens08_header.csv",header=TRUE)
stdr_cam5_ens09<- read.csv("std_ratio_cam5_ens09_header.csv",header=TRUE)
stdr_cam5_ens10<- read.csv("std_ratio_cam5_ens10_header.csv",header=TRUE)

# stdr_cmip6<- read.csv("cmip6/arctic/std_ratio_header.csv",header=TRUE)
# stdr_waccm<- read.csv("waccm/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5<- read.csv("cam5/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens02<- read.csv("cam5_ens02/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens03<- read.csv("cam5_ens03/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens04<- read.csv("cam5_ens04/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens05<- read.csv("cam5_ens05/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens06<- read.csv("cam5_ens06/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens07<- read.csv("cam5_ens07/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens08<- read.csv("cam5_ens08/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens09<- read.csv("cam5_ens09/arctic/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens10<- read.csv("cam5_ens10/arctic/std_ratio_header.csv",header=TRUE)

# stdr_cmip6<- read.csv("cmip6/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_waccm<- read.csv("waccm/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5<- read.csv("cam5/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens02<- read.csv("cam5_ens02/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens03<- read.csv("cam5_ens03/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens04<- read.csv("cam5_ens04/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens05<- read.csv("cam5_ens05/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens06<- read.csv("cam5_ens06/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens07<- read.csv("cam5_ens07/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens08<- read.csv("cam5_ens08/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens09<- read.csv("cam5_ens09/extratropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens10<- read.csv("cam5_ens10/extratropics/std_ratio_header.csv",header=TRUE)

# stdr_cmip6<- read.csv("cmip6/tropics/std_ratio_header.csv",header=TRUE)
# stdr_waccm<- read.csv("waccm/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5<- read.csv("cam5/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens02<- read.csv("cam5_ens02/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens03<- read.csv("cam5_ens03/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens04<- read.csv("cam5_ens04/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens05<- read.csv("cam5_ens05/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens06<- read.csv("cam5_ens06/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens07<- read.csv("cam5_ens07/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens08<- read.csv("cam5_ens08/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens09<- read.csv("cam5_ens09/tropics/std_ratio_header.csv",header=TRUE)
# stdr_cam5_ens10<- read.csv("cam5_ens10/tropics/std_ratio_header.csv",header=TRUE)

colnames(stdr_cmip6)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_waccm)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens02)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens03)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens04)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens05)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens06)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens07)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens08)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens09)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(stdr_cam5_ens10)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")

cors_cmip6<- read.csv("corr_cmip6_header.csv",header=TRUE)
cors_waccm<- read.csv("corr_waccm_header.csv",header=TRUE)
cors_cam5<- read.csv("corr_cam5_header.csv",header=TRUE)
cors_cam5_ens02<- read.csv("corr_cam5_ens02_header.csv",header=TRUE)
cors_cam5_ens03<- read.csv("corr_cam5_ens03_header.csv",header=TRUE)
cors_cam5_ens04<- read.csv("corr_cam5_ens04_header.csv",header=TRUE)
cors_cam5_ens05<- read.csv("corr_cam5_ens05_header.csv",header=TRUE)
cors_cam5_ens06<- read.csv("corr_cam5_ens06_header.csv",header=TRUE)
cors_cam5_ens07<- read.csv("corr_cam5_ens07_header.csv",header=TRUE)
cors_cam5_ens08<- read.csv("corr_cam5_ens08_header.csv",header=TRUE)
cors_cam5_ens09<- read.csv("corr_cam5_ens09_header.csv",header=TRUE)
cors_cam5_ens10<- read.csv("corr_cam5_ens10_header.csv",header=TRUE)

# cors_cmip6<- read.csv("cmip6/arctic/corr_header.csv",header=TRUE)
# cors_waccm<- read.csv("waccm/arctic/corr_header.csv",header=TRUE)
# cors_cam5<- read.csv("cam5/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens02<- read.csv("cam5_ens02/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens03<- read.csv("cam5_ens03/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens04<- read.csv("cam5_ens04/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens05<- read.csv("cam5_ens05/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens06<- read.csv("cam5_ens06/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens07<- read.csv("cam5_ens07/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens08<- read.csv("cam5_ens08/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens09<- read.csv("cam5_ens09/arctic/corr_header.csv",header=TRUE)
# cors_cam5_ens10<- read.csv("cam5_ens10/arctic/corr_header.csv",header=TRUE)

# cors_cmip6<- read.csv("cmip6/extratropics/corr_header.csv",header=TRUE)
# cors_waccm<- read.csv("waccm/extratropics/corr_header.csv",header=TRUE)
# cors_cam5<- read.csv("cam5/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens02<- read.csv("cam5_ens02/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens03<- read.csv("cam5_ens03/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens04<- read.csv("cam5_ens04/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens05<- read.csv("cam5_ens05/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens06<- read.csv("cam5_ens06/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens07<- read.csv("cam5_ens07/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens08<- read.csv("cam5_ens08/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens09<- read.csv("cam5_ens09/extratropics/corr_header.csv",header=TRUE)
# cors_cam5_ens10<- read.csv("cam5_ens10/extratropics/corr_header.csv",header=TRUE)

# cors_cmip6<- read.csv("cmip6/tropics/corr_header.csv",header=TRUE)
# cors_waccm<- read.csv("waccm/tropics/corr_header.csv",header=TRUE)
# cors_cam5<- read.csv("cam5/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens02<- read.csv("cam5_ens02/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens03<- read.csv("cam5_ens03/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens04<- read.csv("cam5_ens04/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens05<- read.csv("cam5_ens05/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens06<- read.csv("cam5_ens06/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens07<- read.csv("cam5_ens07/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens08<- read.csv("cam5_ens08/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens09<- read.csv("cam5_ens09/tropics/corr_header.csv",header=TRUE)
# cors_cam5_ens10<- read.csv("cam5_ens10/tropics/corr_header.csv",header=TRUE)

colnames(cors_cmip6)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_waccm)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens02)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens03)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens04)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens05)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens06)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens07)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens08)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens09)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")
colnames(cors_cam5_ens10)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")


# next read the mean SS values (ssm) produced by PierceSS.R:
setwd(datdir_3)
ss=read.csv("SS_globe_ppe.csv",head=T)
  # ss=read.csv("SS_arctic_ppe.csv",head=T)
  # ss=read.csv("SS_extratropics_ppe.csv",head=T)
 # ss=read.csv("SS_tropics_ppe.csv",head=T)
ssm=ss$mean
ss_cmip6=read.csv("SS_cmip6_ppe.csv",head=T)
ss_waccm=read.csv("SS_waccm_ppe.csv",head=T)
ss_cam5=read.csv("SS_cam5_ppe.csv",head=T)
ss_cam5_ens02=read.csv("SS_cam5_ens02_ppe.csv",head=T)
ss_cam5_ens03=read.csv("SS_cam5_ens03_ppe.csv",head=T)
ss_cam5_ens04=read.csv("SS_cam5_ens04_ppe.csv",head=T)
ss_cam5_ens05=read.csv("SS_cam5_ens05_ppe.csv",head=T)
ss_cam5_ens06=read.csv("SS_cam5_ens06_ppe.csv",head=T)
ss_cam5_ens07=read.csv("SS_cam5_ens07_ppe.csv",head=T)
ss_cam5_ens08=read.csv("SS_cam5_ens08_ppe.csv",head=T)
ss_cam5_ens09=read.csv("SS_cam5_ens09_ppe.csv",head=T)
ss_cam5_ens10=read.csv("SS_cam5_ens10_ppe.csv",head=T)

# ss_cmip6=read.csv("SS_cmip6_arctic_ppe.csv",head=T)
# ss_waccm=read.csv("SS_waccm_arctic_ppe.csv",head=T)
# ss_cam5=read.csv("SS_cam5_arctic_ppe.csv",head=T)
# ss_cam5_ens02=read.csv("SS_cam5_ens02_arctic_ppe.csv",head=T)
# ss_cam5_ens03=read.csv("SS_cam5_ens03_arctic_ppe.csv",head=T)
# ss_cam5_ens04=read.csv("SS_cam5_ens04_arctic_ppe.csv",head=T)
# ss_cam5_ens05=read.csv("SS_cam5_ens05_arctic_ppe.csv",head=T)
# ss_cam5_ens06=read.csv("SS_cam5_ens06_arctic_ppe.csv",head=T)
# ss_cam5_ens07=read.csv("SS_cam5_ens07_arctic_ppe.csv",head=T)
# ss_cam5_ens08=read.csv("SS_cam5_ens08_arctic_ppe.csv",head=T)
# ss_cam5_ens09=read.csv("SS_cam5_ens09_arctic_ppe.csv",head=T)
# ss_cam5_ens10=read.csv("SS_cam5_ens10_arctic_ppe.csv",head=T)

# ss_cmip6=read.csv("SS_cmip6_extratropics_ppe.csv",head=T)
# ss_waccm=read.csv("SS_waccm_extratropics_ppe.csv",head=T)
# ss_cam5=read.csv("SS_cam5_extratropics_ppe.csv",head=T)
# ss_cam5_ens02=read.csv("SS_cam5_ens02_extratropics_ppe.csv",head=T)
# ss_cam5_ens03=read.csv("SS_cam5_ens03_extratropics_ppe.csv",head=T)
# ss_cam5_ens04=read.csv("SS_cam5_ens04_extratropics_ppe.csv",head=T)
# ss_cam5_ens05=read.csv("SS_cam5_ens05_extratropics_ppe.csv",head=T)
# ss_cam5_ens06=read.csv("SS_cam5_ens06_extratropics_ppe.csv",head=T)
# ss_cam5_ens07=read.csv("SS_cam5_ens07_extratropics_ppe.csv",head=T)
# ss_cam5_ens08=read.csv("SS_cam5_ens08_extratropics_ppe.csv",head=T)
# ss_cam5_ens09=read.csv("SS_cam5_ens09_extratropics_ppe.csv",head=T)
# ss_cam5_ens10=read.csv("SS_cam5_ens10_extratropics_ppe.csv",head=T)

# ss_cmip6=read.csv("SS_cmip6_tropics_ppe.csv",head=T)
# ss_waccm=read.csv("SS_waccm_tropics_ppe.csv",head=T)
# ss_cam5=read.csv("SS_cam5_tropics_ppe.csv",head=T)
# ss_cam5_ens02=read.csv("SS_cam5_ens02_tropics_ppe.csv",head=T)
# ss_cam5_ens03=read.csv("SS_cam5_ens03_tropics_ppe.csv",head=T)
# ss_cam5_ens04=read.csv("SS_cam5_ens04_tropics_ppe.csv",head=T)
# ss_cam5_ens05=read.csv("SS_cam5_ens05_tropics_ppe.csv",head=T)
# ss_cam5_ens06=read.csv("SS_cam5_ens06_tropics_ppe.csv",head=T)
# ss_cam5_ens07=read.csv("SS_cam5_ens07_tropics_ppe.csv",head=T)
# ss_cam5_ens08=read.csv("SS_cam5_ens08_tropics_ppe.csv",head=T)
# ss_cam5_ens09=read.csv("SS_cam5_ens09_tropics_ppe.csv",head=T)
# ss_cam5_ens10=read.csv("SS_cam5_ens10_tropics_ppe.csv",head=T)

ss_cmip6_m=ss_cmip6$mean
ss_waccm_m=ss_waccm$mean
ss_cam5_m=ss_cam5$mean
ss_cam5_ens02_m=ss_cam5_ens02$mean
ss_cam5_ens03_m=ss_cam5_ens03$mean
ss_cam5_ens04_m=ss_cam5_ens04$mean
ss_cam5_ens05_m=ss_cam5_ens05$mean
ss_cam5_ens06_m=ss_cam5_ens06$mean
ss_cam5_ens07_m=ss_cam5_ens07$mean
ss_cam5_ens08_m=ss_cam5_ens08$mean
ss_cam5_ens09_m=ss_cam5_ens09$mean
ss_cam5_ens10_m=ss_cam5_ens10$mean

# Set up thresholds for subsetting parameter space:
ss_thresh= quantile(ssm,probs = 0.9)


# lastly, read the parameter values for the training cases, which are the predictors (design matrix):

params= read.table("/mnt/data/users/c5fletch/projects/CESM_UQ/PPEobs_Saurav/params_50_5vals_withDefaults.txt",header=T)
# set up proper col names for params:
colnames(params)=c("x8","x5","x6","x7","x9")
# reordering columns of parameter values
params<- params[,c(2,3,4,1,5)]
# normalized version of params
params.norm=normalize(params)
# standard parameter values 
X.stand=c(0.91,14.00,1800.00, 0.80,3600.00)
# params along with default values appended at bottom
params.stand.append<- rbind(params,X.stand)
#other models mns
data_mns_cmip6<- c(NA,NA,NA,NA,NA,mns_cmip6$CLDL,mns_cmip6$FNET,mns_cmip6$LWCF,mns_cmip6$PRECT,mns_cmip6$SWCF,mns_cmip6$TREFHT,mns_cmip6$PSL,ss_cmip6_m)
data_mns_waccm<- c(NA,NA,NA,NA,NA,mns_waccm$CLDL,mns_waccm$FNET,mns_waccm$LWCF,mns_waccm$PRECT,mns_waccm$SWCF,mns_waccm$TREFHT,mns_waccm$PSL,ss_waccm_m)
data_mns_cam5<- c(NA,NA,NA,NA,NA,mns_cam5$CLDL,mns_cam5$FNET,mns_cam5$LWCF,mns_cam5$PRECT,mns_cam5$SWCF,mns_cam5$TREFHT,mns_cam5$PSL,ss_cam5_m)
data_mns_cam5_ens02<- c(NA,NA,NA,NA,NA,mns_cam5_ens02$CLDL,mns_cam5_ens02$FNET,mns_cam5_ens02$LWCF,mns_cam5_ens02$PRECT,mns_cam5_ens02$SWCF,mns_cam5_ens02$TREFHT,mns_cam5_ens02$PSL,ss_cam5_ens02_m)
data_mns_cam5_ens03<- c(NA,NA,NA,NA,NA,mns_cam5_ens03$CLDL,mns_cam5_ens03$FNET,mns_cam5_ens03$LWCF,mns_cam5_ens03$PRECT,mns_cam5_ens03$SWCF,mns_cam5_ens03$TREFHT,mns_cam5_ens03$PSL,ss_cam5_ens03_m)
data_mns_cam5_ens04<- c(NA,NA,NA,NA,NA,mns_cam5_ens04$CLDL,mns_cam5_ens04$FNET,mns_cam5_ens04$LWCF,mns_cam5_ens04$PRECT,mns_cam5_ens04$SWCF,mns_cam5_ens04$TREFHT,mns_cam5_ens04$PSL,ss_cam5_ens04_m)
data_mns_cam5_ens05<- c(NA,NA,NA,NA,NA,mns_cam5_ens05$CLDL,mns_cam5_ens05$FNET,mns_cam5_ens05$LWCF,mns_cam5_ens05$PRECT,mns_cam5_ens05$SWCF,mns_cam5_ens05$TREFHT,mns_cam5_ens05$PSL,ss_cam5_ens05_m)
data_mns_cam5_ens06<- c(NA,NA,NA,NA,NA,mns_cam5_ens06$CLDL,mns_cam5_ens06$FNET,mns_cam5_ens06$LWCF,mns_cam5_ens06$PRECT,mns_cam5_ens06$SWCF,mns_cam5_ens06$TREFHT,mns_cam5_ens06$PSL,ss_cam5_ens06_m)
data_mns_cam5_ens07<- c(NA,NA,NA,NA,NA,mns_cam5_ens07$CLDL,mns_cam5_ens07$FNET,mns_cam5_ens07$LWCF,mns_cam5_ens07$PRECT,mns_cam5_ens07$SWCF,mns_cam5_ens07$TREFHT,mns_cam5_ens07$PSL,ss_cam5_ens07_m)
data_mns_cam5_ens08<- c(NA,NA,NA,NA,NA,mns_cam5_ens08$CLDL,mns_cam5_ens08$FNET,mns_cam5_ens08$LWCF,mns_cam5_ens08$PRECT,mns_cam5_ens08$SWCF,mns_cam5_ens08$TREFHT,mns_cam5_ens08$PSL,ss_cam5_ens08_m)
data_mns_cam5_ens09<- c(NA,NA,NA,NA,NA,mns_cam5_ens09$CLDL,mns_cam5_ens09$FNET,mns_cam5_ens09$LWCF,mns_cam5_ens09$PRECT,mns_cam5_ens09$SWCF,mns_cam5_ens09$TREFHT,mns_cam5_ens09$PSL,ss_cam5_ens09_m)
data_mns_cam5_ens10<- c(NA,NA,NA,NA,NA,mns_cam5_ens10$CLDL,mns_cam5_ens10$FNET,mns_cam5_ens10$LWCF,mns_cam5_ens10$PRECT,mns_cam5_ens10$SWCF,mns_cam5_ens10$TREFHT,mns_cam5_ens10$PSL,ss_cam5_ens10_m)
#other models cors
data_cors_cmip6<- c(NA,NA,NA,NA,NA,cors_cmip6$CLDL,cors_cmip6$FNET,cors_cmip6$LWCF,cors_cmip6$PRECT,cors_cmip6$SWCF,cors_cmip6$TREFHT,cors_cmip6$PSL,ss_cmip6_m)
data_cors_waccm<- c(NA,NA,NA,NA,NA,cors_waccm$CLDL,cors_waccm$FNET,cors_waccm$LWCF,cors_waccm$PRECT,cors_waccm$SWCF,cors_waccm$TREFHT,cors_waccm$PSL,ss_waccm_m)
data_cors_cam5<- c(NA,NA,NA,NA,NA,cors_cam5$CLDL,cors_cam5$FNET,cors_cam5$LWCF,cors_cam5$PRECT,cors_cam5$SWCF,cors_cam5$TREFHT,cors_cam5$PSL,ss_cam5_m)
data_cors_cam5_ens02<- c(NA,NA,NA,NA,NA,cors_cam5_ens02$CLDL,cors_cam5_ens02$FNET,cors_cam5_ens02$LWCF,cors_cam5_ens02$PRECT,cors_cam5_ens02$SWCF,cors_cam5_ens02$TREFHT,cors_cam5_ens02$PSL,ss_cam5_ens02_m)
data_cors_cam5_ens03<- c(NA,NA,NA,NA,NA,cors_cam5_ens03$CLDL,cors_cam5_ens03$FNET,cors_cam5_ens03$LWCF,cors_cam5_ens03$PRECT,cors_cam5_ens03$SWCF,cors_cam5_ens03$TREFHT,cors_cam5_ens03$PSL,ss_cam5_ens03_m)
data_cors_cam5_ens04<- c(NA,NA,NA,NA,NA,cors_cam5_ens04$CLDL,cors_cam5_ens04$FNET,cors_cam5_ens04$LWCF,cors_cam5_ens04$PRECT,cors_cam5_ens04$SWCF,cors_cam5_ens04$TREFHT,cors_cam5_ens04$PSL,ss_cam5_ens04_m)
data_cors_cam5_ens05<- c(NA,NA,NA,NA,NA,cors_cam5_ens05$CLDL,cors_cam5_ens05$FNET,cors_cam5_ens05$LWCF,cors_cam5_ens05$PRECT,cors_cam5_ens05$SWCF,cors_cam5_ens05$TREFHT,cors_cam5_ens05$PSL,ss_cam5_ens05_m)
data_cors_cam5_ens06<- c(NA,NA,NA,NA,NA,cors_cam5_ens06$CLDL,cors_cam5_ens06$FNET,cors_cam5_ens06$LWCF,cors_cam5_ens06$PRECT,cors_cam5_ens06$SWCF,cors_cam5_ens06$TREFHT,cors_cam5_ens06$PSL,ss_cam5_ens06_m)
data_cors_cam5_ens07<- c(NA,NA,NA,NA,NA,cors_cam5_ens07$CLDL,cors_cam5_ens07$FNET,cors_cam5_ens07$LWCF,cors_cam5_ens07$PRECT,cors_cam5_ens07$SWCF,cors_cam5_ens07$TREFHT,cors_cam5_ens07$PSL,ss_cam5_ens07_m)
data_cors_cam5_ens08<- c(NA,NA,NA,NA,NA,cors_cam5_ens08$CLDL,cors_cam5_ens08$FNET,cors_cam5_ens08$LWCF,cors_cam5_ens08$PRECT,cors_cam5_ens08$SWCF,cors_cam5_ens08$TREFHT,cors_cam5_ens08$PSL,ss_cam5_ens08_m)
data_cors_cam5_ens09<- c(NA,NA,NA,NA,NA,cors_cam5_ens09$CLDL,cors_cam5_ens09$FNET,cors_cam5_ens09$LWCF,cors_cam5_ens09$PRECT,cors_cam5_ens09$SWCF,cors_cam5_ens09$TREFHT,cors_cam5_ens09$PSL,ss_cam5_ens09_m)
data_cors_cam5_ens10<- c(NA,NA,NA,NA,NA,cors_cam5_ens10$CLDL,cors_cam5_ens10$FNET,cors_cam5_ens10$LWCF,cors_cam5_ens10$PRECT,cors_cam5_ens10$SWCF,cors_cam5_ens10$TREFHT,cors_cam5_ens10$PSL,ss_cam5_ens10_m)
#other models stdr
data_stdr_cmip6<- c(NA,NA,NA,NA,NA,stdr_cmip6$CLDL,stdr_cmip6$FNET,stdr_cmip6$LWCF,stdr_cmip6$PRECT,stdr_cmip6$SWCF,stdr_cmip6$TREFHT,stdr_cmip6$PSL,ss_cmip6_m)
data_stdr_waccm<- c(NA,NA,NA,NA,NA,stdr_waccm$CLDL,stdr_waccm$FNET,stdr_waccm$LWCF,stdr_waccm$PRECT,stdr_waccm$SWCF,stdr_waccm$TREFHT,stdr_waccm$PSL,ss_waccm_m)
data_stdr_cam5<- c(NA,NA,NA,NA,NA,stdr_cam5$CLDL,stdr_cam5$FNET,stdr_cam5$LWCF,stdr_cam5$PRECT,stdr_cam5$SWCF,stdr_cam5$TREFHT,stdr_cam5$PSL,ss_cam5_m)
data_stdr_cam5_ens02<- c(NA,NA,NA,NA,NA,stdr_cam5_ens02$CLDL,stdr_cam5_ens02$FNET,stdr_cam5_ens02$LWCF,stdr_cam5_ens02$PRECT,stdr_cam5_ens02$SWCF,stdr_cam5_ens02$TREFHT,stdr_cam5_ens02$PSL,ss_cam5_ens02_m)
data_stdr_cam5_ens03<- c(NA,NA,NA,NA,NA,stdr_cam5_ens03$CLDL,stdr_cam5_ens03$FNET,stdr_cam5_ens03$LWCF,stdr_cam5_ens03$PRECT,stdr_cam5_ens03$SWCF,stdr_cam5_ens03$TREFHT,stdr_cam5_ens03$PSL,ss_cam5_ens03_m)
data_stdr_cam5_ens04<- c(NA,NA,NA,NA,NA,stdr_cam5_ens04$CLDL,stdr_cam5_ens04$FNET,stdr_cam5_ens04$LWCF,stdr_cam5_ens04$PRECT,stdr_cam5_ens04$SWCF,stdr_cam5_ens04$TREFHT,stdr_cam5_ens04$PSL,ss_cam5_ens04_m)
data_stdr_cam5_ens05<- c(NA,NA,NA,NA,NA,stdr_cam5_ens05$CLDL,stdr_cam5_ens05$FNET,stdr_cam5_ens05$LWCF,stdr_cam5_ens05$PRECT,stdr_cam5_ens05$SWCF,stdr_cam5_ens05$TREFHT,stdr_cam5_ens05$PSL,ss_cam5_ens05_m)
data_stdr_cam5_ens06<- c(NA,NA,NA,NA,NA,stdr_cam5_ens06$CLDL,stdr_cam5_ens06$FNET,stdr_cam5_ens06$LWCF,stdr_cam5_ens06$PRECT,stdr_cam5_ens06$SWCF,stdr_cam5_ens06$TREFHT,stdr_cam5_ens06$PSL,ss_cam5_ens06_m)
data_stdr_cam5_ens07<- c(NA,NA,NA,NA,NA,stdr_cam5_ens07$CLDL,stdr_cam5_ens07$FNET,stdr_cam5_ens07$LWCF,stdr_cam5_ens07$PRECT,stdr_cam5_ens07$SWCF,stdr_cam5_ens07$TREFHT,stdr_cam5_ens07$PSL,ss_cam5_ens07_m)
data_stdr_cam5_ens08<- c(NA,NA,NA,NA,NA,stdr_cam5_ens08$CLDL,stdr_cam5_ens08$FNET,stdr_cam5_ens08$LWCF,stdr_cam5_ens08$PRECT,stdr_cam5_ens08$SWCF,stdr_cam5_ens08$TREFHT,stdr_cam5_ens08$PSL,ss_cam5_ens08_m)
data_stdr_cam5_ens09<- c(NA,NA,NA,NA,NA,stdr_cam5_ens09$CLDL,stdr_cam5_ens09$FNET,stdr_cam5_ens09$LWCF,stdr_cam5_ens09$PRECT,stdr_cam5_ens09$SWCF,stdr_cam5_ens09$TREFHT,stdr_cam5_ens09$PSL,ss_cam5_ens09_m)
data_stdr_cam5_ens10<- c(NA,NA,NA,NA,NA,stdr_cam5_ens10$CLDL,stdr_cam5_ens10$FNET,stdr_cam5_ens10$LWCF,stdr_cam5_ens10$PRECT,stdr_cam5_ens10$SWCF,stdr_cam5_ens10$TREFHT,stdr_cam5_ens10$PSL,ss_cam5_ens10_m)
# Bind all data together in a data frame: cols 1-5 are the INPUTS, cols 6-12 are the outputs, 13 is ssm
full_data=cbind(params.stand.append,mns$CLDL,mns$FNET,mns$LWCF,mns$PRECT,mns$SWCF,mns$TREFHT,mns$PSL,ssm)
full_data_wom=rbind(full_data,data_mns_cmip6,data_mns_waccm,data_mns_cam5,data_mns_cam5_ens02,data_mns_cam5_ens03,data_mns_cam5_ens04,data_mns_cam5_ens05,data_mns_cam5_ens06,data_mns_cam5_ens07,data_mns_cam5_ens08,data_mns_cam5_ens09,data_mns_cam5_ens10)
colnames(full_data)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")
colnames(full_data_wom)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")
# also get normalized default predictors
params.stand.append.norm=normalize(params.stand.append)
X.stand.norm <- params.stand.append.norm[length(params.stand.append.norm[,1]),]
#  version with normalized parameters
full_data.norm=as.data.frame(cbind(params.stand.append.norm,mns$CLDL,mns$FNET,mns$LWCF,mns$PRECT,mns$SWCF,mns$TREFHT,mns$PSL,ssm))
full_data.norm_wom=rbind(full_data.norm,data_mns_cmip6,data_mns_waccm,data_mns_cam5,data_mns_cam5_ens02,data_mns_cam5_ens03,data_mns_cam5_ens04,data_mns_cam5_ens05,data_mns_cam5_ens06,data_mns_cam5_ens07,data_mns_cam5_ens08,data_mns_cam5_ens09,data_mns_cam5_ens10)
colnames(full_data.norm)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")
colnames(full_data.norm_wom)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")

## Read the outputs and SS from the default model. 

# HERE recomputes the OBS data and gets values for the default model,
# we should add default parameter values, and outputs (and SS) to the bottom row of the data frame.
# DEFAULT CASE IS ALREADY ROW 51... NO NEED TO ADD IT AGAIN.

# design matrix of input parameters (normalized and non-normalized)
X.norm=full_data.norm[,1:5]
X=full_data[,1:5]

# New version, for cors and vars, which we can plot later (e.g. for output histograms)
full_data.cors= cbind(params.stand.append,cors$CLDL,cors$FNET,cors$LWCF,cors$PRECT,cors$SWCF,cors$TREFHT,cors$PSL,ssm)
full_data.cors_wom<- rbind(full_data.cors,data_cors_cmip6,data_cors_waccm,data_cors_cam5,data_cors_cam5_ens02,data_cors_cam5_ens03,data_cors_cam5_ens04,data_cors_cam5_ens05,data_cors_cam5_ens06,data_cors_cam5_ens07,data_cors_cam5_ens08,data_cors_cam5_ens09,data_cors_cam5_ens10)
colnames(full_data.cors)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")
colnames(full_data.cors_wom)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")
full_data.stdr= cbind(params.stand.append,stdr$CLDL,stdr$FNET,stdr$LWCF,stdr$PRECT,stdr$SWCF,stdr$TREFHT,stdr$PSL,ssm)
full_data.stdr_wom<- rbind(full_data.stdr,data_stdr_cmip6,data_stdr_waccm,data_stdr_cam5,data_stdr_cam5_ens02,data_stdr_cam5_ens03,data_stdr_cam5_ens04,data_stdr_cam5_ens05,data_stdr_cam5_ens06,data_stdr_cam5_ens07,data_stdr_cam5_ens08,data_stdr_cam5_ens09,data_stdr_cam5_ens10)
colnames(full_data.stdr)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")
colnames(full_data.stdr_wom)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")


# ---------------------------------------
# Helper functions

f <- function(s){
  strsplit(s, split = "a.pt")[[1]][1]
}


open.field <- function(fn, var){
  
  # helper function to load a map of var from nc file
  
  nc <- open.nc(fn)
  nc.var <- var.get.nc(nc, var)
  nc.var	
}

load.spatial.ens <- function(fn.list, var){
  
  # open all nc files in a list, vectorise, and concatenate to
  # an ensemble matrix, each row is a map
  
  field.list <- lapply(fn.list, FUN = open.field, var = var)
  
  out <- t(sapply(field.list,cbind)) # should do by columns
  out
}

remap.famous <- function(dat,longs,lats, shift = FALSE){
  
  # reshape a map in vector form so that image() like functions
  # will plot it correctly
  
  mat <- matrix(dat, nrow = length(longs), ncol = length(lats))[ ,length(lats):1]
  
  if(shift){
    
    block1.ix <- which(longs < shift)
    block2.ix <- which(longs > shift)
    
    mat.shift <- rbind(mat[ block2.ix, ], mat[block1.ix, ]) 
    
    out <- mat.shift
  }
  
  else{
    out <- mat
  }
  
  out
}

pc.project <- function(pca,scores.em,Z.em,scale){
  
  # project principal components
  
  num.pc <- dim(scores.em)[2]
  
  if (scale){
    anom <- ((pca$rotation[ ,1:num.pc] %*% t(scores.em))*pca$scale)
    anom.sd <- ((pca$rotation[ ,1:num.pc] %*% t(Z.em))*pca$scale)          
  }
  
  else {
    anom <- pca$rotation[ ,1:num.pc] %*% t(scores.em)
    anom.sd <- pca$rotation[ ,1:num.pc] %*% t(Z.em)   
  }
  
  tens <- t(anom + pca$center)
  
  return(list(tens = tens, anom.sd = anom.sd))
}


km.pc <- function(Y, X, newdata, num.pc, scale = FALSE, center = TRUE, type = "UK", ...){
  
  # Base function for emulation of high dimensional data
  # with PCA and Gaussian Process emulator
  
  if (class(Y)!= 'prcomp'){
    pca <- prcomp(Y,scale = scale, center = center)
  }
  
  else{
    pca <- Y
  }
  
  if(is.matrix(newdata)!= TRUE){
    print('matrixifying newdata')
    newdata <- matrix(newdata,nrow = 1) 
  }
  
  scores.em <- matrix(nrow = dim(newdata)[1],ncol = num.pc)
  Z.em <- matrix(nrow = dim(newdata)[1],ncol = num.pc)
  
  for (i in 1:num.pc){
    
    # build the GP model
    
    fit <- km(design = X, response = pca$x[,i])
    pred <- predict(fit, newdata = newdata, type = type, ...)
    
    scores.em[ ,i] <- pred$mean
    Z.em[ ,i] <- pred$sd
    
  }
  
  proj = pc.project(pca, scores.em, Z.em, scale)
  
  return(list(tens = proj$tens,scores.em = scores.em,Z.em = Z.em,anom.sd = proj$anom.sd))
}


prop.thres <- function(x, thres, above = FALSE){
  
  # propotion of vector x below a threshold thres
  
  n <- length(x)
  
  if(above) bt <- length(x[x > thres])
  
  else bt <- length(x[x < thres])
  
  prop <- bt/n
  
  prop  
}



# ---------------------------------------
# pallettes
rb <- brewer.pal(11, "RdBu")
ryg <- brewer.pal(11, "RdYlGn")
pbg <- brewer.pal(9, "PuBuGn")
bg <- brewer.pal(9, "BuGn")
yg <- brewer.pal(9, "YlGn")
byr <- rev(brewer.pal(11,'RdYlBu'))
br <- rev(rb)
blues <-  brewer.pal(9,'Blues')
rblues <-  rev(blues)

greens <-  brewer.pal(9,'Greens')
ygb <- brewer.pal(9, "YlGnBu")
brbg <- brewer.pal(11, "BrBG")
yob <- brewer.pal(9, "YlOrBr")
yor <- brewer.pal(9, "YlOrRd")

acc <- brewer.pal(8,'Paired')

col.amaz <- acc[1]
col.namerica <- acc[2]
col.seasia <- acc[3]
col.congo <- acc[4]
col.global <- acc[5]


pch.global <- 3
pch.amaz <- 1
pch.congo <- 2
pch.seasia <- 5
pch.namerica <- 4

# ---------------------------------------

# ---------------------------------------
# input space


#ndims <- ncol(X)
#nens <- nrow(X)

# Implausibility helper

inputs.set <- function(X, y, thres, obs, obs.sd = 0, disc = 0, disc.sd = 0, n = 100000, abt = FALSE){ 
  
  # find a set of inputs that are consistent with a particular
  # set of implausibility (either below or above)
  
  X.mins <- apply(X,2,min)
  X.maxes <- apply(X,2,max)
  
  X.unif <- samp.unif(n, mins = X.mins, maxes = X.maxes)
  colnames(X.unif) <- colnames(X)
  
  fit <- km(~., design = X, response = y, control = list(trace = FALSE))
  pred <- predict(fit, newdata = X.unif, type = 'UK')
  pred.impl <- impl(em = pred$mean, em.sd = pred$sd,
                    disc = disc, obs = obs, disc.sd = disc.sd, obs.sd = obs.sd)
  
  if(abt){
    # choose those above the threshold 
    ix.bt <- pred.impl > thres
  }
  
  else{
    ix.bt <- pred.impl < thres
  }
  
  X.out <- X.unif[ix.bt, ]
  
  return(list(X.out = X.out, fit = fit, X.unif = X.unif, pred = pred,pred.impl = pred.impl))   
  
}


dfunc.up <- function(x,y,...){
  require(MASS)
  require(RColorBrewer)
  
#  br <- brewer.pal(9, 'Blues')
  br <- brewer.pal(9, 'Greys')
  # function for plotting 2d kernel density estimates in pairs() plot.
  kde <- kde2d(x,y)
  image(kde, col = br, add = TRUE)
  
}

dfunc.up.line <- function(x,y,...){
  # cgf mod to plot reference lines based on last row (default parameters)
  require(MASS)
  require(RColorBrewer)
  nt=length(x)
  
    br <- brewer.pal(9, 'Blues')
#  br <- brewer.pal(9, 'Greys')
  # function for plotting 2d kernel density estimates in pairs() plot.
  kde <- kde2d(x[1:nt-1],y[1:nt-1])
  image(kde, col = br, add = TRUE)
  abline(v=x[nt],col="red",lwd=1.5)
  abline(h=y[nt],col="red",lwd=1.5)
  
}

dfunc.up.pt <- function(x,y,...){
  # cgf mod to plot reference points based on last row (default parameters)
  require(MASS)
  require(RColorBrewer)
  nt=length(x)
  
  br <- brewer.pal(9, 'Blues')
  #  br <- brewer.pal(9, 'Greys')
  # function for plotting 2d kernel density estimates in pairs() plot.
  kde <- kde2d(x[1:nt-1],y[1:nt-1])
  image(kde, col = br, add = TRUE,xlim=c(0,1),ylim=c(0,1))
  points(x[nt],y[nt],col="red",pch=19)
  #  abline(v=x[nt],col="red",lwd=1.5)
  #  abline(h=y[nt],col="red",lwd=1.5)
  
}

dfunc.image <- function(x,y,...){
  # produce paired contour images of CS by x/y in a pairs plot
  require(MASS)
  require(RColorBrewer)
  require(akima)
  # z-values: would be nice to find a way to generalize this, by passing it through panel
  yn<-normalize(y)
  xn<-normalize(x)
  z<-thisz
  
  br <- rev(brewer.pal(10, 'RdYlBu'))
  # create contour surface for this pair
  fld<-interp(xn,yn,z)
  image(fld, col = br, add = TRUE,zlim=c(0.35,0.7))
}