library(quantmod); library(moments); library(tseries)
 
if (!exists("spy_prices")) spy_prices <- getSymbols("SPY", src = "yahoo", from = "2005-01-01", to = "2024-12-31",
                  periodicity = "weekly", auto.assign = FALSE)
if (!exists("gld_prices")) gld_prices <- getSymbols("GLD", src = "yahoo", from = "2005-01-01", to = "2024-12-31",
                  periodicity = "weekly", auto.assign = FALSE)
 
spy <- spy_prices
gld <- gld_prices
rs <- na.omit(merge(diff(log(Ad(spy))), diff(log(Ad(gld)))))
rs <- exp(rs) - 1; colnames(rs) <- c("SPY", "GLD")
 
dist <- data.frame(
  Median_weekly   = apply(rs, 2, median),
  Skewness        = apply(rs, 2, skewness),
  Excess_kurtosis = apply(rs, 2, kurtosis) - 3,
  JB_statistic    = apply(rs, 2, function(x) as.numeric(jarque.bera.test(x)$statistic)),
  JB_pvalue       = apply(rs, 2, function(x) jarque.bera.test(x)$p.value))
write.csv(dist, "DISTRIBUTION_STATS.csv")
write.csv(round(cor(rs), 4), "CORRELATION_TABLE.csv")
 
p  <- na.omit(merge(Ad(spy), Ad(gld))); colnames(p) <- c("SPY", "GLD")
pn <- 100 * sweep(as.matrix(p), 2, as.numeric(p[1, ]), "/")
pdf("9_Price_Series.pdf", height = 6, width = 10)
plot(index(p), pn[, 1], type = "l", lwd = 2, col = "black", ylim = range(pn),
     xlab = "", ylab = "Index (first week = 100)")
lines(index(p), pn[, 2], lwd = 2, col = "red")
legend("topleft", legend = c("SPY", "GLD"), col = c("black", "red"), lty = 1, lwd = 2)
dev.off()
