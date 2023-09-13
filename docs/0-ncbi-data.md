## NCBI Command Line Interface tool

### Installation

```
conda create -n ncbi
conda activate ncbi
conda install -c conda-forge ncbi-datasets-cli

datasets --version
```
```
datasets version: 15.11.0
```

### Documentation

https://www.ncbi.nlm.nih.gov/datasets/docs/v2/reference-docs/data-reports/genome-assembly/  
https://www.ncbi.nlm.nih.gov/datasets/docs/v2/how-tos/genomes/get-genome-metadata/  

### Running the CLI tool

Have first created a .txt file containing all of the metadata fields to include in the download `data/fields.txt` - essentially this is all available fields minus a few relating to BioSample metadata (initially kept these in, but the data is not needed for our purposes and introduces multiple lines per assembly which is undesirable).  
  
To run the tool, execute `ncbi-script.sh` which runs the following line, pulling in the fields from `fields.txt`

```
datasets summary genome taxon Chordata --reference --as-json-lines | dataformat excel genome --fields $fields --outputfile Chordata.xlsx
```

The resulting excel file is available here: `/data/Chordata.xlsx` (compiled on 01/08/2023)