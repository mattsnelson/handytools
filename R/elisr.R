#' @name elisr
#' @title elisr
#'
#' @description This script groups together the ODs for the same sample/standard, calculates the mean, SD and %CV between them and
#' then calcluates the mean - blank. Is agnostic to postion/number of samples/standards on the plate. (Got 4 replicates of one random sample spread out all over the plate - no worries!)
#'
#' @param template this is 96 well plate template
#' @param od this is the OD data (can be absorbance/fluoro/etc) - in 96 well format
#' @param blank the value in the plate template that specifies which position contains the blank (default = "B")
#'
#' @examples
#' elisr(my_template, my_results, "BLK)
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
### Plate Template (96 well plate template)
### Absorbance Values (96 well)

##and provides the output in a SPREAD format
### inculding: mean OD, standard deviation of OD and % CV of OD
### and OD-blank)

##function argulents to sepcify:
### 1) template (8 x 12)
### 2) absorance values (8 x 12)
### 3) what the blank is called (default is B)

library(tidyverse)
library(data.table)

elisr <- function(template, od, blank = "B"){

  #check size of template data is correct.
  if(nrow(template) == 8 & ncol(template) == 12){
    print("template in correct format")
  } else {
    error_msg <- paste("You must upload data in a 8 x 12 format (i.e. standard 96 well format). Your template data is",
                       nrow(template), "x", ncol(template), "format", sep=" ")
    stop(error_msg)
  }

  #check size of absorbance data is correct.
  if(nrow(od) == 8 & ncol(od) == 12){
    print("Absorbance in correct format")
  } else {
    error_msg <- paste("You must upload data in a 8 x 12 format (i.e. standard 96 well format). Your OD data is",
                       nrow(od), "x", ncol(od), "format", sep=" ")
    stop(error_msg)
  }

  #Initialise long_list (for adding matched values too)
  long_list <- t(as.data.frame(c("temp",2)))
  colnames(long_list) <- c("sample ID","OD")
  long_list <- long_list[-1,]

  ##=========loop through each well on the plate layouth and the OD output - create LONG list=============
  for(y in 1:12){

    for(x in 1:8){
      current_well <- as.data.frame(c(template[x,y],od[x,y]))
      colnames(current_well) <- c("sample ID","OD")
      long_list <- dplyr::bind_rows(long_list,current_well)
    }

  }

  ##============================================= SPREAD DATA =============================================
  #1. Melt data and add dummy variable
  melted_list <- reshape2::melt(long_list, id.vars="sample ID")
  melted_list <- melted_list %>% dplyr::filter(`sample ID` != "NA")  # remove any rows that were not accounted for by the plate template
  melted_list <- melted_list %>% dplyr::select(-variable) #get rid of unnecessary column
  melted_list <- melted_list %>%  #add dummy variable
    dplyr::group_by(`sample ID`) %>%
    dplyr::mutate(grouped_id = row_number())

  #2. Spread, get rid of dummy variable and transpose the data
  spread_list <- as.data.frame(t(melted_list %>%
                                   tidyr::spread(`sample ID`, value) %>%
                                   dplyr::select(-grouped_id)))

  ##========================================== ADD MEAN, STDEV, %CV ========================================

  for_calc_sd <- spread_list #make a copy for doing SD below

  #rename columns with OD values to OD1, OD2...OD X
  ncols <- ncol(spread_list) #
  colnames_OD <- paste("OD",rep(1:ncols),sep="")
  colnames(spread_list) <- colnames_OD

  ###make rownames part data frame (so don't lose later)
  data.table::setDT(spread_list, keep.rownames = TRUE)[]
  colnames(spread_list)[1] <- "sample ID"

  ncol_new <- ncols+1  #number of cols now (coz have added in row names)

  ## ADD MEAN
  spread_list_w_mean <- spread_list %>% dplyr::mutate(mean = rowMeans(.[,2:ncol_new], na.rm = TRUE))

  ## ADD SD
  with_sd_calc <- transform(for_calc_sd, SD=apply(for_calc_sd,1, sd, na.rm = TRUE))

  #TODO remove: write.csv(spread_list_w_mean,"temp_mean.csv") (FOR DEBUGGING)
  #TODO remove: wwrite.csv(with_sd_calc,"temp_sd.csv") (FOR DEBUGGING)

  spread_list_w_mean_sd <- bind_cols(spread_list_w_mean,with_sd_calc[length(colnames(with_sd_calc))])

  ## ADD %CV
  spread_list_w_mean_sd_cv <- spread_list_w_mean_sd %>%
    dplyr::mutate(CV_percent = SD/mean * 100)

  #TODO remove: write.csv(spread_list_w_mean_sd_cv,"temp_with_cv.csv") (FOR DEBUGGING)
  ##====================================== ADD MEAN-BLANK====================================

  blank_mean <- spread_list_w_mean_sd_cv %>%  ##grab out blank mean
    filter(`sample ID` == blank) %>%
    dplyr::select(mean)

  blank_mean <- as.numeric(blank_mean) # convert from data frame to a number

  spread_list_w_mean_sd_cv_blank_corrected <- spread_list_w_mean_sd_cv %>%
    mutate(mean_OD_minus_blank = mean - blank_mean)

  ##================================== OUTPUT FINAL SPREAD DATA ================================
  return(spread_list_w_mean_sd_cv_blank_corrected)

}
