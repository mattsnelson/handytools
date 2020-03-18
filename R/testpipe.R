#' @title Minimal example to get that pipe workin!
#'
#'
#' @importFrom reshape2 melt
#'
#'

# In DESCRPTION: Imports: reshape2
# At top of this file #' @importFrom reshape2 melt
testpipe_melt <- function(df) {
  reshape2::melt(df)
}
