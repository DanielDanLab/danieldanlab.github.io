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
        <p class="errata-thanks">We thank Professor Tsung-wu Ho for spotting this omission.</p>
      </div>
            <div class="errata-item">
        <h2>Chapter 6.2.4 &mdash; Clarification on hyperplanes (p. 187, line 7 ff.)</h2>
        <p><strong>Location:</strong> Page 187, line 7 ff.</p>
        <p>The sentence should read:</p>
        <blockquote>
          &ldquo;For example, in a three-dimensional space, a hyperplane will have two dimensions,
          while in a two-dimensional space the hyperplane has one dimension, basically a line.&rdquo;
        </blockquote>
        <p class="errata-thanks">
          We thank Clara Wiebel (<a href="https://www.tum.de/" target="_blank" rel="noopener noreferrer">Technische Universit&auml;t M&uuml;nchen</a>) for this correction.
        </p>
      </div>
      <div class="errata-item">
        <h2>Chapter 6.2.1 &mdash; Lemmatization in the data set preparation code (p. 175)</h2>
        <p><strong>Location:</strong> Page 175, code that creates the document-term matrix.</p>
        <p>
          The line <code>tm_map(content_transformer(lemmatize_words))</code> does not lemmatize the reviews.
          <code>lemmatize_words()</code> expects a vector of single words, but <code>tm_map()</code> passes
          each review as one string, so the text is returned unchanged (e.g. &ldquo;apps&rdquo; and
          &ldquo;applications&rdquo; remain separate terms). Use <code>lemmatize_strings()</code>, which
          lemmatizes every word of each document:
        </p>
        <pre><code>tm_map(content_transformer(lemmatize_strings)) %&gt;% # Lemmatization</code></pre>
        <p>
          The online code for Chapter 6 has been corrected. With lemmatization working, the document-term
          matrix has fewer terms (e.g. &ldquo;apps&rdquo; is counted as &ldquo;app&rdquo;), so the classification
          results differ slightly from those printed in the book.
        </p>
      </div>
      <div class="errata-item">
        <h2>Chapter 7.2: Reassignment of &ldquo;screen&rdquo; in the Gibbs sampling example (p. 217)</h2>
        <p><strong>Location:</strong> Page 217, line 232.</p>
        <p>
          In the reassignment of &ldquo;screen&rdquo; in Doc1, the document-topic factor for T<sub>1</sub>
          should use the counts without the current word, as is done for T<sub>2</sub>:
          (2 + 0.1) / (2 + 2 &times; 0.1) = 2.1 / 2.2. The combined value for T<sub>1</sub> is therefore
          0.01 / 7.08 &times; 2.1 / 2.2 = 0.00135, not 0.001608.
        </p>
        <p>
          The conclusion is unchanged: T<sub>2</sub> (0.00755) is more likely than T<sub>1</sub>,
          with probabilities of about 85% and 15%.
        </p>
      </div>
      <div class="errata-item">
        <h2>Chapter 7.2: Clarification on the reassignment step (p. 217, lines 237&ndash;240)</h2>
        <p><strong>Location:</strong> Page 217, lines 237&ndash;240.</p>
        <p>
          The new topic of &ldquo;screen&rdquo; is drawn at random with probabilities proportional to the
          two values (about 15% for T<sub>1</sub> and 85% for T<sub>2</sub>); it is not simply set to the
          larger one. Unlike the initial assignment, which ignores the data, this draw is weighted by the
          current counts. Keeping a small chance for the less likely topic lets the sampler move away from
          a poor starting arrangement; as the counts sharpen over the iterations, the assignments stabilise.
        </p>
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
.errata-thanks {
  margin-top: 0.75rem;
  font-style: italic;
  color: #555;
}
</style>
