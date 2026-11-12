## Independent hand-check of the Lo (2008) decomposition and the bootstrap indexing
set.seed(1)
n <- 40; bl <- 5
I <- rbinom(n,1,0.6); x <- rnorm(n,0.002,0.02)
f <- mean(I)
mu       <- mean(I*x)*52
baseline <- f*mean(x)*52
tau      <- mean((I-f)*x)*52
cov_n    <- sum((I-mean(I))*(x-mean(x)))/n * 52     # denominator n, as specified
cat("=== 1. IDENTITY  52*mean(Ix) = 52*f*mean(x) + 52*cov_n(I,x) ===\n")
cat(sprintf("   mu %.10f | baseline+tau %.10f | diff %.2e\n", mu, baseline+tau, abs(mu-baseline-tau)))
cat(sprintf("   tau %.10f | cov_n*52 %.10f | diff %.2e  -> tau IS the n-denominator covariance\n",
            tau, cov_n, abs(tau-cov_n)))
cat(sprintf("   (R's cov() uses n-1: %.10f, which is NOT what is used)\n", cov(I,x)*52))
cat("\n=== 2. AVERAGING POSITIONS == MEAN OF PER-RULE COVARIANCES ===\n")
P <- matrix(rbinom(n*7,1,0.5), n, 7)
per_rule <- apply(P,2,function(p) mean(p*x)-mean(p)*mean(x))
qbar <- rowMeans(P)
agg  <- mean(qbar*x)-mean(qbar)*mean(x)
cat(sprintf("   mean of 7 per-rule covariances %.12f\n   covariance of the averaged position %.12f\n   diff %.2e  -> identical, as claimed\n",
            mean(per_rule), agg, abs(mean(per_rule)-agg)))
cat("\n=== 3. CIRCULAR BLOCK INDEXING ===\n")
starts <- c(3L, 38L, 1L)
ii <- as.vector(t(outer(starts-1L,0:(bl-1L),'+')))%%n+1L
cat("   starts:", starts, "| block length", bl, "\n   indices:", ii, "\n")
cat("   block 1 consecutive?", all(diff(ii[1:5])==1), "\n")
cat("   block 2 wraps 38,39,40,1,2?", paste(ii[6:10],collapse=","), "\n")
cat("   -> consecutive within block and circular at the boundary: CORRECT\n")
cat("\n=== 4. ANNUALISATION ===\n")
cat("   weekly mean x52. For a mean-return decomposition this is the standard linear\n")
cat("   annualisation and is internally consistent across mu, baseline and tau.\n")
