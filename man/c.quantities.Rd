% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/misc.R
\name{c.quantities}
\alias{c.quantities}
\title{Combine Values into a Vector or List}
\usage{
\method{c}{quantities}(...)
}
\arguments{
\item{...}{objects to be concatenated.}
}
\description{
S3 method for \code{quantities} objects (see \code{\link{c}}).
}
\examples{
c(set_quantities(1, m/s, 0.2), set_quantities(30, km/h, 0.1))

}