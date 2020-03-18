#' @title melt384
#'
#' @desription This script takes an input of a 384 well template and melts it to give the value with well position

#'
#' Testing first as a simple function (takes 2 inputs)
#'
#' @param x this is the first number to input
#' @param y this is the second number to input
#'
#' @examples
#' samples <- any_384_well_dataframe # needs to be 24 x 16
#' melt384(samples)
#' output:
#'      A1  220
#       A2  221
#       A3  222 , etc/#'
#'
#' @importFrom reshape2 melt
#'
#' @import magrittr
#'
#' @export

melt384 <- function(samples){

  #TODO - add in sanity check that it's correct dimensions (see 96 well plate template for how to do)

  samples <- sapply(samples, as.character) #TODO add a check here may not be required if all values numeric.
  colnames(samples) <- seq(1:24) #assign column numbers
  rownames(samples) <- LETTERS[1:16] #assign row letters

  samples <- melt(samples)
  samples$position <- paste0(samples$Var1, samples$Var2) #add in position number "A1", "A2", etc

  samples <- samples %>%
    select(position, value)

  return(samples) #TODO check this works; this should output the tidy list
}
