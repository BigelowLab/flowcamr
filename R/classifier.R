# classifier.R

#' Scans a class block which include particle ID
#'
#' Produces a \code{klass} object which is a list of 
#' \itemize{
#'    \item name character, the name of the class (user label)
#'    \item andor character, either \code{and} or \code{or}
#'    \item n_filters numeric, the number of filters
#'    \item filters character, zero or more filter names
#'    \item n_particles numeric,the number of particles labels in this class
#'    \item particles character, the particle IDs
#' }
#' 
#' @param txt the block of text to scan
#' @param iline the starting line
#' @return a list of klass and iline
scan_class <- function(txt, iline){
   if (iline >= length(txt)) return(list(class = NULL, iline = iline))
   name <- txt[iline]
   iline <- iline + 1
   andor <- txt[iline]
   iline <- iline + 1
   n_filters <- as.numeric(txt[iline])
   iline <- iline + 1
   if (n_filters > 0){
      filters <- txt[iline:(iline+n_filters - 1)]
      iline <- iline + n_filters
   } else {
      filters = character()
   }
   n_particles <- as.numeric(txt[iline])
   iline <- iline + 1
   if (n_particles > 0){
      particles <- txt[iline:(iline+n_particles - 1)]
      iline <- iline + n_particles 
   } else {
      particles = character()
   }
   x <- list(
         name = name,
         andor = andor,
         n_filters = n_filters,
         filters = filters,
         n_particles = n_particles,
         particles = particles)
   class(x) <- 'klass'
   list(
      class = x,
      iline = iline
   )
}

#' Scans a classification block which is comprised of zero or more classes bundled
#' into groups of 'klassifcation'
#' 
#' The \code{klassification} class is a list of the following
#' \itemize{
#'    \item name character, the name of the classification group 
#'    \item n_classes numeric, the number of klass objects
#'    \item classes list, zero of more klass objects
#' }
#'
#' @param txt the input text vector
#' @param X FlowCam_class object
#' @param iline the starting line
#' @return the updated list of X and iline
scan_classification <- function(txt, X, iline){
   
   if (iline >= length(txt)) return(X)
   if (length(X[['classifications']]) >= X[['n_classifications']]) return(X)
   classification_name <- txt[iline]
   iline <- iline + 1
   n_classes <- as.numeric(txt[iline])
   iline <- iline + 1
   classes <- list()
   for (n in seq_len(n_classes)){
      x <- scan_class(txt, iline)
      if(is.null(x[['class']])) {
         iline <- x[['iline']]
         break
      }
      iline <- x[['iline']]
      classes[[x[['class']]$name]] <- x[['class']]
   }
   
   classification <- list(
         name = classification_name,
         n_classes = n_classes,
         classes = classes)
   class(classification) <- 'klassification'
   X[['classifications']][[classification_name]] <- classification
   list(X = X, iline = iline)
}


#' Give a list of klasses, return a data.frame of [class_name, particle_id]
#' 
#' @param x a list of klass objects
#' @return data.frame
unpack_classes <- function(x){
   xx <- lapply(x,
      function(x){
         if(x$n_particles > 0){
            z <- data.frame(
               class_name = rep(x$name, x$n_particles), 
               particle_id = x$particles, 
               stringsAsFactors = FALSE)
         } else {
            z <- data.frame()
         }
      })
   do.call(rbind, xx)
} 
   

#' Given a FlowCam_class object, return a data.frame of 
#'     [class_name, particle_id, classification]
#'
#' @param X a FlowCam_class object
#' @return data.frame
unpack_classifications <- function(X){

   zz <- lapply(X[['classifications']],
      function(x){
         unpack_classes(x[['classes']])
      })
   for (nm in names(X[['classifications']])){
      zz[[nm]] <- data.frame(zz[[nm]], 
         classification = rep(nm, nrow(zz[[nm]])),
         stringsAsFactors = FALSE)
   }
   r <- do.call(rbind, zz)   
   rownames(r) <- NULL
   r
}


#' Read a classification table from a .cla file
#' 
#' Produces a \code{FlowCam_class} object whihc may be converted to \code{data.frame}.
#' The \code{FlowCam_class} is a list of the following...
#' \itemize{
#'    \item version character, the .cla version
#'    \item n_classifications numeric, the number of classifications
#'    \item classifications, a list of zero or more \code{klassification} objects
#' }
#'
#' @param filename the name of the file
#' @param form character, desired output - either 'data.frame' or 'FlowCam_class'
#' @return either a FlowCam_class object or a data.frame 
read_classifications <- function(filename,
   form = c("data.frame", "FlowCam_class")[1]){

   if (missing(filename)) stop("filename is required")
   if (!file.exists(filename[1])) stop("file not found:", filename[1])
   
   txt <- readLines(filename[1])
   X <- list(
      version = txt[1],
      n_classifications = as.numeric(txt[2]),
      classifications = list()
      )
   class(X) <- 'FlowCam_class'
   iline <- 3
   if (X[['n_classifications']] > 0){
       for (i in seq_len(X[['n_classifications']])){
         #cat('read_classifications n =', i, " iline =", iline, "\n")
         x <- scan_classification(txt, X, iline)
         X <<- X <- x[['X']]
         iline <<- iline <- x[['iline']]
      } # i loop
   } # n_classification > 0
   
   if(tolower(form) == 'data.frame') X <- unpack_classifications(X)
   
   invisible(X)
}


#' Convert a .cla file to a flat table in CSV format
#'
#' @param filename the name of the file
#' @param dest the name of the destination file, by default '<filename.cla>.csv'
#' @return the data.frame invisibly
export_classifications <- function(filename, dest){
   if (missing(filename)) stop("filename is required")
   if (!file.exists(filename[1])) stop("file not found:", filename[1])   
   if (missing(dest)) dest <- paste0(filename, ".csv")
   x <- read_classifications(filename[1], form = 'data.frame')
   write.csv(x, file = dest[1], row.names = FALSE, quote = FALSE)
   invisible(x)
}

read_classification_example <- function(){
   
}
