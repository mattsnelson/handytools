#' @name prismify
#' @title prismify
#'
#' @description Takes a tidy dataset with two columns (column 1: group, column 2: value) and then arranges so each group is it's own column, to make it easy to put into prism.
#'
#' @importFrom magrittr %>%
#' @importFrom tidyr pivot_wider
#' @importFrom dplyr select
#' @importFrom dplyr group_by
#'
#' @export

library(tidyverse)

prismify <- function(input_tidy_data){
  # check that oly 2 columns in tnput datw
  if(ncol(input_tidy_data) == 2){
    print("template in correct format")
  } else {
    error_msg <- paste("You must upload data that has 2 columns (group and values). Your data is",
                       nrow(input_tidy_data), "x", ncol(tinput_tidy_data), "format", sep=" ")
    stop(error_msg)
  }

  #make a temp id for allowing to move data into wider format
  input_tidy_data[3] <- c(1:nrow(input_tidy_data))
  colnames(input_tidy_data) <- c("group", "value", "temp_id1")

  # creates an output with each group in a different column. It's not the prettiest, but can be dropped straight into prism
  data.wide1 <- input_tidy_data%>%
    tidyr::pivot_wider(names_from = group,
                values_from = value) %>%
    dplyr::select(-temp_id1)

  #### makes the prism output much prettier
  # find max number of samples per group
  n <-  input_tidy_data %>%
    dplyr::group_by(group) %>%
    summarise(no_rows = length(group)) %>%
    dplyr::select(no_rows) %>%
    max()

  #initialise empty data frame with ID
  data.wide.out = data.frame(c(1:n))
  colnames(data.wide.out)[1] <- "temp_id"

  for(i in 1:length(colnames(data.wide1)) ){
    current <- data.wide1[,i] %>% drop_na()
    current_name <- colnames(current)[1]
    data.wide.out <- bind_cols(data.wide.out, pull(current)[1:n]) # lose colname here
    colnames(data.wide.out)[i+1] <- current_name # rename column again
  }
  # remove temp_id
  data.wide.out <- data.wide.out %>% select(-temp_id)

  return(data.wide.out)
}
