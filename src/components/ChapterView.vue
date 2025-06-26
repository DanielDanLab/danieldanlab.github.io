<!-- src/components/ChapterView.vue -->
<template>
    <div class="chapter-view">
      <h1>{{ slug }}</h1>
      <div v-html="htmlContent" class="markdown-content" />
  
      <section v-if="images.length">
        <h2>Figures</h2>
        <div class="figures">
          <div v-for="(src, i) in images" :key="i">
            <img :src="src" :alt="`Figure ${i+1}`" />
          </div>
        </div>
      </section>
  
      <section v-if="snippets.length">
        <h2>Code Snippets</h2>
        <pre v-for="(code, i) in snippets" :key="i"><code>{{ code }}</code></pre>
      </section>
    </div>
  </template>
  
  <script setup>
import { ref, onMounted } from 'vue'
import { useRoute }          from 'vue-router'
import { marked }            from 'marked'

const route       = useRoute()
const slug        = route.params.slug
const htmlContent = ref('')
const images      = []
const snippets    = []

const allImages   = import.meta.glob('../content/*/media/*',   { eager: true, as: 'url' })
const allSnippets = import.meta.glob('../content/*/code-snippets/*.txt', { eager: true, as: 'raw' })

onMounted(async () => {
  // 1) Load and render Markdown via fetch
  const mdUrl  = new URL(`../content/${slug}/${slug}.md`, import.meta.url).href
  const mdText = await fetch(mdUrl).then(r => r.text())
  htmlContent.value = marked(mdText)

  // 2) Images
  for (const [path, url] of Object.entries(allImages)) {
    if (path.includes(`/content/${slug}/media/`)) images.push(url)
  }

  // 3) Snippets
  for (const [path, raw] of Object.entries(allSnippets)) {
    if (path.includes(`/content/${slug}/code-snippets/`)) snippets.push(raw)
  }
})
</script>

  
  <style scoped>
  .markdown-content img {
    max-width: 100%;
  }
  .figures {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px,1fr));
    gap: 1rem;
  }
  .chapter-view pre {
    background: #f9f9f9;
    padding: 1rem;
    border-radius: 4px;
    overflow-x: auto;
  }
  </style>
  