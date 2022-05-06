# cgf: Run the emulator to predict CS and AOD and SS,
# use predict() to expand the probability space,
# then use SS to constrain parameter ranges.
# 

# cgf mod: use normalized predictors (full_data.norm)

# -----------------------------------------------------------------
# 0. Packages, functions and data
# -----------------------------------------------------------------

source('/home/sraj/Fletcher_2018_scripts/density_common.R')

# -----------------------------------------------------------------
# 1. Find a set of inputs consistent with SS > thresh
# - fit km() model for SS given inputs X, and predict (emulate) SS for full probability space
# - then select areas of prob space where SS > thresh, 
# - and make pairs density plot of X.
# -----------------------------------------------------------------

# fit model:  (note: X is defined in common routine)
# cgf mod: using normalized predictors, and version of data without defaults:
set.seed(99)
fit <- km(~., design = X.norm, response = full_data.norm[,"ssm"], control = list(trace = FALSE)) 

# set up full parameter space
n=100000
# ranges based on mins/maxs of INPUTS
X.mins <- apply(X.norm,2,min)
X.maxes <- apply(X.norm,2,max)
# sample from uniform distribution n times
set.seed(99)
X.unif <- samp.unif(n, mins = X.mins, maxes = X.maxes)
colnames(X.unif) <- colnames(X)
pred.ss <- predict(fit, newdata = X.unif, type = 'UK')

# select plausible data from pred
ix.at<-pred.ss$lower95 > ss_thresh
X.out <- X.unif[ix.at, ]
X.out.unnorm<-unnormalize(X.out,apply(X,2,min),apply(X,2,max))
# append default parameters as bottom row to normalized subset
X.out.stand <- rbind(X.out,params.stand.append.norm[length(params.stand.append.norm[,1]),])
# append default parameters as bottom row to unnormalized subset
X.out.unnorm.stand <- rbind(X.out.unnorm,params.stand.append[length(params.stand.append[,1]),])

full_data.pred=as.data.frame(cbind(X.out.unnorm,pred.ss$mean[ix.at],pred.ss$lower95[ix.at],pred.ss$upper95[ix.at]))
full_data.pred.norm=as.data.frame(cbind(X.out,pred.ss$mean[ix.at],pred.ss$lower95[ix.at],pred.ss$upper95[ix.at]))
colnames(full_data.pred)[6:8]=c("SS_Mean","SS_Lower95","SS_Upper95")
colnames(full_data.pred.norm)[6:8]=c("SS_Mean","SS_Lower95","SS_Upper95")
print(paste("SS>thresh: ",100*dim(X.out)[1]/n," % of prob space."))

# -----------------------------------------------------------------
# 2. Next, plot histograms for OUTPUTs for this subset of "best cases"
# -----------------------------------------------------------------

pfile='Fig_density.pdf'
file = paste(plotpath,pfile,sep="")

pdf(file = file, width = 3, height = 8)
par(mfrow= c(8,1) , las = 1, mar = c(1,2,1,2), oma = c(5,2,0,0), cex.axis = 1.0) #,fg = 'white'

# loop over OUTPUTS, build emulator and emulate parameter space, then subset by SS
for (i in 1:8){
  print(paste("processing",colnames(full_data.norm)[i+5],sep=""))
    # indexing starts at 6 for CLDL and ends at 13 for ssm
  fit <- km(~., design = X.norm, response = full_data.norm[,i+5], control = list(trace = FALSE))
  pred <- predict(fit, newdata = X.unif, type = 'UK')
  # get density for the training set (CAM4) which will be overlaid as a black line
  histt <- density(full_data.norm[1:48,i+5], n=256)
  # define two density objects for each OUTPUT (one is all cases, the other is subset)
  hist1 <- density(pred$mean, n=256)
  hist <- density(subset(pred$mean,pred.ss$lower95 > ss_thresh),n=256)
  yl=c(0,max(hist$y,hist1$y,histt$y))
  x1=min(hist$x,hist1$x,histt$x,full_data.norm_wom[,i+5])
  x2=max(abs(hist$x),abs(hist1$x),abs(histt$x),abs(full_data.norm_wom[,i+5]))
  #x1=min(x1,-x2)
  xl=c(x1,x2)
  plot(hist1$x,hist1$y,xlim = xl, main = '',xlab = '', ylab = '', axes=T,type="h",lwd=2,ylim=yl,col="darkgrey")
  lines(histt$x,histt$y,col="black",lwd=2)
  lines(hist$x,hist$y,col="red",lwd=2)
  # cgf mod: add line to show default model output (last row of full_data with default)
  abline(v=full_data.norm[49,i+5],col="darkgreen",lwd=0.5)
  abline(v=full_data.norm_wom[50,i+5],col="red",lwd=0.5)
  abline(v=full_data.norm_wom[51,i+5],col="blue",lwd=0.5)
  abline(v=full_data.norm_wom[52,i+5],col="gold",lwd=0.5)
  abline(v=full_data.norm_wom[53,i+5],col="gold1",lwd=0.5)
  abline(v=full_data.norm_wom[54,i+5],col="gold2",lwd=0.5)
  abline(v=full_data.norm_wom[55,i+5],col="gold3",lwd=0.5)
  abline(v=full_data.norm_wom[56,i+5],col="gold4",lwd=0.5)
  abline(v=full_data.norm_wom[57,i+5],col="goldenrod",lwd=0.5)
  abline(v=full_data.norm_wom[58,i+5],col="goldenrod1",lwd=0.5)
  abline(v=full_data.norm_wom[59,i+5],col="goldenrod2",lwd=0.5)
  abline(v=full_data.norm_wom[60,i+5],col="goldenrod3",lwd=0.5)
  abline(v=full_data.norm_wom[61,i+5],col="goldenrod4",lwd=0.5)
  legend("topleft",legend= c("CAM4","CMIP6","WACCM","CAM5"),cex=0.5,bty= "n",inset= 0.05,col= c("darkgreen","red","blue","gold"),lty=1)
  mtext(side = 4, adj = 0, line = -4, text = colnames(full_data.norm)[i+5], cex = 0.5, col = 'black')

} 


