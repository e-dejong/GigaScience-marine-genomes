#!/bin/bash
fields=$(<fields.txt)
datasets summary genome taxon Chordata --reference --as-json-lines | dataformat excel genome --fields $fields --outputfile Chordata.xlsx
