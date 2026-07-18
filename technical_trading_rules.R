# Technical Trading Rules — Profitability Analysis
# Backtesting framework across SPY / GLD, weekly data 2005–2024
# Methodology follows Gerritsen et al. (2020); LW (2008) Sharpe test via PeerPerformance

rm(list = ls(all = TRUE))
setwd("~/Desktop/dissertation kings/results code/GLD")

library("TTR")
library("quantmod")

# ---- Configuration ----
ticker     <- "SPY"
start.date <- "2005-01-01"
end.date   <- "2024-12-31"
tfrequency <- "weekly"
short_sell <- FALSE

# ---- Trading rule parameters (7 indicator families, Gerritsen et al. 2020 Sec 2.1) ----

# Family 1a: Single moving averages. Rule: price >= MA -> long; price < MA -> short/flat
MAtype <- "exponential"
MAr    <- c(2, 4, 12, 24, 52)

# Family 1b: Dual moving averages (fast vs slow). Rule: fast >= slow -> long
MAfast <- c(2,  2,  2,  2,  4,  4,  4, 12, 12, 24)
MAslow <- c(4, 12, 24, 52, 12, 24, 52, 24, 52, 52)

# Family 2: Trading Range Breakout
TRB <- c(4, 8, 12, 24, 38, 52)

# Family 3: MACD (reuses MAfast/MAslow pairs)
MACDsignal <- 12

# Family 4: Rate of Change
ROCp <- c(4, 8, 12, 24, 38, 52)

# Family 5: On-Balance Volume (reuses MAfast/MAslow)

# Family 6: RSI (standard 30/70 thresholds)
RSIp <- c(2, 4, 8, 12, 24, 38, 52)

# Family 7: Bollinger Bands (lookback + standard deviation pairs)
BBma <- c(2, 4, 8, 12, 24, 2, 4, 8, 12, 24)
BBsd <- c(1, 1, 1,  1,  1, 2, 2, 2,  2,  2)

# ============================================================
# No configuration needed below this point
# ============================================================

# Figure parameters
wwidth    <- 11.7
hheight   <- 8.3
linewidth <- 3
colz      <- c("black", "#e31a1c", "#1f78b4", "#33a02c", "#6a3d9a")

# ---- Load data from Yahoo Finance ----
xdata <- getSymbols(ticker, src = "yahoo", from = start.date, to = end.date,
                    periodicity = tfrequency, auto.assign = FALSE)
xdataxts <- xdata
xdata <- as.matrix(xdata)
colnames(xdata) <- c("O", "H", "L", "C", "Vol", "Adj")
d   <- as.Date(rownames(xdata))
dch <- as.character(d)
rownames(xdata) <- dch

# ---- Returns (from adjusted prices) ----
log.ret <- function(x) diff(log(x))
pch.ret <- function(x) exp(log.ret(x)) - 1

R <- as.matrix(c(NA, pch.ret(xdata[, "Adj"])))
rownames(R) <- dch
colnames(R) <- "Ret"

# ---- Family 1a: single MA signals ----
pdf("1a_MA_single.pdf", height = hheight, width = wwidth)
sMA <- matrix(NA, NROW(xdata), NROW(MAr))
rownames(sMA) <- dch
colnames(sMA) <- paste("MA(", MAr, ")", sep = "")
xduse <- xdata[, "Adj"]
for (i in 1:NROW(MAr)) {
  if (MAtype == "simple")      xtemp <- SMA(xduse, n = MAr[i])
  if (MAtype == "weighted")    xtemp <- WMA(xduse, n = MAr[i])
  if (MAtype == "exponential") xtemp <- WMA(xduse, n = MAr[i])

  xsignal <- rep(0, NROW(xduse))
  xsignal[xduse > xtemp] <-  1
  xsignal[xduse < xtemp] <- -1
  sMA[, i] <- xsignal

  plot(d, xduse, main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sMA)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xduse, lwd = linewidth, col = colz[1])
  lines(d, xtemp, lwd = linewidth, col = colz[2])
  legend("topleft", lty = c(1, 1), col = colz[1:2], legend = c("Price", "MA"),
         cex = 0.7, lwd = rep(linewidth, 2), bg = "white")
}
dev.off()

