rm(list = ls())

masterseed <- 198765111

create.protocol <- function(pid) {
  set.seed(masterseed + pid)
  n <- 202
  p <- data.frame(pid = rep(pid, n),
                  block = c(0,0,rep(1:4, each = (n - 2) / 4)),
                  trial = 1:n,
                  file = character(n),
                  trialid = numeric(n),
                  trialType = numeric(n),                  
                  rest_k = numeric(n),
                  stringsAsFactors = F)
  ks <- c(0.005, 0.01, 0.02, 0.04, 0.08)
  stopifnot((n - 2) %% length(ks) == 0)
  
  dfx <- rbind(expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks)) 
  dfx <- dfx[sample(1:nrow(dfx)),]
  
  p$trialType <- c(sample(ks,2), dfx[,1]) 
  p$trialid   <- sample(n) 
  p$rest_k   <- c(sample(ks,2), dfx[,2])
  p$file      <- sprintf("../trajectories/T%03d_%.03f_rest%.03f.csv", p$trialid, p$trialType, p$rest_k)
    
  return(p)
}

for (i in 1:100) {
  p <- create.protocol(i)
  write.csv(p,sprintf("../data/exp4/protocols/P%03d.csv", i), row.names = F)
}
