#' @name rna2cdna
#' @title rna2cdna
#'
#' @description Takes input of qiaxpert output (with a sample identifier #TODO)
#'
#'
#'
#' @importFrom reshape2 melt
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom dplyr filter
#' @importFrom dplyr bind_rows
#' @importFrom dplyr bind_cols
#' @importFrom dplyr group_by
#' @importFrom dplyr mutate
#' @importFrom tidyr spread
#' @importFrom data.table setDT
#'
#' @export

## Function that takes the following INPUT:

## input_rna = a table that has Qiaxpert output columns. Must have the following columns (Anything else will get ignored)
#  - mouse
#  - path
#  -`A260 Concentration (ng/ul)`,`A260/A280`,`A260/A230`, - the qiaexpert outputs.
#  - Notes column  ( ?? might get rid of this in the future)
#optional - a batch effect columned, defined next:

## batch_effect = the colname in the input_rna table that (default)
#               my default: "rna-extraction-batch:

##  desired_rna.ug (default = 2.5) this is the desired ug of RNA want to put into each cDNA reaction

### Description: his is a script for taking the tabulated outputs from the QIAxpert for RNA concentration
### and quality (A260?A280 etc) and making
###     1) assessments on the quality of the RNA.
###     2) calculations necessary for the next step to actually synthesis the cDNA from RNA

library(tidyverse)

rna2cdna <- function(input_rna, desired_rna.ug = 2.5, batch_effect = "rna-extraction-batch"){

  # check that batch_effect names exists in the input data
  if(batch_effect %in% colnames(input_rna))
  {
    # select out mouse, path, batch number, RNA concentration, and the A260/A280 and A260/A230 ratios
    cdna_synthesis <- input_rna %>%
      select(mouse, path, batch_effect, `A260 Concentration (ng/ul)`,`A260/A280`,`A260/A230`, Notes)

    ### Change names to simplofy downstream analysis
    colnames(cdna_synthesis)[3:6] <- c("rna_extraction_batch", "A260_conc_ng.ul", "A260A280", "A260A230")

    cdna_synthesis$rna_extraction_batch <- as.factor(cdna_synthesis$rna_extraction_batch) #factorise batch effect

  } else {

    # select out mouse, path, batch number, RNA concentration, and the A260/A280 and A260/A230 ratios
    cdna_synthesis <- input_rna %>%
      select(mouse, path, `A260 Concentration (ng/ul)`,`A260/A280`,`A260/A230`, Notes)

    ### Change names to simplofy downstream analysis
    colnames(cdna_synthesis)[3:5] <- c("A260_conc_ng.ul", "A260A280", "A260A230")

  }

  ####=========assign RNA quailty score==================
  j <- length(colnames(cdna_synthesis))

  for(i in 1:nrow(cdna_synthesis)) {
    if(cdna_synthesis[i,5] > 2.0) {
      qual = "HIGH"
    } else if(cdna_synthesis[i,5] > 1.8) {
      qual = "GOOD"
    } else if(cdna_synthesis[i,5] > 1.7) {
      qual = "FAIR"
    } else if(cdna_synthesis[i,5] > 1.6) {
      qual = "POOR"
    } else if(cdna_synthesis[i,5] <= 1.6) {
      qual = "BAD"
    } else {
      qual = "ERROR"
    }
    cdna_synthesis[i,j] <- qual # assign qual score
  }
  colnames(cdna_synthesis)[j] <- "RNA_quality_rating"

  #CHECK FOR ERRORS in RNA quality SCORE
  sum(cdna_synthesis$RNA_quality_rating == "ERROR")
  cdna_synthesis$RNA_quality_rating <- as.factor(cdna_synthesis$RNA_quality_rating)  # factorise qual rating

  #order factors for RNA qual rating
  cdna_synthesis$RNA_quality_rating <- factor(cdna_synthesis$RNA_quality_rating,
                                              levels = c("HIGH", "GOOD", "FAIR", "POOR", "BAD", "ERROR"))

  #### ============ CALCULATIONS FOR cDNA REACTIONS =========
  # In this section will make the calcluations of what will add in cDNA synthesis reactions
  # this will allow to print out a sheet to have at lab bech when doing reactions

  cdna_synthesis$ideal_amount_rna_to_add.ul <- desired_rna.ug*1000/cdna_synthesis$A260_conc_ng.ul

  #Prepare empty columns for doing calculations below
  cdna_synthesis$amount_rna_to_add.ul <- rep(NA,nrow(cdna_synthesis))
  cdna_synthesis$amount_water_to_add.ul <- rep(NA,nrow(cdna_synthesis))
  cdna_synthesis$rna_added.ug <- rep(NA,nrow(cdna_synthesis))
  cdna_synthesis$note <- rep(NA,nrow(cdna_synthesis))


  ##### Do calculations and make notes based on concentration of RNA will get
  nrow(cdna_synthesis)

  for(i in 1:nrow(cdna_synthesis)){
    if(cdna_synthesis$ideal_amount_rna_to_add.ul[i] > 8){
      water <- 0
      note <- "Too low Conc - use 8ul RNA and 0ul water"
      rna.ul <- 8
      actual_rna_amount.ug <- cdna_synthesis$A260_conc_ng.ul[i]*8/1000
    } else if(cdna_synthesis$ideal_amount_rna_to_add.ul[i] < 8){
      water <- 8 - cdna_synthesis$ideal_amount_rna_to_add.ul[i]
      note <- "Good"
      rna.ul <- cdna_synthesis$ideal_amount_rna_to_add.ul[i]
      actual_rna_amount.ug <- cdna_synthesis$A260_conc_ng.ul[i]*cdna_synthesis$ideal_amount_rna_to_add.ul[i]/1000
    } else {
      water <- NA
      note <- "ERROR"
      actual_rna_amount.ug <- NA
      rna.ul <- NA
    }
    cdna_synthesis$amount_rna_to_add.ul[i]  <- rna.ul
    cdna_synthesis$amount_water_to_add.ul[i]  <- water
    cdna_synthesis$rna_added.ug[i] <- actual_rna_amount.ug
    cdna_synthesis$note[i] <- note
  }

  return(cdna_synthesis)

}
