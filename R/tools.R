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

plot_fig2 <- function(restk_var, ggtit) {
  df_exp1a %>%
    filter(restk == restk_var) %>%
    ggplot(aes(x = type, y = accuracy)) + 
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line", aes(group = 1)) + 
    geom_hline(yintercept=0.125) + 
    theme(aspect.ratio = 1)  + xlab(expression("Target's"~kappa)) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    scale_x_continuous(expression("Target's"~kappa~" (log scale)"),breaks = c(1,8,16,32,64,128),labels = c("1","8","16","32","64","128"), trans = "log2") + 
    geom_vline(xintercept = restk_var, linetype = 2) +
    ggtitle(ggtit)
}

plot_fig3 <- function(restk_var, show_legend = F) {
  
  p <- df2_exp1b %>%
    filter(restk == restk_var) %>%
    ggplot(aes(x = type, y = accuracy, group = version)) + 
    #facet_grid(~ restk) + 
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line", aes(group = version, linetype = version)) + 
    geom_hline(yintercept=0.125) +
    theme(aspect.ratio = 1) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    scale_x_continuous(expression("Variable"~kappa~" (log scale)"),breaks = c(2,4,8,16,64),labels = c("2","4","8","16","64"), trans = "log2") + 
    scale_linetype_manual(values = c(2,1)) +
    geom_vline(xintercept = restk_var, linetype = 2) +
    ggtitle(bquote("Fixed "~kappa~"= "~.(restk_var)))
  
  if (show_legend) {
    p 
  } else {
    p + theme(legend.position="none")
  }
  
}

plot_fig4 <- function(restspd, ggtit) {
  df_exp2a %>%
    filter(restk == restspd) %>%
    ggplot(aes(x = type, y = accuracy)) + 
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line", aes(group = 1)) + 
    geom_hline(yintercept=0.125) + 
    theme(aspect.ratio = 1) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    geom_vline(xintercept = restspd, linetype = 2) +
    scale_x_continuous("Target's speed (log scale)",breaks = c(0.5,1,2,3,4,6,8),labels = c("0.5","1","2","3","4","6","8"), trans = "log2") + 
    ggtitle(ggtit)
}

plot_fig5 <- function(restspd, show_legend = F) {
  p <- df2_exp2b %>%
    filter(restk == restspd) %>%
    ggplot(aes(x = type, y = accuracy, group = version)) + 
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line", aes(group = version, linetype = version)) + 
    geom_hline(yintercept=0.125) +
    theme(aspect.ratio = 1) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    scale_x_continuous("Variable speed (log scale)",breaks = c(.5,1,2,4,8),labels = c(".5","1","2","4","8"),
                       trans = "log2") + 
    geom_vline(xintercept = restspd, linetype = 2) +
    ggtitle(bquote("Fixed speed = "~.(restspd)*degree*"/s"))
  if (show_legend) {
    p 
  } else {
    p + theme(legend.position="none")
  }   
}
