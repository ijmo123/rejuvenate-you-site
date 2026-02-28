#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import https from 'https';
import http from 'http';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PAGES_FILE = '/home/javier/.openclaw/workspace/Hermes/website-migration/all-pages.txt';
const PROJECT_DIR = process.cwd();
const CONTENT_DIR = path.join(PROJECT_DIR, 'src/content');

// Ensure directories exist
const dirs = ['services', 'blog', 'pages'];
dirs.forEach(dir => {
    const dirPath = path.join(CONTENT_DIR, dir);
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
});

function fetchUrl(url) {
    return new Promise((resolve, reject) => {
        const protocol = url.startsWith('https') ? https : http;
        const req = protocol.get(url, {
            timeout: 10000,
            headers: {
                'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
            }
        }, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                resolve(data);
            });
        });
        req.on('error', reject);
        req.on('timeout', () => {
            req.destroy();
            reject(new Error('Timeout'));
        });
    });
}

function extractTitle(html) {
    const match = html.match(/<title[^>]*>([^<]+)<\/title>/i);
    return match ? match[1].trim() : 'Untitled';
}

function extractDescription(html) {
    const match = html.match(/<meta\s+name="description"\s+content="([^"]*)"/i) ||
                  html.match(/<meta\s+property="og:description"\s+content="([^"]*)"/i);
    return match ? match[1].trim() : '';
}

function extractContent(html) {
    // Remove scripts and styles
    let content = html.replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
                       .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '');

    // Extract main content from common divs
    const mainMatch = content.match(/<main[^>]*>([\s\S]*?)<\/main>/i) ||
                      content.match(/<article[^>]*>([\s\S]*?)<\/article>/i) ||
                      content.match(/<div[^>]*class="[^"]*content[^"]*"[^>]*>([\s\S]*?)<\/div>/i);

    const mainContent = mainMatch ? mainMatch[1] : content;

    // Extract headings and paragraphs
    const headings = (mainContent.match(/<h[1-6][^>]*>([^<]+)<\/h[1-6]>/gi) || [])
        .map(h => h.replace(/<[^>]+>/g, '').trim());

    const paragraphs = (mainContent.match(/<p[^>]*>([^<]+)<\/p>/gi) || [])
        .map(p => p.replace(/<[^>]+>/g, '').trim())
        .filter(p => p.length > 0);

    return { headings, paragraphs };
}

function slugify(text) {
    return text
        .toLowerCase()
        .replace(/[^\w\s-]/g, '')
        .replace(/[\s_-]+/g, '-')
        .replace(/^-+|-+$/g, '');
}

function createMarkdownFile(url, html) {
    const title = extractTitle(html);
    const description = extractDescription(html);
    const { headings, paragraphs } = extractContent(html);

    // Determine file path
    let outputFile;
    if (url.includes('/blog/')) {
        const slug = url.split('/blog/')[1].replace(/\/$/, '');
        outputFile = path.join(CONTENT_DIR, 'blog', `${slug || 'index'}.md`);
    } else if (url.endsWith('/blog')) {
        outputFile = path.join(CONTENT_DIR, 'blog', 'index.md');
    } else {
        const slug = url.split('rejuvenate-you.com/')[1].replace(/\/$/, '');
        const dir = (slug.includes('-wax-') || slug.includes('-phoenix') || slug.includes('-scottsdale') ||
                     slug === 'services') ? 'services' : 'pages';
        outputFile = path.join(CONTENT_DIR, dir, `${slug || 'home'}.md`);
    }

    // Ensure directory exists
    const dir = path.dirname(outputFile);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }

    // Create markdown content
    const markdown = `---
title: "${title.replace(/"/g, '\\"')}"
description: "${description.replace(/"/g, '\\"')}"
---

# ${title}

${description ? `\n${description}\n` : ''}

${headings.length > 0 ? headings.slice(0, 5).map(h => `## ${h}`).join('\n\n') : ''}

${paragraphs.length > 0 ? paragraphs.slice(0, 10).join('\n\n') : 'Content to be imported from original site.'}
`;

    fs.writeFileSync(outputFile, markdown);
    console.log(`✓ Created: ${outputFile}`);
}

async function scrapeAllPages() {
    const pages = fs.readFileSync(PAGES_FILE, 'utf-8')
        .split('\n')
        .filter(line => line.trim().length > 0);

    console.log(`Found ${pages.length} pages to scrape\n`);

    let processed = 0;
    let errors = 0;

    // Process in batches of 3 concurrent requests
    for (let i = 0; i < pages.length; i += 3) {
        const batch = pages.slice(i, i + 3);

        await Promise.all(batch.map(async (url) => {
            try {
                console.log(`[${++processed}/${pages.length}] Scraping: ${url}`);
                const html = await fetchUrl(url);
                createMarkdownFile(url, html);
            } catch (error) {
                console.error(`✗ Error scraping ${url}: ${error.message}`);
                errors++;
                // Create placeholder file
                const slug = url.split('/').pop() || 'index';
                const outputFile = path.join(CONTENT_DIR, 'pages', `${slug}.md`);
                fs.writeFileSync(outputFile, `---\ntitle: "${slug}"\ndescription: ""\n---\n\n# ${slug}\n\nContent to be imported.\n`);
            }
        }));
    }

    console.log(`\n✓ Scraping complete! (${pages.length - errors} successful, ${errors} errors)`);
}

scrapeAllPages().catch(console.error);
