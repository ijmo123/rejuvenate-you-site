#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PAGES_FILE = '/home/javier/.openclaw/workspace/Hermes/website-migration/all-pages.txt';
const PROJECT_DIR = __dirname;
const PAGES_DIR = path.join(PROJECT_DIR, 'src/pages');
const CONTENT_DIR = path.join(PROJECT_DIR, 'src/content');

// Ensure directories exist
if (!fs.existsSync(PAGES_DIR)) {
    fs.mkdirSync(PAGES_DIR, { recursive: true });
}

// Helper function to determine if URL is a blog post
function isBlogPost(url) {
    return url.includes('/blog/');
}

// Helper function to determine if URL is a special page
function isSpecialPage(slug) {
    return ['home', 'about', 'services', 'contact-us', 'scottsdale', 'phoenix', 'blog'].includes(slug);
}

// Helper function to determine if it's a service page
function isServicePage(slug) {
    return slug.includes('-wax-') || slug.includes('-phoenix') || slug.includes('-scottsdale') ||
           slug.includes('dermaplaning') || slug.includes('microneedling') || slug.includes('mobile') ||
           slug.includes('waxing') || slug === 'services';
}

// Get markdown file path
function getMarkdownPath(url) {
    if (isBlogPost(url)) {
        const slug = url.split('/blog/')[1].replace(/\/$/, '');
        return path.join(CONTENT_DIR, 'blog', `${slug || 'index'}.md`);
    } else {
        const slug = url.split('rejuvenate-you.com/')[1].replace(/\/$/, '');
        const dir = isServicePage(slug) ? 'services' : 'pages';
        return path.join(CONTENT_DIR, dir, `${slug || 'home'}.md`);
    }
}

// Read markdown file
function readMarkdownFile(filePath) {
    try {
        if (!fs.existsSync(filePath)) {
            return null;
        }
        return fs.readFileSync(filePath, 'utf-8');
    } catch {
        return null;
    }
}

// Parse markdown frontmatter
function parseFrontmatter(content) {
    const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!match) {
        return { frontmatter: {}, body: content };
    }

    const frontmatterStr = match[1];
    const body = match[2];

    const frontmatter = {};
    frontmatterStr.split('\n').forEach(line => {
        const [key, ...valueParts] = line.split(':');
        const value = valueParts.join(':').trim().replace(/^["']|["']$/g, '');
        if (key && value) {
            frontmatter[key.trim()] = value;
        }
    });

    return { frontmatter, body };
}

// Generate page file
function generatePageFile(url, slug, outputPath) {
    const mdPath = getMarkdownPath(url);
    const markdown = readMarkdownFile(mdPath);

    let frontmatter = {
        title: slug.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' '),
        description: 'Service from Rejuvenate You'
    };

    let body = 'Content to be imported.';

    if (markdown) {
        const parsed = parseFrontmatter(markdown);
        frontmatter = { ...frontmatter, ...parsed.frontmatter };
        body = parsed.body;
    }

    // Clean up title
    const cleanTitle = (frontmatter.title || slug)
        .replace(/&mdash;/g, '—')
        .replace(/&ndash;/g, '–')
        .replace(/&[^;]+;/g, '')
        .replace(/"/g, '\\"');

    const cleanDesc = (frontmatter.description || 'Professional waxing and beauty services in Scottsdale and Phoenix')
        .replace(/&mdash;/g, '—')
        .replace(/&ndash;/g, '–')
        .replace(/&[^;]+;/g, '')
        .replace(/"/g, '\\"')
        .substring(0, 160);

    const layoutName = isBlogPost(url) ? 'BlogPost' : isServicePage(slug) ? 'ServicePage' : 'BaseLayout';

    let imports = '';
    if (layoutName === 'BlogPost') {
        imports = `import BlogPost from '../../layouts/BlogPost.astro';\n`;
    } else if (layoutName === 'ServicePage') {
        imports = `import ServicePage from '../../layouts/ServicePage.astro';\n`;
    } else {
        imports = `import BaseLayout from '../../layouts/BaseLayout.astro';\n`;
    }

    // Calculate correct relative path based on output path depth
    // Count directory levels from src/pages/ to the file location
    const relPath = path.relative(PAGES_DIR, outputPath);
    // Count slashes to determine depth
    const dirsInPath = (relPath.match(/\//g) || []).length;
    const goUpLevels = dirsInPath + 1; // +1 to get from pages to src
    const layoutPath = Array(goUpLevels).fill('..').join('/') + '/layouts/' + layoutName + '.astro';

    const astroContent = `---
import ${layoutName} from '${layoutPath}';
---

<${layoutName}
  title="${cleanTitle}"
  description="${cleanDesc}"
>
${body}
</${layoutName}>
`;

    return astroContent;
}

// Generate all pages
function generateAllPages() {
    const pages = fs.readFileSync(PAGES_FILE, 'utf-8')
        .split('\n')
        .filter(line => line.trim().length > 0);

    console.log(`Generating ${pages.length} page files...\n`);

    let created = 0;
    let errors = 0;

    pages.forEach((url, index) => {
        try {
            // Determine slug and path
            let slug, outputPath;

            if (isBlogPost(url)) {
                slug = url.split('/blog/')[1].replace(/\/$/, '');
                outputPath = path.join(PAGES_DIR, 'blog', slug ? `${slug}.astro` : 'index.astro');
            } else {
                slug = url.split('rejuvenate-you.com/')[1].replace(/\/$/, '') || 'index';
                // Check if it's a nested path
                if (slug.includes('/')) {
                    outputPath = path.join(PAGES_DIR, `${slug}.astro`);
                } else {
                    outputPath = path.join(PAGES_DIR, `${slug}.astro`);
                }
            }

            // Create parent directories
            const dir = path.dirname(outputPath);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }

            // Generate and write file
            const content = generatePageFile(url, slug, outputPath);
            fs.writeFileSync(outputPath, content);

            console.log(`✓ [${index + 1}/${pages.length}] ${outputPath}`);
            created++;
        } catch (error) {
            console.error(`✗ Error generating page for ${url}: ${error.message}`);
            errors++;
        }
    });

    console.log(`\n✓ Generated ${created} page files (${errors} errors)`);
}

generateAllPages();
