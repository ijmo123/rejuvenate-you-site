# Images to Create Before Launch

## 1. Open Graph Image (PRIORITY)
**Location:** `public/images/og-image.jpg`
**Size:** 1200 x 630 pixels
**Purpose:** Social media sharing preview

### What to Include:
- Your logo "Rejuvenate You"
- Tagline: "Reveal Your Skin. Refresh Your Mindset."
- Purple brand color (#7B2D8E)
- Clean, professional design
- Optional: Subtle sunset background (use the same sunset photo)

### Tools to Create:
- Canva (free): https://www.canva.com/
- Search "Open Graph" or "Facebook Cover" template
- Resize to 1200x630

### Already Configured:
The meta tags are already in BaseLayout.astro pointing to this URL:
```
https://www.rejuvenate-you.com/images/og-image.jpg
```

Just upload the image to `public/images/og-image.jpg` and it will work.

---

## 2. Favicon (DONE ✅)
**Location:** `public/favicon.svg` 
**Status:** Created simple SVG with "RY" initials

This will work as a basic favicon. For better browser support, you may want to create:
- `public/favicon.ico` (for older browsers)
- Or use a favicon generator: https://realfavicongenerator.net/

---

## 3. Apple Touch Icon (DONE ✅)
**Location:** `public/apple-touch-icon.png`
**Status:** Created SVG version

Note: For iOS devices, you should ideally create a proper PNG at 180x180 pixels.

---

## Quick Fix Option:
Use your existing sunset hero image temporarily:
1. Crop `/images/phoenix-sunset-hero.jpg` to 1200x630
2. Add text overlay with Canva or Photoshop
3. Save as `public/images/og-image.jpg`

This is good enough to launch, and you can create a nicer one later.
