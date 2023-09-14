#-----------------------------------------------------------------------------------------------------------------
# Code to generate Figure 2
#-----------------------------------------------------------------------------------------------------------------


#### Load libraries ----------------------------------------------------------------------------------------------

library(here)         # simplify file paths
library(tidyverse)    # data wrangling+


#### Read in data ----------------------------------------------------------------------------------------------

ncbi <- read.csv(here("data/supp-table-1.csv"))


#### Data wrangling ----------------------------------------------------------------------------------------------

# create a new column that captures the N50 assembly size
ncbi <- ncbi %>%
  mutate(N50size = case_when(
    Assembly.Stats.Contig.N50 >= 1000000 ~ "≥1Mbp",
    TRUE ~ "<1Mbp"
  ))

# Convert the date column to a Date format
ncbi$Assembly.Release.Date <- as.Date(ncbi$Assembly.Release.Date)

# Extract year from the date
ncbi$Year <- format(ncbi$Assembly.Release.Date, "%Y")

#### Figure 2A Bar Plot----------------------------------------------------------------------------------------------

# colour palette
pal <- c("#00A087CC", "#91D1C2CC")

# create plot
ggplot(ncbi, aes(x = Year, fill = N50size)) +
  geom_bar(position = "stack") +
  labs(title = "", x = "", y = "Number of ref. genomes") +  
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 12),
        axis.title.y = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        legend.text = element_text(size = 12),
        legend.position = "top") +
  scale_fill_manual(values=pal)


#### Figure 2B Box Plot ----------------------------------------------------------------------------------------------

# create plots
ggplot(data = ncbi, aes(x = Year, y = Assembly.Stats.Contig.N50, fill = Year)) +
  geom_boxplot() +
  labs(title = " ",
       x = " ",
       y = "Contig N50")+  
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 12),
        axis.title.y = element_text(vjust = 1.5, size = 12),
        axis.text.y = element_text(size = 12),
        legend.text = element_text(size = 12)) +
  guides(fill = FALSE)
 


