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

plot_fig3 <- function(restk_var, ggtit) {
  df_exp1a %>%
    filter(restk == restk_var) %>%
    ggplot(aes(x = type, y = accuracy)) + 
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line", aes(group = 1)) + 
    geom_hline(yintercept=0.125) + 
    theme(aspect.ratio = 1) + 
    xlab(expression("Target's"~kappa)) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    scale_x_continuous(expression("Target's"~kappa~" (log scale)"),breaks = c(1,2,4,8,16,32,64,128),labels = c("1","2","4","8","16","32","64","128"), trans = "log2") + 
    geom_vline(xintercept = restk_var, linetype = 2) +
    ggtitle(ggtit) +
    theme(plot.title = element_text(hjust = 0.5))
}

plot_trial_frame <-function(tt) {
  traj_k64 %>% 
    filter(t == tt) %>%
    ggplot(aes(xcoord, ycoord, group = object)) + 
    geom_point(size = 5) + 
    theme(aspect.ratio = 1) + 
    xlim(-15,15) +
    ylim(-15,15) +
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(), 
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())
}

plot_fig4 <- function(restk_var, show_legend = F) {
  
  p <- df_exp1b %>%
    filter(restk == restk_var) %>%
    ggplot(aes(x = targetk, y = accuracy, group = 1)) + 
    #facet_grid(~ restk) + 
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line") + 
    geom_hline(yintercept=0.125) +
    theme(aspect.ratio = 1) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    scale_x_continuous(expression("Target's"~kappa~" (log scale)"),breaks = c(2,4,8,16,64),labels = c("2","4","8","16","64"), trans = "log2") + 
    geom_vline(xintercept = restk_var, linetype = 2) +
    ggtitle(bquote("Distractors'"~kappa == .(restk_var))) +
    theme(plot.title = element_text(hjust = 0.5))
  
  if (show_legend) {
    p 
  } else {
    p + theme(legend.position="none")
  }
  
}

plot_fig3a <- function() {
  restk_lab <- as_labeller(c(`2` = expression("Distractor's"~kappa~"=2"), 
                             `4` = expression("Distractor's"~kappa~"=4"),
                             `8` = expression("Distractor's"~kappa~"=8"),
                             `16` = expression("Distractor's"~kappa~"=16"),
                             `64` = expression("Distractor's"~kappa~"=64")), label_parsed)
  p <- df_exp1b %>% 
    ggplot(aes(x = targetk, y = accuracy)) + 
    facet_grid(~restk, labeller = restk_lab) +
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line") + 
    geom_hline(yintercept=0.125) + 
    theme(aspect.ratio = 1)  + xlab(expression("Target's"~kappa)) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    scale_x_continuous(expression("Target's"~kappa~" (log scale)"),breaks = c(1,2,4,8,16,64),labels = c("1","2","4","8","16","64"), trans = "log2") + 
    theme(plot.title = element_text(hjust = 0.5))
  p
}

