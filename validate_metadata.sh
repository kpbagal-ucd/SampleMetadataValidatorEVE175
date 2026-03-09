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

# Checking individal rows for proper formatting
# Checks for a few things: Missing values, duplicate sample IDs, and proper date format

seenIDs=" "
# Line at 2 bc first line is header
lineNum=2
errorLines=0

# Read file line by line (starting after header)
# Different columns values are auto-assigned to the variables defined in the loop every line
while read -r sample_id species tissue date; do
    lineFailed="false"

    # Check if any of the columns are missing a value in a given lines
    missing_vals=()
    if [ -z "$sample_id" ]; then
        missing_vals+=("sample_id")
    fi
    if [ -z "$species" ]; then
        missing_vals+=("species")
    fi
    if [ -z "$tissue" ]; then
        missing_vals+=("tissue")
    fi
    if [ -z "$date" ]; then
        missing_vals+=("date")
    fi
    if [ ${#missing_vals[@]} -ne 0 ]; then
        echo "Line $lineNum: Missing value in column(s): '${missing_vals[*]}'"
        lineFailed="true"
    fi

    # Check duplicate sample IDs
    if [ -n "$sample_id" ]; then
        if [[ "$seenIDs" == *" $sample_id "* ]]; then
            echo "Line $lineNum: Duplicate sample_id '$sample_id'"
            lineFailed="true"
        else
            seenIDs+="$sample_id "
        fi
    fi

    # Proper date matching
    if [ -n "$date" ]; then
        if [[ ! "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            echo "Line $lineNum: Invalid date format '$date'"
            lineFailed="true"
        fi
    fi

    # Add one failed line if any of the above failed
    if [[ "$lineFailed" == "true" ]]; then
        ((errorLines+=1))
    fi

    #Add to line number to keep proper track
    ((lineNum+=1))
done < <(tail -n +2 "$INPUT")

# Summary Stats
# -2 bc started 1 line ahead and while loop ends 1 number ahead of last line
totalLinesRead=$((lineNum - 2))
goodLines=$((totalLinesRead - errorLines))
echo -e "\nSummary:"
echo "Total rows: $totalLinesRead"
echo "Rows with errors: $errorLines"
echo "Rows passing: $goodLines"

# Check if no errors and exit accordingly
if (( errorLines == 0 )); then
    exit 0
else
    exit 1
fi
