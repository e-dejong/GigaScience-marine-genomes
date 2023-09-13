## Manual curation

Some entries need to be removed since they are not marine species. The
inconsistencies have occurred due to inconsistent classification of a
species as “marine” between it’s unaccepted name on WoRMS (often the
curent scientific name) and the accepted name. For example, the species
Aythya fuligula was kept in as “marine” since it’s scientific nameID
`urn:lsid:marinespecies.org:taxname:1453492` is classified as marine on
WoRMS: <https://www.marinespecies.org/aphia.php?p=taxdetails&id=1453492>

``` r
w |> filter(acceptedNameUsageID == "urn:lsid:marinespecies.org:taxname:159164") |> select(acceptedNameUsageID,acceptedNameUsage,scientificName,scientificNameID)
```

    ##                         acceptedNameUsageID acceptedNameUsage  scientificName
    ## 1 urn:lsid:marinespecies.org:taxname:159164   Aythya fuligula Nyroca fuligula
    ## 2 urn:lsid:marinespecies.org:taxname:159164   Aythya fuligula   Anas fuligula
    ##                             scientificNameID
    ## 1 urn:lsid:marinespecies.org:taxname:1453491
    ## 2 urn:lsid:marinespecies.org:taxname:1453492

Six entries have been flagged for removal