# ---- Family 1b: dual MA signals ----
pdf("1b_MA_dual.pdf", height = hheight, width = wwidth)
sMA2 <- matrix(NA, NROW(xdata), NROW(MAfast))
rownames(sMA2) <- dch
colnames(sMA2) <- paste("MA(", MAfast, ",", MAslow, ")", sep = "")
xduse <- xdata[, "Adj"]
for (i in 1:NROW(MAfast)) {
  if (MAtype == "simple") {
    xtemp1 <- SMA(xduse, n = MAfast[i]); xtemp2 <- SMA(xduse, n = MAslow[i])
  }
  if (MAtype == "weighted") {
    xtemp1 <- WMA(xduse, n = MAfast[i]); xtemp2 <- WMA(xduse, n = MAslow[i])
  }
  if (MAtype == "exponential") {
    xtemp1 <- EMA(xduse, n = MAfast[i]); xtemp2 <- EMA(xduse, n = MAslow[i])
  }

  xsignal <- rep(0, NROW(xduse))
  xsignal[xtemp1 > xtemp2] <-  1
  xsignal[xtemp1 < xtemp2] <- -1
  sMA2[, i] <- xsignal

  plot(d, xduse, main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sMA2)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xduse,  lwd = linewidth, col = colz[1])
  lines(d, xtemp1, lwd = linewidth, col = colz[2])
  lines(d, xtemp2, lwd = linewidth, col = colz[3])
  legend("topleft", lty = c(1, 1, 1), col = colz[1:3], legend = c("Price", "MA_Fast", "MA_Slow"),
         cex = 0.7, lwd = rep(linewidth, 2), bg = "white")
}
dev.off()

# ---- Family 2: Trading Range Breakout ----
pdf("2_TRB.pdf", height = hheight, width = wwidth)
sTRB <- matrix(NA, NROW(xdata), NROW(TRB))
rownames(sTRB) <- dch
colnames(sTRB) <- paste("TRB(", TRB, ")", sep = "")
xduse <- xdata[, "Adj"]
for (i in 1:NROW(TRB)) {
  xlook <- TRB[i]
  xsup <- xres <- xsignal <- NULL
  for (j in 1:NROW(xduse)) {
    xusei <- (j - xlook):(j - 1)
    if (min(xusei) <= 0) {
      xsup <- c(xsup, NA); xres <- c(xres, NA); xsignal <- c(xsignal, NA)
    } else {
      xmin <- min(xduse[xusei]); xmax <- max(xduse[xusei])
      xsup <- c(xsup, xmin); xres <- c(xres, xmax)
      xstemp <- 0
      if (xduse[j] > xmax) xstemp <-  1
      if (xduse[j] < xmin) xstemp <- -1
      xsignal <- c(xsignal, xstemp)
    }
  }
  sTRB[, i] <- xsignal

  plot(d, xduse, main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sTRB)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xduse, lwd = linewidth, col = colz[1])
  lines(d, xsup,  lwd = linewidth, col = colz[2])
  lines(d, xres,  lwd = linewidth, col = colz[3])
  legend("topleft", lty = c(1, 1, 1), col = colz[1:3], legend = c("Price", "Support", "Resistance"),
         cex = 0.7, lwd = rep(linewidth, 2), bg = "white")
}
dev.off()

# ---- Family 3: MACD ----
pdf("3_MACD.pdf", height = hheight, width = wwidth)
sMACD <- matrix(NA, NROW(xdata), NROW(MAfast))
rownames(sMACD) <- dch
colnames(sMACD) <- paste("MACD(", MAfast, ",", MAslow, ",", MACDsignal, ")", sep = "")
xduse <- xdata[, "Adj"]
if (MAtype == "simple")      xmatype <- "SMA"
if (MAtype == "weighted")    xmatype <- "WMA"
if (MAtype == "exponential") xmatype <- "EMA"
for (i in 1:NROW(MAfast)) {
  xtemp <- MACD(xduse, nFast = MAfast[i], nSlow = MAslow[i], nSig = MACDsignal,
                percent = FALSE, maType = xmatype)

  xsignal <- rep(0, NROW(xduse))
  xsignal[(xtemp[, 1] - xtemp[, 2]) > 0] <-  1
  xsignal[(xtemp[, 1] - xtemp[, 2]) < 0] <- -1
  sMACD[, i] <- xsignal

  plot(d, xtemp[, 1], main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sMACD)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xtemp[, 1], lwd = linewidth, col = colz[1])
  lines(d, xtemp[, 2], lwd = linewidth, col = colz[2])
  legend("topleft", lty = c(1, 1), col = colz[1:2], legend = c("MACD", "Signal"),
         cex = 0.7, lwd = rep(linewidth, 2), bg = "white")
}
dev.off()

