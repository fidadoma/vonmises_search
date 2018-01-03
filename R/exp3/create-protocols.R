rm(list = ls())

masterseed <- 18766

create.protocol <- function(pid) {
  set.seed(masterseed + pid)
  n <- 198
  p <- data.frame(pid = rep(pid, n),
                  block = c(0,0,rep(1:4, each = (n - 2) / 4)),
                  trial = 1:n,
                  file = character(n),
                  trialid = numeric(n),
                  trialType = numeric(n),                  
                  rest_k = numeric(n),
                  stringsAsFactors = F)
  ks <- c(0.005, 0.01, 0.02, 0.03, 0.04, 0.06, 0.08)
  stopifnot((n - 2) %% length(ks) == 0)
  p$trialType <- c(sample(ks,2), sample(rep(ks, each = (n - 2) / length(ks)))) 
  p$trialid   <- sample(n) 
  p$rest_k   <- c(0.02,0.04,sample(c(rep(0.02,(n - 2) / 2), rep(0.04, (n - 2) / 2))))
  p$file      <- sprintf("../trajectories/T%03d_%.03f_rest%.03f.csv", p$trialid, p$trialType, p$rest_k)
    
  return(p)
}

for (i in 1:100) {
  p <- create.protocol(i)
  write.csv(p,sprintf("../data/exp3/protocols/P%03d.csv", i), row.names = F)
}
