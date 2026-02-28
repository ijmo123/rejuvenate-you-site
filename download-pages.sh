#!/bin/bash

# Scrape all 77 pages from rejuvenate-you.com
# Creates HTML files in pages-raw/ directory

# Base directory
WORK_DIR="/home/javier/.openclaw/workspace/Hermes/website-migration/rejuvenate-you-site"
PAGES_FILE="/home/javier/.openclaw/workspace/Hermes/website-migration/all-pages.txt"
OUTPUT_DIR="$WORK_DIR/pages-raw"

# Create output directory using bash mkdir
bash -c "mkdir -p '$OUTPUT_DIR'" 2>/dev/null || {
    echo "Creating output directory via alternative method..."
    python3 -c "import os; os.makedirs('$OUTPUT_DIR', exist_ok=True)"
}

if [ ! -f "$PAGES_FILE" ]; then
    echo "Error: Pages file not found at $PAGES_FILE"
    exit 1
fi

# Counter for progress
count=0
total=77
success=0
failed=0

echo "Starting to scrape $total pages from rejuvenate-you.com..."
echo "Output directory: $OUTPUT_DIR"
echo ""

# Read each URL from the file
while IFS= read -r url; do
    # Skip empty lines
    [ -z "$url" ] && continue

    count=$((count + 1))

    # Extract just the URL (remove line numbers)
    url=$(echo "$url" | sed 's/^[0-9]*→//')

    echo -ne "\r[$count/$total] Processing: $(basename "$url")                    "

    # Generate filename from URL
    filename=$(echo "$url" | sed 's|https://www.rejuvenate-you.com/||; s|/$||; s|/|-|g; s|?.*||')
    [ -z "$filename" ] && filename="index"

    # Fetch the page with timeout
    if curl -s -m 15 -A "Mozilla/5.0" "$url" > "$OUTPUT_DIR/${filename}.html" 2>/dev/null; then
        if [ -s "$OUTPUT_DIR/${filename}.html" ]; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
            rm -f "$OUTPUT_DIR/${filename}.html"
        fi
    else
        failed=$((failed + 1))
    fi

    # Add a small delay to be respectful to the server
    sleep 0.3
done < "$PAGES_FILE"

echo ""
echo ""
echo "========================================"
echo "Scraping Complete!"
echo "========================================"
echo "Total pages processed: $count"
echo "Successfully downloaded: $success"
echo "Failed: $failed"
echo "Output directory: $OUTPUT_DIR"
echo "Files saved: $(ls -1 "$OUTPUT_DIR" 2>/dev/null | wc -l)"
