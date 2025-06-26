// src/scripts/convertTex.js
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

// Polyfill __dirname in ESM
const __filename = fileURLToPath(import.meta.url)
const __dirname  = path.dirname(__filename)

const TEX_DIR     = path.resolve(__dirname, '../../overleaf/chapters')
const CONTENT_DIR = path.resolve(__dirname, '../content')

// Ensure a directory exists
function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
}

// Clear out old content
const rmDir = fs.rmSync || fs.rmdirSync
rmDir(CONTENT_DIR, { recursive: true, force: true })
ensureDir(CONTENT_DIR)

// Find all .tex files
const texFiles = fs.existsSync(TEX_DIR)
  ? fs.readdirSync(TEX_DIR).filter(f => f.endsWith('.tex'))
  : []

// --- Helper: Clean LaTeX macros from comments and code ---
function cleanLatexMacros(s) {
  // Replace LaTeX single-quote macro with a literal '
  s = s.replace(/\\textquotesingle(\{\})?/g, "'");
  // Replace \textasciigrave{} or \textasciigrave with `
  s = s.replace(/\\textasciigrave\{\}/g, '`');
  s = s.replace(/\\textasciigrave/g, '`');
  // Operators and general cleanups
  s = s
    .replace(/\\textless{}\s*\{\s*\-\s*\}/g, '<-')
    .replace(/\\textless{}\s*\-/g, '<-')
    .replace(/\\textless{}/g, '<')
    .replace(/\\textgreater{}/g, '>')
    .replace(/\\%/g, '%')
    .replace(/\{\}/g, '');

  // Remove general latex macros (recursive, in case of nesting)
  let prev;
  do {
    prev = s;
    s = s.replace(/\\[a-zA-Z]+(?:\[\])?\{([^{}]*)\}/g, '$1');
  } while (s !== prev);

  // Restore special chars and whitespace
  s = s
    .replace(/\\([#_])/g, '$1')
    .replace(/~+/g, ' ')
    .replace(/ +/g, ' ')
    .replace(/^\s*\{+/, '')
    .replace(/\}+\s*$/, '')
    .trimEnd();

  return s;
}

// --- Improved LaTeX-to-R conversion (comments + code) ---
function latexToR(line) {
  // 1. Dedicated processing for LaTeX comments
  const commentMatch = line.match(/^\s*\\CommentTok\{\s*#?(.*)\}$/)
  if (commentMatch) {
    // Remove a single leading backslash-hash and any following space
    let text = commentMatch[1].replace(/^\\#\s*/, '').trim()
    // Clean LaTeX macros in the comment text
    text = cleanLatexMacros(text)
    return '# ' + text
  }
  // 2. Code line: clean as usual
  return cleanLatexMacros(line)
}

// --- Multi-line LaTeX heading extractor ---
function extractMultilineHeading(lines, idx, macro) {
  const startLine = lines[idx]
  const macroPattern = new RegExp('^\\\\' + macro + '\\*?\\{')
  if (!macroPattern.test(startLine)) return {heading: null, nextIdx: idx}

  let headingText = startLine.replace(macroPattern, '')
  let i = idx
  let found = false
  while (!found && i + 1 < lines.length) {
    if (headingText.includes('}')) {
      found = true
    } else {
      i++
      headingText += '\n' + lines[i]
    }
  }
  // Extract heading up to first }
  const endIdx = headingText.indexOf('}')
  if (endIdx === -1) return {heading: headingText.trim(), nextIdx: i}
  let heading = headingText.slice(0, endIdx).replace(/\s+/g, ' ').trim()
  return {heading, nextIdx: i}
}

// --- Main script ---

for (const file of texFiles) {
  const slug       = path.basename(file, '.tex')
  const chapterDir = path.join(CONTENT_DIR, slug)
  const rPath      = path.join(chapterDir, `${slug}.R`)

  rmDir(chapterDir, { recursive: true, force: true })
  ensureDir(chapterDir)

  const texContent = fs.readFileSync(path.join(TEX_DIR, file), 'utf8')
  const lines = texContent.split(/\r?\n/)

  // Explicit heading variables
  let currentSection = null
  let currentSubsection = null
  let currentSubsubsection = null

  const outputLines = []

  for (let idx = 0; idx < lines.length; idx++) {
    // ---- Multiline heading extraction ----
    let headingInfo = extractMultilineHeading(lines, idx, 'section')
    if (headingInfo.heading) {
      currentSection = headingInfo.heading
      currentSubsection = null
      currentSubsubsection = null
      idx = headingInfo.nextIdx
      continue
    }
    headingInfo = extractMultilineHeading(lines, idx, 'subsection')
    if (headingInfo.heading) {
      currentSubsection = headingInfo.heading
      currentSubsubsection = null
      idx = headingInfo.nextIdx
      continue
    }
    headingInfo = extractMultilineHeading(lines, idx, 'subsubsection')
    if (headingInfo.heading) {
      currentSubsubsection = headingInfo.heading
      idx = headingInfo.nextIdx
      continue
    }

    // ---- Code block extraction ----
    const line = lines[idx]
    if (
      /^\s*\\begin\{Shaded\}\s*$/.test(line) &&
      idx + 1 < lines.length &&
      /^\s*\\begin\{Highlighting\}\[\]\s*$/.test(lines[idx + 1])
    ) {
      const codeLines = []
      idx += 2
      while (idx < lines.length && !/^\s*\\end\{Highlighting\}\s*$/.test(lines[idx])) {
        codeLines.push(lines[idx])
        idx++
      }
      idx++ // skip \end{Highlighting}
      if (idx < lines.length && /^\s*\\end\{Shaded\}\s*$/.test(lines[idx])) {
        // skip
      }

      // Output only present headings, properly indented
      if (currentSection)       outputLines.push(`# ${currentSection}`)
      if (currentSubsection)    outputLines.push(`#   ${currentSubsection}`)
      if (currentSubsubsection) outputLines.push(`#     ${currentSubsubsection}`)
      if (currentSection || currentSubsection || currentSubsubsection)
        outputLines.push('')

      outputLines.push(...codeLines.map(latexToR))
      outputLines.push('# ─────────────────────────────────────────────')
      outputLines.push('')
    }
  }

  if (outputLines.length) {
    fs.writeFileSync(rPath, outputLines.join('\n'), 'utf8')
    console.log(`Generated R script for ${slug}`)
  } else {
    console.log(`No code blocks found in ${slug}, skipping R script`)
  }
}

console.log('All chapters processed!')
