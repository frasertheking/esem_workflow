

# -----------------------------------------------------------------
# 0. Packages, functions and data
# -----------------------------------------------------------------

source('/home/sraj/Fletcher_2018_scripts/common.R')

# -----------------------------------------------------------------
# 1. Sensitivity analysis using the extended FAST algorithm of Saltelli et al, 
# using the R package "sensitivity".
# ------------------------------------------------------------------------------

#
# We should check whether we need to first normalize the predictors.
X=full_data.norm[,1:5]
set.seed(99)
fit.ssm <- km(~., design = X, response = full_data.norm[,"ssm"], control = list(trace = FALSE))

# generate the design to run the emulator at, using fast99
x <- fast99(model = NULL, factors = colnames(X), n = 1000,
            q = "qunif", q.arg = list(min = 0, max = 1))

# run the emulator at the sensitivity analysis design points
fast.pred.ssm <- predict(fit.ssm, newdata = x$X, type = 'UK')

# Calculate the sensitivity indices
fast.ssm <- tell(x, fast.pred.ssm$mean)

bp.convert <- function(fastmodel){
  # get the FAST summary into an easier format for barplot
  fast.summ <- print(fastmodel)
  fast.diff <- fast.summ[ ,2] - fast.summ[ ,1]
  fast.bp <- t(cbind(fast.summ[ ,1], fast.diff))
  fast.bp
}

# Plot the sensitivity indices

pfile='Fig4_3.pdf'
file = paste(plotpath,pfile,sep="")

pdf(width = 5, height = 5, file = file)
par(mfrow = c(1,1), mar = c(4,4,0,2), las = 1, oma = c(5,4,1,2), fg = 'darkgrey', xaxs = 'i', cex.axis = 1.1)

barplot(bp.convert(fast.ssm), ylim = c(0,1), col = c('blue', 'lightgrey'),border='black',ylab='Fraction of total variance',xlab = "Input parameter")
legend('top', legend = c('Main effect', 'Interaction'),
       fill = c('blue', 'lightgrey'), bty = 'n', text.col = 'black', cex = 1.3)


dev.off()


