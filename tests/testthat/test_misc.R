
# ------------------------------------------------------------------------------

context("checking for multi_predict")

source(test_path("helper-objects.R"))
hpc <- hpc_data[1:150, c(2:5, 8)]

test_that('parsnip objects', {

  lm_idea <- linear_reg() %>% set_engine("lm")
  expect_false(has_multi_predict(lm_idea))

  lm_fit <- fit(lm_idea, mpg ~ ., data = mtcars)
  expect_false(has_multi_predict(lm_fit))
  expect_false(has_multi_predict(lm_fit$fit))

  mars_fit <-
    mars(mode = "regression") %>%
    set_engine("earth") %>%
    fit(mpg ~ ., data = mtcars)
  expect_true(has_multi_predict(mars_fit))
  expect_false(has_multi_predict(mars_fit$fit))
})

test_that('other objects', {

  expect_false(has_multi_predict(NULL))
  expect_false(has_multi_predict(NA))

})

# ------------------------------------------------------------------------------

context("getting y names from terms")

test_that('getting y names from terms', {

  expect_equal(
    parsnip:::terms_y(lm(cbind(mpg, disp)  ~., data = mtcars)$terms),
    c("mpg", "disp")
  )

  expect_equal(
    parsnip:::terms_y(lm(mpg  ~., data = mtcars)$terms),
    "mpg"
  )

  expect_equal(
    parsnip:::terms_y(lm(log(mpg)  ~., data = mtcars)$terms),
    "mpg"
  )

  expect_equal(
    parsnip:::terms_y(terms(  ~., data = mtcars)),
    character(0)
  )


})

# ------------------------------------------------------------------------------

test_that('S3 method dispatch/registration', {

  expect_error(
    res <-
      null_model() %>%
      set_engine("parsnip") %>%
      set_mode("regression") %>%
      fit(mpg ~ ., data = mtcars) %>%
      tidy(),
    regex = NA
  )
  expect_true(tibble::is_tibble(res))

  expect_error(
    res <-
      null_model() %>%
      set_engine("parsnip") %>%
      set_mode("classification") %>%
      fit(class ~ ., data = hpc) %>%
      tidy(),
    regex = NA
  )
  expect_true(tibble::is_tibble(res))

})

# ------------------------------------------------------------------------------

test_that('control class', {
  x <- linear_reg() %>% set_engine("lm")
  ctrl <- control_parsnip()
  class(ctrl) <- c("potato", "chair")
  expect_error(
    fit(x, mpg ~ ., data = mtcars, control = ctrl),
    "The 'control' argument should have class 'control_parsnip'"
  )
  expect_error(
    fit_xy(x, x = mtcars[, -1], y = mtcars$mpg, control = ctrl),
    "The 'control' argument should have class 'control_parsnip'"
  )
})


