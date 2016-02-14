# context.R

#' Read a context file into a Configurator class
#'
#' @export
#' @seealso \url{https://github.com/BigelowLab/configurator}
#' @param filename the name of the context file
#' @param ... other arguments for \code{Configurator()}
#' @return A ConfiguratorRefClass object
read_context <- function(filename, ...){

   if (missing(filename)) stop("filename is required")
   if (!file.exists(filename[1])) stop("file not found:", filename[1])
   Configurator(filename, ...)
}

#' Show the contents of a context object
#'
#' @export
#' @param X the ConfiguratorRefClass context object
show_context <- function(X){
   cat("Version: ", X$get("Software", "SoftwareVersion"), "\n")
   trig <- X$get('Camera', 'AutoTriggerFlag')
   triggerMode <- c("0" = 'Fluorescent', "1" = "Auto")[trig]
   cat("Trigger Mode: ", triggerMode, '\n') 
   cat("Cal Const: ", X$get('Fluid', 'CalibrationConstant'), '\n')
   minESD <- X$get('CaptureParameters', 'MinESD')
   maxESD <- X$get('CaptureParameters', 'MaxESD')
   cat(sprintf("ESD range: %s - %s",minESD, maxESD), "\n")
}