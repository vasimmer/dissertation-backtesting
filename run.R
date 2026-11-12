# Run from this directory: Rscript run.R
# Fast diagnostic replay: Rscript run.R --diagnostics
root <- normalizePath('.')
stopifnot(dir.exists(file.path(root, 'inputs')))
required <- c('quantmod','zoo','PeerPerformance','moments','tseries')
missing <- required[!vapply(required, requireNamespace, logical(1), quietly=TRUE)]
if (length(missing)) stop(paste('Install required R packages:',paste(missing,collapse=', ')))
suppressPackageStartupMessages(library(quantmod))
quick <- '--diagnostics' %in% commandArgs(trailingOnly=TRUE)
output <- file.path(root, if (quick) 'diagnostic_replay' else 'replayed_outputs')
dir.create(output,showWarnings=FALSE)
setwd(output)
for (asset in c('SPY','GLD')) {
  list2env(readRDS(file.path(root,'inputs',paste0(asset,'_inputs.rds'))),.GlobalEnv)
  source(file.path(root,'code','E.1.R'))
  if (quick) {
    colnames(Rstrat) <- colnames(alls)
    Rstrat <- na.omit(Rstrat)
    for (suffix in c('_STATISTICS_LW.csv','_STATISTICS_LW_subperiods.csv')) {
      file.copy(file.path(root,'verified_outputs',paste0(asset,suffix)),
                paste0(asset,suffix),overwrite=TRUE)
    }
  } else source(file.path(root,'code','E.2.R'))
  source(file.path(root,'code','E.3.R'))
  source(file.path(root,'code','E.6.R'))
}
spy_prices <- readRDS(file.path(root,'inputs','SPY_prices.rds'))
gld_prices <- readRDS(file.path(root,'inputs','GLD_prices.rds'))
source(file.path(root,'code','E.4.R'))
source(file.path(root,'code','E.5.R'))
writeLines(capture.output(sessionInfo()),'sessionInfo.txt')
cat('Replay complete. Outputs:',output,'\n')
