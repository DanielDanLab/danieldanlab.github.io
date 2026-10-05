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
      <div class="errata-item">
        <h2>Chapter 2.3.3: Number of unique titles with the repaired data set (p. 28)</h2>
        <p><strong>Location:</strong> Page 28, output of <code>length(unique(prodtitle))</code> and the sentence below it.</p>
        <p>
          The printed values (31,405 unique titles, 9,336 duplicates) are correct for the original version of
          <code>Product Reviews.csv</code>. In September 2026 the data file on this site was repaired: 217 damaged rows
          (titles and reviews cut at the first semicolon, and three spreadsheet errors) were restored. With the repaired file the code returns
          31,433 unique titles out of 40,741, so 9,308 titles are duplicates.
        </p>
      </div>
      <div class="errata-item">
        <h2>Chapter 2.4.5: <code>\w</code> and <code>\W</code> in Table 2.5 (p. 44)</h2>
        <p><strong>Location:</strong> Page 44, Table 2.5, rows <code>\w</code> and <code>\W</code>.</p>
        <p>
          A word character also includes the underscore, as stated in Section 2.4.2. The rows should read:
        </p>
        <pre><code>\w   Matches a word character      [A-Za-z0-9_]
\W   Matches a nonword character   [^A-Za-z0-9_]</code></pre>
        <p>For example, <code>grepl("^\\w+$", "a_b")</code> returns <code>TRUE</code>.</p>
      </div>
      <div class="errata-item">
        <h2>Chapter 2.4.7: Lazy quantifiers are supported in R (p. 45)</h2>
        <p><strong>Location:</strong> Page 45, first paragraph (&ldquo;greedy (standard in R) and lazy (enabled in RStudio)&rdquo;) and last paragraph of the section.</p>
        <p>
          R&rsquo;s regex engines do support lazy matching. Adding <code>?</code> after a quantifier
          (<code>*?</code>, <code>+?</code>, <code>??</code>, <code>{n,m}?</code>) makes it lazy both in the default
          engine and with <code>perl = TRUE</code>, and also in <strong>stringr</strong>. Greedy matching is only the
          default. The sentence on p. 45 should read: &ldquo;Quantifiers in R are greedy by default; adding
          <code>?</code> makes them lazy, both in R&rsquo;s regex functions and in RStudio&rsquo;s search and replace.&rdquo;
        </p>
        <pre><code>x &lt;- "Text Analytics for Digital Marketing"
regmatches(x, regexpr("(Text)(.*?)(i)", x))               # "Text Analyti"
regmatches(x, regexpr("(Text)(.*?)(i)", x, perl = TRUE))  # "Text Analyti"
regmatches(x, regexpr("(Text)(.*)(i)", x))                # "Text Analytics for Digital Marketi"</code></pre>
      </div>
      <div class="errata-item">
        <h2>Chapter 4.3.1: Term frequency of Doc 2 in Table 4.2 (p. 105)</h2>
        <p><strong>Location:</strong> Page 105, Table 4.2, row &ldquo;tf Doc 2&rdquo;.</p>
        <p>
          Doc 2 has three terms, so each of its terms has tf = 1/3, which rounds to <strong>0.33</strong>, not 0.34.
          The tf-idf value of &ldquo;best&rdquo; in Doc 2 is unchanged: 0.33 &times; 0.30 = 0.10.
        </p>
      </div>
      <div class="errata-item">
        <h2>Chapter 10.6.1: Error function and gradient in the word2vec update (pp. 342&ndash;343)</h2>
        <p><strong>Location:</strong> Page 342, definition of the error <em>E</em>, and page 343, the gradients and the numerical example.</p>
        <p>
          The error is defined as <em>E</em> = <em>t</em> &minus; &sigma;(<em>v</em> &middot; <em>u</em>), with gradient
          &minus;&sigma;(<em>v</em> &middot; <em>u</em>)(1 &minus; &sigma;(<em>v</em> &middot; <em>u</em>)) &middot; <em>u</em>.
          The target <em>t</em> then drops out of the gradient, so the update always increases <em>v</em> &middot; <em>u</em>.
          This is right for a positive pair (<em>t</em> = 1) but moves the vectors the wrong way for a negative
          pair (<em>t</em> = 0).
        </p>
        <p>
          Word2vec with negative sampling minimises the log loss
          <em>E</em> = &minus;[<em>t</em> log &sigma;(<em>v</em> &middot; <em>u</em>) + (1 &minus; <em>t</em>) log(1 &minus; &sigma;(<em>v</em> &middot; <em>u</em>))].
          Its gradients are:
        </p>
        <pre><code>&part;E/&part;v = (&sigma;(v &middot; u) &minus; t) &middot; u
&part;E/&part;u = (&sigma;(v &middot; u) &minus; t) &middot; v

v_new = v_old &minus; &eta; &middot; (&sigma;(v_old &middot; u_old) &minus; t) &middot; u_old
u_new = u_old &minus; &eta; &middot; (&sigma;(v_old &middot; u_old) &minus; t) &middot; v_old</code></pre>
        <p>
          In the numerical example (<em>v</em> = (0.5, 0.3), <em>u</em> = (0.1, 0.2), <em>t</em> = 1, &eta; = 0.1),
          &sigma;(0.11) &asymp; 0.5275, so the gradient for <em>v</em> is (0.5275 &minus; 1) &middot; (0.1, 0.2) &asymp;
          (&minus;0.0473, &minus;0.0945) and the update gives <em>v</em><sub>new</sub> &asymp; <strong>(0.5047, 0.3095)</strong>,
          not (0.50249, 0.30498). For a negative pair (<em>t</em> = 0) the same formula moves <em>v</em> away from <em>u</em>.
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
