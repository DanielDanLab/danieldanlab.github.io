# Section: Word2vec in practice

library(data.table)
library(lubridate)
library(word2vec)

# Read the dataset into a data.table
prodreviews <- fread("data/Product Reviews.csv",
 select = c("Content", "Brand"))
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

# Train word2vec model
model <- word2vec(x = tolower(prodreviews$Content), type = "cbow", dim = 200, window=5, iter = 30)
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

# Find similar words to apple
result_a <- predict(model, c("apple"), type = "nearest", top_n = 5)
print(result_a)
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

# Find similar words to samsung
result_s <- predict(model, c("samsung"), type = "nearest", top_n = 5)
print(result_s)
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

library(tm)
library(magrittr)

# Select the Content column
reviews <- prodreviews$Content

# Preprocess the corpus
corpus <- Corpus(VectorSource(reviews)) %>%
 tm_map(content_transformer(tolower)) %>%
 tm_map(removePunctuation) %>%
 tm_map(removeNumbers) %>%
 tm_map(removeWords, stopwords("en")) %>%
 tm_map(stripWhitespace)

# Extract the words from the document-term matrix
words <- colnames(as.matrix(DocumentTermMatrix(corpus)))

# Remove duplicates and empty strings
word_list <- unique(words[words != ""])
# Select the first 50 words
word_list <- head(word_list, 50)

# Check embeddings and remove the empty values, if any
embedding <- predict(model, word_list, type = "embedding")
embedding <- na.omit(embedding)
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

library(ggrepel)
library(plotly)
library(umap)

# Visualize embeddings using UMAP
vizualization <- umap(embedding, n_neighbors = 15, n_threads = 2)

# Transform into a data frame
df <- data.frame(word = rownames(embedding),
 x = vizualization$layout[, 1],
 y = vizualization$layout[, 2],
 stringsAsFactors = FALSE)

# Plot embeddings using Plotly
plot_ly(df, x = ~x, y = ~y, type = "scatter", mode = 'text', text = ~word) #%>%
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

# layout(title = "CBOW Embeddings Visualization")
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

library(proxy)

# Use the proxy package to compute the cosine distance
embedding_cos <- dist(embedding, method = "cosine")

# Perform hierarchical clustering, plot the dendrogram
plot(as.dendrogram(hclust(embedding_cos)), horiz = FALSE, cex = 0.2)
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

# Get the vectors for specific words: 'amazon', 'apple', 'good', 'bad', 'screen'
kindle <- predict(model, newdata = "kindle", type = "embedding")
good <- predict(model, newdata = "good", type = "embedding")
bad <- predict(model, newdata = "bad", type = "embedding")

# Perform vector arithmetic for the word kindle
result_kindle <- kindle - good + bad

# Find the top 10 words closest to the result vector for kindle
similar_kindle <- predict(model, newdata = result_kindle, type = "nearest", top_n = 10)
print(similar_kindle)
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

# Get the vectors for the kindle and ipad
kindle <- predict(model, newdata = "kindle", type = "embedding")
ipad <- predict(model, newdata = "ipad", type = "embedding")

# Get the vectors for good, bad, fast, slow, cheap and expensive
good <- predict(model, newdata = "good", type = "embedding")
bad <- predict(model, newdata = "bad", type = "embedding")
fast <- predict(model, newdata = "fast", type = "embedding")
slow <- predict(model, newdata = "slow", type = "embedding")
cheap <- predict(model, newdata = "cheap", type = "embedding")
expensive <- predict(model, newdata = "expensive", type = "embedding")

# Perform vector arithmetic for the kindle word
result_kindle <- kindle + good + fast + cheap - bad - slow - expensive

# Perform vector arithmetic for the ipad word
result_ipad <- ipad + good + fast + expensive - bad - slow - cheap

# Find the top 10 words closest to each result vector
similar_kindle <- predict(model, newdata = result_kindle, type = "nearest", top_n = 10)
similar_ipad <- predict(model, newdata = result_ipad, type = "nearest", top_n = 10)

# Print the results for kindle
print(similar_kindle)
# ──────────────────────────────────────────────────────────────


# Section: Word2vec in practice

# Print the results for ipad
print(similar_ipad)
# ──────────────────────────────────────────────────────────────


# Section: Transformers in action
#   Subsection: Text Summarizing

library(text)

# Install text required python packages in a conda environment (with defaults).
# textrpp_initialize(save_profile = TRUE) saves the profile
textrpp_install()
textrpp_initialize()

# Select the Amazon brand
amazon_reviews <- prodreviews[prodreviews$Brand == "Amazon", ]


# Set seed for reproducibility
set.seed(123)

# Sample 1000 indices from the available reviews
sampled_ind <- sample(1:nrow(amazon_reviews), size = 100, replace = FALSE)

# Extract the content of the sampled reviews
sampled_reviews <- amazon_reviews$Content[sampled_ind]

# Concatenate the text into one big string
big_review <- paste(sampled_reviews, collapse = " ")

# Perform the summarization operation, use the t5-small model
ts <- textSum(big_review, min_length = 5L, max_length = 100L, model = "t5-small", device = "gpu", tokenizer_parallelism = TRUE, logging_level = "warning", return_text = TRUE, return_tensors = FALSE, clean_up_tokenization_spaces = FALSE, set_seed = 42L )
# ──────────────────────────────────────────────────────────────


# Section: Transformers in action
#   Subsection: Text Summarizing

# View the results
cat(ts[[1,1]])
# ──────────────────────────────────────────────────────────────


# Section: Transformers in action
#   Subsection: Information searches, questions and answering using transformers (Q\&A)

# List of questions to be answered
questions <- c(
"How is the Kindle screen?",
"How is the Amazon customer service?",
"How much memory does the Kindle Fire have?",
"Where is the Kindle tablet camera?",
"Does the brand Amazon offer good value for the money?"
)
# ──────────────────────────────────────────────────────────────


# Section: Transformers in action
#   Subsection: Information searches, questions and answering using transformers (Q\&A)

# Initialize a list to store the answers
answers <- vector("list", length(questions))

# Iterate over each question and apply the textQA function
for (i in seq_along{(questions))
 answers[[i]] <- textQA(
 question = questions[i],
 context = big_review,
 model = "deepset/roberta-base-squad2",
 device = "cpu",
 tokenizer_parallelism = FALSE,
 logging_level = "warning",
 top_k = 10L,
 doc_stride = 128L,
 max_answer_len = 20L,
 max_seq_len = 384L,
 max_question_len = 64L,
 handle_impossible_answer = FALSE,
 set_seed = 202208L
 )

# ──────────────────────────────────────────────────────────────


# Section: Transformers in action
#   Subsection: Information searches, questions and answering using transformers (Q\&A)

# Print the answers
for (i in seq_along{(questions))
 cat("Question:", questions[i], "\textbackslashnAnswer:", paste(unlist(answers[[i]][4]), collapse = ", "), "\textbackslashn\textbackslashn")

# ──────────────────────────────────────────────────────────────

