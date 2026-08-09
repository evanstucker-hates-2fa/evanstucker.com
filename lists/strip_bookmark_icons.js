#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const usage = `
Usage: node strip_bookmark_icons.js [file] [options]

Strips ICON="data:..." and ICON_URI="..." attributes from a Netscape
bookmark export, rewriting it in place. Safe to re-run.

Arguments:
  file                Bookmark HTML to clean (default: bookmarks.html)

Options:
  --dry-run           Report what would be removed without writing
  -h, --help          Show this help message

Example:
  node strip_bookmark_icons.js
  node strip_bookmark_icons.js ~/Downloads/bookmarks.html --dry-run
`;

if (args.includes('-h') || args.includes('--help')) {
  console.log(usage);
  process.exit(0);
}

const dryRun = args.includes('--dry-run');
const fileArg = args.find(a => !a.startsWith('-'));
const bookmarksPath = fileArg
  ? path.resolve(fileArg)
  : path.join(__dirname, 'bookmarks.html');

let html;
try {
  html = fs.readFileSync(bookmarksPath, 'utf8');
} catch (err) {
  console.error(`Error reading ${bookmarksPath}:`, err.message);
  process.exit(1);
}

const iconRe = / ICON(?:_URI)?="[^"]*"/g;
const matches = html.match(iconRe) || [];
if (matches.length === 0) {
  console.log('No ICON or ICON_URI attributes found. Nothing to do.');
  process.exit(0);
}

const cleaned = html.replace(iconRe, '');

const linksBefore = (html.match(/HREF=/g) || []).length;
const linksAfter = (cleaned.match(/HREF=/g) || []).length;
if (linksBefore !== linksAfter) {
  console.error(
    `Error: link count changed (${linksBefore} -> ${linksAfter}), refusing to write.`
  );
  process.exit(1);
}

const icons = matches.filter(m => m.startsWith(' ICON=')).length;
const iconUris = matches.length - icons;
const saved = Buffer.byteLength(html) - Buffer.byteLength(cleaned);
const kb = Math.round(saved / 1024);

console.log(`${icons} ICON, ${iconUris} ICON_URI (${kb} KB), ${linksAfter} links kept`);

if (dryRun) {
  console.log('Dry run: no changes written.');
  process.exit(0);
}

const relPath = path.relative(process.cwd(), bookmarksPath);
const shownPath = relPath.startsWith('..') ? bookmarksPath : relPath;

try {
  fs.writeFileSync(bookmarksPath, cleaned);
  console.log(`Cleaned ${shownPath}`);
} catch (err) {
  console.error(`Error writing ${bookmarksPath}:`, err.message);
  process.exit(1);
}
