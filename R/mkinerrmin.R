# $Id$

# Copyright (C) 2010-2013 Johannes Ranke
# Contact: jranke@uni-bremen.de

# This file is part of the R package mkin

# mkin is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>
if(getRversion() >= '2.15.1') utils::globalVariables(c("name", "value_mean"))

mkinerrmin <- function(fit, alpha = 0.05)
{
  parms.optim <- fit$par

  kinerrmin <- function(errdata, n.parms) {
    means.mean <- mean(errdata$value_mean, na.rm = TRUE)
    df = length(errdata$value_mean) - n.parms
  
    err.min <- sqrt((1 / qchisq(1 - alpha, df)) *
               sum((errdata$value_mean - errdata$value_pred)^2)/(means.mean^2))

    return(list(err.min = err.min, n.optim = n.parms, df = df))
  }

  means <- aggregate(value ~ time + name, data = fit$observed, mean, na.rm=TRUE)
  errdata <- merge(means, fit$predicted, by = c("time", "name"), 
    suffixes = c("_mean", "_pred"))
  errdata <- errdata[order(errdata$time, errdata$name), ]

  # Any value that is set to exactly zero is not really an observed value
  # Remove those at time 0 - those are caused by the FOCUS recommendation
  # to set metabolites occurring at time 0 to 0
  errdata <- subset(errdata, !(time == 0 & value_mean == 0))

  n.optim.overall <- length(parms.optim)

  errmin.overall <- kinerrmin(errdata, n.optim.overall)
  errmin <- data.frame(err.min = errmin.overall$err.min,
    n.optim = errmin.overall$n.optim, df = errmin.overall$df)
  rownames(errmin) <- "All data"

  for (obs_var in fit$obs_vars)
  {
    errdata.var <- subset(errdata, name == obs_var)

    # Check if initial value is optimised
    n.initials.optim <- length(grep(paste(obs_var, ".*", "_0", sep=""), names(parms.optim)))

    # Rate constants are attributed to the source variable
    n.k.optim <- length(grep(paste("^k", obs_var, sep="_"), names(parms.optim)))

    # Formation fractions are attributed to the target variable
    n.ff.optim <- length(grep(paste("^f", ".*", obs_var, "$", sep=""), names(parms.optim)))

    n.optim <- n.k.optim + n.initials.optim + n.ff.optim

    # FOMC, DFOP and HS parameters are only counted if we are looking at the
    # first variable in the model which is always the source variable
    if (obs_var == fit$obs_vars[[1]]) {
      if ("alpha" %in% names(parms.optim)) n.optim <- n.optim + 1
      if ("beta" %in% names(parms.optim)) n.optim <- n.optim + 1
      if ("k1" %in% names(parms.optim)) n.optim <- n.optim + 1
      if ("k2" %in% names(parms.optim)) n.optim <- n.optim + 1
      if ("g" %in% names(parms.optim)) n.optim <- n.optim + 1
      if ("tb" %in% names(parms.optim)) n.optim <- n.optim + 1
    }

    # Calculate and add a line to the results
    errmin.tmp <- kinerrmin(errdata.var, n.optim)
    errmin[obs_var, c("err.min", "n.optim", "df")] <- errmin.tmp
  }

  return(errmin)
}
