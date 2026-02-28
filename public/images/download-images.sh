#!/bin/bash
# Download all images from Squarespace CDN

IMAGE_LIST="/home/javier/.openclaw/workspace/Hermes/website-migration/all-images.txt"
TOTAL=$(wc -l < "$IMAGE_LIST")
COUNT=0

while IFS= read -r url; do
    COUNT=$((COUNT + 1))
    # Extract clean filename
    filename=$(echo "$url" | sed 's|https://images.squarespace-cdn.com/content/v1/||; s|/|_|g')
    # Add extension if missing
    if [[ ! "$filename" =~ \.(jpg|jpeg|png|gif|webp|svg)$ ]]; then
        filename="${filename}.jpg"
    fi
    
    # Download
    curl -sL "$url" -o "$filename" --max-time 30
    
    # Progress every 10 images
    if [ $((COUNT % 10)) -eq 0 ]; then
        echo "Downloaded $COUNT/$TOTAL..."
    fi
done < "$IMAGE_LIST"

echo "Done! Downloaded $COUNT images."
