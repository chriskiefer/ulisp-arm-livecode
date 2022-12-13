#!/usr/bin/env sh

# Check if the correct number of arguments was passed to the script
if [ $# -ne 2 ]; then
  echo "Usage: $0 INPUT_FILE OUTPUT_FILE"
  exit 1
fi

# Get the input and output file paths
input_file=$1
output_file=$2

# Read the input file and remove all comments
contents=$(cat $input_file | sed 's/;.*$//')

# Turn the contents into a valid C string
const_string=$(echo "$contents" | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
const_string="const char LispLibrary[] PROGMEM = \"$const_string\";"

# Write the result to the output file
echo "$const_string" > $output_file

# Print a success message
echo "Wrote C string to $output_file"
