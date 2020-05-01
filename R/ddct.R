#' @name ddct
#' @title ddct
#'
#' @description Taq it easy! Here's a script that takes your CT values for your 18S and gene of interest
#' and does all those sweet ddCT and fold change calcs for you
#'
#' @param ct_data_table Pre-prcoessed data here. Needs following minimum columns: "group" (necessary), "ct_gene" (can be named anything), and "ct_18S" (can specify name)
#' @param refgroup specfiy which group within the treatment_group column is your reference group (default = "control")
#' @param targetgene Specify EXACTLY name of target gene in the ct_data_table
#' @param refgene Specify EXACTLY name of refence gene in the ct_data_table (default "ct-18s")
#' @param refgene.cutoff CT cutoff for referene gene (default = 15)
#'
#' @importFrom magrittr %>%
#' @importFrom magrittr %>%
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr mutate
#' @importFrom dplyr mutate_at
#' @importFrom tidyr spread
#' @importFrom janitor clean_names
#'
#' @export

library(tidyverse)
library(janitor)

ddct <- function(ct_data_table, refgroup = "control", targetgene, refgene, refgene.cutoff = 15){

# Sanity check the inputs
  if("group" %in% colnames(ct_data_table)){
  }else{
    error_msg <- "Your data table does not contain a 'group' column. The column names in your table are: "
    error_msg2 <- colnames(ct_data_table)
    stop(error_msg, error_msg2)
  }

  if(refgroup %in% ct_data_table$group){
  }else{
    error_msg <- (paste0("Your specified reference group '", refgroup ,"' isn't present in the group column of the data frame. The groups in the group column are: "))
    error_msg2 <- unique(ct_data_table$group)
    stop(error_msg, error_msg2)
  }

  if( targetgene %in% colnames(ct_data_table)){
  }else{
    error_msg <- (paste0("Your specified target gene name '", targetgene ,"' isn't a column name. The column names in your table are: "))
    error_msg2 <- colnames(ct_data_table)
    stop(error_msg, error_msg2)
  }

  if( refgene %in% colnames(ct_data_table)){
  }else{
    error_msg <- (paste0("Your specified reference gene name '", refgene ,"' isn't a column name. The column names in your table are: "))
    error_msg2 <- colnames(ct_data_table)
    stop(error_msg, error_msg2)
  }

#====Deal with Undertermineds and Refgene over the cutoff==========
  # Commenting re: Undetermined / High Ref genes
  pcrlong1 <- ct_data_table %>%
    dplyr::mutate(comment_gene = case_when(ct_data_table[targetgene]  == "Undetermined" ~ "Undetermined Target Gene")) %>%
    dplyr::mutate(comment_ref = case_when(ct_data_table[refgene] == "Undetermined" ~ "Undetermined Ref Gene",
                                   ct_data_table[refgene] != "Undetermined" & ct_data_table[refgene] < refgene.cutoff ~ "High Ref Gene CT") )
  # any Undetermined values get replaced with NAs
  pcrlong1 <- pcrlong1 %>%
    dplyr::mutate_at(vars(colnames(pcrlong1[targetgene]),
                   colnames(pcrlong1[refgene])),
              na_if, "Undetermined")

  #Replace values for the refgene that are over the refgene cutoff value with NA
  pcrlong1[[refgene]][pcrlong1[[refgene]] < refgene.cutoff  ] <- NA

  # make sure CT values are numeric (if undetermineds in there, will be character)
  pcrlong1[[targetgene]] <- as.numeric(pcrlong1[[targetgene]])
  pcrlong1[[refgene]] <- as.numeric(pcrlong1[[refgene]])

  # do dCT calc
  pcrlong1 <- pcrlong1 %>%
    dplyr::mutate(dCT = pcrlong1[[targetgene]] - pcrlong1[[refgene]])

  #====dtermine average dct per group, and pulling out the 'control' group average dct=====
  pcrlong2 <- pcrlong1

  mean_dct <- pcrlong2 %>%
    dplyr::group_by(group) %>%
    dplyr::summarize(mean_dct = mean(dCT, na.rm = T))

  control_dct <- (mean_dct %>% filter (group==refgroup))[2]  #pulls out the mean dCT of the control group
  control_dct <- deframe(control_dct) #make it a value, rather than a tibble

  #=========calculate ddCT and fold change================
  pcrlong3 <- pcrlong2 %>%
    dplyr::mutate(ddCT = dCT - control_dct) %>%
    dplyr::mutate(fold_change = 2^-ddCT)

  return(pcrlong3)
}
