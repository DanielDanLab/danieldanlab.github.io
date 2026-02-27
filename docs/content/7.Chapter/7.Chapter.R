# Section: Latent Dirichlet allocation
#   Subsection: Applying simple LDA

# Fit an LDA model to the DFM with 5 topics
set.seed(42)
lda <- textmodel_lda(dfmt, k = 5, verbose = FALSE)
# Display terms associated with each topic
terms(lda)
# ──────────────────────────────────────────────────────────────


# Section: Latent Dirichlet allocation
#   Subsection: Applying simple LDA

# Extract document-level variables from the LDA model's data
dat <- docvars(lda$data)
# Assign the most probable topic to each document based on the LDA model
dat$topic <- topics(lda)
# Display the first 10 rows of some selected columns
head(dat[,c("Review_date", "topic", "Title")], 10)
# ──────────────────────────────────────────────────────────────

# Create the dfmt document
library(quanteda)

prodreviews <- read.csv("data/Product Reviews.csv")
corp <- corpus(prodreviews, text_field = "Content")

toks <- tokens(
  corp,
  remove_punct = TRUE,
  remove_numbers = TRUE
) |>
  tokens_tolower() |>
  tokens_remove(stopwords("en"))

dfmt <- dfm(toks)



# Section: Latent Dirichlet allocation
#   Subsection: Seeded LDA.

# Create the dict variable containing the seeded words
dict <- dictionary(file = "data/dictionary.yml")

# Fit an seeded LDA model to the DFM with 5 topics
set.seed(42)
# Add auto_iter = TRUE for faster convergence
lda_seed <- textmodel_seededlda(dfmt, dict, auto_iter = TRUE)
# Display terms associated with each topic
terms(lda_seed)
# ──────────────────────────────────────────────────────────────


# Section: Latent Dirichlet allocation
#   Subsection: Seeded LDA.

# Fit an seeded LDA model to the DFM with 7 topics
set.seed(42)
# Add auto_iter = TRUE for faster convergence
lda_res <- textmodel_seededlda(dfmt, dict, residual = 2, auto_iter = TRUE)
# Display terms associated with each topic
terms(lda_res)
# ──────────────────────────────────────────────────────────────


# Section: Latent Dirichlet allocation
#   Subsection: Applying sequential sentence-based LDA with seeded words

library(seededlda)
library(quanteda)
library(ggmatplot)


corp <- corpus(prodreviews, text_field ="Content") |>
 corpus_reshape(to = "sentences")

toks <- tokens(corp, remove_punct = TRUE, remove_symbols = TRUE,
 remove_numbers = TRUE, remove_url = TRUE)
dfmt <- dfm(toks) |>
 dfm_remove(stopwords("en")) |>
 dfm_remove("*@*") |>
 dfm_trim(max_docfreq = 0.1, docfreq_type = "prop")

# Enable the sequential algorithm, set gamma to 0.5
# A lower value of gamma would impact the classification of the current sentence.
lda_seq <- textmodel_lda(dfmt, k = 5, gamma = 0.5,
 batch_size = 0.01, auto_iter = TRUE,
 verbose = FALSE)
print(lda_seq)
# ──────────────────────────────────────────────────────────────


# Section: Latent Dirichlet allocation
#   Subsection: Topic visualization

library(LDAvis)
library(quanteda)
library(stringi)

# Find required quantities
json <- createJSON(phi = lda_seq$phi,
 theta = lda_seq$theta,
 doc.length = rowSums(dfmt),
 vocab = colnames(dfmt),
 term.frequency = colSums(dfmt)
)

serVis(json)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models

library(stm)
library(tm)
library(dplyr)
library(lubridate)

# Preprocessing
options(stringsAsFactors = FALSE)

# Read product reviews from a CSV file into a dataframe
prodreviews <- read.csv("data/Product Reviews.csv")

# Select the desired columns
data <- prodreviews[, c("Content", "Rating", "Brand", "Review_date")]

# Transform the character content of Review_date into date type
data$Review_date <- mdy(data$Review_date)

# Select the year 2012
data <- data %>% filter(year(Review_date) == 2012)

# Use the strftime to transform the date into a number (day of the year)
data$Review_date <- as.integer(strftime(data$Review_date, format ="%j"))

# Select the relevant rows (Amazon and Apple)
data <- subset(data, Brand == "Amazon" | Brand == "Apple")

# Set seed for reproducibility
set.seed(42)

# Process the text data
processed <- textProcessor(documents = data$Content, metadata = data)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models

# Associate text with metadata
out <- prepDocuments(documents = processed$documents,
 vocab = processed$vocab,
 meta = processed$meta, lower.thresh = 15)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models

# Extract variables
docs <- out$documents
vocab <- out$vocab
meta <- out$meta
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models

# Fitting the example model
productsFit <- stm(documents = out$documents, vocab = out$vocab,
 K = 5, prevalence =~ Brand,
 max.em.its = 75, data = out$meta,
 init.type = "Spectral", verbose = FALSE)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models

# Find which words belong to which topic
(lT <- labelTopics(productsFit))
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models

plot(productsFit, type = "summary", xlim = c(0, 0.8))
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models

# Select the first 200 text characters, to simplify
shortdoc <- substr(meta$Content, 1, 200)

# Find 2 documents associated with topic 4
thoughts1 <- findThoughts(productsFit, texts = shortdoc, n = 2,
topics = 4)$docs[[1]]

# Find 2 documents associated with topic 5
thoughts2 <- findThoughts(productsFit, texts = shortdoc, n = 2,
topics = 5)$docs[[1]]

