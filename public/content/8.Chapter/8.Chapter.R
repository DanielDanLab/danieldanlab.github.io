# Section: Performing sentiment analysis in R
#   Subsection: Sentiment over a timeline

library(dplyr)
library(lubridate)

# Prevent conversion of strings into factors
options(stringsAsFactors = FALSE)

# Read product reviews from the CSV file into a dataframe
prodreviews <- read.csv("data/Product Reviews.csv")

# Select the desired columns
data <- prodreviews[, c("Content", "Rating",
 "Brand", "Review_date")]

# Transform the character content of Review_date into date type
data$Review_date <- mdy(data$Review_date)

# Select the relevant rows (Amazon and Apple)
data <- subset(data, Brand %in% c("Samsung", "Apple", "Amazon"))
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment over a timeline

library(stringr)

# Replace the emojis in reviews with their explanation
data$Content <- replace_emoji(data$Content)

# Remove non-ASCII characters with suitable ASCII equivalent or removes them
data$Content <- replace_non_ascii(data$Content)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment over a timeline

library(sentimentr)
library(sentiment.ai)
library(SentimentAnalysis)
library(vader)
library(syuzhet)
library(data.table)

# init_sentiment.ai() is to be run once, at the beginning

# sentiment.ai
sentiment.ai.score <- sentiment_score(data$Content)

# From Sentiment Analysis
sentimentAnalysis.score <- analyzeSentiment(data$Content)$SentimentQDAP

# From sentimentr
sentimentr.score <- sentiment_by(get_sentences(data$Content),
 1:(length(data$Content)-1))$ave_sentiment
# Calculate and aggregate sentiment scores

# From VADER
vader.score <- vader_df(data$Content)$compound

# From syuzhet
syuzhet.score <- get_sentiment(data$Content)

# Compile results into a data table
comparison <- data.table(
 Review_id = 1:nrow(data),
 target = data$Content,
 sentiment.ai = sentiment.ai.score,
 sentimentAnalysis = sentimentAnalysis.score,
 sentimentr = sentimentr.score,
 vader = vader.score,
 syuzhet = syuzhet.score,
 Brand = data$Brand,
 Rating = data$Rating,
 R_date = data$Review_date
)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment over a timeline

library(ggplot2)
library(lubridate)

# Round 'R_date' down to the first day of its month, add it as a new column
comparison[, Month := floor_date(R_date, "month")]

# Average score for selected columns
monthly_aggregated <- comparison[, .(sentiment.ai = mean(sentiment.ai)),
 by = .(Month, Brand)]

# Plot the graph
ggplot(monthly_aggregated, aes(x = Month, y = sentiment.ai,
 color = Brand, group = Brand)) +
 geom_smooth(method = "loess", se = FALSE, linewidth = 1.2) +
 geom_point(size = 3) + # Slightly larger points
 labs(x = "Month",
 y = "Average sentiment.ai score",
 color = "Brand"
 ) +
 theme_minimal() +
 theme(
 text = element_text(size = 12),
 axis.text.x = element_text(angle = 45, hjust = 1)
 )
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment over a timeline

ggplot(monthly_aggregated, aes(x = Month, y = sentiment.ai,
 fill = Brand)) +
 geom_col(show.legend = FALSE) + # Use columns for visualization
 labs(
 x = "Month",
 y = "Average sentiment.ai score",
 fill = "Brand"
 ) +
 theme_minimal() +
 theme(
 text = element_text(size = 12),
 axis.text.x = element_text(angle = 45, hjust = 1)) +
 facet_wrap(~ Brand, ncol = 1, scales = "free_y")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

library(dplyr)
library(tm)
library(SnowballC)
library(wordcloud)
library(slam)
library(RWeka)
library(tidyr)
library(igraph)
library(ggraph)

# Filter Amazon reviews and split into positive and negative
kindle_reviews <- comparison %>% filter(Brand == "Amazon")
pos_reviews <- kindle_reviews %>% filter(sentiment.ai > 0.7)
neg_reviews <- kindle_reviews %>% filter(sentiment.ai < -0.7)

