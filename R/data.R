# data.R

#' Identifies 'missingness' in a data frame by examining the value of the
#'  test_col.  If a given row's (test_col <= 0) & (test_col != NaN) the row 
#'  values are changed to NA.
#' 
#' @param x a data.frame
#' @param test_col the name of the column to test (!=0 and !=NaN)
#' @param replace the value to use for the replacement
#' @param keep_col the names of the columns to *not* change
#' @param the transformed data frame
transform_missing <- function(x, test_col = 'Count', replace = NA,
    keep_col = c("Label", "Blob", "Count", "UserLabel")){
    
    nm <- names(x)
    kpnm <- nm %in% keep_col
    chnm <- nm[!kpnm]
    
    # first we look for NaN - IJ now serves up 0 but we'll be ready for the future
    # if no NaN then we look for count == 0
    ix <- is.nan(x[,test_col[1]])
    if (any(ix)){
        x[ix,chnm] <- replace[1]
    } else {
        ix <- x[,test_col[1]] == 0
        if (any(ix)) x[ix, chnm] <- replace[1]
    }
    
    invisible(x)   
}

#' Reads a FlowCam data file, possibly appending post-processed data
#'
#' @export
#' @param X a FlowCamRefClass
#' @return a data.frame with post-processed columns prepended with "PP"
flowcam_read_data <- function(X){

    data_file <- X$get_filename("data")
    if ((nchar(data_file) == 0) || !file.exists(data_file)) {
        cat("data file not found:", data_file, "\n")
        return(NULL)
    }
    x <- try(read.csv(data_file, stringsAsFactors = FALSE))
    if (inherits(x, "try-error")) return(NULL)
    
    post_file <- X$get_filename("postdata")
    if ((nchar(post_file) != 0) || file.exists(post_file)) {
        y <- try(read.csv(post_file, stringsAsFactor = FALSE, row.names = 1))
        
        if (!inherits(y,"try-error")){
            y <- transform_missing(y)
            if (nrow(y) == nrow(x)){
                colnames(y) <- paste0("PP_", colnames(y))
                x <- data.frame(x,y, stringsAsFactors = FALSE)
            } else {
                cat("row counts differ between data and postdata\n")
            }
        }
    }
   
    x
}