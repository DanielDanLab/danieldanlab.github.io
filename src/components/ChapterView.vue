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

    <!-- R script download + display -->
    <div v-if="rScript || rUrl" class="r-code">
      <div class="download-container">
        <a
          v-if="rUrl"
          :href="rUrl"
          :download="`${slug}.R`"
          class="btn-download"
        >
          Download
        </a>
      </div>

      <div v-if="rScript" class="filename">{{ slug }}.R</div>
      <pre v-if="rScript"><code>{{ rScript }}</code></pre>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute }    from 'vue-router'

const allChapters = [
  '1.Chapter','2.Chapter','3.Chapter','4.Chapter','5.Chapter',
  '6.Chapter','7.Chapter','8.Chapter','9.Chapter','10.Chapter'
]

// 1) reactive slug from the route
const route = useRoute()
const slug  = computed(() => route.params.slug)

// 2) reactive title
const title = computed(() => slug.value.replace('.', '. '))

// 3) prev / next
const currentIndex = computed(() => allChapters.indexOf(slug.value))
const prevSlug = computed(() =>
  currentIndex.value > 0 ? allChapters[currentIndex.value - 1] : null
)
const nextSlug = computed(() =>
  currentIndex.value < allChapters.length - 1
    ? allChapters[currentIndex.value + 1]
    : null
)

// 4) R‐script state
const rScript = ref('')
const rUrl    = ref('')

// 5) load function
async function loadChapter() {
  rScript.value = ''
  rUrl.value    = ''

  try {
    const rawMod = await import(
      /* @vite-ignore */ `../content/${slug.value}/${slug.value}.R?raw`
    )
    rScript.value = rawMod.default
  } catch {}

  try {
    const urlMod = await import(
      /* @vite-ignore */ `../content/${slug.value}/${slug.value}.R?url`
    )
    rUrl.value = urlMod.default
  } catch {}
}

// 6) watch slug (and run once on initial load)
watch(slug, loadChapter, { immediate: true })
</script>

<style scoped>
.chapter-view {
  max-width: 800px;
  margin: 2rem auto;
  line-height: 1.6;
}

/* ─── Navigation Row ─────────────────────────────────────── */
.chapter-nav {
  position: relative;
  text-align: center;
  margin-bottom: 1.5rem;
}
/* absolutely position links */
.nav-link {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  color: #42b983;
  text-decoration: none;
  font-weight: 500;
}
.nav-link:hover {
  text-decoration: underline;
}
/* left and right offsets */
.nav-link.prev {
  left: 0.5rem;
}
.nav-link.next {
  right: 0.5rem;
}
/* center title normally */
.chapter-title {
  margin: 0;
  font-size: 1.75rem;
  font-weight: bold;
}

/* ─── Download / Filename / Code ───────────────────────── */
.download-container {
  text-align: center;
  margin-bottom: 1rem;
}
.btn-download {
  background: #42b983;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  text-decoration: none;
}
.btn-download:hover {
  background: #36996f;
}
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
