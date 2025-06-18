// src/scripts/convertTex.js
// Pipeline: copy and dedupe figures, convert .tex to Markdown, patch image links, extract code listings
import fs from 'fs'
import path from 'path'
import { execSync } from 'child_process'
import { fileURLToPath } from 'url'
import crypto from 'crypto'

// Polyfill __dirname for ESM
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const TEX_DIR = path.resolve(__dirname, '../../overleaf/chapters')
const RAW_DIR = path.resolve(__dirname, '../../overleaf/raw-figures')
const EXP_DIR = path.resolve(__dirname, '../../overleaf/exported-figures')
const CONTENT_DIR = path.resolve(__dirname, '../content')

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
}

// Compute file checksum (md5)
function checksum(filePath) {
  const data = fs.readFileSync(filePath)
  return crypto.createHash('md5').update(data).digest('hex')
}

// Reset content directory
fs.rmSync(CONTENT_DIR, { recursive: true, force: true })
ensureDir(CONTENT_DIR)

// Find chapters
const texFiles = fs.existsSync(TEX_DIR)
  ? fs.readdirSync(TEX_DIR).filter(f => f.endsWith('.tex'))
  : []

for (const file of texFiles) {
  const base = path.basename(file, '.tex')  // e.g. '2.Chapter'
  const chapNum = base.split('.')[0]        // e.g. '2'
  const slug = base                        // keep original name
  const folder = `chapter${chapNum}`

  const srcTex = path.join(TEX_DIR, file)
  const chapterDir = path.join(CONTENT_DIR, slug)
  const mediaDir = path.join(chapterDir, 'media')
  const codeDir = path.join(chapterDir, 'code-snippets')
  const mdPath = path.join(chapterDir, `${slug}.md`)

  // Prepare directories
  fs.rmSync(chapterDir, { recursive: true, force: true })
  ensureDir(mediaDir)
  ensureDir(codeDir)

  // Dedupe state for this chapter
  const seenHashes = new Set()

  // 1) Collect all figure sources
  const sources = []
  const rawSrc = path.join(RAW_DIR, folder)
  if (fs.existsSync(rawSrc)) {
    for (const img of fs.readdirSync(rawSrc)) {
      sources.push(path.join(rawSrc, img))
    }
  }
  const expSrc = path.join(EXP_DIR, folder, 'figure-pdf')
  if (fs.existsSync(expSrc)) {
    for (const img of fs.readdirSync(expSrc)) {
      sources.push(path.join(expSrc, img))
    }
  }

  // 2) Copy & dedupe figures
  for (const srcPath of sources) {
    if (!fs.lstatSync(srcPath).isFile()) continue
    const hash = checksum(srcPath)
    if (seenHashes.has(hash)) continue      // skip duplicate
    seenHashes.add(hash)
    const fileName = path.basename(srcPath)
    fs.copyFileSync(srcPath, path.join(mediaDir, fileName))
  }

  // 3) Convert .tex to Markdown
  execSync(
    `pandoc "${srcTex}" -f latex -t markdown -o "${mdPath}"`,
    { stdio: 'inherit' }
  )

  // 4) Patch image links in Markdown
  let md = fs.readFileSync(mdPath, 'utf8')
  md = md.replace(/\\includegraphics(?:\[[^\]]*\])?\{(?:.*?\/)?([^}]+)\}/g,
    (_, imgName) => `![](media/${imgName})`
  )
  fs.writeFileSync(mdPath, md)

  // 5) Extract code listings (verbatim or lstlisting)
  const texLines = fs.readFileSync(srcTex, 'utf8').split(/\r?\n/)
  let inBlock = false
  let buffer = []
  for (const line of texLines) {
    if (/\\begin\{(?:lstlisting|verbatim)\}/.test(line)) {
      inBlock = true; continue
    }
    if (/\\end\{(?:lstlisting|verbatim)\}/.test(line)) {
      inBlock = false
      const snippetFile = path.join(codeDir, `${slug}-${Date.now()}.txt`)
      fs.writeFileSync(snippetFile, buffer.join('\n'))
      buffer = []
      continue
    }
    if (inBlock) buffer.push(line)
  }

  console.log(`Processed ${slug}`)
}

console.log('All chapters processed!')