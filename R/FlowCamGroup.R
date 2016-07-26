# FlowCamGroup.R


#' Retrieve the volume summary for each FlowCam object.
#' 
#' @export
#' @param x a FlowCamGroup
#' @param bind logical, if TRUE then rbind the classification tables
#' @param save_file logical, if TRUE then save the output, ignored if 
#'   bind is FALSE
#' @param filename the name of the file to save, 
#' @return either a list of data.frames or a single data.frame
#' \dontrun{
#'  # get a volume-by-class summary table, save by default
#'  vs <- volume_summary(XX)
#'
#'  # get a volume-by-class summary table, save to specified file
#'  vs <- volume_summary(XX, filename = 'C:/my/path/volume_summary.csv')
#' }
volume_summary <- function(x, bind = TRUE, save_file = TRUE,
    filename = file.path(attr(x, 'summary_path'), "volume_summary.csv")) {
    
    if (!inherits(x, 'FlowCamGroup')){ return(invisible(NULL)) }
    
    xx <- lapply(x, function(x) x$volume_summary(include_name = TRUE) )
    
    if (bind) {
       xx <- do.call(rbind, xx)
       if (save_file) {
         cat("saving:", filename, "\n")
         write.csv(xx, file = filename, row.names = FALSE)
       }
    }    
          
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

#' Pretty print a FlowCamGroup
#' 
#' @export
# @methods print FlowCamGroup
#' @param x a FlowCamGroup object
print.FlowCamGroup <- function(x){
   if (!inherits(x, 'FlowCamGroup')){ return(invisible(NULL)) }
   cat("FlowCamGroup:", length(x), "dataset(s)\n")
   cat("Default summary path:", attr(x, 'summary_path'), "\n")
   
   lapply(x, function(x) {cat("\n") ; x$show()})
   
}

#' Read one or more FlowCam datasets
#' 
#' @export
#' @param dirlist character vector of one or more paths to FlowCam datasets
#' @param filename character specifies a text file that contains the list of 
#'  directories
#' @return a list of FlowCam objects in a FlowCamGroup class object
#' @examples
#' \dontrun{
#'  XX <- FlowCamGroup(file = "D:/SABOR FCAM Classified/LCL CLASSIFIED_2016-01-20.SABOR.txt")
#' }
FlowCamGroup <- function(dirlist, filename = NULL){

   if (!missing(dirlist)) {
      x <- lapply(dirlist, FlowCam)
      names(x) <- basename(dirlist)
      att <- list(summary_path = dirname(dirlist[1]))
   } else if (!is.null(filename)) {
      if (!file.exists(filename[1])) stop("filename not found:", filename[1])
      dirlist <- readLines(filename[1])
      x <- lapply(dirlist, FlowCam)
      names(x) <- basename(dirlist)
      att <- list(summary_path = dirname(filename[1]))
   } else {
      x <- list()
      att <- list(path = '.')
   }
   

   attributes(x) <- att
   class(x) <- 'FlowCamGroup'
   invisible(x)
}