# Section: The basics: A short use case

# Set URL of the text file
url <- "http://www.gutenberg.org/cache/epub/53/pg53.txt"

# Read text as character strings, split by newline
etext <- scan(url, what = "character", sep="\textbackslashn")
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

head(etext)
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Identify lines containing 'INTRODUCTION' or '}END\CommentTok{' and store the content
keyword_lines <- grep("\\bINTRODUCTION\\b|\\bEND\\b", etext, value = TRUE)
keyword_lines
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Find indices of lines containing 'INTRODUCTION' or '}END\CommentTok{'
keyword_indices <- grep("\\bINTRODUCTION\\b|\\bEND\\b", etext)
keyword_indices
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Select the elements between keyword_indices
etext <- etext[keyword_indices[1]:keyword_indices[2]]
head(etext)
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Isolate words
etext <- strsplit(etext, "\\W")
head(etext)
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Vectorize
etext <- unlist(etext)
head(etext)
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Remove empty spaces
etext <- etext[!etext==""]
head(etext)
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Check text length
length(etext)
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Check unique words number
length(unique(etext))
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Sort words in alphabetical order
s_etext <- sort(unique(etext))

# Take a glimpse into the vector
s_etext[975:1000]
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

# Sort words based on frequency
sorted_etext <- sort(table(etext), decreasing = TRUE)
head(sorted_etext, 25)
# ──────────────────────────────────────────────────────────────


# Section: The basics: A short use case

plot(sorted_etext[1:100],
 type = "b", # Both points and lines
 xlab = "Rank of Words",
 ylab = "Frequency of Words",
 las = 2,
 cex.axis = 0.8, # Slightly reduce axis label size
 )
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: Corpus preparation

# Load the tm library
library(tm)

# Set string handling to non-factor
options(stringsAsFactors = FALSE)

# Load the Product Reviews dataset
prodreviews <- read.csv("data/Product Reviews.csv")

# Convert 'Content' column to character type
content <- as.character(prodreviews$Content)

# Create a volatile corpus
docs <- VCorpus(VectorSource(content))

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: Lowercase transformation

# Transform all the characters to lower case
docs <- tm_map(docs, content_transformer(tolower))

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: Stop-word removal

# remove the stopwords and specify the language
docs <- tm_map(docs, content_transformer(removeWords), stopwords("english"))

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: Removing other words

# Remove specific words from the corpus
docs <- tm_map(docs, content_transformer(removeWords), c("will"))

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: Removing other words

# Remove punctuation
docs <- tm_map(docs, removePunctuation)

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: Removing or transforming numbers

# Remove numbers
docs <- tm_map(docs, removeNumbers)

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: Reduction of inflectional forms

# Load the SnoballC library for stemming
library(SnowballC)

# Stemming
docs <- tm_map(docs, content_transformer(stemDocument))

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Data preparation and normalization (text pre-processing)
#   Subsection: White-space deletion

# White space removal
docs <- tm_map(docs, stripWhitespace)

# Inspect the first document in the corpus
inspect(docs[[1]])
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Word frequencies

library(slam)

# Create the term-document matrix
tdm <- TermDocumentMatrix(docs)

# Remove sparse terms with a threshold of 0.9
tdms <- removeSparseTerms(tdm, 0.9)

# Sort the values in decreasing order and create a dataframe
v <- sort(row_sums(tdms),decreasing=TRUE)
top_terms <- data.frame(word = names(v),freq=v)

# Display the top 20 terms
head(top_terms, 20)
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Word bar plotting

barplot(
 top_terms[1:20, ]$freq,
 las = 2,
 names.arg = top_terms[1:20, ]$word,
 col = "lightblue",
 main = "Most Frequent Words",
 ylab = "Word Frequencies",
 cex.names = 0.8,
 cex.lab = 0.9,
 cex.main = 1
)
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Word clouds

library(wordcloud)

# Set seed for reproducibility
set.seed(1234)

# Create word cloud
wordcloud(
 words = top_terms$word, # Words for the cloud
 freq = top_terms$freq, # Their frequencies
 min.freq = 1, # Minimum frequency for inclusion
 max.words = 200, # Limit on number of words
 random.order = FALSE, # Keep words in frequency order
 rot.per = 0.35, # Fraction of vertical words
 scale = c(3.5, 0.25) # Scale for word size
)
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Word correlation

