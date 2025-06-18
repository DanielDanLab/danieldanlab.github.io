<!-- src/components/ChapterList.vue -->
<template>
  <div class="chapter-list">
    <h1>Chapters</h1>
    <div class="grid">
      <div v-for="ch in chapters" :key="ch.slug" class="card">
        <div class="chapter-info">
          <h2>{{ ch.number }}. {{ ch.title }}</h2>
          <router-link :to="`/chapters/${ch.slug}`" class="btn-read">
            Read
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const chapters = ref([])

onMounted(async () => {
  const modules = import.meta.glob('../content/*/*.md', { eager: true, as: 'url' })
  for (const [path, url] of Object.entries(modules)) {
    const parts = path.split('/')
    const slug = parts[2]
    const number = parseInt(slug.split('.')[0], 10)

    // Fetch markdown
    const res = await fetch(url)
    const md = await res.text()
    const lines = md.split(/\r?\n/)

    // Extract title from first H1
    let title = slug
    for (const line of lines) {
      if (line.startsWith('# ')) {
        title = line.slice(2).trim()
        break
      }
    }

    chapters.value.push({ slug, number, title })
  }

  chapters.value.sort((a, b) => a.number - b.number)
})
</script>

<style scoped>
.chapter-list {
  padding: 2rem;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;

  /* center and constrain width */
  max-width: 1000px;
  margin: 0 auto;
}

.card {
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 1rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.chapter-info {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.chapter-info h2 {
  margin: 0 0 1rem;
  font-size: 1.25rem;
  text-align: center;
}

.btn-read {
  background: #42b983;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  text-decoration: none;
  align-self: center;
}

.btn-read:hover {
  background: #36996f;
}
</style>