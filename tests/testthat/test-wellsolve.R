# global state
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

nw <- 7 #number of wells + 1 (the tank)
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

test_that("wellsolve() works", {
  default_wellsolve <-
    function(ff) wellsolve(projected,
                           T=0.0025, R=3000, ff=ff, qtot<-0.5, r0=0.200,
                           Dlist, qextra, nw, xc, yc,links,
                           nwextra, xextra, yextra, xstart)

  result<-default_wellsolve(ff=0.03)

  # Case A
  Dlist[1:6] <- 2
  result_a <- default_wellsolve(ff=0.03)

  # Case LC1
  result_lc1 <- default_wellsolve(ff=0)

  # Case B
  Dlist[1:6] <- 0.4
  result_b <- default_wellsolve(ff=0.03)

  # Case C
  qextra[1] <- 0.1
  qextra[2] <- 0.4
  result_c <- default_wellsolve(ff=0.03)

  expect_equal_to_reference(result, 'expected/result.rds')
  expect_equal_to_reference(result_a, 'expected/result_a.rds')
  expect_equal_to_reference(result_lc1, 'expected/result_lc1.rds')
  expect_equal_to_reference(result_b, 'expected/result_b.rds')
  expect_equal_to_reference(result_c, 'expected/result_c.rds')
})

test_that("calculate_distances() works", {
  xextra <- c(xextra,xc)
  yextra <- c(yextra,yc)

  result <- calculate_distances(xc, yc, projected, r0=0.2, nw=length(xc))
  resultextra <-
    calculate_distances(xextra, yextra, projected, r0=0.2, nw=length(xextra))
  expect_equal_to_reference(result$r, 'expected/r.rds')
  expect_equal_to_reference(result$coords, 'expected/coords.rds')
  expect_equal_to_reference(result$test, 'expected/test.rds')

  expect_equal_to_reference(resultextra$r, 'expected/rextra.rds')
  expect_equal_to_reference(resultextra$coords, 'expected/coordsextra.rds')
  expect_equal_to_reference(resultextra$test, 'expected/testextra.rds')
})

test_that("calculate_s() works", {
  # Case C
  qextra[1] <- 0.1
  qextra[2] <- 0.4

  qresult <- readRDS('mocks/qresult.rds')

  rnot <- readRDS('mocks/rnot.rds')
  rextranot <- readRDS('mocks/rextranot.rds')

  R <- 3000
  T <- 0.0025

  nwextra <- nwextra + nw
  s <- calculate_s(ncol=nw-1, nrow=nw-1, qresult, rnot, R, T)
  sextra <-
    calculate_s(ncol=nwextra-nw, nrow=nwextra, qextra, rextranot, R, T)

  expect_equal_to_reference(s, 'expected/s.rds')
  expect_equal_to_reference(sextra, 'expected/sextra.rds')
})