library(tm)
library(ggplot2)
library(ggthemes)

# Finding frequent terms
a <- findFreqTerms(tdm, lowfreq=10)
head(a) # Display top terms
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Word correlation

# Finding word associations for "tablet", a correlation limit of 0.3
associations <- findAssocs(tdm, terms="tablet", corlimit=0.3)
# Convert associations to dataframe
associations_df <- data.frame(term = names(associations$tablet), correlation = unlist(associations$tablet))
# Sort associations by correlation in ascending order
associations_df <- associations_df[order(associations_df$correlation),]


# Plotting associations
ggplot(associations_df, aes(x = correlation, y = reorder(term, correlation))) +
 geom_point(color = "blue", size = 3) +
 geom_segment(aes(x = 0, xend = correlation, y = term, yend = term),
 color = "lightblue", size = 0.7) + # Add connecting lines for emphasis
 theme_minimal() +
 labs(
 x = "Correlation Score",
 y = "Associated Terms"
 ) +
 theme(
 axis.text = element_text(size = 10),
 axis.title = element_text(size = 12),
 plot.title = element_text(size = 14, hjust = 0.5),
 panel.grid.major.y = element_blank() # Remove horizontal gridlines for a cleaner look
 )
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Bi-gram word clouds

library(RWeka)
library(wordcloud)

# Define bigram tokenizer
Bigram_Tokenizer <- function(x) NGramTokenizer(x, Weka_control(min=2, max=2))

# Create bigram term-document matrix
bitdm <- TermDocumentMatrix(docs, control = list(tokenize = Bigram_Tokenizer))

# Remove sparse terms
bitdms <- removeSparseTerms(bitdm, 0.99)

# Convert to matrix and sort by frequency
v <- sort(rowSums(as.matrix(bitdms)), decreasing=TRUE)
d <- data.frame(word = names(v), freq=v)

# Generate bigram word cloud
wordcloud(words = d$word, freq = d$freq, random.order = FALSE)
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Bi-gram word clouds

library(dplyr)
library(tidyr)
library(igraph)
library(ggraph)

# Separate bigrams into two words
d_2words<- d %>%
 separate(word, into = c("word1", "word2"), sep = " ") %>%
 filter(freq > 700)

# Build a filtered word network
word_network <- graph_from_data_frame(d_2words)

# Inspect the word_network variable
word_network
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Community Detection

# Convert to undirected graph
word_network <- as.undirected(word_network, mode = "collapse")

# Perform community detection using the Louvain method
communities <- cluster_louvain(word_network, resolution = 1)

# Visualization of the word network with communities
ggraph(word_network, layout = 'fr') +
 geom_edge_link(edge_alpha = 0.5, show.legend = FALSE) +
 geom_node_point(aes(color = factor(communities$membership)), size = 3) +
 geom_node_text(aes(label = name, color = factor(communities$membership)),
 repel = TRUE, fontface = "bold", size = 2, show.legend = FALSE) +
 labs(color = "Community") +
 theme_void()
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Some considerations regarding word frequencies

library(tm)
library(magrittr)
library(wordcloud)

options(stringsAsFactors = FALSE)

# Load the data
prodreviews <- read.csv("data/Product Reviews.csv")
content <- as.character(prodreviews$Content)

# Compact preprocessing (cleaning) function
preprocess <- function{(feedtext)
 feedtext %>%
 tolower() %>%
 removeWords(stopwords("english")) %>%
 removePunctuation() %>%
 stripWhitespace() %>%
 removeNumbers() %>%
 stemDocument() %>%
 return()


# Call the defined function
pre <- preprocess(content)

# Filter reviews by Item_ID (ASIN) and select the first 100 comments for each product
kindle_reviews <- head(prodreviews$Content[prodreviews$Item_ID == "B0051VVOB2"], 100) # Kindle Fire 2011
ipad2_reviews <- head(prodreviews$Content[prodreviews$Item_ID == "B0047DVWLW"], 100) # iPad2 16GB

# Preprocess the reviews
sub_kindle <- preprocess(paste(kindle_reviews, collapse = " "))
sub_ipad2 <- preprocess(paste(ipad2_reviews, collapse = " "))

# Combine the two preprocessed review sets into a single vector
tablets <- c(sub_kindle, sub_ipad2)

# Create a corpus from the vector
corpus <- VCorpus(VectorSource(tablets))

# Create a Term-Document Matrix
dtm <- TermDocumentMatrix(corpus)
dtmmatrix <- as.matrix(dtm)

# Name the columns based on the products being compared
colnames(dtmmatrix) <- c("Kindle Fire 2011", "iPad2 16GB")
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Some considerations regarding word frequencies

commonality.cloud(dtmmatrix, max.words=200, random.order=FALSE)
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Some considerations regarding word frequencies

library(RWeka)
library(dplyr)
library(ggplot2)
library(tm)

# Bigram tokenizer function
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))

