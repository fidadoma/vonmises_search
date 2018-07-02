rm(list = ls())

masterseed <- 198765

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
  ks <- c(2, 4, 8, 16, 64)
  stopifnot((n - 2) %% length(ks) == 0)
  
  dfx <- rbind(expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks),expand.grid(ks, ks)) 
  dfx <- dfx[sample(1:nrow(dfx)),]
  
  p$trialType <- c(sample(ks,2), dfx[,1]) 
  p$trialid   <- sample(n) 
  p$rest_k   <- c(sample(ks,2), dfx[,2])
  p$file      <- sprintf("../trajectories/T%03d_%d_rest%d.csv", p$trialid, p$trialType, p$rest_k)
    
  return(p)
}

for (i in 1:100) {
  p <- create.protocol(i)
  write.csv(p,sprintf("../data/exp2/protocols/P%03d.csv", i), row.names = F)
}
