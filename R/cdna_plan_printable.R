#' @name cdna_plan_printable
#' @title cdna_plan_printable
#'
#' @description Simple script, takes the output from rna2cdna and then makes it an easy to print form for taking ito lab
#'
#' @importFrom magrittr %>%
#'
#' @export

library(tidyverse)

cdna_plan_printable <- function(input_from_rna2cdna){
  #### Make an easy to read printable version for when in the lab doing the experiement
  # (only put minimal needed data, and in the order most useful)
  cdna_synthesis_printable <- cdna_synthesis %>%
    select(A260A280, RNA_quality_rating, path, amount_rna_to_add.ul, amount_water_to_add.ul, rna_added.ug, note)
  # round to 3 DP
  cdna_synthesis_printable$amount_rna_to_add.ul <- round(cdna_synthesis_printable$amount_rna_to_add.ul , 3)
  cdna_synthesis_printable$amount_water_to_add.ul <- round(cdna_synthesis_printable$amount_water_to_add.ul , 3)

  #change labels so easy to read
  colnames(cdna_synthesis_printable)[4:5] <- c("RNA_ul", "Water_ul")

  return(cdna_synthesis_printable)
}
