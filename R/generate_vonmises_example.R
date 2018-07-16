
# create data -------------------------------------------------------------
set.seed(180307)

library(tidyverse)

if(!require(circular)) {install.packages("circular"); library(circular)}

nDot  <- 1000L
t     <- 30
kappa <- 16
spd <- 1

ang <- rvonmises(nDot, circular(0), kappa, control.circular=list(units="degrees"))

y <- cos(ang)
x <- sin(ang)

df <- data_frame(id = 1:nDot, x, y, t = 1, ang)

for(i in 1:t){
  ang <- rvonmises(nDot,circular(0), kappa, control.circular=list(units="degrees"))

  y <- cos(ang)
  x <- sin(ang)
  tmp <- data_frame(id = 1:nDot,x, y, t=i, ang)
  df <- rbind(df, tmp)  
}

df2 <- df %>% 
  group_by(id) %>% 
  mutate(x = cumsum(x), y = cumsum(y)) %>% 
  ungroup()

df2 %>% 
  filter(id < 6) %>% 
  ggplot(aes(x,y, col = as.factor(id))) + 
  geom_path() + 
  theme(aspect.ratio = 1) +
  xlim(-10,10)+
  ylim(-10,10)


# another take ------------------------------------------------------------

nDot <- 10000

ang_k16 <- rvonmises(nDot, circular(0), 16, control.circular=list(units="degrees"))
h <- hist(as.numeric(ang_k16),plot = F, breaks = 0:360)
h$counts
data <- data_frame(
  id = 1:360,
  ang_bin = h$counts
)

# Make the plot
p <- ggplot(data, aes(x=as.factor(id), y=ang_bin)) +       # Note that id is a factor. If x is numeric, there is some space between the first bar
  
  # This add the bars with a blue color
  geom_bar(stat = "identity", fill = "black", width = 1) +
coord_polar(start = 0) + 
  scale_x_discrete(breaks = seq(0, 360), labels = seq(0, 360)) +
  theme(
    axis.text = element_blank()
    
  )
  # Limits of the plot = very important. The negative value controls the size of the inner circle, the positive one is useful to add size over each bar
  ylim(-100,120) +
  
  # Custom the theme: no axis title and no cartesian grid
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-2,4), "cm")     # This remove unnecessary margin around plot
  ) +
  
  # This makes the coordinate polar instead of cartesian.
  coord_polar(start = 0)
p

