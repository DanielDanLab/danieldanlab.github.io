# Companion Website for the book “Text Analytics in Marketing”

This project hosts a Vue.js–based companion site for the textbook, with:

- **R scripts** extracted from the LaTeX source  
- **AI-generated summaries** for each chapter  
- **Raw data files** for download  

It builds via Vite, deploys into `docs/`, and is served on GitHub Pages.

---

## 📁 Project Structure

```
├── .github/
│   └── workflows/
│       └── vue-build-deploy.yml   # CI: convert → build → deploy to GH Pages
├── overleaf/                      # .tex chapters
│   └── chapters/
├── public/
│   ├── assets/                    # static assets (icons, etc.)
│   └── content/                   # generated .R and .summary.md files  
│       ├── 1.Chapter/
│       │   ├── 1.Chapter.R
│       │   └── 1.Chapter.summary.md
│       └── …
├── src/
│   ├── assets/                    # global CSS, images, etc.
│   ├── components/                # reusable Vue components
│   │   ├── ChapterList.vue
│   │   ├── ChapterView.vue
│   │   ├── Contact.vue
│   │   ├── Data.vue
│   │   └── Home.vue
│   ├── router/                    # Vue Router setup
│   │   └── index.js
│   ├── scripts/
│   │   └── convertTex.js          # Node script: .tex → .R + summaries
│   └── main.js                    # app entrypoint
├── docs/                          # built site (output of `npm run build`)
│   ├── index.html
│   └── assets/                    # production JS/CSS bundles
├── package.json                   # scripts & dependencies
├── vite.config.js                 # Vite build & dev config
└── README.md                      # you’re reading this
```

---

## ⚙️ Local Development

1. **Install deps**  
   ```bash
   npm ci
   ```
2. **Convert LaTeX → R + summaries**  
   ```bash
   npm run convert
   ```
   This writes `.R` files into `public/content/...`.

3. **Run dev server**  
   ```bash
   npm run dev
   ```
   Opens at `http://localhost:5173` (or different port) with hot reload.

4. **Build for production**  
   ```bash
   npm run build
   ```
   Outputs into `docs/`, ready for deployment.

5. **Preview the build**  
   ```bash
   npm run serve
   ```
   Serves the `docs/` folder on a local HTTP server.

---

## 🚀 Deployment on GitHub Pages

This repo uses a GitHub Actions workflow to automate:

1. **`npm run convert`**  
2. **`npm run build`** → writes to `docs/`  
3. **Push `docs/` to `gh-pages` branch**  
4. GitHub Pages (configured to serve `gh-pages` → root) publishes the site

Whenever you merge into `main`, CI rebuilds and redeploys the live site.

---

## 📄 Content Pipeline

- **`convertTex.js`** parses each `.tex` chapter, extracts code blocks into `.R` scripts, and preserves any manually written `*.summary.md` files.  
- Vue components load via `fetch()` from `/content/<slug>/<slug>.R` and `/content/<slug>/<slug>.summary.md`.  
- Chapter list and navigation are driven by a static slug array and dynamic imports of content files.

---

## 🖥️ Understanding the Vue SPA

This companion site is built as a Single Page Application (SPA) using Vue.js. Below are practical pointers for anyone new to Vue:

### Project Entry & Mount Point
- **`src/main.js`**  
  - Imports Vue, the root component (`App.vue`), and the router.  
  - Mounts the app to `<div id="app">` in `index.html`.

### Root Component
- **`src/App.vue`**  
  - Defines the global layout: navigation bar, router view placeholder (`<router-view/>`).  
  - Modify this file to change site-wide elements (e.g. new header, footer, nav links, etc.).

### Routing
- **`src/router/index.js`**  
  - Registers all routes (e.g. `/chapters`, `/chapters/:slug`, `/data`).  
  - To add a new page, create a component in `src/components/`, then add a route entry in `src/router/index.js`.

### Components & Views
- **`src/components/`**  
  - Reusable UI pieces (e.g., `ChapterList.vue`, `ChapterView.vue`).  
  - To tweak chapter listings or detail layouts, edit these files.  
  - Full-page views (e.g., `Data.vue`).  
  - Add new components/views here and reference them in the router.

