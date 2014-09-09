context("tests on inputs")

test_that("tests for grp variable",{
  set.seed(12345)
  dat <- matrix(rnorm(100*30),nrow=100,ncol=30)

  grp <- rep(c(0,1),each=15)
  expect_that(deFunction(dat,grp),throws_error("grp variable must be a factor"))

  grp <- as.factor(rep(c(0,1,2),each=10))
  expect_that(deFunction(dat,grp),throws_error("grp variable must have exactly two levels"))

  grp <- as.factor(rep(0,30))
  expect_that(deFunction(dat,grp),throws_error("grp variable must have exactly two levels")) 
})

test_that("tests for dat variable",{
  set.seed(12345)
  grp <- as.factor(rep(c(0,1),each=15))

  dat <- matrix(0,nrow=100,ncol=30)
  expect_that(deFunction(dat,grp),throws_error("some genes have zero variance; t-test won't work"))
})

context("test on outputs")

test_that("test p-values are numeric and non-zero",{
  set.seed(12345)
  grp <- as.factor(rep(c(0,1),each=15))
  dat <- matrix(matrix(rnorm(100*30)),nrow=100,ncol=30)

  expect_that(deFunction(dat,grp),is_a("numeric"))
  expect_that(all(deFunction(dat,grp) > 0),is_true())
})