#' @name ddct_taq
#' @title ddct_taq
#'
#' @description Taq it easy! Here's a script that takes your CT values for your 18S and gene of interest
#' and does all those sweet ddCT calcs for you
#'
#' @param ct_data_table Pre-prcoessed data here. Needs following minimum columns: "treatment_group", "ct_gene" (can be named anything), and "ct_18S" (can specify name)
#' @param refgroup specfiy which group within the treatment_group column is your reference group (default = "control")
#' @param targetgene Specify EXACTLY name of target gene in the ct_data_table
#' @param refgene Specify EXACTLY name of refence gene in the ct_data_table (default "ct-18s")
#' @param refgene.cutoff CT cutoff for referene gene (default = 15)
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

ddct_taq <- function(ct_data_table, refgroup = "control", targetgene, refgene, refgene.cutoff = 15){

  #TODO sanity check re coulmn names

  #====Deal with Undertermineds and 18S > 15==========
  # Undetermineds
  pcrlong1 <- ct_data_table %>%
    mutate(comment_gene = case_when(ct_data_table[targetgene]  == "Undetermined" ~ "Undetermined Target Gene")) %>%
    mutate(comment_ref = case_when(ct_data_table[refgene] == "Undetermined" ~ "Undetermined Ref Gene",
                                   ct_data_table[refgene] != "Undetermined" & ct_data_table[refgene] > refgene.cutoff ~ "High Ref Gene CT") )

  #================UP TOHERRE WORKS!===============
  #TODO here FIX so removes undetermine
  #makle all CTs numeric: removes "Undertmined" results by coercians
  pcrlong1[targetgene]  <- pcrlong1[targetgene] <- as.numeric(pcrlong1[targetgene])
  pcrlong1[refgene] <- pcrlong1[refgene] <- as.numeric(pcrlong1[refgene])

  #MAke a comment note
  pcrlong1 <- pcrlong1 %>%
    mutate(CT_comment2 = case_when(pcrlong1[refgene] > refgene.cutoff ~ "High 18S CT - Removed"))

  #Replace values over the cutoff value with NA
  pcrlong1$CT_18S[pcrlong1$CT_18S > cutoff18S] <- NA

  ####======= do dCT calc============ ######
  pcrlong1 <- pcrlong1 %>%
    mutate(dCT = CT_Gene - CT_18S)

  head(pcrlong1)
  #====merge with Metadata file========
  pcrlong2 <- pcrlong1
  pcrlong2 <- merge(metadata_sep, pcrlong2, by="sampleID")

  pcrlong2 <- pcrlong2 %>%
    mutate(group = paste(gpr109a_genotype,stz_diabetes,diet,sep="_"))

  #====dtermine acerage dct per group, and pulling out the 'control' group average dct=====
  #note: the control group = "WT_N_LAGE" here

  mean_dct <- pcrlong2 %>%
    group_by(group) %>%
    summarize(mean_dct = mean(dCT, na.rm = T))
  mean_dct

  control_dct <- (mean_dct %>% filter (group==reference.group))[2]
  control_dct <- deframe(control_dct) #make it a value, rather than a tibble

  #=========calculate ddCT and fold change================
  pcrlong3 <- pcrlong2 %>%
    mutate(ddCT = dCT - control_dct) %>%
    mutate(fold_change = 2^-ddCT)

  return(pcrlong3)
}
