#!/bin/bash
# Simple download script for all pages

PAGES_FILE="/home/javier/.openclaw/workspace/Hermes/website-migration/all-pages.txt"
OUTPUT_DIR="pages-raw"

# Attempt to create directory
mkdir -p "$OUTPUT_DIR" 2>/dev/null || mkdir "$OUTPUT_DIR" 2>/dev/null || true

echo "Downloading pages from rejuvenate-you.com..."
echo "Output directory: $OUTPUT_DIR"
echo ""

success=0
failed=0
count=0

# Read URLs from file
head -77 "$PAGES_FILE" | while read -r line; do
    # Extract URL from line (remove line number prefix)
    url=$(echo "$line" | cut -d'→' -f2-)

    # Skip empty lines
    if [ -z "$url" ] || [ "$url" = " " ]; then
        continue
    fi

    count=$((count + 1))

    # Generate filename
    filename=$(echo "$url" | sed 's|https://www.rejuvenate-you.com/||; s|/$||; s|/|-|g')
    [ -z "$filename" ] && filename="index"

    echo -ne "\r[$count/77] Downloading: $filename                                   "

    # Download with curl
    curl -s -m 15 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$url" -o "$OUTPUT_DIR/${filename}.html" 2>/dev/null

    if [ -s "$OUTPUT_DIR/${filename}.html" ]; then
        success=$((success + 1))
    else
        failed=$((failed + 1))
        rm -f "$OUTPUT_DIR/${filename}.html"
    fi

    # Small delay to be respectful
    sleep 0.5
done

echo ""
echo ""
echo "Download complete!"
echo "Successfully downloaded: $success"
echo "Failed: $failed"
echo "Files in output: $(ls -1 "$OUTPUT_DIR" 2>/dev/null | wc -l)"
