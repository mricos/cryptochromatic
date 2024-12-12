#!/bin/bash

export vars=./vars
# Input file
INPUT_FILE=$1

# Check if input file is provided
if [[ -z "$INPUT_FILE" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Process the file line by line
while IFS= read -r line; do
    # Check for embedded Bash commands using $(...)
    while [[ "$line" =~ \$\(\s*([^\)]+)\s*\) ]]; do
        # Extract the command inside $(...)
        COMMAND="${BASH_REMATCH[1]}"
        # Execute the command and capture its output
        COMMAND_OUTPUT=$(eval "$COMMAND" 2>&1)
        if [[ $? -ne 0 ]]; then
            COMMAND_OUTPUT="Error executing command: $COMMAND"
        fi
        # Replace the command in the line with its output
        line="${line/\$\($COMMAND\)/$COMMAND_OUTPUT}"
    done
    # Write the processed line to stdout
    echo "$line"
done < "$INPUT_FILE"