# Plot the results
par(mfrow = c(1, 2), mar = c(0.5, 0.5, 1, 0.5))
plotQuote(thoughts1, width = 30, main = "Topic 4")
plotQuote(thoughts2, width = 30, main = "Topic 5")
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Estimating metadata-topic relationships

# Convert "Brand" to a categorical variable
out$meta$Brand <- as.factor(out$meta$Brand)

# Estimate the effect of the covariates on topics
prep <- estimateEffect(1:5 ~ Brand +s(Review_date)+Rating, productsFit, meta = out$meta, uncertainty = "Global")

# Summarize the estimated effect on topic 1
summary(prep, topics = 1)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Estimating metadata-topic relationships

# Using apply to concatenate labels for each row
custom_labels <- apply(lT$score, 1, function(x) paste(x, collapse = ", "))

# Plot the results
plot(prep, covariate = "Brand", topics = c(1, 2, 3, 4, 5),
 model = productsFit, method = "difference", cov.value1 = "Apple",
 cov.value2 = "Amazon", xlab = "More Amazon ... More Apple",
 xlim = c(-0.5, 0.5), labeltype = "custom", custom.labels = custom_labels)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Estimating metadata-topic relationships

# Plot the effect of 'Review_date' on topic 4
plot(prep, "Review_date", method = "continuous", topics = 4, model = productsFit, printlegend = FALSE, xaxt = "n",
xlab="Time (2012)")
# Create a sequence of dates incremented by month.
monthseq <- seq(from = as.Date("2012-01-01"), to = as.Date("2012-07-11"), by = "month")

# Extract the month name
monthnames <- months(monthseq)

# Add custom x-axis labels to the plot
axis(1,at = as.numeric(monthseq) - min(as.numeric(monthseq)), labels = monthnames)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Topical content.

# Fit the model with the Brand content
dataContent <- stm(out$documents, out$vocab, K = 5,
 prevalence =~ Brand + s(Review_date), content =~ Brand,
 max.em.its = 75, data = out$meta, init.type = "Spectral",
 verbose = FALSE)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Visualizing the influence of topical content

# Plot vocabulary differences by Brand for Topic 4
plot(dataContent, type = "perspectives", topics = 4)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Visualizing the influence of topical content

# Label the top words for Topic 4
(lT2 <- labelTopics(dataContent, 4))
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Comparing words across two topics

# Plot the contrast in words across Topics 4 and 5
plot(dataContent, type = "perspectives", topics = c(5, 4))
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Comparing words across two topics

# Create a word cloud for Topic 4
cloud(dataContent, topic = 4)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Comparing words across two topics

# Calculate and plot topic correlations
mod.out.corr <- topicCorr(dataContent)
plot(mod.out.corr)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Exploring topic interactions and visualizations in STM

tabletInteraction <- stm(out$documents, out$vocab, K = 5,
prevalence =~ Brand * Review_date, max.em.its = 75, data = out$meta,
init.type = "Spectral", verbose = FALSE)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Exploring topic interactions and visualizations in STM

prep <- estimateEffect(c(4) ~ Brand * Review_date, tabletInteraction, meta = out$meta, uncertainty = "None")

# Plot interaction effect for Apple
plot(prep, covariate = "Review_date", model = tabletInteraction,
 method = "continuous", xlab = "Days", moderator = "Brand",
 moderator.value = "Apple", linecol = "blue", ylim = c(0, 0.60),
 printlegend = FALSE)

# Add interaction effect for Amazon
plot(prep, covariate = "Review_date", model = tabletInteraction,
 method = "continuous", xlab = "Days", moderator = "Brand",
 moderator.value = "Amazon", linecol = "red", add = TRUE,
 printlegend = FALSE)

legend(0, 0.4, c("Apple", "Amazon"), lwd = 2,
 col = c("blue", "red"))
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Exploring topic interactions and visualizations in STM

# Calculate the topic correlations
mod.out.corr <- topicCorr(tabletInteraction)

# View the correlation matrix
mod.out.corr$cor
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Exploring topic interactions and visualizations in STM

# Plot the topic correlation network
plot(mod.out.corr)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Determining the number of topics using STM.

storage <- searchK(out$documents, out$vocab, K = 3:7,
 prevalence =~ Brand + s(Review_date),
 data = out$meta, verbose = FALSE)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Determining the number of topics using STM.

options(seededlda_threads = 4)

# Read product reviews from a CSV file into a dataframe
prodreviews <- read.csv("data/Product Reviews.csv")


# Select the desired columns
data <- prodreviews[, c("Content", "Rating", "Brand", "Review_date")]

# Transform the character content of Review_date into date type
data$Review_date <- mdy(data$Review_date)

# Select the year 2011
data <- data %>% filter(year(Review_date) == 2012)

# Use the strftime to transform the date into a number (day of the year)
data$Review_date <- as.integer(strftime(data$Review_date, format ="%j"))

# Select the relevant rows (Amazon and Apple)
data <- subset(data, Brand == "Amazon" | Brand == "Apple")

# do some cleaning here....

# Create a text corpus from the 'Content' column of the product reviews dataframe
corp <- corpus(data, text_field = "Content")
dfmt <- TermDocumentMatrix(corp)

library("ldatuning")
result <- FindTopicsNumber(
 dtm=dfmt,
 topics = seq(from = 3, to = 7, by = 1),
 metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010"),
 method = "Gibbs",
 control = list(seed = 42),
 mc.cores = 8L,
 verbose = TRUE
)
# ──────────────────────────────────────────────────────────────


# Section: Structural topic models
#   Subsection: Determining the number of topics using STM.

suppressWarnings(FindTopicsNumber_plot(result))
# ──────────────────────────────────────────────────────────────

