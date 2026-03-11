#!/bin/bash

PASS=0
FAIL=0
BadFile="bad_file.tsv"
GoodFile="good_file.tsv"
BadExpected="bad_expected.txt"
GoodExpected="good_expected.txt"
BadOutput="bad_output.txt"
GoodOutput="good_output.txt"

# Set up text files (Bad)
cat << 'EOF' > "$BadFile"
sample_id	species	WRONG	date
S001	Human	Blood	03-08-26
	Mouse	Brain	2026-03-08
S001	Dog	Liver	26-03-08
S004	Cat	Lungs	2026/03/08
EOF

cat << 'EOF' > "$BadExpected"
Line 1: Missing column(s): tissue
Line 2: Invalid date format '03-08-26'
Line 3: Missing value in column(s): 'sample_id'
Line 4: Duplicate sample_id 'S001'
Line 4: Invalid date format '26-03-08'
Line 5: Invalid date format '2026/03/08'

Summary:
Total rows: 4
Rows with errors: 4
Rows passing: 0
EOF

# Running the files
# Save both good output + answer
./validate_metadata.sh "$BadFile" > "$BadOutput" 2>&1
bExitCode=$?

# Test 1, file with errors on all lines
# Check that expected output is same as actual output and exited with code 1
if (diff -q "$BadExpected" "$BadOutput" > /dev/null && [ $bExitCode -ne 0 ]); then
    echo "PASS: Caught all errors in full-error file and exited with code 1"
    ((PASS++))
else
    echo "FAIL"
    echo "Exit code expected = 1, Exit code actual = $bExitCode"
    diff "$BadExpected" "$BadOutput"
    ((FAIL++))
fi

# Set up text files (Good)
cat << 'EOF' > "$GoodFile"
sample_id	species	tissue	date
S001	Human	Blood	2026-03-08
S002	Mouse	Brain	2026-03-09
S003	Dog	Liver	2026-03-10
EOF

cat << 'EOF' > "$GoodExpected"

Summary:
Total rows: 3
Rows with errors: 0
Rows passing: 3
EOF

./validate_metadata.sh "$GoodFile" > "$GoodOutput" 2>&1
gExitCode=$?

# Test 2, file with no errors
# Check that expected output is same as actual output and exited with code 0
if (diff -q "$GoodExpected" "$GoodOutput" > /dev/null && [ $gExitCode -eq 0 ]); then
    echo "PASS: No errors in file with no errors and exited code 0"
    ((PASS++))
else
    echo "FAIL"
    echo "Exit code expected = 0, Exit code actual = $gExitCode"
    diff "$GoodExpected" "$GoodOutput"
    ((FAIL++))
fi

# Test 3, call script with no arguments
./validate_metadata.sh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "PASS: exits with error when given no argument"
    ((PASS++))
else
    echo "FAIL: should exit with error for no argument"
    ((FAIL++))
fi

# Test 4, call script with non existant file
./validate_metadata.sh /tmp/NoFile.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "PASS: exits with error when given nonexistent file"
    ((PASS++))
else
    echo "FAIL: should exit with error for nonexistent file"
    ((FAIL++))
fi

# Test 5, call script with non-tsv file
./validate_metadata.sh /validate_metadata.sh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "PASS: exits with error when given non-tsv file"
    ((PASS++))
else
    echo "FAIL: should exit with error for nonexistent file"
    ((FAIL++))
fi

# Get rid of files that we made for the test script
rm -f "$BadFile" "$GoodFile" "$BadExpected" "$GoodExpected" "$BadOutput" "$GoodOutput"

echo ""
echo "Results: $PASS passed, $FAIL failed"