# Text preprocessing function
preprocess <- function{(text)
 text %>% tolower() %>%
 removeWords(stopwords("english")) %>%
 removePunctuation(ucp = TRUE) %>%
 stripWhitespace() %>%
 wordStem(language = "en") %>%
 removeNumbers()


# Preprocess text and transform into a corpus
corpus_pos <- VCorpus(VectorSource(lapply(pos_reviews$target, preprocess)))
corpus_neg <- VCorpus(VectorSource(lapply(neg_reviews$target, preprocess)))

# Bigram function
bigram_tokenizer <- function(x) NGramTokenizer(x,
 Weka_control(min = 2, max = 2))

# Create matrices for both positive and negative reviews
process_bigrams <- function{(corpus)
 tdm <- TermDocumentMatrix(corpus,
 control = list(tokenize = bigram_tokenizer))
 removeSparseTerms(tdm, 0.999) %>%
 as.matrix() %>%
 rowSums() %>%
 sort(decreasing = TRUE)


v_pos_bigram <- process_bigrams(corpus_pos)
v_neg_bigram <- process_bigrams(corpus_neg)

# Create data frames
df_pos_bigram <- data.frame(word = names(v_pos_bigram),
 freq = v_pos_bigram)
df_neg_bigram <- data.frame(word = names(v_neg_bigram),
 freq = v_neg_bigram)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

# Plot barplots
plot_word_data <- function{(d, title)
 par(mar = c(5, 4, 4, 2) + 0.1) # Adjust margins
 barplot(d[1:30, ]$freq, las = 2, names.arg = d[1:30, ]$word,
 col = "lightblue", main = title, ylab = "Word frequencies",
 cex.names = 0.6)


# Plot the positive and negative reviews one under the other
par(mfrow = c(2, 1))
plot_word_data(df_pos_bigram, "Most frequent bigrams in positive reviews")
plot_word_data(df_neg_bigram, "Most frequent bigrams in negative reviews")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

# Hypothetical frequency sums based on visual inspection:
positive_total <- sum(df_pos_bigram$freq[1:30])
negative_total <- sum(df_neg_bigram$freq[1:30])

print(positive_total)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

print(negative_total)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

# Sum the frequencies of positive/negative bigrams
positive_total <- sum(df_pos_bigram$freq)
negative_total <- sum(df_neg_bigram$freq)

print(paste("Total frequency of positive bigrams:", positive_total))
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

print(paste("Total frequency of negative bigrams:", negative_total))
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

# Build and visualize word networks
visualize_word_network <- function{(d, freq_threshold, title)
 d_sep <- d %>%
 separate(word, c("word1", "word2"), sep = " ")

wordnet <- d_sep %>%
 filter(freq > freq_threshold) %>%
 graph_from_data_frame()

ggraph(wordnet, layout = "fr") +
 geom_edge_link(aes(color = freq, width = freq),
 arrow = grid::arrow(type = "closed", length = unit(0.15, "cm"))) +
 geom_node_point() +
 geom_node_text(aes(label = name), repel = TRUE, size = 3) +
 scale_edge_color_gradient(low = "lightblue", high = "blue") +
 scale_edge_width(range = c(0.5, 3)) +
 theme_void() +
 labs(title = title, edge_color = "Frequency", edge_width = "Frequency")


# Visualize the word network for positive reviews
visualize_word_network(df_pos_bigram, 30, "Word Network - Positive Reviews")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment word networks

# Visualize the word network for positive reviews
visualize_word_network(df_neg_bigram, 10, "Word Network - Negative Reviews")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Detecting negative sections of text

library(magrittr)
library(purrr)
# Set seed for reproducibility
set.seed(42)

# Subdivision into sentences and score assignment to each of them
# Filter data and sample one row per brand
output <- comparison %>%
 filter(Brand %in% c("Apple", "Samsung")) %>%
 filter(sentiment.ai < -0.6) %>%
 group_by(Brand) %>%
 slice_sample(n = 1) %>%
 ungroup() %>%
# Subdivide reviews into sentences
 mutate(review = map(target, get_sentences)) %>%
 unnest(review)

# Calculate sentiment scores by review
sentiment_output <- sentiment_by(output$review, output$Review_id)

# Highlight sentiment results
highlight(sentiment_output)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

# Boxplot to visualize the relationship between sentiment.ai scores and Rating
ggplot(comparison, aes(x = factor(Rating), y = sentiment.ai)) +
 geom_boxplot() +
 labs(
 title = "Distribution of Sentiment Scores by Star Rating",
 x = "Star Rating",
 y = "Sentiment.ai Score"
 ) +
 theme_minimal()
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

# Calculate the correlation between sentiment.ai and Rating
correlation <- cor(comparison$sentiment.ai, comparison$Rating, use = "complete.obs")
cat("Correlation between sentiment.ai and Rating:", correlation, "\textbackslashn")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

set.seed(42) # For reproducibility

# Examples of reviews with high sentiment.ai and high rating
high_sentiment_high_rating <- comparison %>%
 filter(sentiment.ai > 0.5, Rating == 5) %>%
 slice_sample(n = 3)
cat("High Sentiment, High Rating Reviews:\textbackslashn")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

# Display values in a nicely formatted table
kable(high_sentiment_high_rating[, .(Review_id, target, sentiment.ai, Rating)],
 format="markdown") %>%
 kable_styling(full_width = FALSE) %>%
 column_spec(1, width = "4em") %>%
 column_spec(2, width = "25em") %>%
 column_spec(3, width = "5em")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

set.seed(42) # For reproducibility

# Examples of reviews with low sentiment.ai and low rating
low_sentiment_low_rating <- comparison %>%
 filter(sentiment.ai < -0.5, Rating == 1) %>%
 slice_sample(n = 3)
cat("Low Sentiment, Low Rating Reviews:\textbackslashn")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

kable(low_sentiment_low_rating[, .(Review_id, target, sentiment.ai, Rating)],
 format="markdown") %>%
 kable_styling(full_width = FALSE) %>%
 column_spec(1, width = "4em") %>%
 column_spec(2, width = "25em") %>%
 column_spec(3, width = "5em")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

set.seed(42)
# Examples of reviews with high sentiment.ai and low rating
high_sentiment_low_rating <- comparison %>%
 filter(sentiment.ai > 0.5, Rating == 1) %>%
 slice_sample(n = 3)
cat("High Sentiment, Low Rating Reviews:\textbackslashn")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: Sentiment score and ratings

kable(high_sentiment_low_rating[, .(Review_id, target, sentiment.ai, Rating)],
 format="markdown") %>%
 kable_styling(full_width = FALSE) %>%
 column_spec(1, width = "4em") %>%
 column_spec(2, width = "25em") %>%
 column_spec(3, width = "5em")
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: The classification of emotions

library(sentiment.ai)
library(tidyverse)

# Create word vectors for each emotion
joy <- c("happy", "cheer", "content", "excitement",
 "pleasure", "delight", "satisfaction")
sadness <- c("sad", "unhappy", "distress", "upset",
 "sorrow", "grief", "despair", "dismay")
anger <- c("angry", "fury", "enragement", "mad", "annoyance")
fear <- c("afraid", "scared", "frightened",
 "petrified", "horrified", "terrified",
 "dread", "alarmed", "panicked", "anguished",
 "anxious", "worried", "concerned", "apprehensive")
disgust <- c("disgust", "repulse", "nausea", "distaste",
 "dislike", "loath", "revulse")

# List of words that express emotion
emotions <- list(Joy=joy, Sadness=sadness, Anger=anger, Fear=fear, Disgust=disgust)

# Select the Kindle reviews
kindle_reviews <- comparison %>% filter(Brand == "Amazon")
em_words <- sentiment_match(x = kindle_reviews$target, phrases = emotions)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: The classification of emotions

# Check the frequency of each emotion
emotion_freq <- em_words %>%
 count(class) %>%
 arrange(desc(n))

# Define colors for each emotion
color_map <- c('Joy' = 'yellow', 'Sadness' = 'blue', 'Anger' = 'red', 'Fear' = 'violet', 'Disgust' = 'green')

# Plot the frequency of each emotion with specified colors
p1 <- ggplot(emotion_freq, aes(x = class, y = n, fill = class)) +
 geom_bar(stat = "identity") +
 scale_fill_manual(values = color_map) +
 labs(x = 'Emotion',
 y = 'Frequency',
 fill = 'Emotion'
 ) +
 theme_minimal() +
 theme(
 text = element_text(size = 6),
 plot.title = element_text(hjust = 0.5) # Center the plot title
 )
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: The classification of emotions

library(tidytext)

# Tokenize the phrases into words and count the frequency of each word by emotion class
word_freq <- em_words %>%
 unnest_tokens(word, phrase) %>%
 count(class, word, sort = TRUE) %>%
 filter(n > 1) %>%
 ungroup()

# Plot the word distribution for each emotion class
p2 <- ggplot(word_freq, aes(x = reorder(word, n), y = n, fill = class)) +
 geom_bar(stat = "identity") +
 facet_wrap(~ class, scales = "free_y") +
 scale_fill_manual(values = color_map) +
 labs(x = 'Words',
 y = 'Frequency'
 ) +
 coord_flip() +
 theme_minimal() +
 theme(
 text = element_text(size = 6),
 plot.title = element_text(hjust = 0.5), # Center the plot title
 strip.text = element_text(size = 6)
 )

# Combine the plots using gridExtra
library(gridExtra)
# ──────────────────────────────────────────────────────────────


# Section: Performing sentiment analysis in R
#   Subsection: The classification of emotions

grid.arrange(p1, p2, ncol = 1)
# ──────────────────────────────────────────────────────────────


# Section: The change of topics and sentiments over time.

library(quanteda)
library(sentimentr)
library(seededlda)
library(ggplot2)
library(dplyr)

corpus <- corpus(data$Content, docvars = data[, c("Brand", "Review_date")])

# Preprocess the text data
tokens <- tokens(corpus, remove_punct = TRUE)
tokens <- tokens_remove(tokens, stopwords("en"))
dfm <- dfm(tokens)

set.seed(42)
# Fit a Sentence LDA model using sentencelda package
lda_model <- textmodel_lda(dfm, k = 5, verbose = FALSE)

# Extract the topic probabilities for each document
topic_probs <- as.data.frame(lda_model$theta)

# Add the date and brand to the topic probabilities
topic_probs$date <- docvars(corpus, "Review_date")
topic_probs$brand <- docvars(corpus, "Brand")
# ──────────────────────────────────────────────────────────────


# Section: The change of topics and sentiments over time.

# Conduct sentiment analysis using sentimentr
sentiments <- sentiment(data$Content)
sentiments <- sentiments %>%
 group_by(element_id) %>%
 summarise(sentiment = mean(sentiment))

# Combine topic probabilities with sentiment
topic_sentiment <- bind_cols(topic_probs,
 sentiment = sentiments$sentiment,
 date = topic_probs$date, brand = topic_probs$brand)
# ──────────────────────────────────────────────────────────────


# Section: The change of topics and sentiments over time.

# Aggregate data on a monthly basis
library(lubridate)
library(dplyr)
# Ensure date is of Date type
topic_sentiment$month <- as.Date(topic_sentiment$date...6)

# Aggregate data on a monthly basis
topic_sentiment <- topic_sentiment %>%
 mutate(month = floor_date(month, "month")) %>%
 group_by(month, brand...7) %>%
 summarise(
 topic1 = mean(topic1 * sentiment, na.rm = TRUE),
 topic2 = mean(topic2 * sentiment, na.rm = TRUE)
 )

# Reshape data to long format for faceting
topic_sentiment_long <- topic_sentiment %>%
 pivot_longer(cols = c(topic1, topic2),
 names_to = "topic", values_to = "sentiment_score")

# Plot the sentiment of topics over time, colored by brand, faceted by topic
ggplot(topic_sentiment_long, aes(x = month,
 y = sentiment_score, fill = brand...7)) +
 geom_area(position = "stack", alpha = 0.6) +
 labs(x = "Date",
 y = "Sentiment Score",
 fill = "Brand") +
 theme_minimal() +
 scale_fill_manual(values = c("Apple" = "blue", "Samsung" = "red",
 "Amazon" = "green")) +
 facet_grid(rows = vars(topic), scales = "free_y") +
 theme(strip.text = element_text(face = "bold"))
# ──────────────────────────────────────────────────────────────


# Section: Vulgar words in negative reviews

# Filter and sample the reviews
sampled_reviews <- comparison %>%
 filter(Brand %in% c("Apple", "Samsung")) %>%
 filter(sentiment.ai < -0.5) %>%
 group_by(Brand) %>%
 ungroup()

# Split sentences and unnest
sampled_reviews <- sampled_reviews %>%
 mutate(review_sentences = map(target, get_sentences)) %>%
 unnest(review_sentences) %>%
 ungroup()

# Apply profanity_by
profanity_result <- profanity_by(sampled_reviews$review_sentences,
 sampled_reviews$Review_id)

# Filter for reviews that contain profanity
profanity_reviews <- profanity_result %>%
 filter(profanity_count > 0)

# Compare profanity counts by brand
profanity_comparison <- profanity_reviews %>%
 left_join(sampled_reviews, by = "Review_id") %>%
 group_by(Brand) %>%
 summarise(total_profanity_count = sum(profanity_count))

# Display the comparison results
profanity_comparison
# ──────────────────────────────────────────────────────────────


# Section: Vulgar words in negative reviews

# Display an example review containing profanity
example_review <- profanity_reviews %>%
 left_join(sampled_reviews, by = "Review_id") %>%
 filter(profanity_count > 0) %>%
 select(Brand, review_sentences, profanity_count) %>%
 arrange(profanity_count) %>%
 slice(1)

# Display the results as a table
kable(example_review, format = "markdown") %>%
 kable_styling(full_width = FALSE) %>%
 column_spec(1, width = "4em") %>%
 column_spec(2, width = "25em") %>%
 column_spec(3, width = "5em")
# ──────────────────────────────────────────────────────────────

