\name{mkinerrmin}
\Rdversion{1.1}
\alias{mkinerrmin}
\title{
Calculate the minimum error to assume in order to pass the variance test
}
\description{
This function uses \code{\link{optimize}} in order to iteratively find the
smallest relative error still resulting in passing the chi-squared test
as defined in the FOCUS kinetics report from 2006.
}
\usage{
mkinerrmin(fit, alpha = 0.05)
}
\arguments{
  \item{fit}{
    an object of class \code{\link{mkinfit}}.
  }
  \item{alpha}{
    The confidence level chosen for the chi-squared test.
}
}
\value{
  A dataframe with the following components:
  \item{err.min}{The relative error, expressed as a fraction.}
  \item{n.optim}{The number of optimised parameters attributed to the data series.}
  \item{df}{The number of remaining degrees of freedom for the chi2 error level
    calculations.  Note that mean values are used for the chi2 statistic and
    therefore every time point with observed values in the series only counts
    one time.}
  The dataframe has one row for the total dataset and one further row for
  each observed state variable in the model.
}
\details{
    This function is used internally by \code{\link{summary.mkinfit}}.
}
\references{ 
  FOCUS (2006) \dQuote{Guidance Document on Estimating Persistence and
  Degradation Kinetics from Environmental Fate Studies on Pesticides in EU
  Registration} Report of the FOCUS Work Group on Degradation Kinetics,
  EC Document Reference Sanco/10058/2005 version 2.0, 434 pp,
  \url{http://focus.jrc.ec.europa.eu/dk} 
}
\keyword{ manip }
