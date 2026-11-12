# Technical Trading Rules in Equity and Commodity Markets (SPY / GLD)

Code and results for my MSc Finance and Analytics dissertation at King's College London (September 2026).

## The question

Do technical trading rules earn a better risk-adjusted return than simply buying and holding the asset, once the test allows for signal lag, trading costs and the number of rules tried?

## The method

- **Data:** 20 years of weekly data (2005–2024) for the S&P 500 ETF (SPY) and the gold ETF (GLD), downloaded from Yahoo Finance with `quantmod`. The 3-month Treasury bill rate (FRED series DTB3) is the risk-free rate.
- **Rules:** 64 technical trading-rule specifications per asset across seven indicator families, following Gerritsen et al. (2020): moving averages (single and dual crossover), trading range breakout, MACD, rate of change, on-balance volume, RSI and Bollinger Bands. Positions are long or flat, with no short selling, and a rule earns the Treasury bill rate while it is out of the market.
- **Lag:** every signal is lagged by one week, so no rule trades on information it could not have had.
- **Costs:** turnover-based transaction costs of 10 basis points per position change, reported as net-of-cost statistics and as a break-even cost for each rule.
- **Inference:** Sharpe-ratio differences against buy-and-hold are tested with the Ledoit and Wolf (2008) studentised circular block bootstrap (1,000 resamples, block length 5), on the full sample and on four subperiods (2006–2009, 2010–2014, 2015–2019, 2020–2024).

## The result

- **No statistically significant positive Sharpe differences.** On neither asset did any rule deliver a Sharpe ratio significantly above buy-and-hold, in the full sample or in the four subperiods.
- **Lower drawdowns, at the cost of lower returns.** Selected trend rules reduced maximum drawdown from 55% to 26% for SPY and from 45% to about 30% for GLD. Their value, where they have any, lies in limiting losses and not in persistent outperformance.

## How to run

You need R with these packages:

```r
install.packages(c("quantmod", "zoo", "PeerPerformance", "moments", "tseries", "TTR"))
```

From the repository folder:

```bash
Rscript run.R                 # full replay for both assets, reruns the bootstrap (several minutes)
Rscript run.R --diagnostics   # fast replay of the cost, exposure and drawdown tables (seconds)
Rscript code/E.7.R            # additional drawdown and timing diagnostics
```

`run.R` replays the analysis from cached inputs (the signals and returns saved from the base script), so the results do not move with later revisions to Yahoo or FRED data. Results are written to `replayed_outputs/` (or `diagnostic_replay/`) and can be compared with the files in `verified_outputs/`.

To rebuild the signals from a fresh download, set the ticker at the top of `technical_trading_rules.R` and source it in R.

## Repository contents

| Path | What it is |
|------|------------|
| `technical_trading_rules.R` | Base script: data download, the 64 rule signals, performance statistics and the Sharpe-ratio tests |
| `run.R` | Runs the analysis scripts in `code/` for both assets from the cached inputs |
| `code/E.1.R` | Risk-free rate and excess-return construction |
| `code/E.2.R` | Sharpe-difference tests, full sample and four subperiods |
| `code/E.3.R` | Transaction costs, net-of-cost statistics and break-even costs |
| `code/E.4.R` | How rule performance varies with the buy-and-hold Sharpe ratio across subperiods |
| `code/E.5.R` | Return distribution statistics, the SPY and GLD correlation and the price chart |
| `code/E.6.R` | Drawdown comparison against a constant-exposure benchmark |
| `code/E.7.R` | Additional drawdown-window and timing diagnostics |
| `inputs/` | Cached signals, returns and prices used by the replay |
| `verified_outputs/`, `verified_additional_outputs/` | Result tables from the verification run |
| `published/` | The original result exports of 26 August 2026 used for the dissertation tables |
| `verification/` | Checks and logs from the verification run |
| `REPLICATION_NOTES.md` | Detailed notes on the replay, including the small differences between the original and the verification run |

## Attribution

The core backtesting framework was originally provided by **Prof. Fotis Papailias** as a teaching template. My own contributions extend it with:

- the Ledoit and Wolf (2008) Sharpe-ratio significance testing (studentised circular block bootstrap with HAC errors),
- the four-subperiod robustness analysis,
- the transaction-cost and break-even analysis and the other analysis scripts in `code/`,
- and the application to SPY and GLD with the rule parameterisations used in the dissertation.

## References

- Gerritsen, D. F., Bouri, E., Ramezanifar, E., & Roubaud, D. (2020). The profitability of technical trading rules in the Bitcoin market. *Finance Research Letters.*
- Ledoit, O., & Wolf, M. (2008). Robust performance hypothesis testing with the Sharpe ratio. *Journal of Empirical Finance,* 15(5), 850–859.
