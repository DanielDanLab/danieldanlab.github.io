// src/scripts/convertTex.js
// Enhanced pipeline: figures dedupe, .tex→Markdown with cleanup, image linking, advanced code extraction
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

// Compute MD5 checksum of a file
function checksum(filePath) {
  const data = fs.readFileSync(filePath)
  return crypto.createHash('md5').update(data).digest('hex')
}

// Remove old content and recreate
const rmDir = fs.rmSync || fs.rmdirSync
rmDir(CONTENT_DIR, { recursive: true, force: true })
ensureDir(CONTENT_DIR)

// Get all .tex files in Overleaf chapters folder
const texFiles = fs.existsSync(TEX_DIR)
  ? fs.readdirSync(TEX_DIR).filter(f => f.endsWith('.tex'))
  : []

for (const file of texFiles) {
  const slug = path.basename(file, '.tex') // e.g. '2.Chapter'
  const chapNum = slug.split('.')[0]
  const chapterDir = path.join(CONTENT_DIR, slug)
  const mediaDir = path.join(chapterDir, 'media')
  const codeDir = path.join(chapterDir, 'code-snippets')
  const mdPath = path.join(chapterDir, `${slug}.md`)

  // Clean start
  rmDir(chapterDir, { recursive: true, force: true })
  ensureDir(mediaDir)
  ensureDir(codeDir)

  // Copy & dedupe figures
  const seenHashes = new Set()
  for (const baseDir of [RAW_DIR, EXP_DIR]) {
    const sub = baseDir === EXP_DIR ? 'figure-pdf' : ''
    const srcDir = path.join(baseDir, `chapter${chapNum}`, sub)
    if (!fs.existsSync(srcDir)) continue
    for (const fn of fs.readdirSync(srcDir)) {
      const srcPath = path.join(srcDir, fn)
      if (!fs.lstatSync(srcPath).isFile()) continue
      const hash = checksum(srcPath)
      if (seenHashes.has(hash)) continue
      seenHashes.add(hash)
      fs.copyFileSync(srcPath, path.join(mediaDir, fn))
    }
  }

  // Convert .tex to Markdown
  execSync(
    `pandoc "${path.join(TEX_DIR, file)}" -f latex -t markdown -o "${mdPath}"`,
    { stdio: 'inherit' }
  )

  // Post-process Markdown
  let md = fs.readFileSync(mdPath, 'utf8')
  // Remove LaTeX labels & comments
  md = md.replace(/\\label\{[^}]+\}/g, '')
         .replace(/%.*/g, '')
  // Strip custom pseudo-environments
  md = md.replace(/::: ?(?:Shaded|Highlighting)[\s\S]*?:::/g, '')
  // Remove {#anchor} from first heading
  md = md.replace(/^#\s+(.*?)\s*\{#.*?\}/m, '# $1')
  // Patch image links
  md = md.replace(/\\includegraphics(?:\[[^\]]*\])?\{(?:.*?\/)??([^}]+)\}/g,
    (_, img) => `![](media/${img})`
  )
  fs.writeFileSync(mdPath, md)

  // Advanced code extraction
  const texLines = fs.readFileSync(path.join(TEX_DIR, file), 'utf8').split(/\r?\n/)
  let buffering = false
  let buffer = []
  for (const line of texLines) {
    if (/\\begin\{(?:lstlisting|verbatim)\}|Program code starts/.test(line)) {
      buffering = true
      continue
    }
    if (/\\end\{(?:lstlisting|verbatim)\}|Program code ends/.test(line)) {
      buffering = false
      if (buffer.length) {
        const snippet = buffer.join('\n')
        const outFile = path.join(codeDir, `${slug}-${Date.now()}.txt`)
        fs.writeFileSync(outFile, snippet)
        buffer = []
      }
      continue
    }
    if (buffering) {
      // Remove any leftover LaTeX commands in code
      buffer.push(line.replace(/\\[a-zA-Z]+/g, ''))
    }
  }

  console.log(`✅ Processed ${slug}`)
}

console.log('🎉 All chapters processed!')