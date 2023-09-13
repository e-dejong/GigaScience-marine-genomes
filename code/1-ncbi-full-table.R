#-----------------------------------------------------------------------------------------------------------------
# Code to generate Supplementary Table 1
#-----------------------------------------------------------------------------------------------------------------


#### Load libraries ----------------------------------------------------------------------------------------------

library(here)         # simplify file paths
library(tidyverse)    # data wrangling+
library(readxl)       # read excel files


#### Read in data ----------------------------------------------------------------------------------------------

w <- read.csv(here("data/marine-species.csv"))
df <- read_xlsx(here("data/Chordata.xlsx"))
iucn <- read.csv(here("data/Table4a_IUCNRedList.csv"))


#### Data wrangling ----------------------------------------------------------------------------------------------

## Remove non-marine assemblies from NCBI data - match on either accepted name or scientific name
mv <- df |> filter(`Organism Name` %in% w$acceptedNameUsage | `Organism Name` %in% w$scientificName)

## Add taxonomic data 

# genus
mv <- mv |> mutate(genus = ifelse(`Organism Name` %in% w$`acceptedNameUsage`, w$genus[match(`Organism Name`, w$`acceptedNameUsage`)],
                                  ifelse(`Organism Name` %in% w$`scientificName`, w$genus[match(`Organism Name`, w$`scientificName`)],
                                         NA)))

# family
mv <- mv |> mutate(family = ifelse(`Organism Name` %in% w$`acceptedNameUsage`, w$family[match(`Organism Name`, w$`acceptedNameUsage`)],
                                   ifelse(`Organism Name` %in% w$`scientificName`, w$family[match(`Organism Name`, w$`scientificName`)],
                                          NA)))

# order
mv <- mv |> mutate(order = ifelse(`Organism Name` %in% w$`acceptedNameUsage`, w$order[match(`Organism Name`, w$`acceptedNameUsage`)],
                                  ifelse(`Organism Name` %in% w$`scientificName`, w$order[match(`Organism Name`, w$`scientificName`)],
                                         NA)))

# class
mv <- mv |> mutate(class = ifelse(`Organism Name` %in% w$`acceptedNameUsage`, w$class[match(`Organism Name`, w$`acceptedNameUsage`)],
                                  ifelse(`Organism Name` %in% w$`scientificName`, w$class[match(`Organism Name`, w$`scientificName`)],
                                         NA)))

## Re-order the columns
mv <- mv %>%
  relocate(genus, family, order, class, .after = `Organism Common Name`)

## Remove invertebrates
mv <- mv |> filter(!class %in% c("Appendicularia","Ascidiacea","Leptocardii","Thaliacea"))
wv <- w |> filter(!class %in% c("Appendicularia","Ascidiacea","Leptocardii","Thaliacea"))

## Retain "accepted" names only to obtain full list of marine species
wv.species <- wv |> filter(taxonomicStatus == "accepted")

## Check for duplicates 
table(duplicated(mv$`Assembly Accession`))
table(duplicated(wv.species$acceptedNameUsage))

## Remove the duplicates (not removing the duplicate from the full list of species)
mv <- mv |> filter(!duplicated(mv$`Assembly Accession`))


#### Manual curation ----------------------------------------------------------------------------------------------

## Remove species that have incorrectly been labelled as marine - see `docs/1-ncbi-data.md` for full explanation
mv <- mv |> filter(!`Organism Name` %in% c("Accipiter virgatus","Aythya fuligula","Coregonus clupeaformis","Hypophthalmichthys nobilis","Inia geoffrensis","Squalius cephalus"))
wv.species <- wv.species |> filter(!scientificName == "Hymenops perspicillatus")


#### Supplementary Table 1 ----------------------------------------------------------------------------------------------

## Reduce number of columns - keep those of interest
ST1 <- mv |> select("Assembly Accession",
                    "Organism Name",
                    "Organism Common Name",
                    "Organism Taxonomic ID",
                    "class",
                    "order",
                    "family",
                    "genus",
                    "Assembly Release Date",
                    "Assembly Sequencing Tech",
                    "Assembly Stats Contig N50")

## Print the table
ST1 |> print(n=700)

#### Export data ----------------------------------------------------------------------------------------------

## Export the cleaned data - used for Table 1, and Figures 1 and 2
write.csv(ST1, here("data/supp-table-1.csv"), row.names = F)
write.csv(wv.species, here("results/marine-vert-species.csv"), row.names = F)


