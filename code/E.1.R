# ---- Risk-free rate and return construction ----
library("zoo")
library("quantmod")
if (!exists("DTB3")) {
  DTB3 <- getSymbols("DTB3", src = "FRED", auto.assign = FALSE)
}
DTB3 <- na.locf(na.locf(DTB3), fromLast = TRUE)      # carry rate over holidays
rf_idx <- findInterval(d, index(DTB3))               # last rate on or before each week
rf_ann <- as.numeric(DTB3[rf_idx]) / 100
rf_wk  <- (1 + rf_ann)^(1/52) - 1                    # weekly equivalent
 
dimnames(alls2) <- dimnames(alls)
RMAT  <- matrix(R,     NROW(R), NCOL(alls2))
RFMAT <- matrix(rf_wk, NROW(R), NCOL(alls2))
Rstrat_total  <- alls2*RMAT + (1 - alls2)*RFMAT      # asset when in, T-bill when out
Rstrat_excess <- alls2*(RMAT - RFMAT)                # excess over T-bill
Rstrat <- Rstrat_excess                              # excess drives Sharpe and LW test

