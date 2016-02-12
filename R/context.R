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