# $Id$

# Copyright (C) 2010-2012 Johannes Ranke
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

mkinpredict <- function(mkinmod, odeparms, odeini, outtimes, solution_type = "deSolve", map_output = TRUE, atol = 1e-8, rtol = 1e-10, ...) {

  # Get the names of the state variables in the model
  mod_vars <- names(mkinmod$diffs)

  # Order the inital values for state variables if they are named
  if (!is.null(names(odeini))) {
    odeini <- odeini[mod_vars]
  }

  # Create function for evaluation of expressions with ode parameters and initial values
  evalparse <- function(string)
  {
    eval(parse(text=string), as.list(c(odeparms, odeini)))
  }

  # Create a function calculating the differentials specified by the model
  # if necessary
  if (solution_type == "analytical") {
    parent.type = names(mkinmod$map[[1]])[1]  
    parent.name = names(mkinmod$diffs)[[1]]
    o <- switch(parent.type,
      SFO = SFO.solution(outtimes, 
          evalparse(parent.name),
          ifelse(mkinmod$use_of_ff == "min", 
	    evalparse(paste("k", parent.name, "sink", sep="_")),
	    evalparse(paste("k", parent.name, sep="_")))),
      FOMC = FOMC.solution(outtimes,
          evalparse(parent.name),
          evalparse("alpha"), evalparse("beta")),
      DFOP = DFOP.solution(outtimes,
          evalparse(parent.name),
          evalparse("k1"), evalparse("k2"),
          evalparse("g")),
      HS = HS.solution(outtimes,
          evalparse(parent.name),
          evalparse("k1"), evalparse("k2"),
          evalparse("tb")),
      SFORB = SFORB.solution(outtimes,
          evalparse(parent.name),
          evalparse(paste("k", parent.name, "bound", sep="_")),
          evalparse(paste("k", sub("free", "bound", parent.name), "free", sep="_")),
          evalparse(paste("k", parent.name, "sink", sep="_")))
    )
    out <- data.frame(outtimes, o)
    names(out) <- c("time", sub("_free", "", parent.name))
  }
  if (solution_type == "eigen") {
    coefmat.num <- matrix(sapply(as.vector(mkinmod$coefmat), evalparse), 
      nrow = length(mod_vars))
    e <- eigen(coefmat.num)
    c <- solve(e$vectors, odeini)
    f.out <- function(t) {
      e$vectors %*% diag(exp(e$values * t), nrow=length(mod_vars)) %*% c
    }
    o <- matrix(mapply(f.out, outtimes), 
      nrow = length(mod_vars), ncol = length(outtimes))
    out <- data.frame(outtimes, t(o))
    names(out) <- c("time", mod_vars)
  } 
  if (solution_type == "deSolve") {
    mkindiff <- function(t, state, parms) {

      time <- t
      diffs <- vector()
      for (box in names(mkinmod$diffs))
      {
        diffname <- paste("d", box, sep="_")      
        diffs[diffname] <- with(as.list(c(time, state, parms)),
          eval(parse(text=mkinmod$diffs[[box]])))
      }
      return(list(c(diffs)))
    } 
    out <- ode(
      y = odeini,
      times = outtimes,
      func = mkindiff, 
      parms = odeparms,
      atol = atol,
      rtol = rtol,
      ...
    )
  }
  if (map_output) {
    # Output transformation for models with unobserved compartments like SFORB
    out_mapped <- data.frame(time = out[,"time"])
    for (var in names(mkinmod$map)) {
      if((length(mkinmod$map[[var]]) == 1) || solution_type == "analytical") {
        out_mapped[var] <- out[, var]
      } else {
        out_mapped[var] <- rowSums(out[, mkinmod$map[[var]]])
      }
    }
    return(out_mapped) 
  } else {
    return(out)
  }
}
