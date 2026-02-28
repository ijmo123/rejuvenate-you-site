#!/bin/bash

# This script will scrape pages from rejuvenate-you.com and extract content for Astro

# Create output directory
mkdir -p src/content/pages-scraped

# List of URLs to scrape (from all-pages.txt)
# We'll fetch from the source file
PAGES_FILE="/home/javier/.openclaw/workspace/Hermes/website-migration/all-pages.txt"

if [ ! -f "$PAGES_FILE" ]; then
    echo "Error: Pages file not found at $PAGES_FILE"
    exit 1
fi

# Counter for progress
count=0
total=$(wc -l < "$PAGES_FILE")

echo "Starting to scrape $total pages..."

# Read each URL from the file
while IFS= read -r url; do
    count=$((count + 1))
    echo "[$count/$total] Scraping: $url"

    # Generate filename from URL
    # Extract path from URL, remove query strings, convert to safe filename
    filename=$(echo "$url" | sed 's|https://www.rejuvenate-you.com/||; s|/$||; s|/|-|g; s|?.*||')
    [ -z "$filename" ] && filename="index"

    # Skip if already scraped
    if [ -f "src/content/pages-scraped/${filename}.html" ]; then
        echo "  → Already scraped, skipping"
        continue
    fi

    # Fetch the page with timeout
    if curl -s -m 10 "$url" > "src/content/pages-scraped/${filename}.html" 2>/dev/null; then
        echo "  → Success: saved to ${filename}.html"
    else
        echo "  → Failed to fetch $url"
    fi

    # Add a small delay to avoid overwhelming the server
    sleep 0.5
done < "$PAGES_FILE"

echo ""
echo "Scraping complete! Pages saved to src/content/pages-scraped/"
echo ""
echo "Next: Process HTML files to extract content and convert to Markdown"