plot_fig6 <- function(restspd, ggtit) {
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

plot_fig5 <- function() {
  accu_summary <- df_exp1b %>% 
    mutate(contrast_abs_f = as.character(contrast_abs)) %>% 
    group_by(id, contrast_abs, contrast_abs_f, target_straight) %>% 
    dplyr::summarise(accu = mean(accuracy), n = n()) %>% 
    ungroup()
  accu_summary_wo_0 <- accu_summary %>% filter(contrast_abs > 0)
  
  # duplicated values for contrast 0
  accu_summaryx <- bind_rows(
    accu_summary,
    accu_summary %>% 
      filter(contrast_abs == 0, target_straight == F) %>% 
      mutate(target_straight = T)
  )
  
  p <- accu_summaryx %>% 
    ggplot(
      aes(x = contrast_abs, y = accu, 
          group = target_straight, shape = target_straight, linetype = target_straight)) + 
    stat_summary(fun.data = "mean_cl_boot", alpha = .5) +
    stat_summary(fun.y = "mean", alpha = .5, geom = "line") + 
    theme(aspect.ratio = 1) + 
    scale_shape_discrete("Distractor type", labels = c("More Ballistic-like", "More Brownian-like")) +
    scale_linetype_discrete("Distractor type", labels = c("More Ballistic-like", "More Brownian-like")) +
    xlab("contrast") + ylab("Accuracy")
}

plot_fig7 <- function(rest_spd, show_legend = F) {
   
  p <- df_exp2b %>%
    filter(restspd == rest_spd) %>% 
    ggplot(aes(x = targetspd, y = accuracy, xintercept = rest_spd)) + 
    stat_summary(fun.data = "mean_cl_boot") + 
    stat_summary(fun.y = mean, geom = "line") + 
    geom_hline(yintercept=0.125) +
    theme(aspect.ratio = 1) + 
    ylab("Accuracy") + 
    ylim(0,1)+
    scale_x_continuous("Target speed (log scale)",breaks = c(.5,1,2,4,8),labels = c("0.5","1","2","4","8"),
                       trans = "log2") + 
    geom_vline(aes(xintercept = rest_spd), linetype = 2)  +
    ggtitle(bquote("Distractors' speed = "~.(rest_spd)*degree*"/s"))
    
  p
}

plot_fig8 <- function(){
  accu_summary <- df_exp2b %>% 
    mutate(contrast_abs_f = as.character(contrast_abs)) %>% 
    group_by(id, contrast_abs, contrast_abs_f, target_faster) %>% 
    dplyr::summarise(accu = mean(accuracy), n = n()) %>% 
    ungroup()
  accu_summary_wo_0 <- accu_summary %>% filter(contrast_abs > 0)
  
  # duplicated values for contrast 0
  accu_summaryx <- bind_rows(
    accu_summary,
    accu_summary %>% 
      filter(contrast_abs == 0, target_faster == F) %>% 
      mutate(target_faster = T)
  )
  
  p <- accu_summaryx %>% 
    ggplot(
      aes(x = contrast_abs, y = accu, 
          group = target_faster, shape = target_faster, linetype = target_faster)) + 
    stat_summary(fun.data = "mean_cl_boot", alpha = .5, linetype = "solid") +
    stat_summary(fun.y = "mean", alpha = .5, geom = "line") + 
    theme(aspect.ratio = 1) + 
    scale_shape_discrete("Distractor type", labels = c("Faster then target", "Slower than target")) +
    scale_linetype_discrete("Distractor type", labels = c("Faster then target", "Slower than target")) +
    xlab("contrast") + ylab("Accuracy")
}

create_data_scheme_vonmises <- function(nDot, kappa, t) {
  ang <- rvonmises(nDot,circular(0), kappa, control.circular=list(units="radians"))
  
  y <- cos(ang)
  x <- sin(ang)
  
  df <- data_frame(id = 1:nDot, x, y, t = 1, ang)
  
  for(i in 1:t){
    tmp <- rvonmises(nDot,circular(0), kappa, control.circular=list(units="radians"))
    ang <- ang + tmp
    y <- cos(ang)
    x <- sin(ang)
    tmp <- data_frame(id = 1:nDot,x, y, t=i, ang)
    df <- rbind(df, tmp)  
  }
  
  df2 <- df %>% 
    group_by(id) %>% 
    mutate(x = cumsum(x), y = cumsum(y)) %>% 
    ungroup()
  
  return(df2)
}
plot_vonmises_scheme <- function(df, ggtit) {
  df %>% 
    group_by(id) %>% 
    top_n(1,t) %>% 
    ggplot(aes(x, y)) + 
    geom_point(alpha = I(0.1)) + 
    theme(aspect.ratio = 1) +
    xlim(-4,4) +
    ylim(-4,4) +
    geom_segment(aes(x=0, xend=0, y=0, yend=2), 
                   arrow = arrow(length = unit(0.5, "cm"), type = "closed"), size = 2, col = "red") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    xlab("x [deg]") + 
    ylab("y [deg]") + 
    ggtitle(ggtit) + 
    theme(plot.title = element_text(hjust = 0.5))
}

kl_distance <- function(k1, k2) {
  x <- seq(from = -pi, to = pi, length.out = 1000)
  p_k1 <- circular::dvonmises(x,mu = circular::circular(0), kappa = k1)
  p_k2 <- circular::dvonmises(x,mu = circular::circular(0), kappa = k2)
  m <- spatialEco::kl.divergence(cbind(p_k1,p_k2))
  (m[1,2]+m[2,1]) / 2
}
