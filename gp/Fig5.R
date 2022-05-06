# ---------------------------------------


#
# n=50 training cases.
# ---------------------------------------
#
# cgf: Run the emulator to predict SS,
# use predict() to expand the probability space,
# then use SS to constrain parameter ranges.
# 




# cgf mod: use normalized predictors (full_data.norm)
#



# -----------------------------------------------------------------
# 0. Packages, functions and data
# -----------------------------------------------------------------

source('/home/sraj/Fletcher_2018_scripts/common.R')

# -----------------------------------------------------------------
# 1. Find a set of inputs consistent with SS > thresh
# - fit km() model for SS given inputs X, and predict (emulate) SS for full probability space
# - then select areas of prob space where SS > thresh, 
# - and make pairs density plot of X.
# -----------------------------------------------------------------

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

# select plausible data from pred.ss
X.out<-subset(X.unif,pred.ss$lower95 > ss_thresh)
#unnormalizing plausible data
X.out.unnorm<- unnormalize(X.out,apply(X,2,min),apply(X,2,max))
# append default parameters as bottom row to normalized
X.out.stand <- rbind(X.out,params.stand.append.norm[length(params.stand.append.norm[,1]),])
# append default parameters as bottom row to unnormalized
X.out.stand.unnorm <- rbind(X.out.unnorm,params.stand.append[length(params.stand.append[,1]),])
print(paste("SS>thresh:",100*dim(X.out)[1]/n," % of prob space."))
      
# 2D pairs plot of INPUTs for cases with SS>thresh:
pfile='Fig5_tropics.pdf'
file = paste(plotpath,pfile,sep="")
pdf(width = 7, height = 7, file = file)
par(lab=c(3,3,7)) # constrain 3 labels on each plot
# in response to Reviewer #2, removed the red line, replaced by point.
pairs(X.out.stand, panel = dfunc.up.pt, gap = 0.75, upper.panel = NULL,xlim=c(0,1),ylim=c(0,1))

dev.off()


