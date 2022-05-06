# n = 50 training cases
#dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)  # create personal library
#.libPaths(Sys.getenv("R_LIBS_USER"))  # add to the path

#install.packages("DiceKriging")
#install.packages("fields")
#install.packages("randtoolbox")
#install.packages("sensitivity")
#install.packages("RNetCDF")

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

pth="/mnt/data/users/c5fletch/projects/CESM_UQ/fromStrauss/GPmodelling/"
source(paste(pth,'emtools.R',sep=""))
source(paste(pth,'imptools.R',sep=""))
source(paste(pth,'vistools.R',sep=""))

# data dirs
#dd <- '/mnt/data/users/sraj/metrics_regional_csv_final/globe/' 
#dd <- '/mnt/data/users/sraj/metrics_regional_csv_final/arctic/'
#dd <- '/mnt/data/users/sraj/metrics_regional_csv_final/extratropics/' 
dd <- '/mnt/data/users/fdmking/esem_workflow/' 
set.seed(99)

# where to save the plots
plotpath <- '/mnt/data/users/fdmking/esem_workflow/images'

setwd(dd)

# Next read the mean, var and cor for this experiment
mns=read.csv("/mnt/data/users/fdmking/esem_workflow/output/f19_sst2k_glob_ann_mn.csv",head=T)
colnames(mns)[1:7]<- c("CLDL","FNET","LWCF","PRECT","PSL","SWCF","TREFHT")

# next read the mean SS values (ssm) produced by PierceSS.R:
#ss=read.csv("/home/sraj/SS_models/SS_globe_ppe.csv",header=T)
#ss=read.csv("/home/sraj/SS_models/SS_arctic_ppe.csv",header=T)
#ss=read.csv("/home/sraj/SS_models/SS_extratropics_ppe.csv",header=T)
ss=read.csv("/mnt/data/users/fdmking/esem_workflow/output/f19_sst2k_skills.csv",header=T)
#ss=read.csv("/home/sraj/SS_models/SS_1_ppe.csv",header=T)
#ss=read.csv("/home/sraj/SS_models/SS_2_ppe.csv",header=T)
#ss=read.csv("/home/sraj/SS_models/SS_3_ppe.csv",header=T)
ssm=ss$mean
# Set up thresholds for subsetting parameter space:
ss_thresh= quantile(ssm,probs = 0.9)
#ss_thresh= quantile(ssm,probs = 0.95)
#ss_thresh= quantile(ssm,probs = 0.99)
#ss_thresh=ssm[49]
#ss_thresh= quantile(ssm,probs = c(seq(0.1,0.95,by=0.05),0.99))
  

# lastly, read the parameter values for the training cases, which are the predictors (design matrix):

params=read.table("/mnt/data/users/fdmking/esem_test_data/Params_100case_9vals.csv",header=T)
# set up proper col names for params:
colnames(params)=c("x8","x5","x6","x7","x9")
# reordering columns of parameter values
params<- params[,c(2,3,4,1,5)]
# normalized version of params
params.norm=normalize(params)
# standard parameter values (including NAs for those undefined by default in CAM)
X.stand=c(0.91,14.00,1800.00, 0.80,3600.00)
# params along with default values appended at bottom
params.stand.append<- rbind(params,X.stand)
# Bind all data together in a data frame: cols 1-5 are the INPUTS, cols 6-12 are the outputs, 13 is ssm
full_data=cbind(params.stand.append,mns$CLDL,mns$FNET,mns$LWCF,mns$PRECT,mns$SWCF,mns$TREFHT,mns$PSL,ssm)
colnames(full_data)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")
# also get normalized default predictors
params.stand.append.norm=normalize(params.stand.append)
X.stand.norm <- params.stand.append.norm[length(params.stand.append.norm[,1]),]
#  version with normalized parameters
full_data.norm=as.data.frame(cbind(params.stand.append.norm,mns$CLDL,mns$FNET,mns$LWCF,mns$PRECT,mns$SWCF,mns$TREFHT,mns$PSL,ssm))
colnames(full_data.norm)[6:12]=c("CLDL","FNET","LWCF","PRECT","SWCF","TREFHT","PSL")


#==========================================

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


# Normalise the input space
#X <- params_beta[ ,4:10]
#X.norm <- normalize(X)
# Parameter values (x1-x9) from default CAM
#X.standard <- c(NA,NA,1,NA,0.88,14.0,1800,0.5,3600)
#X.stan.norm <- normalize(matrix(X.standard, nrow = 1), wrt = X)

#colnames(X.stan.norm) <- colnames(X.norm)

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
  image(kde, col = br, add = TRUE,xlim=c(0,1),ylim=c(0,1))
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
  z<-X.out$cs
   
  # colours now specified in colarr. 
  #br <- rev(brewer.pal(nl, 'RdYlBu'))
  # create contour surface for this pair
  fld<-interp(xn,yn,z)
  image(fld, col = colarr, add = TRUE,zlim=c(zl1,zl2),breaks=breaks,nlevel=nl)
}