dev.off()

# -----------------------------------------------------------------
# 2b. Version of OUTPUT histograms including means, vars and cors
# -----------------------------------------------------------------

pfile='Fig_density_mcs_globe_comp.pdf'
file = paste(plotpath,pfile,sep="")

pdf(file = file, width = 7.5, height = 9)
par(mfrow= c(7,3) , las = 1, mar = c(1,2,1,2), oma = c(5,2,0,0), cex.axis = 1.0) #,fg = 'white'

# loop over OUTPUTS, build emulator and emulate parameter space, then subset by SS
# NOTE: here we use data that includes the defaults in last row: needs to be omitted from km()
vlet=c("M","C","S")
for (i in 1:7){
  # new: loop over mn, std and cor
  for (k in vlet){ 
    print(paste("processing: k=",k," ,",colnames(full_data)[i+5],sep=""))
   #choose appropriate variable from appropriate dataset (mn, cor or std) and remove default row
      if(k==vlet[1]){thisdata=full_data[1:length(full_data[,1]),i+5]
      thisdata_wom=full_data_wom[52:63,i+5]
      thisdef=full_data[length(full_data[,1]),i+5]}
      if(k==vlet[2]){thisdata=full_data.cors[1:length(full_data.cors[,1]),i+5]
      thisdata_wom=full_data.cors_wom[52:63,i+5]
      thisdef=full_data.cors[length(full_data.cors[,1]),i+5]}
      if(k==vlet[3]){thisdata=full_data.stdr[1:length(full_data.stdr[,1]),i+5]
      thisdata_wom=full_data.stdr_wom[52:63,i+5]
      thisdef=full_data.stdr[length(full_data.stdr[,1]),i+5]}
      # indexing starts at 6 for CLDL and ends at 13 for ssm  
      #  default parameters already removed from X:
      set.seed(99)
      fit <- km(~., design = X.norm, response = thisdata, control = list(trace = FALSE))
      pred <- predict(fit, newdata = X.unif, type = 'UK')
      # get density for the training set (CAM4) which will be overlaid as a black line
      histt <- density(thisdata, n=256)
      # define two density objects for each OUTPUT (one is all cases, the other is subset)
      hist1 <- density(pred$mean, n=256)
      hist <- density(subset(pred$mean,pred.ss$lower95 > ss_thresh),n=256)
      yl=c(0,max(hist$y,hist1$y,histt$y))
      x1=min(hist$x,hist1$x,histt$x,thisdata_wom)
      x2=max(abs(hist$x),abs(hist1$x),abs(histt$x),abs(thisdata_wom))
      if(k==vlet[1]){x1=min(x1,-x2)
      xl=c(x1,x2)}
      if(k==vlet[2]){xl=c(0,1)}
      if(k==vlet[3]){xl=c(0,3)}
      d1=min(thisdata_wom[3:12])
      d2=max(thisdata_wom[3:12])
      plot(hist1$x,hist1$y,xlim = xl, main = '',xlab = '', ylab = '', axes = T,type="h",lwd=2,ylim=yl,col="darkgrey")
      lines(histt$x,histt$y,col="black",lwd=2)
      lines(hist$x,hist$y,col="red",lwd=2)
      # cgf mod: add line to show default model output (last row of full_data with default)
      abline(v=thisdef,col="darkgreen",lwd=0.5)
      abline(v=thisdata_wom[1],col="red",lwd=0.5)
      abline(v=thisdata_wom[2],col="blue",lwd=0.5)
      rect(xleft = d1, xright = d2, ybottom = par("usr")[3], ytop = par("usr")[4], 
           border = NA, col = adjustcolor("yellow", alpha = 0.5))
      mtext(side = 2, adj = 0, line = -0.2, text = paste(k,colnames(full_data)[i+5],sep=":"), cex = 0.7, col = 'black')
      
  }
     
} 
par(fig = c(0, 1, 0, 1), oma = c(0, 0, 0, 0), mar = c(0, 0, 0, 0), new = TRUE)
plot(0, 0, type = 'l', bty = 'n', xaxt = 'n', yaxt = 'n')
legend('bottom',legend= c("CAM4","CMIP6","WACCM","CAM5"), col= c("darkgreen","red","blue","yellow"), lwd = 3, xpd = TRUE, horiz = TRUE, cex = 1, seg.len=1, bty = 'n',lty= 1)

dev.off()