# Extract bigrams for a subset of text
extractBigrams <- function{(text)
# Extract bigrams and flatten the result to a single vector
 bigrams <- unlist(lapply(text, function(line) unlist(BigramTokenizer(line))))
 return(bigrams)


# Extract and process bigrams for Kindle Fire and iPad2
kindle_bigrams <- extractBigrams(sub_kindle)
ipad2_bigrams <- extractBigrams(sub_ipad2)

# Calculate frequencies
kindle_freq <- sort(table(kindle_bigrams), decreasing = TRUE)
ipad2_freq <- sort(table(ipad2_bigrams), decreasing = TRUE)

# Find common bigrams
common_bigrams <- intersect(names(kindle_freq), names(ipad2_freq))

# Select top 20 common bigrams
top_common_bigrams <- head(common_bigrams, 20)

# Prepare data frame for plotting
bigram_df <- data.frame(
 Bigram = rep(top_common_bigrams, 2),
 Frequency = c(as.numeric(kindle_freq[top_common_bigrams]),
-}as.numeric(ipad2_freq[top_common_bigrams])), # Make iPad2 frequencies negative
 Product = rep(c("Kindle Fire 2011", "iPad2 16GB"), each = length(top_common_bigrams))
)

# Create mirrored pyramid plot
ggplot(bigram_df, aes(x = reorder(Bigram, -abs(Frequency)), y = Frequency, fill = Product)) +
 geom_bar(stat = "identity") +
 coord_flip() +
 labs(title = "Comparison of Common Bigrams: Kindle Fire 2011 vs. iPad2 16GB",
 x = "Bigram",
 y = "Frequency") +
 scale_fill_brewer(palette = "Set1") +
 theme_minimal() +
 theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
 axis.text.y = element_text(face = "bold"))
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Some considerations regarding word frequencies

comparison.cloud(
 dtmmatrix,
 max.words = 200,
 random.order = FALSE,
 scale = c(3, 0.5), # Adjust the size scale for words
 fixed.asp = TRUE # Ensure the aspect ratio is fixed to make the cloud appear more square{-like
)
# ──────────────────────────────────────────────────────────────


# Section: Text representation
#   Subsection: Size reduction
#     Subsubsection: Bi-grams comparison

# Calculate frequencies
kindle_freq <- sort(table(kindle_bigrams), decreasing = TRUE)
ipad2_freq <- sort(table(ipad2_bigrams), decreasing = TRUE)

# Identify unique bigrams
unique_kindle <- names(kindle_freq)[!names(kindle_freq) %in% names(ipad2_freq)]
unique_ipad <- names(ipad2_freq)[!names(ipad2_freq) %in% names(kindle_freq)]

# Select top 10 unique bigrams
top_kindle <- head(sort(kindle_freq[unique_kindle], decreasing = TRUE), 10)
top_ipad2 <- head(sort(ipad2_freq[unique_ipad], decreasing = TRUE), 10)

# Convert to data frames
df_kindle <- data.frame(Bigram = names(top_kindle), Frequency = as.numeric(top_kindle), Product = "Kindle Fire 2011")
df_ipad2 <- data.frame(Bigram = names(top_ipad2), Frequency = as.numeric(top_ipad2), Product = "iPad2 16GB")

# Combine data frames
combined_df <- rbind(df_kindle, df_ipad2)

# Plot using ggplot
ggplot(combined_df, aes(x = reorder(Bigram, Frequency), y = Frequency, fill = Product)) +
 geom_bar(stat = "identity", position = position_dodge()) +
 labs(x = "Bigram", y = "Frequency") +
 scale_fill_brewer(palette = "Set1") +
 theme_minimal() +
 coord_flip()
# ──────────────────────────────────────────────────────────────

