#' @title melt384
#'
#' @description This script takes an input of a 384 well template and melts it to give the value with well position
#'
#' @param samples this is your 384 well plate data (16 x 24 format)
#'
#' @examples
#' samples <- read.csv(my__384_well_plate)   #needs to be
#' samples_tidy <- handytools::melt384(samples)
#'
#' # Example output:
#' #   position   value
#' #      A1      220
#' #      A2      221
#' #      A3      222 , etc....
#'
#' @importFrom reshape2 melt
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#'
#' @export
melt384 <- function(samples){

  #TODO - add in sanity check that it's correct dimensions (see 96 well plate template for how to do)

  samples <- sapply(samples, as.character) # may not be required if all values numeric.
  colnames(samples) <- seq(1:24) #assign column numbers
  rownames(samples) <- LETTERS[1:16] #assign row letters

  samples <- reshape2::melt(samples)
  samples$position <- paste0(samples$Var1, samples$Var2) #add in position number "A1", "A2", etc

  samples <- samples %>%
    dplyr::select(position, value)

  return(samples)
}
