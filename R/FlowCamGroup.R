# FlowCamGroup.R


#' Retrieve the volume summary for each FlowCam object.
#' 
#' @export
#' @param x a FlowCamGroup
#' @param bind logical, if TRUE then rbind the classification tables
#' @return either a list of data.frames or a singke data.frame
volume_summary <- function(x, bind = TRUE){
   if (!inherits(x, 'FlowCamGroup')){ return(invisible(NULL)) }
   xx <- lapply(x, function(x) x$volume_summary(include_name = TRUE) )
   if (bind) xx <- do.call(rbind, xx)
   invisible(xx)
}

#' Retrieve the indices for each object for the label(s) specified.
#' 
#' @export
#' @seealso \code{\link{FlowCam_which_labeled}}
#' @param x a FlowCamGroup
#' @param ... further arguments for \code{FlowCam}
#' @return a list of indices in each FlowCam dataset for the labels matching the
#'    requested labels
which_labeled <- function(x, ...){
   if (!inherits(x, 'FlowCamGroup')){ return(invisible(NULL)) }
   lapply(x, function(x, ...) x$which_labeled(...), ...)
}


print.FlowCamGroup <- function(x){
   if (!inherits(x, 'FlowCamGroup')){ return(invisible(NULL)) }
   lapply(x, function(x) x$show())
}

#' Read one or more FlowCam datasets
#' 
#' @export
#' @param dirlist character vector of one or more paths to FlowCam datasets
#' @return a list of FlowCam objects in a FlowCamGroup class object
FlowCamGroup <- function(dirlist){

   if (!missing(dirlist)) {
      x <- lapply(dirlist, FlowCam)
      names(x) <- basename(dirlist)
   } else {
      x <- list()
   }
   
   class(x) <- 'FlowCamGroup'
   
   invisible(x)
}