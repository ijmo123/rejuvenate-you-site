#!/bin/bash
# Download all 77 pages from rejuvenate-you.com

mkdir -p pages-raw pages-processed

# Array of all 77 URLs
declare -a URLS=(
"https://www.rejuvenate-you.com/about"
"https://www.rejuvenate-you.com/bikini-wax-phoenix"
"https://www.rejuvenate-you.com/bikini-wax-scottsdale"
"https://www.rejuvenate-you.com/blog"
"https://www.rejuvenate-you.com/blog/bachelorette-party-ideas-scottsdale"
"https://www.rejuvenate-you.com/blog/bachelorette-wax-party-scottsdale"
"https://www.rejuvenate-you.com/blog/best-wax-for-sensitive-skin"
"https://www.rejuvenate-you.com/blog/best-way-to-remove-ingrown-hair"
"https://www.rejuvenate-you.com/blog/bikini-wax-aftercare-tips"
"https://www.rejuvenate-you.com/blog/bikini-wax-pros-and-cons"
"https://www.rejuvenate-you.com/blog/botox-pros-and-cons"
"https://www.rejuvenate-you.com/blog/brazilian-wax-aftercare-tips"
"https://www.rejuvenate-you.com/blog/brazilian-wax-before-and-after"
"https://www.rejuvenate-you.com/blog/can-you-get-a-brazilian-wax-while-pregnant"
"https://www.rejuvenate-you.com/blog/can-you-get-waxed-on-your-period"
"https://www.rejuvenate-you.com/blog/can-you-wax-over-a-tattoo"
"https://www.rejuvenate-you.com/blog/category/waxing"
"https://www.rejuvenate-you.com/blog/confidence-boost-from-brazilian-wax"
"https://www.rejuvenate-you.com/blog/dark-armpits-causes-and-solutions"
"https://www.rejuvenate-you.com/blog/difference-between-brazilian-and-bikini-wax"
"https://www.rejuvenate-you.com/blog/does-brazilian-wax-hurt"
"https://www.rejuvenate-you.com/blog/facelift-alternatives-options"
"https://www.rejuvenate-you.com/blog/hard-wax-vs-soft-wax"
"https://www.rejuvenate-you.com/blog/how-is-a-brazilian-wax-done"
"https://www.rejuvenate-you.com/blog/how-long-does-a-brazilian-wax-last"
"https://www.rejuvenate-you.com/blog/how-painful-is-waxing"
"https://www.rejuvenate-you.com/blog/how-to-get-rid-of-acne-scars"
"https://www.rejuvenate-you.com/blog/how-to-handle-hair-sensory-issues"
"https://www.rejuvenate-you.com/blog/how-to-prevent-ingrown-hairs-after-waxing"
"https://www.rejuvenate-you.com/blog/how-to-prevent-razor-burn-on-bikini-line"
"https://www.rejuvenate-you.com/blog/how-to-reduce-forehead-wrinkles"
"https://www.rejuvenate-you.com/blog/is-microneedling-painful"
"https://www.rejuvenate-you.com/blog/mens-hair-removal-treatments"
"https://www.rejuvenate-you.com/blog/preventing-bumps-after-brazilian-wax"
"https://www.rejuvenate-you.com/blog/pros-and-cons-of-a-brazilian-wax"
"https://www.rejuvenate-you.com/blog/pros-and-cons-of-waxing-eyebrows"
"https://www.rejuvenate-you.com/blog/spring-skincare-tips"
"https://www.rejuvenate-you.com/blog/types-of-bikini-wax"
"https://www.rejuvenate-you.com/blog/what-is-a-french-bikini-wax"
"https://www.rejuvenate-you.com/blog/what-is-lymphatic-drainage-facial"
"https://www.rejuvenate-you.com/blog/what-is-the-best-treatment-for-deep-wrinkles"
"https://www.rejuvenate-you.com/blog/when-to-wax-before-vacation"
"https://www.rejuvenate-you.com/blog/will-waxing-prevent-hair-growth"
"https://www.rejuvenate-you.com/bookingselection"
"https://www.rejuvenate-you.com/brazilian-wax-phoenix"
"https://www.rejuvenate-you.com/brazilian-wax-scottsdale"
"https://www.rejuvenate-you.com/butt-strip-wax-scottsdale"
"https://www.rejuvenate-you.com/contact-us"
"https://www.rejuvenate-you.com/dermaplaning-phoenix"
"https://www.rejuvenate-you.com/dermaplaning-scottsdale"
"https://www.rejuvenate-you.com/ear-hair-waxing-scottsdale"
"https://www.rejuvenate-you.com/eyebrow-waxing-scottsdale"
"https://www.rejuvenate-you.com/full-face-waxing-phoenix"
"https://www.rejuvenate-you.com/full-face-waxing-scottsdale"
"https://www.rejuvenate-you.com/full-strip-stomach-wax"
"https://www.rejuvenate-you.com/full-strip-stomach-wax-phoenix"
"https://www.rejuvenate-you.com/home"
"https://www.rejuvenate-you.com/llms"
"https://www.rejuvenate-you.com/lymphatic-drainage-massage-scottsdale-az"
"https://www.rejuvenate-you.com/male-face-waxing-phoenix"
"https://www.rejuvenate-you.com/male-face-waxing-scottsdale"
"https://www.rejuvenate-you.com/male-waxing-scottsdale"
"https://www.rejuvenate-you.com/microneedling-phoenix"
"https://www.rejuvenate-you.com/microneedling-scottsdale-az"
"https://www.rejuvenate-you.com/mobile-brazilian-wax-az"
"https://www.rejuvenate-you.com/mobile-waxing-service-az"
"https://www.rejuvenate-you.com/neck-waxing-scottsdale"
"https://www.rejuvenate-you.com/nose-hair-waxing-scottsdale"
"https://www.rejuvenate-you.com/phoenix"
"https://www.rejuvenate-you.com/policy-and-procedures-copy"
"https://www.rejuvenate-you.com/privacy-policy"
"https://www.rejuvenate-you.com/scottsdale"
"https://www.rejuvenate-you.com/scottsdale-bachelorette-party"
"https://www.rejuvenate-you.com/services"
"https://www.rejuvenate-you.com/upper-lip-wax-scottsdale"
"https://www.rejuvenate-you.com/waxing-scottsdale"
"https://www.rejuvenate-you.com/waxing-services-scottsdale"
)

success=0
failed=0
count=${#URLS[@]}

echo "Downloading $count pages from rejuvenate-you.com..."
echo ""

for i in "${!URLS[@]}"; do
    url="${URLS[$i]}"
    idx=$((i + 1))

    # Generate filename from URL
    filename=$(echo "$url" | sed 's|https://www.rejuvenate-you.com/||; s|/$||; s|/|-|g')
    [ -z "$filename" ] && filename="index"

    echo -ne "\r[$idx/$count] Downloading: $filename..."

    # Download the page
    if curl -s -m 15 -A "Mozilla/5.0" "$url" -o "pages-raw/${filename}.html" 2>/dev/null; then
        if [ -s "pages-raw/${filename}.html" ]; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
        fi
    else
        failed=$((failed + 1))
    fi

    sleep 0.3
done

echo ""
echo ""
echo "========================================"
echo "Download Complete!"
echo "========================================"
echo "Successfully downloaded: $success"
echo "Failed: $failed"
echo "Total files: $(ls -1 pages-raw | wc -l)"
