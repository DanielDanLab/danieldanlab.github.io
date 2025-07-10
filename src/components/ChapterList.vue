<template>
  <div class="chapter-list">
    <h1>Chapters</h1>
    <div class="grid">
      <div v-for="ch in chapters" :key="ch.slug" class="card">
        <h2>
          <span class="line1">{{ split(ch.title)[0] }}:</span>
          <span class="line2">{{ split(ch.title)[1] }}</span>
        </h2>
        <router-link :to="`/chapters/${ch.slug}`" class="btn-read">
          Go To Code
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
// Static list of chapters
const chapters = [
  { slug: '1.Chapter',  title: 'Chapter 1: Introduction' },
  { slug: '2.Chapter',  title: 'Chapter 2: Textual Data' },
  { slug: '3.Chapter',  title: 'Chapter 3: Obtaining Textual Data' },
  { slug: '4.Chapter',  title: 'Chapter 4: Basic Text Analysis and Statistics' },
  { slug: '5.Chapter',  title: 'Chapter 5: Clustering' },
  { slug: '6.Chapter',  title: 'Chapter 6: Classification' },
  { slug: '7.Chapter',  title: 'Chapter 7: Topic Modeling' },
  { slug: '8.Chapter',  title: 'Chapter 8: Sentiment Analysis' },
  { slug: '9.Chapter',  title: 'Chapter 9: Named Entity Recognition and Summarizing' },
  { slug: '10.Chapter', title: 'Chapter 10: Extracting Information from Embedding' },
]

// helper: split on first “: ”
function split(title) {
  const [head, ...rest] = title.split(': ')
  return [head, rest.join(': ')]
}
</script>

<style scoped>
.chapter-list {
  padding: 2rem;
  max-width: 900px;
  margin: 0 auto;
}

.grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 400px));
  justify-content: center; /* center the two columns instead of stretching */
  gap: 1.5rem;
}

.card {
  display: flex;
  flex-direction: column;
  align-items: center;        /* center everything */
  justify-content: flex-start;/* push items top & bottom only by margin */
  background: #fff;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  min-height: 120px;         
}

/* Two‐line title inside H2 */
.card h2 {
  margin: 0 0 1rem;           /* fixed space below title */
  font-size: 1.2rem;
  line-height: 1.3;
  text-align: center;
  word-break: break-word;
}

/* Split title into two lines */
.card .line1,
.card .line2 {
  display: block;
}

/* Button always sits exactly 1rem below the title */
.btn-read {
  margin-top: auto;           /* push button to bottom if title is short */
  background: #42b983;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  text-decoration: none;
}
.btn-read:hover {
  background: #36996f;
}

@media (max-width: 600px) {
  .grid {
    grid-template-columns: 1fr;
  }
}
</style>
