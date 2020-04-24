#' @name ddct_taq
#' @title ddct_taq
#'
#' @description Taq it easy! Here's a script that takes the Quantstudio RT-PCR output and your PCR template and then will go
#' and make it all good man and do all that sweet ddCT calcs for you (TODO update)
#'
#' @param quantstudio_output This is the 'results" page of the quantstudio output (currently requires to be exactly just at the results - to fix up and make it so just improt whole sheet methinks)
#' @param plate_map #this is a long list of which sample is in which well A1, A2, A3 etc (use output form melt384 for easiness perhaps)
#' @param refgene Specify EXACTLY what you're refence gene is called in the Quantstdio import (default VIC-18S)
#'
#' @importFrom magrittr %>%
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom tidyr spread
#' @importFrom janitor clean_names
#'
#' @export

library(tidyverse)
library(janitor)

ddct_taq <- function(quantstudio_output, plate_map, refgene){

  #TODO make it so just find results on quantstudio page, rather than having to select exactly??#
  #TODO make it so it nicely checks quantstudio input

  # results nicely by well.
  pcr_results <- quantstudio_output %>%
    janitor::clean_names() %>% #clean names
    dplyr::select(well_position,target_name,ct) %>% #selecting out well_postition, 18S/gene and CT value
    dplyr::filter(!is.na(target_name)) %>%    # filter out any empty wells (where the target name is missing (NA))
    tidyr::spread(key = target_name, value = ct)

  pcr_results <- pcr_results %>%    # rearrange so well_position, then refgene and then [3:x] is other genes
    dplyr::select(well_position,
                  names(pcr_results)[names(pcr_results) == refgene],
                  everything())






}
