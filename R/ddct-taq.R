#' @name ddct_sybr
#' @title ddct_sybr
#'
#' @description Workflow for calcuating differential gene expression from quantstudio output using Sybr green reagents.
#'
#' Input must be in this format for this script to work easily
#'
#' Column 1: sample_id
#' Column2: treatment_group
#' Column3 - x: Cts for various genes of interest
#' Last Column: CT for 18S (ideally called "ct_18s")
#'
#' @param input_cts This is the
#' @param ref_group This is the EXACT name of the treatment_group that is being used as a control group for calcluating ddct (i.e. change from this group)
#' @param cutoff_18S This is the cutoff over which 18S values will be discarded (default = 15)
#' @importFrom magrittr %>%
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom tidyr spread
#' @importFrom janitor clean_names
#'
#' @export

library(tidyverse)
library(janitor)

ddct_sybr <- function(input_cts, ref_group, cutoff_18S = 15){

 #TODO check names of coulns is correct.

  #TODO do check qualtiy of CTS against cutoff and also see about undetermineds. Add in CT comment case

  #TODO do dCT cals - make as a loop an iterater per ct_gene (which can pull list from input doc)

  #TODO do ddCT calcs - again iterate per gene

  #TODO make an outlier alert - i.e. so it alerts if any values are outliers in data.


}
