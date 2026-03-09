# Sample Metadata Validator for EVE175
Final project script for EVE 175
A bash script to check a TSV file for common errors

## Prerequisites
Standard Linux environment + Bash Shell

## Usage
Run the script from terminal by providing the name of the .tsv file to validate
Example command to run:
`./validate_metadata.sh path/data.tsv`

## Script Functions
This script checks for a few common errors that might occur when making/editing a .tsv file
1) Checks heading line to ensure 4 columns are present: sample_id, species, tissue, and date
2) Checks for missing values from any of the columns
3) Checks for duplicate sampleIDs
4) Checks that dates match the pattern YYYY-MM-DD (but not that it is a valid date)
5) Checks that proper file + file format are given as inputs to the script

For each error found, the script will print an error message with the line number and type of error found
At the end, will summarize total stats:
- Prints total rows scanned (after header line)
- Prints total rows that have any type of error
- Prints total rows that have no error
Script exits with status 1 if any error found, and with status 0 if no errors found in the whole file

## Example
Example Input:
sample_id	species	tissue	date
S001	Human	Blood	2026-03-08
	Mouse	Brain	2026-03-08
S001	Dog	Liver	26-03-08
S004	Cat	Lungs	2026/03/08

Example Output:
Line 3: Missing value in column(s): 'date'
Line 4: Duplicate sample_id 'S001'
Line 4: Invalid date format '26-03-08'
Line 5: Invalid date format '2026/03/08'

Summary: 
Total rows: 4
Rows with errors: 3
Rows passing: 1
