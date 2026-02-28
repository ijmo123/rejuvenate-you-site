#!/usr/bin/env python3
"""
Process HTML files from pages-raw/ and extract content into Markdown files.
Saves processed content to pages-processed/ directory.
"""

import os
import sys
import re
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlparse

# Add the working directory to path
WORK_DIR = "/home/javier/.openclaw/workspace/Hermes/website-migration/rejuvenate-you-site"
INPUT_DIR = os.path.join(WORK_DIR, "pages-raw")
OUTPUT_DIR = os.path.join(WORK_DIR, "pages-processed")

# Create output directory
os.makedirs(OUTPUT_DIR, exist_ok=True)


class ContentExtractor(HTMLParser):
    """Extract text content from HTML with structure."""

    def __init__(self):
        super().__init__()
        self.title = ""
        self.meta_description = ""
        self.h1 = []
        self.h2 = []
        self.h3 = []
        self.content = []
        self.internal_links = []
        self.images = []
        self.current_tag = None
        self.in_script = False
        self.in_style = False
        self.in_nav = False
        self.in_footer = False

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)

        if tag == "title":
            self.current_tag = "title"
        elif tag == "meta" and attrs_dict.get("name") == "description":
            self.meta_description = attrs_dict.get("content", "")
        elif tag == "h1":
            self.current_tag = "h1"
        elif tag == "h2":
            self.current_tag = "h2"
        elif tag == "h3":
            self.current_tag = "h3"
        elif tag == "p":
            self.current_tag = "p"
        elif tag == "li":
            self.current_tag = "li"
        elif tag == "a":
            href = attrs_dict.get("href", "")
            if href:
                self.internal_links.append(href)
        elif tag == "img":
            src = attrs_dict.get("src", "")
            alt = attrs_dict.get("alt", "")
            if src:
                self.images.append({"src": src, "alt": alt})
        elif tag == "script":
            self.in_script = True
        elif tag == "style":
            self.in_style = True
        elif tag == "nav":
            self.in_nav = True
        elif tag == "footer":
            self.in_footer = True

    def handle_endtag(self, tag):
        if tag == "script":
            self.in_script = False
        elif tag == "style":
            self.in_style = False
        elif tag == "nav":
            self.in_nav = False
        elif tag == "footer":
            self.in_footer = False

        if self.current_tag:
            self.current_tag = None

    def handle_data(self, data):
        # Skip content in scripts, styles, nav, and footer
        if self.in_script or self.in_style or self.in_nav or self.in_footer:
            return

        # Clean up whitespace
        text = data.strip()
        if not text:
            return

        if self.current_tag == "title":
            self.title = text
        elif self.current_tag == "h1":
            if text not in self.h1:
                self.h1.append(text)
        elif self.current_tag == "h2":
            if text not in self.h2:
                self.h2.append(text)
        elif self.current_tag == "h3":
            if text not in self.h3:
                self.h3.append(text)
        elif self.current_tag in ["p", "li"]:
            if text and len(text) > 10:  # Only include substantial text
                self.content.append(text)


def extract_content_from_html(html_content):
    """Extract structured content from HTML."""
    extractor = ContentExtractor()
    try:
        extractor.feed(html_content)
    except Exception as e:
        print(f"Error parsing HTML: {e}")

    return {
        "title": extractor.title,
        "meta_description": extractor.meta_description,
        "h1": extractor.h1,
        "h2": extractor.h2,
        "h3": extractor.h3,
        "content": extractor.content,
        "internal_links": list(dict.fromkeys(extractor.internal_links)),  # Remove duplicates
        "images": extractor.images,
    }


def generate_markdown(filename, data):
    """Generate Markdown content from extracted data."""
    lines = []

    # Add frontmatter
    title = data.get("title", "").strip()
    if not title and data.get("h1"):
        title = data["h1"][0]

    lines.append("---")
    lines.append(f"title: {title}")

    description = data.get("meta_description", "").strip()
    if description:
        lines.append(f"description: {description}")

    lines.append(f"source: rejuvenate-you.com/{filename}")
    lines.append("---")
    lines.append("")

    # Add title as H1
    if title:
        lines.append(f"# {title}")
        lines.append("")

    # Add H1s (skip if already used as title)
    for h1 in data.get("h1", []):
        if h1 != title:
            lines.append(f"# {h1}")
            lines.append("")

    # Add meta description as intro
    if description:
        lines.append(f"> {description}")
        lines.append("")

    # Add H2s and H3s
    for h2 in data.get("h2", []):
        lines.append(f"## {h2}")
        lines.append("")

    for h3 in data.get("h3", []):
        lines.append(f"### {h3}")
        lines.append("")

    # Add main content
    if data.get("content"):
        lines.append("## Content")
        lines.append("")
        for paragraph in data.get("content", [])[:20]:  # Limit to first 20 paragraphs
            lines.append(paragraph)
            lines.append("")

    # Add images section
    if data.get("images"):
        lines.append("## Images")
        lines.append("")
        for img in data.get("images", [])[:10]:  # Limit to first 10 images
            alt = img.get("alt", "Image")
            src = img.get("src", "")
            if src:
                lines.append(f"- ![{alt}]({src})")
        lines.append("")

    # Add internal links
    if data.get("internal_links"):
        lines.append("## Internal Links")
        lines.append("")
        seen_links = set()
        for link in data.get("internal_links", [])[:15]:  # Limit to first 15 links
            if link and link not in seen_links:
                lines.append(f"- {link}")
                seen_links.add(link)
        lines.append("")

    return "\n".join(lines)


def process_all_pages():
    """Process all HTML files in the input directory."""
    if not os.path.exists(INPUT_DIR):
        print(f"Error: Input directory not found: {INPUT_DIR}")
        return 0, 0

    html_files = sorted([f for f in os.listdir(INPUT_DIR) if f.endswith(".html")])
    total = len(html_files)
    success = 0
    errors = 0

    print(f"Processing {total} HTML files...")
    print("")

    for idx, filename in enumerate(html_files, 1):
        html_path = os.path.join(INPUT_DIR, filename)
        md_filename = filename.replace(".html", ".md")
        md_path = os.path.join(OUTPUT_DIR, md_filename)

        try:
            with open(html_path, 'r', encoding='utf-8', errors='ignore') as f:
                html_content = f.read()

            # Extract content
            data = extract_content_from_html(html_content)

            # Generate Markdown
            markdown_content = generate_markdown(filename.replace(".html", ""), data)

            # Write Markdown file
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(markdown_content)

            success += 1
            print(f"\r[{idx}/{total}] Processed: {md_filename:<50}", end="", flush=True)

        except Exception as e:
            errors += 1
            print(f"\nError processing {filename}: {e}")

    print("\n")
    return success, errors


if __name__ == "__main__":
    print("=" * 60)
    print("HTML Content Extraction and Markdown Generation")
    print("=" * 60)
    print(f"Input directory: {INPUT_DIR}")
    print(f"Output directory: {OUTPUT_DIR}")
    print("")

    success, errors = process_all_pages()

    print("=" * 60)
    print("Processing Complete!")
    print("=" * 60)
    print(f"Successfully processed: {success}")
    print(f"Errors: {errors}")
    print(f"Total files in output: {len(os.listdir(OUTPUT_DIR))}")
    print(f"Output directory: {OUTPUT_DIR}")
