# Task: Build Rejuvenate-You Website with Astro

## Objective
Build a complete Astro static website that replicates rejuvenate-you.com (currently on Squarespace) with improved SEO, performance, and maintainability. The site will be deployed to Cloudflare Pages.

## Phase 1: Project Setup

1. Initialize Astro project with Tailwind CSS
2. Configure for static output (Cloudflare Pages compatible)
3. Set up project structure:
   ```
   src/
     layouts/
       BaseLayout.astro      # Head, meta, schema markup
       ServicePage.astro     # Service page template
       BlogPost.astro        # Blog post template
       LocationPage.astro    # Location landing page
     components/
       Header.astro          # Purple nav with location dropdown
       Footer.astro
       BookingCTA.astro      # Booking buttons (GlossGenius + SquareUp)
       TestimonialCard.astro
       FAQSection.astro      # Schema-ready FAQ
       PricingTable.astro
       ServiceCard.astro
     pages/
       index.astro           # Homepage
       about.astro
       contact-us.astro
       services.astro
       phoenix.astro
       scottsdale.astro
       ...all service pages...
       blog/
         index.astro
         [...slug].astro     # Dynamic blog routes
     content/
       services/             # Markdown for each service page
       blog/                 # Markdown for each blog post
     styles/
       global.css            # Brand colors, fonts
   public/
     images/                 # Downloaded from Squarespace
     favicon.ico
   ```

## Phase 2: Scrape Current Site

Scrape ALL pages from the current site. The full list of URLs is at:
`/home/javier/.openclaw/workspace/Hermes/website-migration/all-pages.txt`

For each page, extract:
- Title tag
- Meta description
- H1, H2, H3 structure
- Body content (text)
- Internal links
- Images used
- Any structured data

Save scraped content as Markdown files in `src/content/`

## Phase 3: Download Images

Download ALL images from Squarespace CDN. The full list is at:
`/home/javier/.openclaw/workspace/Hermes/website-migration/all-images.txt`

Save to `public/images/` with clean filenames.

## Phase 4: Build Components

### Brand Colors (from current site)
- Primary: Purple (#7B2D8E or similar — check actual site)
- Text: Dark gray/black
- Background: White
- Accent: Gold/warm tones

### Header/Navigation
Must include:
- Logo/brand name "Rejuvenate You"
- Location dropdown (Scottsdale | Phoenix)
- Service links
- "Book Now" CTA button
- Mobile hamburger menu

### Footer
- Location info (addresses, hours)
- Quick links
- Social media links
- Copyright

### Booking CTAs
Two booking systems:
- **Scottsdale:** `https://rejuvenateyouwaxing.glossgenius.com/services`
- **Phoenix:** `https://app.squareup.com/appointments/book/e9ycxyisf79aby/L96KEQZQVHJ37/start`

## Phase 5: SEO Requirements

### Every Page Must Have:
- Unique title tag (under 60 chars)
- Unique meta description (under 160 chars)
- Canonical URL
- Open Graph tags
- JSON-LD structured data (LocalBusiness for location pages, Service for service pages, FAQPage for pages with FAQs, BlogPosting for blog posts)

### Technical SEO:
- Auto-generated sitemap.xml
- robots.txt
- Clean URL structure (no trailing slashes — match current URLs exactly)
- 301 redirect map for any URL changes
- Proper heading hierarchy (single H1 per page)
- Image alt text with location keywords
- Internal linking structure

### Schema Markup:
- LocalBusiness schema on /phoenix and /scottsdale pages
  - Scottsdale: 7127 E Sahuaro Dr, Ste 103, Scottsdale, AZ 85254
  - Phoenix: Check current site for address
  - GBP CID Phoenix: 7887328475959804245
  - GBP CID Scottsdale: 9311880125746937216
- Service schema on each service page
- FAQPage schema on pages with FAQ sections
- BreadcrumbList on all pages
- BlogPosting on blog posts

## Phase 6: Performance

- Target Lighthouse score: 95+ across all categories
- Image optimization: WebP format, lazy loading, proper sizing
- Minimal JavaScript
- CSS: Tailwind (purged for production)
- Font optimization: system fonts or self-hosted

## Key URLs to Preserve

ALL URLs from the current sitemap must work identically on the new site.
No URL changes unless absolutely necessary (and then add 301 redirects).

## Cloudflare Pages Config

- Output directory: `dist/`
- Build command: `npm run build`
- Node version: 22
- Add `_redirects` file for any 301s needed

## Important Notes

- This is a REAL business website. Content accuracy matters.
- Match the current site's content exactly — don't rewrite copy (SEO risk)
- The purple brand identity is essential
- Mobile-first responsive design
- The brand guide is at `/home/javier/.openclaw/workspace/Hermes/content/brand-guide.md`
- DO NOT modify any files outside this project directory

## When Done

1. Run `npm run build` to verify everything compiles
2. Run a local preview to check pages render
3. Commit all changes
4. Notify completion with: `openclaw system event --text "Done: Astro website build complete — 77 pages migrated" --mode now`
