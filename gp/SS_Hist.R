source('/home/sraj/Fletcher_2018_scripts/common.R')

# fit model
X<- full_data[,1:5]
X.norm<- full_data.norm[,1:5]
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
colnames(X.unif) <- colnames(X.norm)
#unnormalizing
X.unif.unnorm<- unnormalize(X.unif,apply(X,2,min),apply(X,2,max))
#prediction through model
pred.ss <- predict(fit, newdata = X.unif, type = 'UK')

ssm_pert<- ssm[1:50]
ssm_def<- ssm[51]
ssm_emul<- pred.ss$mean

pfile='Hist_SS_tropics.pdf'
file = paste(plotpath,pfile,sep="")
pdf(width = 7, height = 5, file = file)
par(mar = c(5, 4, 4, 4) + 0.3)
hist(ssm_pert,breaks =30,xlim = c(-4.1,0.9),ylim= c(0,8),main="",xlab = "SS",axes = FALSE)
abline(v = ssm_def,col= "darkgreen",lwd=1.5)
axis(side =1,at = seq(-4.1,0.9,by = 0.5),labels = seq(-4.1,0.9,by =0.5)  )
axis(side =2,at = seq(0,8,by=1),labels = seq(0,8,by=1) )
par(new=TRUE)
plot(density(ssm_emul)$x,density(ssm_emul)$y,type ="l",axes = FALSE,col= "red", xlab="", ylab= "", main="",lwd=2)
axis(side =4,at = pretty(range(density(ssm_emul)$y)), col ="red")
mtext("Density",side =4, line =3, col= "red")

dev.off() 


