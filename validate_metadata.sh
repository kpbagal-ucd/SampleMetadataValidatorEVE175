#!/bin/bash

# Check that file is given into the bash script properly (that we are given an argument)
if [ -z "$1" ]; then
    echo "Error: No file name given. Please give a .tsv file for validation"
    echo "Usage: ./validate_metadata.sh data.tsv"
    exit 1
fi

INPUT=$1

# Check if the file does not exist, and if it does, check that it is actually a .tsv file
if [ ! -f "$INPUT" ]; then
    echo "Error: Input file does not exist. Please use a .tsv file"
    echo "Usage: ./validate_metadata.sh data.tsv"
    exit 1
elif [[ "$INPUT" != *.tsv ]]; then
    echo "Error: Input file is not a .tsv file"
    echo "Usage: ./validate_metadata.sh data.tsv"
    exit 1
fi
