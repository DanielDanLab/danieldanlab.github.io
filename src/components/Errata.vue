<template>
  <div class="errata">
    <h1>Errata</h1>
    <p>
      This page lists corrections and additions to the printed book.
      If you spot any errors, omissions, or other problems, please send an e-mail to
      <a href="mailto:daniel.dan@modul.ac.at">daniel.dan@modul.ac.at</a>.
    </p>

    <div class="errata-list">
      <div class="errata-item">
        <h2>Chapter 7 &mdash; Missing code block</h2>
        <p>
          The following code, which creates the document-feature matrix (<code>dfmt</code>),
          is missing from the printed book but is present in the online code for Chapter 7:
        </p>
        <pre><code># Create the dfmt document
library(quanteda)

prodreviews &lt;- read.csv("data/Product Reviews.csv")
corp &lt;- corpus(prodreviews, text_field = "Content")

toks &lt;- tokens(
  corp,
  remove_punct = TRUE,
  remove_numbers = TRUE
) |&gt;
  tokens_tolower() |&gt;
  tokens_remove(stopwords("en"))

dfmt &lt;- dfm(toks)</code></pre>
      </div>
    </div>
  </div>
</template>

<script setup>
// no imports needed
</script>

<style scoped>
.errata {
  max-width: 800px;
  margin: 3rem auto;
  line-height: 1.6;
}
.errata h1 {
  margin-bottom: 1rem;
}
.errata > p {
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 2rem;
}
.errata a {
  color: #42b983;
  text-decoration: none;
}
.errata-list {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}
.errata-item {
  border-left: 4px solid #42b983;
  padding-left: 1rem;
}
.errata-item h2 {
  margin-bottom: 0.5rem;
  font-size: 1.1rem;
}
.errata-item pre {
  background: #f4f4f4;
  padding: 1rem;
  border-radius: 4px;
  overflow-x: auto;
  font-size: 0.9rem;
  line-height: 1.5;
}
.errata-item code {
  font-family: 'Courier New', Courier, monospace;
}
</style>
