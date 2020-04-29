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
  pcr_results <- pcr_results %>%
    janitor::clean_names() %>% #clean names
    dplyr::select(well_position,target_name,ct) %>% #selecting out well_postition, 18S/gene and CT value
    dplyr::filter(!is.na(target_name))

  genetargets <- unique(pcr_results$target_name) # grab a list of all the genes (at this point includes 18S)
  genetargets <- genetargets[ genetargets != refgene ]  #removes 18S from list of gene targets on plate

  pcr_results <- pcr_results %>%    # filter out any empty wells (where the target name is missing (NA))
    tidyr::spread(key = target_name, value = ct)

  pcr_results <- merge(pcr_results,plate_map,by="well_position",all.x=T,all.y=F) #merge with sample ID number (handy for later methinks)

  #TODO here remain refgene (or continue with refgene methinks?)

  # then do a loop based on number of gene targets
  for(i in genetargets){

    #first up make a table for just this gene
    #TODO add in sampeID too methinks
    current_gene <- pcr_results %>%
      select(well_position,                            # well position
             colnames(pcr_results[i]),                 # gene of interst
             colnames(pcr_results[refgene]))           # reference gene

    head(current_gene)
    #TODO drop nas form this list methikns

    #then pull in all the commands re: doing ddCT etc here


  }
  #then will have to do an rbind at the end I think to get them all out perhaps??
  # as a single return


}
