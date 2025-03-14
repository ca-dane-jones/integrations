#!/bin/bash

# Check if the log directory path is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/log/files"
    exit 1
fi

# Directory containing the log files
log_dir="$1"

# Function to format a timestamp based on the given format
format_timestamp() {
    local timestamp=$1
    local format=$2

    case $format in
        "format1")
            date -d @$timestamp +"%b %d %H:%M:%S"
            ;;
        "format2")
            date -d @$timestamp +"%Y-%m-%dT%H:%M:%S.%6N%:z"
            ;;
        "format3")
            date -d @$timestamp +"%b %d %H:%M:%S"
            ;;
    esac
}

# Get today's date at midnight
start_date=$(date -d "$(date +'%Y-%m-%d') 00:00:00" +%s)

# Iterate over each .log file in the directory
for log_file in "$log_dir"/*.log; do
    echo "Processing $log_file"

    # Initialize the timestamp with today's date at midnight
    current_timestamp=$start_date

    # Temporary file to store the modified log
    temp_file=$(mktemp)

    # Read the log file line by line
    while IFS= read -r line; do
        # Determine the timestamp format
        if [[ $line =~ ^[A-Z][a-z]{2}\ {1,2}[0-9]{1,2}\ [0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
            timestamp_format="format1"
        elif [[ $line =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}-[0-9]{2}:[0-9]{2} ]]; then
            timestamp_format="format2"
        elif [[ $line =~ ^[A-Z][a-z]{2}\ {1,2}[0-9]{1,2}\ [0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
            timestamp_format="format3"
        else
            timestamp_format="unknown"
        fi

        if [[ $timestamp_format != "unknown" ]]; then
            # Generate the new formatted timestamp
            new_timestamp=$(format_timestamp $current_timestamp $timestamp_format)

            # Replace the old timestamp with the new one
            line=$(echo $line | sed -E "s/^[A-Z][a-z]{2}\ {1,2}[0-9]{1,2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}|[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}-[0-9]{2}:[0-9]{2}/$new_timestamp/")

            # Increment the current timestamp by a random number of seconds between 1 and 120
            increment=$((RANDOM % 120 + 1))
            current_timestamp=$((current_timestamp + increment))
        fi

        # Write the modified line to the temporary file
        echo "$line" >> "$temp_file"
    done < "$log_file"

    # Replace the original log file with the modified one
    mv "$temp_file" "$log_file"
done