### Static Content & Fetching
- All generated R scripts and AI summaries live under **`public/content/<slug>/`**, where `<slug>` means `1. Chapter`, `2. Chapter`, etc.  
- The Vue code uses `fetch('/content/...')` to load these files at runtime.  
- To update chapter code or summaries, place `.R` or `.summary.md` files into `public/content/<slug>/` and execute the git commands to push the changes.

### Styling
- Global styles: **`src/assets/style.css`**  
- Component-scoped styles: inside each `.vue` file under `<style scoped>`.  
- To adjust colors, fonts, or layout, update these CSS sections.

### Development Workflow
1. **Convert**: `npm run convert` extracts from LaTeX and writes to `public/content/`.  
2. **Dev Server**: `npm run dev` starts a hot-reload server at `http://localhost:5173`.  
3. **Build**: `npm run build` bundles the SPA into `docs/` for deployment.  
4. **Preview**: `npm run serve` serves the `docs/` folder locally for final checks.

> **Tip**: When you edit Vue files, the dev server reloads automatically—no manual refresh needed.

---

## 🤝 Contributing (git workflow)

1. Pull latest sources: `git pull`
2. Create a new branch off `main`: `git checkout -b 'branc h-name'` 
3. Update code, LaTeX sources, or summaries.  
4. Push, open a PR, and merge to `main`. `git add 'filename-you-added'` -> `git commit -m 'commit message explanation'` -> `git push` -> create merge request by click on the link that appears in the console -> create and merge pull request 
5. CI will automatically rebuild and deploy.

---

## ❓ Questions & Answers

### What if I want to replace the LaTeX source files?
1. **Update the Overleaf files**: make edits in the original `.tex` files under `overleaf/chapters`.  
2. **Reload into local repo**: download the updated `.tex` files into `overleaf/chapters`.  
3. **Run the converter**:
   ```bash
   npm run convert
   ```
   This regenerates all `.R` scripts (preserving the `.summary.md` files for the AI summary) in `public/content`.  
4. **Review changes**: run `npm run dev` to verify locally.  
5. **Commit & PR**:
   ```bash
   git checkout -b update-latex (you could put any other branch name, does not have to be 'update-latex')
   git add overleaf/chapters public/content (here you would add every file that you changed; you can see which files you changed by typing `git status`)
   git commit -m "Update LaTeX sources and regenerate R scripts" (choose the commit message to your liking)
   git push -u origin update-latex
   ```
   Open a pull request against `main`. (this is done by following the links in the console after pushing)
6. **Merge** and let CI rebuild & deploy. (this step is also done in the gitlab ui)

### What if I want to update the AI summaries?
1. **Edit the Markdown**:
   - Open `public/content/<slug>/<slug>.summary.md`.  
   - Make your edits in Markdown format (follow the existing headings).  
2. **Preview locally**:
   ```bash
   npm run dev
   ```
   Click “Show AI Summary” in the chapter view to verify.  
3. **Commit & PR**:
   ```bash
   git checkout -b update-summaries
   git add public/content
   git commit -m "Revise AI summaries for chapters"
   git push -u origin update-summaries
   ```
   Open a pull request against `main`.  
4. **Merge** and let CI rebuild & deploy (summaries are static assets).

### What if I want to add a new navbar item (e.g., “Presentations”)?
1. **Create a new view**:
   - Add `src/components/Presentations.vue` with your page template.  
2. **Add a route**:
   ```js
   // src/router/index.js
   import Presentations from '@/components/Presentations.vue'
   // ...
   { path: '/presentations', name: 'Presentations', component: Presentations },
   ```
3. **Add a nav link**:
   - In `src/App.vue` inside the `<nav>` element:
     ```html
     <router-link to="/presentations">Presentations</router-link>
     ```
4. **Style or adjust** as needed in CSS.  
5. **Commit & PR**:
   ```bash
   git checkout -b add-presentations
   git add src/components src/router App.vue
   git commit -m "Add Presentations page to navbar"
   git push -u origin add-presentations
   ```
6. **Merge** and CI will rebuild & deploy automatically.

---

