// src/scripts/convertTex.js
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

// Polyfill __dirname in ESM
const __filename = fileURLToPath(import.meta.url)
const __dirname  = path.dirname(__filename)

const TEX_DIR     = path.resolve(__dirname, '../../overleaf/chapters')
// Previously pointed at src/content. Now emit into public/content.
const CONTENT_DIR = path.resolve(__dirname, '../../public/content')

// Ensure a directory exists
function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
}
ensureDir(CONTENT_DIR)

// Find all .tex files
const texFiles = fs.existsSync(TEX_DIR)
  ? fs.readdirSync(TEX_DIR).filter(f => f.endsWith('.tex'))
  : []

function unwrapLatexMacro(s, macroName) {
  const macroRegex = new RegExp(`\\\\${macroName}\\{`, 'g');
  let out = '';
  let lastIndex = 0;
  let m;
  while ((m = macroRegex.exec(s)) !== null) {
    out += s.slice(lastIndex, m.index);
    let start = m.index + m[0].length;
    let depth = 1;
    let i = start;
    while (i < s.length && depth > 0) {
      if (s[i] === '\\' && (s[i+1] === '{' || s[i+1] === '}')) {
        i += 2; // skip escaped brace
      } else if (s[i] === '{') {
        depth++;
        i++;
      } else if (s[i] === '}') {
        depth--;
        i++;
      } else {
        i++;
      }
    }
    if (depth === 0) {
      out += s.slice(start, i-1);
      lastIndex = i;
    } else {
      out += s.slice(m.index);
      lastIndex = s.length;
      break;
    }
    macroRegex.lastIndex = lastIndex;
  }
  out += s.slice(lastIndex);
  return out;
}


// --- Helper: Clean LaTeX macros from comments and code ---
function cleanLatexMacros(s) {
  // --- SpecialCharTok and StringTok escapes ---
  s = s.replace(/\\SpecialCharTok\{(\\textbackslash\{\}\\textbackslash\{\})\}/g, '\\\\');
  s = s.replace(/\\SpecialCharTok\{\\textbackslash\{\}\}/g, '\\');
  s = s.replace(/\\StringTok\{"\}/g, '"');
  // --- Other macros and operators ---
  s = s.replace(/\\textquotesingle(\{\})?/g, "'");
  s = s.replace(/\\textasciigrave\{\}/g, '`');
  s = s.replace(/\\textasciigrave/g, '`');
  s = s.replace(/\\textasciitilde/g, '~');
  s = s.replace(/\\sim/g, '~');
  s = s
    .replace(/\\textless{}\s*\{\s*\-\s*\}/g, '<-')
    .replace(/\\textless{}\s*\-/g, '<-')
    .replace(/\\textless{}/g, '<')
    .replace(/\\textgreater{}/g, '>')
    .replace(/\\%/g, '%')
    .replace(/\{\}/g, '');

  s = unwrapLatexMacro(s, "StringTok");

  // --- Remove general latex macros (recursive, in case of nesting) ---
  let prev;
  do {
    prev = s;
    s = s.replace(/\\[a-zA-Z]+(?:\[\])?\{([\s\S]*?)\}/g, '$1');
  } while (s !== prev);
  // Remove macros wrapping single braces or parens/brackets (including whitespace)
  s = s.replace(/\\[a-zA-Z]+(?:\[\])?\{\s*([\(\)\[\]{}])\s*\}/g, '$1');
  // Remove any stray \NormalTok
  s = s.replace(/\\NormalTok\b/g, '');
  // Remove stray backslashes before braces, parentheses, or brackets
  s = s.replace(/\\([{}()])/g, '$1');
  // Remove backslash at line end (from LaTeX linebreak)
  s = s.replace(/\\\s*$/g, '');
  s = s.replace(/^\s*{\s*$/gm, '{');
  s = s.replace(/^\s*}\s*$/gm, '}');
  // --- Whitespace and special chars ---
  s = s
    .replace(/\\([#_])/g, '$1')
    .replace(/ +/g, ' ')
    .replace(/^\s*\{+/, '')
    .replace(/\}+\s*$/, '')
    .trimEnd();
  // Inline \CommentTok to R comment (removes any leading hash or space in the comment)
  s = s.replace(/\\CommentTok\{\s*#?\s*([^}]*)\}/g, '# $1');
  // Replace {-} with -
  s = s.replace(/\{\-\}/g, '-');
  // Unescape LaTeX-escaped curly braces for regex quantifiers
  s = s.replace(/\\\{([0-9,]+)\\\}/g, '{$1}');
  // Remove any stray braces inside character classes in regex
  s = s.replace(/\[([^\]]*)\]/g, (m, chars) => '[' + chars.replace(/[{}]/g, '') + ']');
  // Remove only empty macro braces left after macro expansion
  s = s.replace(/\{\}/g, '');

  return s;
}

// --- Improved LaTeX-to-R conversion (comments + code) ---
function latexToR(line) {
  // 1. Dedicated processing for LaTeX (full line) comments
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

  // Only remove old .R scripts; keep any .summary.md
  if (fs.existsSync(chapterDir)) {
    for (const existing of fs.readdirSync(chapterDir)) {
      if (existing.endsWith('.R')) {
        fs.unlinkSync(path.join(chapterDir, existing))
      }
    }
  }
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
      if (currentSection) {
        outputLines.push(`# Section: ${currentSection}`)
      }
      if (currentSubsection) {
        outputLines.push(`#   Subsection: ${currentSubsection}`)
      }
      if (currentSubsubsection) {
        outputLines.push(`#     Subsubsection: ${currentSubsubsection}`)
      }
      if (currentSection || currentSubsection || currentSubsubsection)
        outputLines.push('')      

      outputLines.push(...codeLines.map(latexToR))
      outputLines.push('# ──────────────────────────────────────────────────────────────')
      outputLines.push('')
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
