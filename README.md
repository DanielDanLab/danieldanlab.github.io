# Companion Website for “Online Content Analysis with Applications for Marketing”

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
│   │   └── ChapterView.vue
│   ├── router/                    # Vue Router setup
│   │   └── index.js
│   ├── scripts/
│   │   └── convertTex.js          # Node script: .tex → .R + summaries
│   ├── views/
│   │   └── Data.vue               # downloads for raw data files
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

## 🤝 Contributing

1. Pull latest sources: `git pull`
2. Create a new branch off `main`.  `git checkout -b 'new-branch-name'` 
3. Update code, LaTeX sources, or summaries.  
4. Push, open a PR, and merge to `main`. `git add 'filename-you-added'` -> `git commit -m 'commit message explanation'` -> `git push` -> create merge request by click on the link that appears in the console -> create and merge pull request 
5. CI will automatically rebuild and deploy.

---

