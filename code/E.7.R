suppressPackageStartupMessages(library(quantmod))
root <- getwd()
outdir <- file.path(root, 'additional_outputs')
dir.create(outdir, recursive=TRUE, showWarnings=FALSE)
assets <- c('SPY','GLD')
windows <- list('2006-2009'=c(2006,2009), '2010-2014'=c(2010,2014), '2015-2019'=c(2015,2019), '2020-2024'=c(2020,2024))
mdd <- function(r) { w <- c(1,cumprod(1+r)); max(1-w/cummax(w)) }
allrows <- timing <- recon <- list()
xs <- qs <- qfs <- list()
for(asset in assets) {
 e <- readRDS(file.path(root,'inputs',paste0(asset,'_inputs.rds')))
 rates <- na.locf(na.locf(e$DTB3),fromLast=TRUE)
 rf <- (1+as.numeric(rates[findInterval(e$d,index(rates))])/100)^(1/52)-1
 pos <- e$alls2
 keep <- complete.cases(pos) & is.finite(e$R) & is.finite(rf)
 pos <- pos[keep,,drop=FALSE]; r <- as.numeric(e$R[keep]); rf <- rf[keep]
 dates <- as.Date(e$d[keep]); yr <- as.integer(format(dates,'%Y'))
 stopifnot(length(r)==991,all(pos %in% c(0,1)))
 jj <- grepl('^(MA|TRB|MACD|ROC)\\(',colnames(pos))
 p <- pos[,jj,drop=FALSE]; stopifnot(ncol(p)==37)
 x <- r-rf
 xs[[asset]] <- x; qs[[asset]] <- rowMeans(p)
 fam <- sub('\\(.*','',colnames(p))
 qfs[[asset]] <- rowMeans(sapply(unique(fam),function(f) rowMeans(p[,fam==f,drop=FALSE])))
 if(asset=='SPY') common_dates <- dates else stopifnot(identical(dates,common_dates))
 for (period in c('Full',names(windows))) {
  ix <- if(period=='Full') seq_along(r) else which(yr>=windows[[period]][1]&yr<=windows[[period]][2])
  pp <- p[ix,,drop=FALSE]; xx <- x[ix]; rr <- r[ix]; cc <- rf[ix]
  f <- colMeans(pp)
  strat <- pp*xx+cc
  mix <- outer(xx,f)+cc
  dr <- apply(strat,2,mdd); dm <- apply(mix,2,mdd)
  z <- data.frame(Asset=asset,Period=period,Rule=colnames(p),N=length(ix),Exposure=f,Rule_MDD=dr,Matched_MDD=dm,Advantage=dm-dr)
  pi <- match(period,names(windows))
  if(!is.na(pi)&&pi>1) {
   prev <- windows[[pi-1]]
   fprev <- colMeans(p[yr>=prev[1]&yr<=prev[2],,drop=FALSE])
   z$Prior_exposure <- fprev
   z$Prior_MDD <- apply(outer(xx,fprev)+cc,2,mdd)
  } else {z$Prior_exposure<-NA_real_;z$Prior_MDD<-NA_real_}
  allrows[[paste(asset,period)]] <- z
  mu <- colMeans(pp*xx)*52; baseline <- f*mean(xx)*52
  tau <- colMeans(sweep(pp,2,f)*xx)*52
  stopifnot(max(abs(mu-baseline-tau))<1e-12)
  timing[[paste(asset,period)]] <- data.frame(Asset=asset,Period=period,Rule=colnames(p),Exposure=f,Rule_mean=mu,Matched_mean=baseline,Timing=tau)
  if(period=='Full') recon[[asset]]<-data.frame(Asset=asset,Rule=colnames(p),Original_MDD=apply(strat,2,function(v)e$maxDDD(cumprod(1+v)-1)$maxDD),Standard_MDD=dr)
 }
}
z<-do.call(rbind,allrows);t<-do.call(rbind,timing)
write.csv(z,file.path(outdir,'drawdown_all.csv'),row.names=FALSE)
write.csv(t,file.path(outdir,'timing_all.csv'),row.names=FALSE)
write.csv(do.call(rbind,recon),file.path(outdir,'drawdown_convention_check.csv'),row.names=FALSE)
summ<-do.call(rbind,lapply(split(z,list(z$Asset,z$Period),drop=TRUE),function(v) data.frame(Asset=v$Asset[1],Period=v$Period[1],N=v$N[1],Lower=sum(v$Advantage>0),Median_rule=median(v$Rule_MDD),Median_matched=median(v$Matched_MDD),Median_paired_advantage=median(v$Advantage),Prior_lower=if(all(is.na(v$Prior_MDD)))NA else sum(v$Rule_MDD<v$Prior_MDD),Prior_median_advantage=median(v$Prior_MDD-v$Rule_MDD))))
write.csv(summ,file.path(outdir,'drawdown_summary.csv'),row.names=FALSE)
# Bootstrap the sample covariance, retaining paired data and re-estimating means.
X <- do.call(cbind,xs); Q <- do.call(cbind,qs); QF<-do.call(cbind,qfs)
stat <- function(ii,q) 52*(colMeans(q[ii,,drop=FALSE]*X[ii,,drop=FALSE])-colMeans(q[ii,,drop=FALSE])*colMeans(X[ii,,drop=FALSE]))
n<-nrow(X);B<-10000L
ci<-list()
for(bl in c(5L,13L,26L)) {
 set.seed(260905L+bl)
 boot<-matrix(NA_real_,B,4)
 for(b in seq_len(B)) {
  starts<-sample.int(n,ceiling(n/bl),replace=TRUE)
  ii<-as.vector(t(outer(starts-1L,0:(bl-1L),'+')))%%n+1L
  ii<-ii[seq_len(n)]
  boot[b,]<-c(stat(ii,Q),stat(ii,QF))
 }
 estimates<-c(stat(seq_len(n),Q),stat(seq_len(n),QF))
 lim<-apply(boot,2,quantile,probs=c(.025,.975))
 ci[[as.character(bl)]]<-data.frame(Asset=rep(assets,2),Weighting=rep(c('Equal_rule','Equal_family'),each=2),Block=bl,B=B,Timing=estimates,Lower=lim[1,],Upper=lim[2,])
}
ci<-do.call(rbind,ci)
write.csv(ci,file.path(outdir,'timing_intervals.csv'),row.names=FALSE)
capture.output(sessionInfo(),file=file.path(outdir,'sessionInfo.txt'))
print(summ,row.names=FALSE);print(ci,row.names=FALSE)
cat('Convention maximum difference:',max(abs(do.call(rbind,recon)$Original_MDD-do.call(rbind,recon)$Standard_MDD)),'\n')
