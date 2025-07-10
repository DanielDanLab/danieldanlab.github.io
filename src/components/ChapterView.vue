<template>
  <div class="chapter-view">
    <!-- navigation + title -->
    <div class="chapter-nav">
      <router-link
        v-if="prevSlug"
        :to="`/chapters/${prevSlug}`"
        class="nav-link prev"
      >
        ← Previous
      </router-link>

      <h1 class="chapter-title">{{ title }}</h1>

      <router-link
        v-if="nextSlug"
        :to="`/chapters/${nextSlug}`"
        class="nav-link next"
      >
        Next →
      </router-link>
    </div>

    <!-- controls: download + summary toggle -->
    <div class="download-container">
      <a
        v-if="rUrl"
        :href="rUrl"
        :download="`${slug}.R`"
        class="btn-download"
      >
        Download
      </a>

      <button
        v-if="renderedSummary"
        class="btn-summary"
        @click="showSummary = !showSummary"
      >
        {{ showSummary ? 'Hide AI Summary' : 'Show AI Summary' }}
      </button>
    </div>

    <!-- AI Summary panel -->
    <div v-if="showSummary && renderedSummary"
      class="ai-summary"
      v-html="renderedSummary"/>

    <!-- R script filename + code -->
    <div v-if="rScript || rUrl" class="r-code">
      <div v-if="rScript" class="filename">{{ slug }}.R</div>
      <pre v-if="rScript"><code>{{ rScript }}</code></pre>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute }           from 'vue-router'
import { marked }             from 'marked'

// chapter order
const allChapters = [
  '1.Chapter','2.Chapter','3.Chapter','4.Chapter','5.Chapter',
  '6.Chapter','7.Chapter','8.Chapter','9.Chapter','10.Chapter'
]

const route = useRoute()
const slug  = computed(() => route.params.slug)
const title = computed(() => slug.value.replace('.', '. '))

// navigation helpers
const currentIndex = computed(() => allChapters.indexOf(slug.value))
const prevSlug = computed(() =>
  currentIndex.value > 0
    ? allChapters[currentIndex.value - 1]
    : null
)
const nextSlug = computed(() =>
  currentIndex.value < allChapters.length - 1
    ? allChapters[currentIndex.value + 1]
    : null
)

// script + summary state
const rScript     = ref('')
const rUrl        = ref('')
const summary     = ref('')
const showSummary = ref(false)

// load both R script and summary whenever slug changes
async function loadChapter() {
  rScript.value = ''
  rUrl.value    = ''
  summary.value = ''
  showSummary.value = false

  // 1) fetch the R script text
  try {
    const res = await fetch(`/content/${slug.value}/${slug.value}.R`)
    if (res.ok) {
      rScript.value = await res.text()
      // 2) set the download URL
      rUrl.value = `/content/${slug.value}/${slug.value}.R`
    }
  } catch {
    // no R script
  }

  // 3) fetch the AI summary markdown
  try {
    const res = await fetch(`/content/${slug.value}/${slug.value}.summary.md`)
    if (res.ok) {
      summary.value = await res.text()
    }
  } catch {
    // no summary
  }
}

// re-run on slug change and initial mount
watch(slug, loadChapter, { immediate: true })

// render summary as HTML if markdown, else wrap in <p>
const renderedSummary = computed(() => {
  if (!summary.value) return ''
  return summary.value.includes('\n')
    ? marked(summary.value)
    : `<p>${summary.value}</p>`
})
</script>

<style scoped>
.chapter-view {
  max-width: 800px;
  margin: 2rem auto;
  line-height: 1.6;
}

/* navigation */
.chapter-nav {
  position: relative;
  text-align: center;
  margin-bottom: 1.5rem;
}
.nav-link {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  color: #42b983;
  text-decoration: none;
  font-weight: 500;
}
.nav-link.prev { left: 0.5rem; }
.nav-link.next { right: 0.5rem; }
.chapter-title {
  margin: 0;
  font-size: 1.75rem;
  font-weight: bold;
}

/* controls */
.download-container {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 1rem;
}
.btn-download,
.btn-summary {
  background: #42b983;
  color: white;
  border: none;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  cursor: pointer;
}
.btn-download:hover,
.btn-summary:hover {
  background: #36996f;
}
.ai-summary {
  background: #f5f7fa;
  padding: 1.5rem;
  border-radius: 8px;
  margin: 2rem 0;
  line-height: 1.5;
  text-align: left;
}

.ai-summary em {
  display: block;
  margin: 0.5rem 0 1rem;
}

.ai-summary ul {
  margin-left: 1.25rem;
  list-style-type: disc;
}

.ai-summary strong {
  display: block;
  font-size: 1rem;
  margin-top: 1rem;
}
/* R code display */
.filename {
  font-family: monospace;
  font-weight: bold;
  margin-bottom: 0.5rem;
  text-align: left;
}
.r-code pre {
  text-align: left;
  background: #282c34;
  color: #abb2bf;
  padding: 1rem;
  border-radius: 4px;
  overflow: auto;
}
</style>