# ---- Family 4: Rate of Change ----
pdf("4_ROC.pdf", height = hheight, width = wwidth)
sROC <- matrix(NA, NROW(xdata), NROW(ROCp))
rownames(sROC) <- dch
colnames(sROC) <- paste("ROC(", ROCp, ")", sep = "")
xduse <- xdata[, "Adj"]
for (i in 1:NROW(ROCp)) {
  xtemp <- ROC(xduse, n = ROCp[i])

  xsignal <- rep(0, NROW(xduse))
  xsignal[xtemp > 0] <-  1
  xsignal[xtemp < 0] <- -1
  sROC[, i] <- xsignal

  plot(d, xtemp, main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sROC)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xtemp, lwd = linewidth, col = colz[1])
  abline(h = 0, col = colz[2], lwd = linewidth)
  legend("topleft", lty = c(1), col = colz[1], legend = c("ROC"),
         cex = 0.7, lwd = rep(linewidth, 1), bg = "white")
}
dev.off()

# ---- Family 5: OBV with MA crossover ----
pdf("5_OBV_MA.pdf", height = hheight, width = wwidth)
sOBV <- matrix(NA, NROW(xdata), NROW(MAfast))
rownames(sOBV) <- dch
colnames(sOBV) <- paste("OBV(", MAfast, ",", MAslow, ")", sep = "")
xduse <- as.matrix(OBV(xdataxts[, 6], xdataxts[, 5]))
for (i in 1:NROW(MAfast)) {
  if (MAtype == "simple") {
    xtemp1 <- SMA(xduse, n = MAfast[i]); xtemp2 <- SMA(xduse, n = MAslow[i])
  }
  if (MAtype == "weighted") {
    xtemp1 <- WMA(xduse, n = MAfast[i]); xtemp2 <- WMA(xduse, n = MAslow[i])
  }
  if (MAtype == "exponential") {
    xtemp1 <- EMA(xduse, n = MAfast[i]); xtemp2 <- EMA(xduse, n = MAslow[i])
  }

  xsignal <- rep(0, NROW(xduse))
  xsignal[xtemp1 > xtemp2] <-  1
  xsignal[xtemp1 < xtemp2] <- -1
  sOBV[, i] <- xsignal

  plot(d, xduse, main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sOBV)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xduse,  lwd = linewidth, col = colz[1])
  lines(d, xtemp1, lwd = linewidth, col = colz[2])
  lines(d, xtemp2, lwd = linewidth, col = colz[3])
  legend("topleft", lty = c(1, 1, 1), col = colz[1:3], legend = c("OBV", "MA_Fast", "MA_Slow"),
         cex = 0.7, lwd = rep(linewidth, 2), bg = "white")
}
dev.off()

# ---- Family 6: RSI ----
pdf("6_RSI.pdf", height = hheight, width = wwidth)
sRSI <- matrix(NA, NROW(xdata), NROW(RSIp))
rownames(sRSI) <- dch
colnames(sRSI) <- paste("RSI(", RSIp, ")", sep = "")
xduse <- xdata[, "Adj"]
for (i in 1:NROW(RSIp)) {
  xtemp <- RSI(xduse, n = RSIp[i], maType = xmatype)
  xsignal <- rep(0, NROW(xtemp))
  xsignal[xtemp > 70] <-  1
  xsignal[xtemp < 30] <- -1
  sRSI[, i] <- xsignal

  plot(d, xtemp, main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sRSI)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xtemp, lwd = linewidth, col = colz[1])
  abline(h = 30, col = colz[2], lwd = linewidth)
  abline(h = 70, col = colz[3], lwd = linewidth)
  legend("topleft", lty = c(1), col = colz[1], legend = c("RSI"),
         cex = 0.7, lwd = rep(linewidth, 1), bg = "white")
}
dev.off()

