# Section: NER Information extraction using spacyr
#   Subsection: Identifying and describing entities

library(spacyr)
library(dplyr)
library(lubridate)

# Initialize spaCy with a large English model
spacy_initialize(model = "en_core_web_lg")


# Clean and filter data, then add row numbers as Review_id
data <- comparison %>%
 select(-sentimentAnalysis, -sentimentr, -vader, -syuzhet) %>%
 filter(sentiment.ai < -0.7, Brand %in% c("Samsung", "Apple")) %>%
 mutate(Review_id = row_number())
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Identifying and describing entities

# Parse text to extract syntactic dependencies
parsedtxt <- spacy_parse(data$target)
head(parsedtxt)
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Identifying and describing entities

library(dplyr)

# Create doc_id, remove Review_id
data <- data %>%
 mutate(doc_id = paste0("text", as.character(Review_id))) %>%
 select(-Review_id)

# Tokenize text into sentences and assign sentence IDs
sent_df<- spacy_tokenize(data$target, what = "sentence",
 output = "data.frame",
 doc_id = data$doc_id) %>%
 rename(sentence = token) %>%
 group_by(doc_id) %>%
 mutate(sentence_id = row_number()) %>%
 ungroup()


# Merge back with original data to include the Brand and R_date
sent_df <- sent_df %>%
 left_join(data %>% select(doc_id, Brand, R_date), by = "doc_id" )

sentence_data <- parsedtxt %>%
 left_join(sent_df , by = c("doc_id", "sentence_id"))
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Identifying and describing entities

library(ggplot2)

# Count top 10 unique entities per brand
entity_counts <- sentence_data %>%
 filter(!is.na(entity) \& entity != "") %>%
 distinct(doc_id, entity, .keep_all = TRUE) %>%
 group_by(Brand, entity) %>%
 summarize(count = n()) %>%
 arrange(Brand, desc(count)) %>%
 group_by(Brand) %>%
 slice_max(count, n = 10)

# Plot top entities for each brand
ggplot(entity_counts, aes(x = reorder(entity, -count),
 y = count, fill = Brand)) +
 geom_bar(stat = "identity", position = "dodge") +
 labs(title = "Most Frequent Entities for Each Brand",
 x = "Entity",
 y = "Count",
 fill = "Brand") +
 theme_minimal() +
 coord_flip()
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Identifying and describing entities

# Filter and capitalize specific entities
op_entities <- sentence_data %>%
 filter(entity %in% c("PRODUCT_B", "ORG_B", "ORG_I")) %>%
 mutate(token = ifelse(startsWith(entity, "ORG") |
 startsWith(entity, "PRODUCT"), toupper(token), token))

# Count occurrences, filter, and sort
op_counts <- op_entities %>%
 group_by(token, Brand) %>%
 summarize(count = n()) %>%
 filter(count > 5) %>%
 arrange(desc(count))

# Plot most frequent entities by brand
ggplot(op_counts, aes(x = reorder(token, -count), y = count, fill = Brand)) +
 geom_bar(stat = "identity", position = "dodge") +
 labs(title = "Most Frequent ORG/PROD Entities Subdivided by Brand",
 x = "Organization",
 y = "Count",
 fill = "Brand") +
 theme_minimal() +
 coord_flip()
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Extracting adjectives

library(tidyr)

# Filter adjectives from sentence data and lowercase token
adj_entities <- sentence_data %>%
 filter(pos == "ADJ") %>%
 mutate(token = tolower(token))

# Count occurrences of adjectives by brand
adj_counts <- adj_entities %>%
 group_by(token, Brand) %>%
 summarize(count = n(), .groups = "drop") # Count occurrences per brand

# Create columns for Apple and Samsung brands and counts
adj_counts_wide <- adj_counts %>%
 pivot_wider(names_from = Brand, values_from = count, values_fill = list(count = 0)) %>%
 rename(`Brand Apple` = Apple, `Count Apple` = Apple,
 `Brand Samsung` = Samsung, `Count Samsung` = Samsung) %>%
 arrange(desc(`Count Apple` + `Count Samsung`))

# Display the top 20 most frequent adjectives
top_20_adj <- adj_counts_wide %>%
 slice_max(order_by = (`Count Apple` + `Count Samsung`), n = 20)

# Print results
print(top_20_adj)
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Dependencies and POS highlighting

