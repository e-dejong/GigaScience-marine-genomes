#-----------------------------------------------------------------------------------------------------------------
# Code to generate Table 1
#-----------------------------------------------------------------------------------------------------------------


#### Load libraries ----------------------------------------------------------------------------------------------

library(here)         # simplify file paths
library(tidyverse)    # data wrangling+


#### Read in data ----------------------------------------------------------------------------------------------

ncbi <- read.csv(here("data/supp-table-1.csv"))
mv <- read.csv(here("data/marine-vert-species.csv"))
iucn <- read.csv(here("data/Table4a_IUCNRedList.csv"))


#### Data wrangling ----------------------------------------------------------------------------------------------

## Format data types for IUCN data frame
iucn$Subtotal..threatened.spp.. <- as.numeric(gsub(",", "", iucn$Subtotal..threatened.spp..))
iucn$Total <- as.numeric(gsub(",", "", iucn$Total))

## Remove duplicate species (9 species have two assemblies)
ncbi.orders <- ncbi |> filter(!duplicated("Organism.Name"))
ncbi.orders <- ncbi |> group_by(class,order) |> tally() |> arrange(desc(n))


#### Table 1 ----------------------------------------------------------------------------------------------

## Summarise the number of marine species per order
all.orders <- mv |> group_by(class, order) |> tally() |> arrange(desc(n))

## Add the number of ref genomes available for each order
all.orders$refgenomes <- ncbi.orders$n[match(all.orders$order,ncbi.orders$order)]

## Replace NAs with zeros
all.orders[which(is.na(all.orders$refgenomes)),"refgenomes"] <- 0

## Add a column that calculates % representation of each order
all.orders <- all.orders |> mutate(Percentage = round((refgenomes / n) * 100, 1))

## Calculate % threatened
iucn$PT <- round((iucn$Subtotal..threatened.spp..  / iucn$Total)*100,2)

## Add IUCN data to the table
all.orders$PT <- iucn$PT[match(toupper(all.orders$order), iucn$Name)]
all.orders$TT <- iucn$Subtotal..threatened.spp..[match(toupper(all.orders$order), iucn$Name)] # total threatened

## Print the table
all.orders |> arrange(class,order) |> print(n=200)





