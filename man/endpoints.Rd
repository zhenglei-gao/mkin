\name{endpoints}
\alias{endpoints}
\title{
Function to calculate endpoints for further use from kinetic models fitted with mkinfit
}
\description{
This function calculates DT50 and DT90 values as well as formation fractions from kinetic models
fitted with mkinfit. If the SFORB model was specified for one of the parents or metabolites, 
the Eigenvalues are returned. These are equivalent to the rate constantes of the DFOP model, but 
with the advantage that the SFORB model can also be used for metabolites.
}
\usage{
endpoints(fit, pseudoDT50 = FALSE)
}
\arguments{
  \item{fit}{
  An object of class \code{\link{mkinfit}}.
}
  \item{pseudoDT50}{
  Should pseudoDT50 values for FOMC, DFOP and SFORB models be reported, as 
  recommended by the FOCUS group? Currently not implemented.
}
}
\note{
  The function is used internally by \code{\link{summary.mkinfit}}.
}
\value{
  A list with the components mentioned above.
}
\author{
  Johannes Ranke
}
\keyword{ manip }
