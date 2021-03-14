
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wellsolve

<!-- badges: start -->

[![Travis build
status](https://travis-ci.com/teldosas/wellsolve.svg?branch=master)](https://travis-ci.com/teldosas/wellsolve)
<!-- badges: end -->

Supposing that a number of wells pumps water from an infinite confined
aquifer, transferring the water through pipes to a water tank, using
this package makes it possible to allocate the pumping flow rates so
that the overall operational cost is minimized. The user can insert the
locations of the wells, the pipe network, the aquifer characteristics
and the water demand and get the allocation of the pumping flow rates,
the hydraulic drawdowns and the head losses due to pipe frictions.

## Installation

You can install the released version of wellsolve from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("wellsolve")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("teldosas/wellsolve")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(wellsolve)

projected <- "+proj=utm +zone=34"
x0 = 650000
y0 = 4400000

# the first value is the tank and the rest are wells
xc <- c(0,100,180,100,700,800,900)
xc <- xc + x0 - 10000

yc <- c(0,0,0,80,0,0,900)
yc <- yc + y0 - 10000

# xstart is a wild guess about the result.
# This helps the algorithm search for the result in the correct area
xstart <- c(0.250,0.1,0.25,0.1,0.1,0.01)

nw=7 #number of wells + 1 (the tank)

#                   6
#                  /
#                 /
#       3        /
#      /        /
#    /        /
#  /        /
# T---1----2------4----5
#
# T=Tank 1-6=Wells no. 1-6
links <- data.frame(matrix(ncol=2, nrow=(nw-1)))
links[1:(nw-1),1] <- 1:(nw-1)
links[1,2] <- 0
links[2,2] <- 1
links[3,2] <- 0
links[4,2] <- 2
links[5,2] <- 4
links[6,2] <- 2

Dlist <- list()
Dlist[1:6] <- 0.05


# number of extra wells
nwextra <- 2

xextra <- c(500,800)
xextra <- xextra + x0 - 10000

yextra <- c(500,300)
yextra <- yextra + y0 - 10000

qextra <- c()
qextra[1] <- 0
qextra[2] <- 0

result <- wellsolve(projected, T=0.0025 ,R=3000, ff=0.03, qtot<-0.5, r0=0.200,
                  Dlist, qextra, nw, xc, yc, links,
                  nwextra, xextra, yextra, xstart)
```

    ##   Algorithm parameters
    ##   --------------------
    ##   Method: Broyden  Global strategy: double dogleg (initial trust region = -2)
    ##   Maximum stepsize = 1.79769e+308
    ##   Scaling: fixed
    ##   ftol = 1e-08 xtol = 1e-08 btol = 0.01 cndtol = 1e-12
    ## 
    ##   Iteration report
    ##   ----------------
    ##   Iter         Jac     Lambda      Eta     Dlt0     Dltn         Fnorm   Largest |f|
    ##      0                                                    5.462367e+11  7.410957e+05
    ##      1  N(6.8e-08) N            0.9898   0.1411   0.2822  3.263078e+10  1.769475e+05
    ##      2  B(8.8e-08) N            0.9893   0.0372   0.0372  8.693787e+09  7.796567e+04
    ##      3  B(5.3e-08) N            0.9960   0.0365   0.0730  1.061454e+09  3.210573e+04
    ##      4  B(3.8e-08) N            0.9321   0.0201   0.0201  3.871930e+08  1.946157e+04
    ##      5  B(2.3e-08) W   0.7108   0.9143   0.0201   0.0401  8.979170e+07  9.374749e+03
    ##      6  B(1.5e-08) N            0.9019   0.0318   0.0637  2.519811e+06  1.808672e+03
    ##      7  B(1.4e-08) N            0.9046   0.0030   0.0059  4.167393e+05  6.473717e+02
    ##      8  B(5.9e-09) N            0.9095   0.0049   0.0098  6.329708e+04  2.428495e+02
    ##      9  B(5.4e-09) N            0.9475   0.0004   0.0004  2.216752e+04  1.475947e+02
    ##     10  B(5.9e-09) N            0.8946   0.0001   0.0000  2.170522e+04  1.450197e+02
    ##     11  B(9.9e-10) W   0.0399   0.8497   0.0000   0.0000  2.108433e+04  1.411546e+02
    ##     12  B(5.6e-08) C            0.8873   0.0000   0.0000  2.049992e+04  1.395073e+02
    ##     13  B(7.1e-08) W   0.0021   0.2056   0.0000   0.0000  2.060405e+04  1.388003e+02
    ##     14  N(5.2e-07) N            0.2489   0.0017   0.0035  2.455097e+02  1.575401e+01
    ##     15  B(5.2e-07) N            0.2367   0.0002   0.0004  9.223712e+00  3.044597e+00
    ##     16  B(5.5e-07) N            0.6625   0.0001   0.0001  2.607577e-04  1.449910e-02
    ##     17  B(5.5e-07) N            0.3479   0.0000   0.0000  5.376011e-07  7.942852e-04
    ##     18  B(5.6e-07) N            0.3109   0.0000   0.0000  1.836902e-07  4.390565e-04
    ##     19  B(5.5e-07) N            0.2292   0.0000   0.0000  4.581097e-10  2.331423e-05

``` r
# Case A
Dlist[1:6] <- 2
result <- wellsolve(projected, T=0.0025 ,R=3000, ff=0.03, qtot<-0.5, r0=0.200,
                    Dlist, qextra, nw, xc, yc, links,
                    nwextra, xextra, yextra, xstart)
```

    ##   Algorithm parameters
    ##   --------------------
    ##   Method: Broyden  Global strategy: double dogleg (initial trust region = -2)
    ##   Maximum stepsize = 1.79769e+308
    ##   Scaling: fixed
    ##   ftol = 1e-08 xtol = 1e-08 btol = 0.01 cndtol = 1e-12
    ## 
    ##   Iteration report
    ##   ----------------
    ##   Iter         Jac     Lambda      Eta     Dlt0     Dltn         Fnorm   Largest |f|
    ##      0                                                    2.191820e+05  3.933785e+02
    ##      1  N(2.0e-04) N            0.9605   0.2779   0.5558  2.460913e-05  3.316578e-03
    ##      2  B(2.0e-04) N            0.9948   0.0000   0.0000  3.059305e-14  1.164155e-07
    ##      3  B(2.0e-04) N            0.9990   0.0000   0.0000  6.342875e-26  1.928310e-13

``` r
# Case LC1
result <- wellsolve(projected, T=0.0025 ,R=3000, ff=0, qtot<-0.5, r0=0.200,
                    Dlist, qextra, nw, xc, yc, links,
                    nwextra, xextra, yextra, xstart)
```

    ##   Algorithm parameters
    ##   --------------------
    ##   Method: Broyden  Global strategy: double dogleg (initial trust region = -2)
    ##   Maximum stepsize = 1.79769e+308
    ##   Scaling: fixed
    ##   ftol = 1e-08 xtol = 1e-08 btol = 0.01 cndtol = 1e-12
    ## 
    ##   Iteration report
    ##   ----------------
    ##   Iter         Jac     Lambda      Eta     Dlt0     Dltn         Fnorm   Largest |f|
    ##      0                                                    2.191839e+05  3.933803e+02
    ##      1  N(2.0e-04) N            0.9605   0.2779   0.5558  5.736430e-13  8.167479e-07
    ##      2  B(2.0e-04) N            0.6520   0.0000   0.0000  9.087678e-28  2.842171e-14

``` r
# Case B
Dlist[1:6] <- 0.4
result <- wellsolve(projected, T=0.0025 ,R=3000, ff=0.03, qtot<-0.5, r0=0.200,
                    Dlist, qextra, nw, xc, yc, links,
                    nwextra, xextra, yextra, xstart)
```

    ##   Algorithm parameters
    ##   --------------------
    ##   Method: Broyden  Global strategy: double dogleg (initial trust region = -2)
    ##   Maximum stepsize = 1.79769e+308
    ##   Scaling: fixed
    ##   ftol = 1e-08 xtol = 1e-08 btol = 0.01 cndtol = 1e-12
    ## 
    ##   Iteration report
    ##   ----------------
    ##   Iter         Jac     Lambda      Eta     Dlt0     Dltn         Fnorm   Largest |f|
    ##      0                                                    2.139104e+05  3.877135e+02
    ##      1  N(1.9e-04) N            0.9664   0.2662   0.5324  2.229651e+02  9.945352e+00
    ##      2  B(1.9e-04) N            0.9995   0.0068   0.0137  2.044975e+00  9.380462e-01
    ##      3  B(1.7e-04) N            0.9999   0.0006   0.0012  1.587382e-05  3.448635e-03
    ##      4  B(1.7e-04) N            0.9751   0.0000   0.0000  1.163745e-09  4.167468e-05
    ##      5  B(1.7e-04) N            0.6950   0.0000   0.0000  1.249868e-12  1.416031e-06
    ##      6  B(1.7e-04) N            0.6949   0.0000   0.0000  6.889993e-17  6.448097e-09

``` r
# Case C
qextra[1] <- 0.1
qextra[2] <- 0.4
result <- wellsolve(projected, T=0.0025 ,R=3000, ff=0.03, qtot<-0.5, r0=0.200,
                    Dlist, qextra, nw, xc, yc, links,
                    nwextra, xextra, yextra, xstart)
```

    ##   Algorithm parameters
    ##   --------------------
    ##   Method: Broyden  Global strategy: double dogleg (initial trust region = -2)
    ##   Maximum stepsize = 1.79769e+308
    ##   Scaling: fixed
    ##   ftol = 1e-08 xtol = 1e-08 btol = 0.01 cndtol = 1e-12
    ## 
    ##   Iteration report
    ##   ----------------
    ##   Iter         Jac     Lambda      Eta     Dlt0     Dltn         Fnorm   Largest |f|
    ##      0                                                    2.154684e+05  3.812010e+02
    ##      1  N(1.9e-04) N            0.9739   0.2619   0.5239  2.378423e+02  1.049493e+01
    ##      2  B(1.9e-04) N            0.9989   0.0071   0.0141  2.182377e+00  9.653594e-01
    ##      3  B(1.7e-04) N            0.9996   0.0006   0.0012  2.172868e-05  4.698379e-03
    ##      4  B(1.7e-04) N            0.7206   0.0000   0.0000  3.098375e-08  1.748498e-04
    ##      5  B(1.7e-04) N            0.6279   0.0000   0.0000  4.350881e-12  2.631109e-06
    ##      6  B(1.7e-04) N            0.5538   0.0000   0.0000  5.567208e-16  2.117073e-08
