library(tidyverse)
library(arrow)

bigdf <- open_dataset('./obis_20230726.parquet') # downloaded from https://obis.org/data/access/


# The ALA General profile will remove from view records identified:

# with location or spatial issues
# as a possible outlier
# with unaddressed user questions (assertions)
# as being created from environmental DNA analysis or are fossils
# as an absence rather than presence record
# with the date of the occurrence prior to 1700 or the date given is invalid, for example in the future
# with issues in the name given for the organism
# with spatial coordinates that are likely to be inaccurate by 10 kilometres or more
# as a duplicate record.
 
# https://support.ala.org.au/support/solutions/articles/6000240256-getting-started-with-the-data-quality-filters

# I did some of that above; some others weren't included in the first place (see OBIS download page)

bigdf <- bigdf |> dplyr::filter(scientificName %in% df$`Organism Name`) |>
  dplyr::filter(date_year >= 2000) |>
  dplyr::filter(coordinateUncertaintyInMeters < 10000) |>
  dplyr::filter(absence == FALSE)

bigdf2 <- bigdf |> collect()

# Now remove ON_LAND fish and sharks
bigdf3 <- bigdf2 |> dplyr::filter( ! (grepl(x = flags, 'ON_LAND') &  (class == 'Teleostei'))  ) |>
  dplyr::filter(! (grepl(x = flags, 'ON_LAND') &  (class == 'Elasmobranchii')))

# make the plot

my_breaks <- c(1, 20, 400, 8000, 160000)
final_map <- ggplot(worldMap) +
  geom_sf() +
  geom_hex(data = bigdf3 |> dplyr::filter(class %in% c('Elasmobranchii', 'Teleostei')), aes(x = decimalLongitude, y = decimalLatitude,
                             fill = after_stat(count)),
           alpha = 0.8, colour = "white", bins = 50) +
  theme_void() +
  #scale_fill_gradient(name = "Sightings", trans = "log",
  #                     guide="legend", labels = my_breaks, palette=) +
  scale_fill_distiller(name = 'Sightings', trans = "log",
                       guide="legend", labels = my_breaks, palette='Spectral' ) +
  labs(fill='log(counts)')+
  theme(legend.position= 'bottom')

final_map

cowplot::save_plot('final_map.png', base_height = 3.71 * 2, plot = final_map)
cowplot::save_plot('final_map.pdf', base_height = 3.71 * 2, plot = final_map)
