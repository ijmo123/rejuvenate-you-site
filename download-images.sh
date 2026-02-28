#!/bin/bash

# Image downloader script
IMAGES_FILE="/home/javier/.openclaw/workspace/Hermes/website-migration/all-images.txt"
PROJECT_DIR="$(pwd)"
IMAGES_DIR="$PROJECT_DIR/public/images"

mkdir -p "$IMAGES_DIR"

# Function to download image
download_image() {
    local url=$1
    local output_dir=$2

    # Extract filename from URL
    local filename=$(echo "$url" | sed 's|.*/||' | sed 's/?.*$//')

    # Clean up filename
    filename=$(echo "$filename" | sed 's/[?&].*$//')

    local output_path="$output_dir/$filename"

    # Skip if already exists
    if [ -f "$output_path" ]; then
        echo "✓ Already exists: $filename"
        return 0
    fi

    # Download with curl
    if curl -s -L -o "$output_path" --max-time 10 "$url" 2>/dev/null; then
        # Check if file was actually created and has content
        if [ -f "$output_path" ] && [ -s "$output_path" ]; then
            echo "✓ Downloaded: $filename"
            return 0
        else
            rm -f "$output_path"
            echo "✗ Failed (empty): $filename"
            return 1
        fi
    else
        echo "✗ Failed (timeout): $filename"
        return 1
    fi
}

# Read URLs and download
counter=0
failed=0
total=$(grep -c . "$IMAGES_FILE")

while IFS= read -r url; do
    [ -z "$url" ] && continue

    ((counter++))
    download_image "$url" "$IMAGES_DIR" || ((failed++))

    # Limit concurrent downloads
    if [ $((counter % 10)) -eq 0 ]; then
        echo "Progress: $counter/$total"
        wait -n 2>/dev/null || true
    fi
done < "$IMAGES_FILE"

# Wait for remaining jobs
wait

echo "✓ Image download complete!"
echo "Downloaded: $((total - failed))/$total images"