# ---- Family 7: Bollinger Bands ----
pdf("7_BB.pdf", height = hheight, width = wwidth)
sBB <- matrix(NA, NROW(xdata), NROW(BBma))
rownames(sBB) <- dch
colnames(sBB) <- paste("BB(", BBma, ",", BBsd, ")", sep = "")
xduse <- xdata[, "C"]
for (i in 1:NROW(BBma)) {
  xtemp <- as.matrix(BBands(xdataxts[, 2:4], n = BBma[i], maType = xmatype, sd = BBsd[i]))

  xsignal <- rep(0, NROW(xtemp))
  xsignal[xduse < xtemp[, 1]] <-  1
  xsignal[xduse > xtemp[, 3]] <- -1
  sBB[, i] <- xsignal

  plot(d, xduse, main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(sBB)[i])
  grid(col = "grey", lwd = linewidth)
  lines(d, xduse,      lwd = linewidth, col = colz[1])
  lines(d, xtemp[, 1], lwd = linewidth, col = colz[2])
  lines(d, xtemp[, 3], lwd = linewidth, col = colz[3])
  lines(d, xtemp[, 2], lwd = linewidth, col = colz[4])
  legend("topleft", lty = c(1, 1, 1, 1), col = colz[1:4],
         legend = c("Price", "BB_Lower", "BB_Upper", "BB_MA"),
         cex = 0.7, lwd = rep(linewidth, 1), bg = "white")
}
dev.off()

# ---- Combine all signals; column 1 is buy-and-hold benchmark ----
alls   <- cbind(sMA, sMA2, sTRB, sMACD, sROC, sOBV, sRSI, sBB)
cnames <- colnames(alls)
bnh    <- rep(1, NROW(alls))
alls   <- cbind(bnh, alls)
colnames(alls) <- c(ticker, cnames)

# Disallow short positions if configured
if (short_sell == FALSE) alls[alls == -1] <- 0

# Apply one-period signal lag before computing strategy returns
alls2  <- rbind(matrix(0, 1, NCOL(alls)), alls[1:(NROW(alls) - 1), ])
RMAT   <- matrix(R, NROW(R), NCOL(alls2))
Rstrat <- RMAT * alls2

# ---- Drawdown function (depth and duration) ----
maxDDD <- function(cumret, doplot = F, ...) {
  N <- NROW(cumret)
  highmark <- matrix(0, N, 1)
  drawdown <- matrix(0, N, 1)
  duration <- matrix(0, N, 1)

  for (i in seq(2, N, 1)) {
    highmark[i] <- max(c(highmark[i - 1], cumret[i]))
    drawdown[i] <- 1 - (1 + cumret[i]) / (1 + highmark[i])
    if (drawdown[i] == 0) duration[i] <- duration[i - 1]
    else                  duration[i] <- duration[i - 1] + 1
  }

  to   <- which.max(drawdown)
  from <- double(NROW(to))
  for (i in 1:NROW(to)) from[i] <- max(which(drawdown[1:to[i]] == 0))

  list(drawdown = drawdown, duration = duration,
       maxDD = max(drawdown), maxD = max(duration), maxFrom = from, maxTo = to)
}

# ---- Performance statistics (datatype: 252 daily, 52 weekly, 12 monthly) ----
matrix.stats <- function(out, datatype) {
  mu   <- apply(out, 2, mean) * datatype
  sg   <- apply(out, 2, sd) * sqrt(datatype)
  sr   <- mu / sg
  maxr <- apply(out, 2, max)
  minr <- apply(out, 2, min)
  cret <- apply(1 + out, 2, cumprod) - 1
  cumr <- cret[NROW(cret), ]
  maxDD <- apply(cret, 2, function(x) maxDDD(x)$maxDD)
  maxDu <- apply(cret, 2, function(x) maxDDD(x)$maxD)

  # Profit/loss ratio, win rate, expectation index
  pwp <- function(ret) {
    pnl     <- abs(mean(subset(ret, ret > 0)) / mean(subset(ret, ret < 0)))
    winrate <- sum(ret > 0, na.rm = T) / length(na.omit(ret))
    expind  <- (1 + abs(pnl)) * winrate - 1
    c(pnl, winrate, expind)
  }

  pnl <- apply(out, 2, function(x) pwp(x)[1])
  wnr <- apply(out, 2, function(x) pwp(x)[2])
  exi <- apply(out, 2, function(x) pwp(x)[3])

  stats <- rbind(mu, sg, sr, maxr, minr, cumr, maxDD, maxDu, pnl, wnr, exi)
  rownames(stats) <- c("Average", "Volatility", "Sharpe", "Max", "Min", "Cumulative",
                       "Drawdown", "Duration", "Profit/Loss", "Win Rate", "Expectation")
  colnames(stats) <- colnames(out)

  list(statistics = stats, cum.return = cret)
}

if (tfrequency == "daily")   xdtp <- 252
if (tfrequency == "weekly")  xdtp <- 52
if (tfrequency == "monthly") xdtp <- 12

out <- matrix.stats(na.omit(Rstrat), xdtp)
write.csv(t(out$statistics), "STATISTICS.csv")

