#-----------------------------------------------------------------------------------------------------------------
# Code to generate Figure 1
#-----------------------------------------------------------------------------------------------------------------


#### Load libraries ----------------------------------------------------------------------------------------------

library(here)           # simplify file paths
library(tidyverse)      # data wrangling+
library(UpSetR)         # upset plot
library(ComplexHeatmap) # used for upset plot
library(ggsci)          # plot colour theme

#### Read in data ----------------------------------------------------------------------------------------------

ncbi <- read.csv(here("data/supp-table-1.csv"))


#### Data wrangling ----------------------------------------------------------------------------------------------

# Format the submitter-supplied tech column
tech <- strsplit(toupper(ncbi$"Assembly.Sequencing.Tech"), "\\s+|,")
tech <- lapply(tech, function(x) gsub(";", "", x))

# remove entires from `tech` that only contain NA
tech <- discard(tech, ~all(is.na(.)))

# Define a custom cleaning function to standardise tech input
clean_element <- function(vec) {
  # Replace "HIC" with "HI-C"
  vec[vec == "HIC"] <- "HI-C"
  
  # Replace "10XGENOMICS" with "10X"
  vec[vec == "10XGENOMICS"] <- "10X"
  
  # Replace "BGISEQ," "BGISEQ-500," and "BGISEQ500" with "BGI-SEQ"
  vec[vec %in% c("BGISEQ", "BGISEQ-500", "BGISEQ500")] <- "BGI-SEQ"
  
  # Replace "ILLUMINA\"" with "ILLUMINA"
  vec[vec == "ILLUMINA\""] <- "ILLUMINA"
  
  # Replace "HI-FI" with "HIFI"
  vec[vec == "HI-FI"] <- "HIFI"
  
  # Replace "PACBIO_SMART" with "PACBIO"
  vec[vec == "PACBIO_SMART"] <- "PACBIO"
  
  return(vec)
}

# Apply the cleaning function to each element of the list
cleaned_list <- lapply(tech, clean_element)

# Add names to the list elements
names(cleaned_list) <- 1:length(cleaned_list)

# convert the list to a matrix, specify the universal set (tech terms of interest)
tech.m <- list_to_matrix(cleaned_list, universal_set = c("ILLUMINA","PACBIO","HI-C","NANOPORE","BIONANO","BGI-SEQ"))

# transpose the matrix and create a combination matrix
m1 <- make_comb_mat(t(tech.m))

#### Figure 1A ----------------------------------------------------------------------------------------------

# define colour palette
mypal <- pal_npg("nrc", alpha = 0.9)(6)

UpSet(m1,
      comb_order = order(comb_size(m1), decreasing = T), 
      pt_size = unit(5, "mm"),
      lwd = 3,
      left_annotation = upset_left_annotation(m1),
      comb_col = mypal[comb_degree(m1)])


#### Figure 1B ----------------------------------------------------------------------------------------------