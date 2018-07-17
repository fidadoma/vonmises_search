rm(list = ls())

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

data_pth <- here::here("..","data", "exp1b", "trajectories")

traj_k64_raw <- read.table(file.path(data_pth, "T001_4_rest64.csv")) %>% 
  as_data_frame() %>% 
  mutate(t=1:n())

trajx <- traj_k64_raw %>% 
  select(V1,V3,V5,V7,V9,V11,V13,V15,t) %>% 
  gather(key = "object", value = "xcoord", -t) %>% 
  mutate(object = recode(object, V1 = "o1", V3 = "o2", V5 = "o3", V7 = "o4", V9 = "o5", V11 = "o6", V13 = "o7", V15 = "o8"))

trajy <- traj_k64_raw %>% 
  select(V2,V4,V6,V8,V10,V12,V14,V16,t) %>% 
  gather(key = "object", value = "ycoord", -t) %>% 
  mutate(object = recode(object, V2 = "o1", V4 = "o2", V6 = "o3", V8 = "o4", V10 = "o5", V12 = "o6", V14 = "o7", V16 = "o8"))

traj_k64 <- trajx %>% 
  left_join(trajy, by = c("t", "object")) %>% 
  mutate(type = if_else(object == "o1", "target", "distractor"))
  
  
p <- traj_k64 %>% 
  filter(t > 10) %>%
  filter(object %in% c("o1","o2","o7","o4","o5")) %>% 
  ggplot(aes(xcoord, ycoord, group = object)) + 
  geom_path(size = 0.5) + 
  theme(aspect.ratio = 1) + 
  xlim(-15,15) +
  ylim(-15,15) +
  #scale_linetype_manual(values=c("solid", "solid")) + 
  geom_point(data = traj_k64 %>% filter(t==max(t), object %in% c("o2","o7","o4","o5")), aes(xcoord, ycoord, fill = type), size = 4, shape = 16, show.legend=FALSE) +
  geom_point(data = traj_k64 %>% filter(t==max(t), object %in% c("o1")), aes(xcoord, ycoord, fill = type), size = 4, shape = 1, show.legend=FALSE) +
  #geom_point(data = traj_k64 %>% filter(t==max(t),object %in% c("o1","o2","o7","o4","o5")), aes(xcoord, ycoord, fill = type), size = 4, shape = 16, show.legend=FALSE) +
  guides(color = FALSE) +
  xlab("x [deg]") +
  ylab("y [deg]") +
  ggtitle(expression("Target's "*kappa~"= 4; Distractors' "*kappa~"= 64"))

ggsave(here::here("..", "plots", "scheme_trial_example.png"), p, width = 6, height = 6)
