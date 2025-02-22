#' Handle Measurement Uncertainty on a Numeric Vector
#'
#' Set or retrieve measurement uncertainty to/from numeric vectors (extensions
#' to the \pkg{errors} package for \code{quantities} and \code{units} objects).
#'
#' @param x a numeric object, or object of class \code{quantities}, \code{units}
#' or \code{errors}.
#' @param value a numeric vector or \code{units} object of length 1, or the same
#' length as \code{x} (see details).
#'
#' @details For objects of class \code{quantities} or \code{units}, the
#' \code{errors()} method returns a \code{units} object that matches the units
#' of \code{x}. Methods \code{`errors<-`()} and \code{set_errors()} assume that
#' the provided uncertainty (\code{value}) has the same units as \code{x}.
#' However, it is a best practice to provide a \code{value} with explicit units.
#' In this way, uncertainty can be provided in different (but compatible) units,
#' and it will be automatically converted to the units of \code{x} (see examples
#' below).
#'
#' @seealso \code{\link[errors]{errors}}.
#'
#' @examples
#' x <- set_units(1:5, m)
#' errors(x) <- 0.01 # implicit units, same as x
#' errors(x)
#' errors(x) <- set_units(1, cm) # explicit units
#' errors(x)
#'
#' @name errors
#' @export
errors.units <- function(x) {
  xx <- if (inherits(x, "quantities"))
    NextMethod() else getS3method("errors", "numeric")(x)
  units(xx) <- units(x)
  xx
}

#' @name errors
#' @export
errors.mixed_units <- function(x) structure(lapply(x, errors), class=class(x))

#' @name errors
#' @export
`errors<-.units` <- function(x, value) {
  if (inherits(value, "units")) {
    xx <- x
    quantities(xx) <- list(units(value), NULL)
    xx <- xx + value
    units(xx) <- units(x)
    value <- as.numeric(xx) - as.numeric(x)
  }
  xx <- if (inherits(x, "quantities"))
    NextMethod() else getS3method("errors<-", "numeric")(x, value)
  reclass(xx)
}

#' @name errors
#' @export
`errors<-.mixed_units` <- function(x, value)
  structure(mapply(set_errors, x, value, SIMPLIFY=FALSE), class=class(x))

#' @name errors
#' @export
set_errors.units <- getS3method("set_errors", "numeric")

#' @name errors
#' @export
set_errors.mixed_units <- getS3method("set_errors", "numeric")

#' @name errors
#' @export
errors_max.units <- function(x)
  set_units(errors_max(drop_units(x)), units(x), mode="standard")

#' @name errors
#' @export
errors_min.units <- function(x)
  set_units(errors_min(drop_units(x)), units(x), mode="standard")

#' Handle Correlations Between \code{quantities} Objects
#'
#' Methods to set or retrieve correlations or covariances between
#' \code{quantities} objects.
#'
#' @param x an object of class \code{quantities}.
#' @param y an object of class \code{quantities} of the same length as \code{x}.
#' @param value a compatible object of class \code{units} of length 1 or the
#' same length as \code{x}. For correlations, this means a unitless vector (a
#' numeric vector is also accepted in this case). For covariances, this means
#' the same magnitude as \code{x*y}.
#'
#' @seealso \code{\link[errors]{correl}}.
#'
#' @examples
#' x <- set_quantities(1:10, m/s, 0.1)
#' y <- set_quantities(10:1, km/h, 0.2)
#' correl(x, y) <- 0.1 # accepted
#' correl(x, y) <- set_units(0.1) # recommended
#' correl(x, y)
#' covar(x, y)
#'
#' @name correl
#' @export
correl.quantities <- function(x, y) {
  NextMethod()
}

#' @name correl
#' @export
`correl<-.quantities` <- function(x, y, value) {
  stopifnot(inherits(y, "quantities"))
  if (inherits(value, "units"))
    stopifnot(units(value) == units(as_units(1)))
  else units(value) <- 1
  NextMethod()
}

#' @name correl
#' @export
covar.quantities <- function(x, y) {
  if (!is.null(xy <- NextMethod()))
    units(xy) <- as_units(units(x)) * as_units(units(y))
  xy
}

#' @name correl
#' @export
`covar<-.quantities` <- function(x, y, value) {
  stopifnot(inherits(y, "quantities"))
  stopifnot(inherits(value, "units"))
  units(value) <- units(x*y)
  value <- drop_units(value)
  NextMethod()
}
