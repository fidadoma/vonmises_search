rm(list = ls())

library(tidyverse)

source("tools.R")

# von mises - circle -------------------------------------------------------------
set.seed(180307)

library(tidyverse)
theme_set(theme_bw(16))

if(!require(circular)) {install.packages("circular"); library(circular)}

nDot  <- 1000L
t     <- 15

p1 <- create_data_scheme_vonmises(nDot, t, kappa = 2) %>% plot_vonmises_scheme(expression("Highly variable movement ("*kappa~"=2)"))
p2 <- create_data_scheme_vonmises(nDot, t, kappa = 16) %>% plot_vonmises_scheme(expression("Medium variable movement ("*kappa~"=16)"))
p3 <- create_data_scheme_vonmises(nDot, t, kappa = 64) %>% plot_vonmises_scheme(expression("Low variable movement ("*kappa~"=64)"))
ggsave(here::here("..", "plots", "scheme_vonmises_k2.png"), p1, width = 6, height = 6)
ggsave(here::here("..", "plots", "scheme_vonmises_k16.png"), p2, width = 6, height = 6)
ggsave(here::here("..", "plots", "scheme_vonmises_k64.png"), p3, width = 6, height = 6)


# real data ---------------------------------------------------------------




# video -------------------------------------------------------------------
library(gganimate)
theme_set(theme_bw(16))

p <- traj_k64 %>% 
  ggplot(aes(xcoord, ycoord, group = object)) + 
  geom_point(size = 4) + 
  theme(aspect.ratio = 1) + 
  xlim(-15,15) +
  ylim(-15,15) +
  guides(color = FALSE) +
  xlab("x [deg]") +
  ylab("y [deg]") +
  ggtitle(expression("Target's "*kappa~"= 4; Distractors' "*kappa~"= 64")) +
  theme(plot.title = element_text(hjust = 0.5)) +
  labs(title = 'Time: {t}', x = 'x [deg]', y = 'y [deg]') +
  transition_time(t) +
  ease_aes('linear')
  
p
anim_save(here::here("..", "plots", "trial_video.gif"))
