library(tidyverse)
library(animation)
library(circular)


data_pth <- here::here("..","data", "exp1b", "trajectories")

traj_k64_raw <- read.table(file.path(data_pth, "T001_4_rest64.csv")) %>% 
  as_data_frame() %>% 
  mutate(t=1:n())

trajx <- traj_k64_raw %>% 
  select(V1,V3,V5,V7,V9,V11,V13,V15,t) %>% 
  gather(key = "object", value = "xcoord", -t) %>% 
  mutate(object = recode(object, V1 = "o1", V3 = "o2", V5 = "o3", V7 = "o4", V9 = "o5", V11 = "o6", V13 = "o7", V15 = "o8"))

tt <- list()
class(tt) <- "trajectory"
tt$n <- 8
tt$xlim <- c(-15,15)
tt$ylim <- c(-15,15)
tt$time <- seq(0,(nrow(traj_k64_raw)-1)/100, by = 0.01)
x <- traj_k64_raw %>% select(V1,V3,V5,V7,V9,V11,V13,V15) %>% as.matrix()
colnames(x) <- NULL
y <- traj_k64_raw %>% select(V2,V4,V6,V8,V10,V12,V14,V16) %>% as.matrix()
colnames(y) <- NULL

tt$x <- x
tt$y <- y

# final version was adjusted in inkscape 

# utility functions for trajectory generation -------------------
#   - these function came from motAnalysis package 

snapshot.trajectory <- function(track, time, time.index = NA) {
  if (is.na(time.index)) {
    time.index <- which.min(abs(track$time - time))
  }
  pos <- list(
    n = track$n, xlim = track$xlim, ylim = track$ylim,
    x = track$x[time.index, ],
    y = track$y[time.index, ],
    radius = 0.5
  ) # TODO
  class(pos) <- "positions"
  return(pos)
}



# display functions ---------------------------------------------
xplot.positions <- function(pos, targets = NA, labels = F,
                            legend = F, expand = c(0, 1)) {
  expand.add <- c(-1, +1) * expand[2]
  expand <- as.numeric(na.omit(c(expand, 0, 0))) # add one or two zeros
  width <- diff(pos$xlim)
  height <- diff(pos$ylim)
  margin.x <- width * expand[1]
  margin.y <- height * expand[1]
  xlim.new <- c(
    pos$xlim[1] - margin.x - expand[2],
    pos$xlim[2] + margin.x + expand[2]
  )
  ylim.new <- c(
    pos$ylim[1] - margin.y - expand[2],
    pos$ylim[2] + margin.y + expand[2]
  )
  n <- pos$n
  d <- data.frame(
    dot = factor(1:n), x = pos$x, y = pos$y,
    type = "dot", stringsAsFactors = F
  )
  d$type[d$type != "target"] <- "distractor"
  if (!any(is.na(targets))) {
    d$type[targets] <- "target"
    d$type[d$type != "target"] <- "distractor"
  }
  
  pp <- qplot(x, y,
              data = d,
              geom = "point", colour = type,
              asp = 1, size = I(10)
  ) +
    labs(
      x = "", y = "", title = "",
      colour = "", shape = ""
    ) +
    coord_cartesian(xlim = xlim.new, ylim = ylim.new) +
    scale_y_reverse() +
    scale_color_manual(values = c("#AAAAAA", "#00FF00")) +
    theme(
      rect = element_rect(fill = "white"), text = element_blank(),
      line = element_blank(),
      panel.background = element_rect(fill = "white"),
      plot.background = element_rect(fill = "white")
    )
  if (labels) {
    pp <- pp + geom_text(aes(label = dot),
                         colour = I("black"), size = I(8)
    )
  }
  # better or _no_ legend
  pp <- pp + theme(legend.position = "none")
  return(pp)
}
# xplot.positions(xy, targets = 1:3)

plot.trajectory.x <- function(tr, legend = F, expand = c(1, 1)) {
  expand.add <- c(-1, +1) * expand[2]
  xlim.new <- tr$xlim * expand[1] + expand.add
  ylim.new <- rev(tr$ylim * expand[1] + expand.add)
  n <- tr$n
  d <- long.trajectory(tr)
  pp <- qplot(x, y,
              data = d,
              geom = "point", colour = factor(object), asp = 1
  ) +
    labs(x = "", y = "", title = "") +
    coord_cartesian(xlim = xlim.new, ylim = ylim.new) +
    scale_y_reverse()
  pp <- pp + theme(legend.position = "none")
  pp <- pp + theme()
  return(pp)
}
# plot.trajectory.x(xyt)

make.videox <- function(tt, fname, fps = 25,
                        outdir = getwd(), targets) {
  tmin <- min(tt$time)
  tmax <- max(tt$time)
  tlen <- tmax - tmin
  oopt <- ani.options(
    interval = 1 / fps, nmax = fps * tlen * 2,
    outdir = outdir, ani.width = 1920 / 2, ani.height = 1080 / 2
  )
  saveVideo({
    for (tim in seq(tmin, tmax, 1 / fps)) {
      p <- snapshot.trajectory(tt, tim)
      print(xplot.positions(p, targets = NA))
    }
  }, video.name = fname, other.opts = "-pix_fmt yuv420p -b 300k", clean = T)
  ani.options(oopt)
}

# making videos ------------------------------------------------------------

ani.options(ffmpeg = "c:\Users\dechterenkof\Downloads\ffmpeg-20181205-953bd58-win64-static\bin\ffmpeg") # TODO

xy1 <- random.positions(8)
xyt1 <- vonmises.trajectory(xy1, speed = 5, initial.dir = "runif")
make.videox(xyt1, "video_s05_n1_01.mp4", targets = 1)

make.videox(tt, "video_s05_n1_01.mp4", targets = 1)


