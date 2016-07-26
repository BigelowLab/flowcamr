# FlowCam.R

#' Reference class for FlowCam data
#'
#' @field path the path to the dataset
#' @field name the basename of path
#' @field filelist the listing of relative filepaths
#' @field ctx the context ConfiguratorRefClass
#' @field data a data.frame of .csv exported data
FlowCamRefClass <- setRefClass("FlowCamRefClass",

   field = list(
      path = "character",
      name = "character",
      filelist = 'ANY',
      ctx = "ANY",
      cla = 'ANY',
      data = "ANY"),
   
   methods = list(
      initialize = function(flowcam_path){
         if (missing(flowcam_path)) flowcam_path = .self$path
         if (!file.exists(flowcam_path[1])) stop("path not found:", flowcam_path[1])
         .self$path <- flowcam_path[1]
         .self$name <- basename(.self$path)
         .self$filelist <- list.files(.self$path, recursive = TRUE, include.dirs = FALSE)
         if(!.self$readData()) cat("error reading data\n")
         if(!.self$readContext()) cat("error reading context\n")
         if(!.self$readClassification()) cat("error reading classification\n")
      },
      show = function(){
         cat("Path:", .self$path, "\n")
         if(inherits(.self$ctx, 'ConfiguratorRefClass')) show_context(.self$ctx)
         if(inherits(.self$data, "data.frame")) .self$show_data()
      },
      show_data = function(){
         if (!is.data.frame(.self$data)) return(invisible(NULL))
         s <- .self$volume_summary()
         cat("n_particles:", nrow(.self$data), "\n")
         print(s)      
         invisible(NULL)
      }   
   ) # methods
) # setRefClass



#' Find the indices of particles labeled as identified
#'
#' @name FlowCamRefClass_which_labeled
#' @param label one or more labels to search for
#' @param column the value of the user label column
#' @return zero or more indices of labeled items
NULL
FlowCamRefClass$methods(
   which_labeled = function(label = 'none', column = 'PP_UserLabel'){
      index = integer()
      if (column[1] %in% colnames(.self$data)){
         index <- which(.self$data[,column[1]] %in% label)
      }
      return(index)
   } 
)
#' 
#' Summarize by class and volume
#' 
#' @name FlowCamRefClass_volume_summary
#' @param include_name logical if TRUE include a colume for the data set name
#' @return a data frame of 'UserLabel', 'Count' and 'Volume' or NULL
NULL
FlowCamRefClass$methods(
   volume_summary = function(include_name = FALSE){
      if (!is.data.frame(.self$data)) return(NULL)
      if (all(c('PP_UserLabel', "PP_Vol") %in% colnames(.self$data)) ){
         tx <- table(.self$data[,'PP_UserLabel'])
         x <- split(.self$data, .self$data[,'PP_UserLabel'])
         sx <- sapply(x, function(x) sum(x[,'PP_Vol'], na.rm = TRUE) )
         s <- data.frame(UserLabel = names(tx), Count = as.vector(tx), Volume = sx,
               stringsAsFactors = FALSE) 
      } else {
         s <- data.frame(UserLabel = 'none', Count = nrow(.self$data),
               Volume = NA)
      }
      if (include_name){
         s <- data.frame(name = rep(.self$name, nrow(s)), 
            s, stringsAsFactors = FALSE)
      }
      s
   })

#' Read the classification file
#' 
#' @name FlowCamRefClass_read_classification
#' @return logical
NULL
FlowCamRefClass$methods(
   readClassification = function(){
      OK <- FALSE
      ff <- .self$get_filename("classification")
      if (length(ff)>0) {
         tryCatch(
            .self$cla <- read_classifications(ff),
            finally = OK)
      }
      TRUE
   })


#' Read the context file
#' 
#' @name FlowCamRefClass_read_context
#' @return logical
NULL
FlowCamRefClass$methods(
   readContext = function(){
      OK <- FALSE
      ff <- .self$get_filename("context")
      tryCatch(
         .self$ctx <- read_context(ff),
         finally = OK)
      TRUE
   })

#' Read the data
#' 
#' @name FlowCamRefClass_read_data
#' @return logical
NULL
FlowCamRefClass$methods(
   readData = function(){
      .self$data <- flowcam_read_data(.self)
      !is.null(.self$data)
   })

#' Retrieve a filename by keyword
#'
#' @name FlowCamRefClass_get_filename
#' @param what the keyword describing the file
#' @param test logical if TRUE test for existence
#' @return the fully qualified filename(s)
NULL
FlowCamRefClass$methods(
   get_filename = function(what = c("data", "postdata", "context", "classification", 
      "collage", "mask", "raw", "background", "cal")[1], test = TRUE){
 
   select_files <- function(pattern, files = .self$filelist){
      ix <- grepl(pattern, files)
      files[ix]
   }
   
   ff <- switch(tolower(what),
      "data" = paste0(.self$name, ".csv"),
      "postdata" = file.path(paste0("_", .self$name), paste0(.self$name, ".csv")),
      "context" = paste0(.self$name, ".ctx"),
      "classification" = paste0(.self$name, ".cla"),
      "collage" = select_files(paste0(name, "_[0-9]+\\.tif")),
      "mask" = select_files(paste0(name, "_[0-9]+\\_bin.tif")),
      "raw"= select_files("^raw.*\\.tif$"),
      "background" = select_files("^cal.*\\.tif$"),
      "cal" = select_files("^cal.*\\.tif$"),
      .self$filelist
      )
   
   ff <- file.path(.self$path, ff)
   if(test && (length(ff) > 0)){
      ok <- sapply(ff,file.exists)
      ff <- ff[ok]
   }
   if (length(ff) == 0) ff <- ""
   return(ff)  
})

#' Create an instance of a FlowCamRefClass object
#'
#' @export
#' @param path character directory name (required, must exist)
#' @return a FlowCamRefClass object
FlowCam <- function(path){
   if (missing(path)) stop("path is required")
   if (!file.exists(path[1])) stop("path not found:", path[1])
   FlowCamRefClass$new(path[1])
}

