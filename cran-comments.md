## Test environments
* local OS X install, R 4.0.3
* ubuntu 18.04 (on travis-ci), R 4.0.2
* win-builder (devel and release)

## R CMD check results
There were no ERRORs or WARNINGs

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Aristotelis Dossas <teldosas@gmail.com>'

  * New submission

  * Possibly mis-spelled words in DESCRIPTION:
  drawdowns (19:19)

    It's not a misspelling it's referenced like that [in the paper
    referenced in the docs](https://link.springer.com/article/10.1007%2Fs11269-020-02661-x)

* checking LazyData ... NOTE
  'LazyData' is specified without a 'data' directory

    It's data for testing purposes so they are kept in subfolders
    in the tests folder

## Downstream dependencies
There are currently no downstream dependencies for this package.
