## Manual curation

Some entries need to be removed since they are not marine species. The discrepancies have occurred due to inconsistent classification of a species as "marine" between the unaccepted name on WoRMS (often the current scientific name) and the accepted name. For example, the species Aythya fuligula was kept in as "marine" since it's scientific nameID `urn:lsid:marinespecies.org:taxname:1453492` is [classified as marine](https://www.marinespecies.org/aphia.php?p=taxdetails&id=1453492) on WoRMS. 

``` r
w |> filter(acceptedNameUsageID == "urn:lsid:marinespecies.org:taxname:159164") |> select(acceptedNameUsageID,acceptedNameUsage,scientificName,scientificNameID)
```

    ##                         acceptedNameUsageID acceptedNameUsage  scientificName
    ## 1 urn:lsid:marinespecies.org:taxname:159164   Aythya fuligula Nyroca fuligula
    ## 2 urn:lsid:marinespecies.org:taxname:159164   Aythya fuligula   Anas fuligula
    ##                             scientificNameID
    ## 1 urn:lsid:marinespecies.org:taxname:1453491
    ## 2 urn:lsid:marinespecies.org:taxname:1453492

Six entries have been flagged for removal by domain experts:  
> [Accipiter virgatus](https://www.marinespecies.org/aphia.php?p=taxdetails&id=1611552)  
> [Aythya fuligula](https://www.marinespecies.org/aphia.php?p=taxdetails&id=159164)  
> [Coregonus clupeaformis](https://www.marinespecies.org/aphia.php?p=taxdetails&id=158726)  
> [Hypophthalmichthys nobilis](https://www.marinespecies.org/aphia.php?p=taxdetails&id=154600)  
> [Inia geoffrensis](https://www.marinespecies.org/aphia.php?p=taxdetails&id=254960) 
> [Squalius cephalus](https://www.marinespecies.org/aphia.php?p=taxdetails&id=282855)  
    

Also need to remove one entry from the larger list of marine vertebrates where there is a mis-match between the WoRMS metadata and the website listing. i.e. the metadata has incorrectly classified [Hymenops perspicillatus](https://www.marinespecies.org/aphia.php?p=taxdetails&id=1034745 ) of order Passeriformes as marine.   
  
This leaves a total of 19,800 unique marine species.