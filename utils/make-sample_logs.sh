#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 /path/to/log/files /path/to/output/file"
    exit 1
fi

# Directory containing the log files
log_dir="$1"

# Output file path
output_file="$2"

# Initialize or clear the output file
> "$output_file"

# Iterate over each .log file in the directory and append its contents to the output file
for log_file in "$log_dir"/*.log; do
    if [ -f "$log_file" ]; then
        echo "Processing $log_file"
        cat "$log_file" >> "$output_file"
    fi
done

echo "All log files have been concatenated into $output_file"
