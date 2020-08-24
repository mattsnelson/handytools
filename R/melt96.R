#' @title melt96
#'
#' @description This script takes an input of a 384 well template and melts it to give the value with well position
#'
#' @param samples this is your 96 well plate data (8 x 12 format)
#'
#' @examples
#' samples <- read.csv(my_96_well_plate.csv)
#' samples_long_list <- handytools::melt96(samples)
#'
#' # Example output:
#' #  well_position  sample_id
#' #      A1         220
#' #      A2         221
#' #      A3         222 , etc...
#'
#' @importFrom reshape2 melt
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#'
#' @export

melt96 <- function(samples){

  #check size of data is correct.
  if(nrow(samples) == 8 & ncol(samples) == 12){
  } else {
    error_msg <- paste("You must upload data in a 8 x 12 format (i.e. standard 96 well format). Your template data is",
                       nrow(samples), "x", ncol(samples), "format", sep=" ")
    stop(error_msg)
  }

  samples <- sapply(samples, as.character) # may not be required if all values numeric.
  colnames(samples) <- seq(1:12) #assign column numbers
  rownames(samples) <- LETTERS[1:8] #assign row letters

  samples <- reshape2::melt(samples)
  samples$position <- paste0(samples$Var1, samples$Var2) #add in position number "A1", "A2", etc

  samples <- samples %>%
    dplyr::select(position, value)

  colnames(samples) <- c("well_position", "sample_id")

  return(samples)
}
