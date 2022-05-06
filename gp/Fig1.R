# ---------------------------------------

#
# n=50 training cases on Graham. Use those data here.
# ---------------------------------------

# New version of the pairs plot with shaded background colour based on correlation

# -------------------------------------------------------------
# 0. Packages, functions and data
# -------------------------------------------------------------
source('/home/sraj/Fletcher_2018_scripts/common.R')


# -------------------------------------------------------------------
# 1. Pairs plot of input space and All OUTPUT data
# -------------------------------------------------------------------
old.names=names(full_data)
new.names<-c("x5\n(IN)","x6\n(IN)","x7\n(IN)","x8\n(IN)","x9\n(IN)","CLDL\n(OUT)","FNET\n(OUT)","LWCF\n(OUT)","PRECT\n(OUT)",
           "SWCF\n(OUT)","TREFHT\n(OUT)","PSL\n(OUT)","SS\n(OUT)")
colnames(full_data) <- new.names

library(RColorBrewer)
# get array of colours for correlation matrix:
cols = brewer.pal(11, "RdBu")   # goes from red to white to blue
pal = colorRampPalette(cols)
cor_colors = data.frame(correlation = seq(-1,1,0.01), 
                        correlation_color = rev(pal(201)[1:201]))  # assigns a color for each r correlation value
cor_colors$correlation_color = as.character(cor_colors$correlation_color)

mypanel <- function(x,y,...){
  # pairs plot panel function
  ll <- par("usr") 
  r <- cor(x, y,method="spearman",use="complete.obs")
  test <- cor.test(x,y)
  bgcolor = cor_colors[1+(r+1)*100,2]    # converts correlation into a specific color
  rect(ll[1], ll[3], ll[2], ll[4], col=bgcolor , border = NA)
  points(x, y, ... ) 
}



t.p <- function(x, y, labels, cex, font, ...){
  ll <- par("usr") 
  text(x, y, labels, cex, font, col = 'black', ...)
  
}


pfile='Fig1_tropics.pdf'
file = paste(plotpath,pfile,sep="")

pdf(file = file, width = 9, height = 9)

par(fg = 'grey90')
ndt=length(full_data[,1])-1
plotdata=full_data
labnames<-names(plotdata)
par(lab=c(2,2,4))
pairs(plotdata, gap = 0.5,
      lower.panel = mypanel,
      upper.panel = NULL,
      label.pos = 0.7,
      text.panel = t.p,
      col = c(rep('black', ndt), 'red'),
      cex = c(rep(0.1,ndt), 0.75),
      pch = c(rep(19, ndt),19), 
      las = 2,cex.axis=1.2,labels=labnames
)
dev.off()