# ---- Cumulative return plots (each rule vs buy-and-hold) ----
pdf("8_Cumulative_Return.pdf", height = hheight, width = wwidth)
outcret <- out$cum.return
dd <- as.Date(rownames(outcret))
for (i in 1:NCOL(outcret)) {
  if (i == 1) {
    plot(dd, outcret[, 1], main = ticker, xlab = "", ylab = "", type = "n", sub = colnames(outcret)[i])
    grid(col = "grey", lwd = linewidth)
    abline(h = 0, col = "grey", lwd = linewidth)
    lines(dd, outcret[, 1], lwd = linewidth, col = colz[1])
    legend("topleft", lty = c(1), col = colz[1], legend = c(ticker),
           cex = 0.7, lwd = rep(linewidth, 1), bg = "white")
  } else {
    xx <- outcret[, c(1, i)]
    xxlims <- c(min(xx), max(xx))
    plot(dd, xx[, 1], main = ticker, xlab = "", ylab = "", type = "n",
         sub = colnames(outcret)[i], ylim = xxlims)
    grid(col = "grey", lwd = linewidth)
    abline(h = 0, col = "grey", lwd = linewidth)
    lines(dd, xx[, 1], lwd = linewidth, col = colz[1])
    lines(dd, xx[, 2], lwd = linewidth, col = colz[2])
    legend("topleft", lty = c(1, 1), col = colz[1:2],
           legend = c(ticker, colnames(outcret)[i]),
           cex = 0.7, lwd = rep(linewidth, 2), bg = "white")
  }
}
dev.off()

# ============================================================
# Ledoit-Wolf (2008) test on Sharpe differences vs buy-and-hold
# Studentised circular block bootstrap, HAC standard errors
# ============================================================
# install.packages("PeerPerformance")
library("PeerPerformance")

colnames(Rstrat) <- colnames(alls)
Rstrat <- na.omit(Rstrat)

# Run the LW Sharpe test for every rule against buy-and-hold
runLW <- function(Rmat) {
  bh    <- Rmat[, 1]              # buy-and-hold benchmark
  rules <- colnames(Rmat)[-1]
  res   <- data.frame(Rule = rules, Sharpe = NA, BH_Sharpe = NA,
                      Diff = NA, p_value = NA)

  for (i in seq_along(rules)) {
    x <- Rmat[, rules[i]]
    y <- bh
    # type=2: studentised circular block bootstrap; nBoot=1000; bBoot=5 block length; HAC errors
    ctr <- list(type = 2, nBoot = 1000, bBoot = 5, hac = TRUE)
    tt  <- tryCatch(sharpeTesting(x, y, control = ctr), error = function(e) NULL)

    sx <- mean(x, na.rm = TRUE) / sd(x, na.rm = TRUE) * sqrt(xdtp)
    sy <- mean(y, na.rm = TRUE) / sd(y, na.rm = TRUE) * sqrt(xdtp)

    res$Sharpe[i]    <- round(sx, 3)
    res$BH_Sharpe[i] <- round(sy, 3)
    res$Diff[i]      <- round(sx - sy, 3)
    res$p_value[i]   <- if (is.null(tt)) NA else round(tt$pval, 3)
  }

  res$sig <- ""
  res$sig[!is.na(res$p_value) & res$p_value < 0.10] <- "*"
  res$sig[!is.na(res$p_value) & res$p_value < 0.05] <- "**"
  res$sig[!is.na(res$p_value) & res$p_value < 0.01] <- "***"
  res
}

# Full sample
set.seed(1234)
full <- runLW(Rstrat)
write.csv(full, "STATISTICS_LW.csv", row.names = FALSE)
print(full)

# Four 5-year subperiods
subperiods <- list(
  "2005-2009" = c("2005-01-01", "2009-12-31"),
  "2010-2014" = c("2010-01-01", "2014-12-31"),
  "2015-2019" = c("2015-01-01", "2019-12-31"),
  "2020-2024" = c("2020-01-01", "2024-12-31")
)

dates  <- as.Date(rownames(Rstrat))
allsub <- NULL
for (nm in names(subperiods)) {
  w   <- subperiods[[nm]]
  sel <- dates >= as.Date(w[1]) & dates <= as.Date(w[2])
  set.seed(1234)
  r <- runLW(Rstrat[sel, , drop = FALSE])
  r$Period <- nm
  allsub <- rbind(allsub, r)
}
write.csv(allsub, "STATISTICS_LW_subperiods.csv", row.names = FALSE)
