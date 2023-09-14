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

# Convert the date column to a Date format
ncbi$Assembly.Release.Date <- as.Date(ncbi$Assembly.Release.Date)

# Extract year from the date
ncbi$Year <- format(ncbi$Assembly.Release.Date, "%Y")

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

# Create new column for technology used
ncbi$tech <- toupper(ncbi$Assembly.Sequencing.Tech)

# Define a custom function to fix spelling errors -  same as for UpSet plot
fix_spelling <- function(tech) {
  tech <- case_when(
    grepl("HIC", tech, ignore.case = TRUE) ~ "HI-C",
    grepl("BGISEQ-500|BGISEQ500|BGISEQ", tech, ignore.case = TRUE) ~ "BGI-SEQ",
    grepl("ILLUMINA\"", tech, ignore.case = TRUE) ~ "ILLUMINA",
    grepl("PACBIO_SMART", tech, ignore.case = TRUE) ~ "PACBIO",
    # Add more replacements as needed
    TRUE ~ tech
  )
  return(tech)
}

# Apply the custom function to the "tech" column of the dataframe
ncbi <- ncbi %>%
  mutate(tech_cleaned = fix_spelling(tech))

# summarise technology types
ncbi <- ncbi %>%
  mutate(tech_type = case_when(
    is.na(tech_cleaned) ~ NA_character_,
    # single technology types
    grepl("ILLUMINA|BGI-SEQ", tech_cleaned) & !grepl("NANOPORE|HI-C|BIONANO|PACBIO", tech_cleaned) ~ "Short-read only",
    grepl("NANOPORE|PACBIO", tech_cleaned) & !grepl("HI-C|ILLUMINA|BIONANO|BGI-SEQ", tech_cleaned) ~ "Long-read only",
    
    # combinations
    grepl("ILLUMINA|BGI-SEQ", tech_cleaned) & grepl("NANOPORE|PACBIO", tech_cleaned) & !grepl("HI-C|BIONANO", tech_cleaned) ~ "Short + long-read",
    grepl("HI-C|BIONANO", tech_cleaned) & grepl("NANOPORE|PACBIO", tech_cleaned) & !grepl("ILLUMINA|BGI-SEQ", tech_cleaned) ~ "Scaffolding + long-read",
    grepl("HI-C|BIONANO", tech_cleaned) & grepl("ILLUMINA|BGI-SEQ", tech_cleaned) & !grepl("NANOPORE|PACBIO", tech_cleaned) ~ "Scaffolding + short-read",
    
    # combination of four technologies
    grepl("ILLUMINA", tech_cleaned) & grepl("PACBIO", tech_cleaned) & grepl("HI-C", tech_cleaned) & grepl("BIONANO", tech_cleaned) & !grepl("BGI-SEQ", tech_cleaned) ~ "Scaffolding + short-read + long-read",
    TRUE ~ "Other"
  ))

# create colour palette
mypal <- c("#3C5488CC", "#4DBBD5CC", "#00A087CC", "#E64B35CC", "#8491B4CC", "#F39B7FCC")

# Generate the plot
ggplot(ncbi, aes(x = Year, fill = tech_type)) +
  geom_bar(position = "stack") +
  labs(title = "", x = "", y = "Number of ref. genomes") +  
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 12),
        axis.title.y = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        legend.text = element_text(size = 12)) +
  scale_fill_manual(values = mypal, na.value = "#999999cc")
