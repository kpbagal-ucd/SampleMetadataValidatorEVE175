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

# Check header list, ensure that all 4 headers are there
expected_header=("sample_id" "species" "tissue" "date")
missing_header=()

# Iterate through columns to check that all are present
for column in "${expected_header[@]}"; do
    if !(head -n 1 "$INPUT" | grep -qw "$column"); then
        missing_header+=("$column")
    fi
done
# Print out missing columns if needed
if [ ${#missing_header[@]} -ne 0 ]; then
    echo "Error: Missing column(s): ${missing_header[*]}"
    exit 1
fi