library(rsyntax)

# Parse the text considering the dependencies
parsedtxt <- spacy_parse(data$target, dependency = TRUE)

# Plot the dependency tree for a specific document
plot_tree(
 as_tokenindex(parsedtxt),
 doc_id = "text1",
 token,
 lemma,
 pos,
 viewer_size = c(110, 150),
 textsize = 1,
 spacing = 2,
 viewer_mode = FALSE
)
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Dependencies and POS highlighting

library(dplyr)
library(htmltools)

# Filter for a specific document
doc_id_nr <- "text1"
parsed_data <- parsedtxt %>% filter(doc_id == doc_id_nr)

# Create a function to highlight annotations in text
highlight_annotations <- function{(text, parsed_data)
 tokens <- parsed_data$token
 entities <- parsed_data$entity
 pos_tags <- parsed_data$pos

# Initialize an empty string to store the highlighted text
 highlighted_text <- ""

 for (i in seq_along{(tokens))
 token <- tokens[i]
 entity <- entities[i]
 pos_tag <- pos_tags[i]

# Highlight based on entity and POS tag
 if (entity != ""{)
 highlighted_text <- paste0(highlighted_text,
 "<span style='color: blue;'>", token, "</span>")
 \ }else if (pos_tag == "ADJ"{)
 highlighted_text <- paste0(highlighted_text,
 "<span style='color: red;'>", token, "</span>")
 \ }else if (pos_tag == "NOUN"{)
 highlighted_text <- paste0(highlighted_text,
 "<span style='color: green;'>", token, "</span>")
 \ }else{
 highlighted_text <- paste0(highlighted_text, token)


# Add a space after each token
 highlighted_text <- paste0(highlighted_text, " ")


 return(highlighted_text)


# Apply the function to the parsed text
highlighted_text <- highlight_annotations(text, parsed_data)

# Display inline
browsable(HTML(highlighted_text))
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Tracking adjective usage over time

# Filter for adjectives and the two brands
adjective_data <- sentence_data %>%
 filter(pos == "ADJ" \& Brand %in% c("Apple", "Samsung"))

# Group by date and brand, then count the number of adjectives
adjective_counts <- adjective_data %>%
 group_by(R_date, Brand) %>%
 summarize(count = n()) %>%
 ungroup()

# Plotting the data with both lines and smoothing
ggplot(adjective_counts, aes(x = R_date, y = count, color = Brand, linetype = Brand)) +
 geom_line() +
 geom_smooth(method = "loess", span = 0.3, se = FALSE) +
 labs(title = "Number of Adjectives Over Time for Apple and Samsung",
 x = "Date",
 y = "Number of Adjectives") +
 theme_minimal() +
 theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
 guides(color = guide_legend(override.aes = list(size = 1)))
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Language complexity

# Load necessary libraries
library(dplyr)
library(ggplot2)

# Calculate linguistic complexity for each document and brand
syn_com <- sentence_data %>%
 group_by(doc_id, Brand) %>%
 summarize(verb_num = sum(pos == "VERB"),
 sent_num = n_distinct(sentence_id),
 word_num = n()) %>%
 mutate(F_C = (verb_num / sent_num) * (word_num / sent_num)) %>%
 ungroup()

# Compare linguistic complexity between the two brands
brand_comparison <- syn_com %>%
 group_by(Brand) %>%
 summarize(avg_F_C = mean(F_C, na.rm = TRUE),
 sd_F_C = sd(F_C, na.rm = TRUE),
 median_F_C = median(F_C, na.rm = TRUE),
 n = n())

# Display the result
print(brand_comparison)
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: Language complexity

# Plot the density of linguistic complexity for the two brands
ggplot(syn_com, aes(x = F_C, fill = Brand)) +
 geom_density(alpha = 0.5) +
 labs(title = "Comparison of Linguistic Complexity for Apple and Samsung",
 x = "Linguistic Complexity (F_C)",
 y = "Density") +
 theme_minimal() +
 scale_fill_manual(values = c("Apple" = "blue", "Samsung" = "red")) +
 theme(legend.title = element_blank())
# ──────────────────────────────────────────────────────────────


# Section: NER Information extraction using spacyr
#   Subsection: A final technical note

# Clean up and release spaCy resources
spacy_finalize()
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

library(lexRankr)
library(dplyr)

# Tokenize text data into sentences
tokenized_data <- data %>%
 unnest_sentences(sentence, target)

# Apply LexRank to rank sentences based on importance
ranked_sentences <- bind_lexrank(tokenized_data, sentence,
 doc_id, level = "sentences")


# Filter and get top 3 sentences for Apple
top_apple <- ranked_sentences %>%
 filter(Brand == "Apple") %>%
 arrange(desc(lexrank)) %>%
 slice(1:3)

# Filter and get top 3 sentences for Samsung
top_samsung <- ranked_sentences %>%
 filter(Brand == "Samsung") %>%
 arrange(desc(lexrank)) %>%
 slice(1:3)

# Display the results, for Apple
print(top_apple$sentence)

# Display the results, for Samsung
print(top_samsung$sentence)
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

# install.packages("LSAfun")
library(LSAfun)
library(dplyr)

# We can recycle the sent_df dataframe because it contains all the elements we need.

apple_data <- sent_df %>%
 filter(Brand == "Apple")

samsung_data <- sent_df %>%
 filter(Brand == "Samsung")

# Summarize to 2 sentences
summary_apple <- genericSummary(apple_data$sentence, k = 2)
summary_samsung <- genericSummary(samsung_data$sentence, k = 2)

# Display the results, for Apple
print(summary_apple)

# Display the results, for Samsung
print(summary_samsung)
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

# Add a unique identifier to each sentence and select relevant columns
sent_df_all <- sentence_data %>%
 mutate(textrank_id = paste(doc_id, sentence_id, sep = "_")) %>%
 select(textrank_id, doc_id, sentence_id, sentence, token, lemma, pos, Brand)

# Filter the data for sentences related to Apple
sent_df_apple <- sent_df_all %>%
 filter(Brand == "Apple")

# Filter the data for sentences related to Samsung
sent_df_smsng <- sent_df_all %>%
 filter(Brand == "Samsung")

# Display the first 10 rows of selected columns for Samsung sentences
head(sent_df_smsng[, c("sentence_id", "lemma", "pos")], 10)
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

library(textrank) # Load library

# Extract keywords for Apple (nouns/adjectives)
tr_kw_a <- textrank_keywords(sent_df_apple$lemma,
 relevant = sent_df_apple$pos %in% c("NOUN", "ADJ"))
# Filter: multi-word, freq >= 2
subset(tr_kw_a$keywords, ngram > 1 \& freq >= 2)
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

# Extract keywords for Samsung (nouns/adjectives)
tr_kw_s <- textrank_keywords(sent_df_smsng$lemma,
 relevant = sent_df_smsng$pos %in% c("NOUN", "ADJ"))
# Filter: multi-word, freq >= 4
subset(tr_kw_s$keywords, ngram > 1 \& freq >= 4)
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

# Extract unique sentences for Apple and Samsung
sentences_apple <- unique(sent_df_apple[, c("textrank_id", "sentence")])
sentences_smsng <- unique(sent_df_smsng[, c("textrank_id", "sentence")])

# Filter terms by POS tags for noun and adjective, select relevant columns
term_apple <- sent_df_apple[sent_df_apple$pos %in% c("NOUN", "ADJ"),
 c("textrank_id", "lemma")]
term_smsng <- sent_df_smsng[sent_df_smsng$pos %in% c("NOUN", "ADJ"),
 c("textrank_id", "lemma")]

# Apply textrank to find relevant sentences
tr_apple <- textrank_sentences(data = sentences_apple, terminology = term_apple)
tr_smsng <- textrank_sentences(data = sentences_smsng, terminology = term_smsng)

# Plot pagerank for Apple's textrank results
plot(sort(tr_apple$pagerank$vector, decreasing = TRUE), type = "b",
 ylab = "Pagerank", main = "Textrank")
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

# Top 3 sentences for Apple
sum_apple <- summary(tr_apple, n = 3, keep.sentence.order = TRUE)
print(sum_apple)
# ──────────────────────────────────────────────────────────────


# Section: Summarizing
#   Subsection: Summarizing in R

# Top 3 sentences for Samsung
sum_smsng <- summary(tr_smsng, n = 3, keep.sentence.order = TRUE)
print(sum_smsng)
# ──────────────────────────────────────────────────────────────

