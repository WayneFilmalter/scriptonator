#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file>"
    echo "Please provide a file to decompress"
    exit 1
fi

# Copy the input file to a working file called 'output'
cp "$1" output

# Loop to detect and decompress repeatedly
while true; do
    TYPE=$(file output)

    echo "Detected file type: $TYPE"

    case "$TYPE" in
        *gzip*)
            mv output temp.gz
            gunzip temp.gz
            mv temp output
            ;;
        *bzip2*)
            mv output temp.bz2
            bunzip2 temp.bz2
            mv temp output
            ;;
        *POSIX\ tar*)
            mkdir -p tarout
            tar -xf output -C tarout
            # Assume only one file gets extracted
            extracted=$(find tarout -type f | head -n 1)
            if [ -z "$extracted" ]; then
                echo "No file extracted from tar. Exiting."
                break
            fi
            cp "$extracted" .
            mv "$(basename "$extracted")" output
            ;;
        *ASCII\ text*)
            echo -e "\nFinal content:"
            cat output
            break
            ;;
        *)
            echo "Unknown or unsupported format. Exiting."
            break
            ;;
    esac
done
