#!/bin/bash

# List of pages that need content
PAGES=(
  "dermaplaning-scottsdale"
  "ear-hair-waxing-scottsdale"
  "eyebrow-waxing-scottsdale"
  "full-face-waxing-phoenix"
  "full-face-waxing-scottsdale"
  "full-strip-stomach-wax"
  "full-strip-stomach-wax-phoenix"
  "home"
  "llms"
  "lymphatic-drainage-massage-scottsdale-az"
  "male-face-waxing-phoenix"
  "male-face-waxing-scottsdale"
  "microneedling-phoenix"
  "microneedling-scottsdale-az"
  "mobile-brazilian-wax-az"
  "mobile-waxing-service-az"
  "neck-waxing-scottsdale"
  "nose-hair-waxing-scottsdale"
  "policy-and-procedures-copy"
  "scottsdale-bachelorette-party"
  "upper-lip-wax-scottsdale"
  "waxing-scottsdale"
  "waxing-services-scottsdale"
  "butt-strip-wax-scottsdale"
  "about"
  "contact-us"
  "services"
  "phoenix"
  "scottsdale"
)

for page in "${PAGES[@]}"; do
  echo "Fixing $page..."
  
  # Fetch the page
  content=$(curl -s "https://www.rejuvenate-you.com/$page" 2>/dev/null)
  
  # Extract title
  title=$(echo "$content" | grep -oP '<title>\K[^<]+' | head -1)
  [ -z "$title" ] && title="$page | Rejuvenate You"
  
  # Extract meta description
  desc=$(echo "$content" | grep -oP '<meta name="description" content="\K[^"]+' | head -1)
  [ -z "$desc" ] && desc="Professional waxing services from Rejuvenate You"
  
  # Extract main content (simplified)
  body=$(echo "$content" | sed -n '/<main/,/<\/main>/p' | sed 's/<[^>]*>//g' | tr -s ' \n' | head -c 2000)
  
  # Create the astro file
  cat > "src/pages/$page.astro" << EOF
---
import ServicePage from '../layouts/ServicePage.astro';
---

<ServicePage
  title="$title"
  description="$desc"
>

# $title

$body

[Book your appointment today](https://rejuvenateyouwaxing.glossgenius.com/services)

</ServicePage>
EOF

done

echo "Done fixing pages!"
