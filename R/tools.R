multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  # source: http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}


thresh.est <- function(p1 = 0.6, model) {
  q.5   <- -coef(model)[1] / coef(model)[2]
  sigma <- 1/coef(model)[2]
  th <- exp(qnorm(p = p1,
                  mean = q.5, sd = sigma))
  return(th)
}

compute.p <- function(dfx) {
  aov1 <- ezANOVA(as.data.frame(dfx),
                  dv = accuracy,
                  wid = subject,
                  within = version)
  return(aov1$ANOVA$p)
}
compute.ges <- function(dfx) {
  aov1 <- ezANOVA(as.data.frame(dfx),
                  dv = accuracy,
                  wid = subject,
                  within = version)
  return(aov1$ANOVA$ges)
}

compute.des <- function(dfx) {
  means <- ezStats(as.data.frame(dfx),
                   dv = accuracy,
                   wid = subject,
                   within = version)
  return(diff(means$Mean))
  
}
