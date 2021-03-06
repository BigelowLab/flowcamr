% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/FlowCamGroup.R
\name{FlowCamGroup}
\alias{FlowCamGroup}
\title{Read one or more FlowCam datasets}
\usage{
FlowCamGroup(dirlist, filename = NULL)
}
\arguments{
\item{dirlist}{character vector of one or more paths to FlowCam datasets}

\item{filename}{character specifies a text file that contains the list of 
directories}
}
\value{
a list of FlowCam objects in a FlowCamGroup class object
}
\description{
Read one or more FlowCam datasets
}
\examples{
\dontrun{
 XX <- FlowCamGroup(file = "D:/SABOR FCAM Classified/LCL CLASSIFIED_2016-01-20.SABOR.txt")
}
}

