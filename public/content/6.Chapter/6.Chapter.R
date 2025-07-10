# Section: Supervised machine-learning-algorithm models
#   Subsection: Data-set preparation

# Set global option to avoid automatic conversion of strings to factors
options(stringsAsFactors = FALSE)

# Load necessary libraries
library(tm)
library(caret)
library(tidyverse)
library(SnowballC)
library(textstem)
library(kableExtra)
library(caretEnsemble)

# Read the classified dataset, directly filter, and select required data
dt <- read.csv("data/Product Reviews.csv") %>%
 filter(Brand %in% c("Apple", "Samsung")) %>%
 select(Content, Brand)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Data-set preparation

# Set the seed for reproducibility
seed <- 123
set.seed(seed)

# Assign "train" or "test" to each observation in the dataset
dt$Type <- sample(c("train", "test"), nrow(dt), replace = TRUE, prob = c(0.8, 0.2))

# Check the distribution of the brands over the Type variable
table(dt$Brand, dt$Type)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Data-set preparation

# Create a corpus from the Content column for preprocessing
library(tm)
library(SnowballC)
corpus <- VCorpus(VectorSource(dt$Content))

# Preprocess the corpus and create a Document Term Matrix
dtm <- corpus %>%
 tm_map(content_transformer(tolower)) %>% # Convert to lowercase
 tm_map(content_transformer(removeWords), stopwords("english")) %>% # Remove stopwords
 tm_map(removePunctuation) %>% # Remove punctuation
 tm_map(removeNumbers) %>% # Remove numbers
# tm_map(stemDocument) %>% # Stemming (commented out)
 tm_map(content_transformer(lemmatize_words)) %>% # Lemmatization
 tm_map(stripWhitespace) %>% # Remove whitespace
 DocumentTermMatrix() %>%
# weightTfIdf() %>% # Tf-Idf weighting (commented out)
 removeSparseTerms(0.98) # Adjust for sparsity

# Check the dimensions of the DTM
dim(dtm)

# Convert the DTM to a data frame
dtm_df <- as.data.frame(as.matrix(dtm))

# Ensure dtm_df and dt contain the same number of documents, then add Brand and Type
dtm_df <- bind_cols(dtm_df, dt[ , c("Brand", "Type")])

# Split the data frame into training and testing sets and remove the Type column
dtm_train <- filter(dtm_df, Type == "train") %>% select(-Type)
dtm_test <- filter(dtm_df, Type == "test") %>% select(-Type)

# Clean up the workspace
rm(dtm, corpus, dtm_df)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Linear discriminant analysis

# Set 10-fold CV, save predictions, enable class probabilities
control <- trainControl(method = "cv", number = 10, savePredictions = "final", classProbs = TRUE)

# Set seed for reproducibility
set.seed(seed)

# Train LDA model, optimize for accuracy, 5 tuning iterations
lda <- train(Brand ~ ., data = dtm_train, method = "lda", trControl = control, metric= "Accuracy", tuneLength = 5)

# Display model summary
lda
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Linear discriminant analysis

# Predict with LDA model on test data
lda.predict <- predict(lda, newdata = dtm_test)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Linear discriminant analysis

# Evaluate model performance on the test set using a confusion matrix
cfm <- confusionMatrix(lda.predict, as.factor(dtm_test$Brand))
print(cfm)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Linear discriminant analysis

# Obtain classification probabilities for each brand in the test set
lda.predict.p <- predict(lda, newdata = dtm_test, type = "prob")

# Display probabilities for the first six documents as percentages, rounded to two decimals
head(round(lda.predict.p * 100, 2))
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: K-nearest neighbors (KNN) classification

# Configure 10-fold CV with class probabilities
ctrl <- trainControl(method = "cv", number = 10, classProbs = TRUE)

# Train kNN, optimizing accuracy, with 5 k values
set.seed(seed) # Ensure reproducible results
knn <- train(Brand ~ ., data = data.frame(dtm_train), method = "knn", trControl = ctrl, metric = "Accuracy", tuneLength = 5)

# Display model summary
knn
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: K-nearest neighbors (KNN) classification

# plot and identify best k
ggplot(knn)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: K-nearest neighbors (KNN) classification

# Predict labels for the test dataset using the trained kNN model
knn.predict <- predict(knn, newdata = data.frame(dtm_test))

# Evaluate the model's performance on the test set using a confusion matrix
cfm <- confusionMatrix(knn.predict, as.factor(dtm_test$Brand))
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Support-vector-machine classification
#     Subsubsection: Linear SVM.

library(kernlab)
# Set 10-fold CV with class probabilities and save predictions
ctrl <- trainControl(method="cv", number=10, savePredictions="final", classProbs=TRUE)

# Tuning grid for 'C' parameter
tG <- expand.grid(C=seq(0, 2, length=5))

# Train SVM with linear kernel, tuning 'C'
set.seed(seed)
svm.linear <- train(Brand~., data=dtm_train, method="svmLinear", trControl=ctrl, preProcess = c("center","scale"), tuneGrid=tG)

# Predict and evaluate with linear kernel SVM
svm.linear.predict <- predict(svm.linear, newdata=dtm_test)
confusionMatrix(svm.linear.predict, as.factor(dtm_test$Brand))
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Support-vector-machine classification
#     Subsubsection: SVM radial

# Set seed for reproducible results
set.seed(seed)

# Train SVM with radial basis function kernel on training data
svm.radial <- train(Brand ~ ., data = dtm_train, method = "svmRadial", trControl = ctrl, tuneLength = 10)

# Predict labels on test data
svm.radial.predict <- predict(svm.radial, newdata = dtm_test)

# Evaluate predictions using a confusion matrix
confusionMatrix(svm.radial.predict, as.factor(dtm_test$Brand))
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Support-vector-machine classification
#     Subsubsection: Polynomial kernel SVM

# Set seed for reproducible results
set.seed(seed)

# Train SVM with polynomial kernel on training data
svm.poly <- train(Brand ~ ., data = dtm_train, method = "svmPoly", trControl = ctrl, tuneLength = 5)

# Predict labels for test data using the trained model
svm.poly.predict <- predict(svm.poly, newdata = dtm_test)

# Evaluate model performance with a confusion matrix
confusionMatrix(svm.poly.predict, as.factor(dtm_test$Brand))
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Support-vector-machine classification
#     Subsubsection: Polynomial kernel SVM

# Aggregate resampling results for SVM models with different kernels
svm <- resamples(list(svm.linear, svm.radial, svm.poly))

# Summarize the performance metrics of the models
summary(svm)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Support-vector-machine classification
#     Subsubsection: Polynomial kernel SVM

# Visualize the performance comparison using ggplot
ggplot(svm)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Ensemble learning

# Set a 10-fold cross-validation scheme, enabling class probability predictions and saving all predictions
ctrl <- trainControl(method="cv", number = 10, classProbs=TRUE, index=createFolds(dtm_train$Brand, k = 10), savePredictions = "all")

# Define a list of machine learning algorithms for ensemble learning
algorithmList <- c('lda', 'knn', 'svmLinear')

library(caretEnsemble)
set.seed(seed) # Ensure reproducible results

# Train models specified in the algorithm list with the defined control settings
models <- caretList(Brand ~ ., data = dtm_train, trControl = ctrl, methodList = algorithmList, tuneLength = 10)

# Compare the models' performance using resampling
results <- resamples(models)

# Summarize the comparative performance of the models
summary(results)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Ensemble learning

# Plot the results
ggplot(results)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Ensemble learning

# Configure 10-fold CV, saving predictions and probabilities
stackControl <- trainControl(method="cv", number=10, savePredictions=TRUE, classProbs=TRUE)

# Stack models using GLM as meta-learner, optimizing for accuracy
stack.glm <- caretStack(models, method="glm", metric="Accuracy", trControl=stackControl, tuneLength = 10)

# Display stacked model summary
stack.glm
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Ensemble learning

# Correlation matrix between model predictions
modelCor(results)
# ──────────────────────────────────────────────────────────────


# Section: Supervised machine-learning-algorithm models
#   Subsection: Ensemble learning

# Scatterplot matrix (splom) to visually examine the correlations between model predictions
splom(results)
# ──────────────────────────────────────────────────────────────


# Section: Neural networks

# Define a grid for tuning the decay parameter and the number of units in the hidden layer
nnetGrid <- expand.grid(decay = c(0, 0.01, .1), size = c(1:10))

# Determine the maximum number of units in the hidden layer from the grid
maxSize <- max(nnetGrid$size)

# Calculate the maximum number of weights for the neural network
# Formula: M(p+1)+M+1, where M is the number of hidden units, and p is the number of inputs
numWts <- 1 * (maxSize * (length(dtm_train) + 1) + maxSize + 1)

# Set a 10-fold cross-validation scheme (see the ensemble method)
ctrl <- trainControl(method="cv", number = 10, classProbs=TRUE, index=createFolds(dtm_train$Brand, k = 10), savePredictions = "all")

# Load the nnet package for neural network training
library(nnet)

# Set a random seed for reproducible results
set.seed(seed)

# Train the neural network model using the specified control parameters and tuning grid
NNModel <- train(Brand ~ ., data = dtm_train, method = "nnet", trace = FALSE,
 trControl = ctrl, tuneGrid = nnetGrid, # Include the tuning grid in the training process
 na.action = na.omit, MaxNWts = numWts)

# Predict the test set using the trained neural network model
NNPredictions <- predict(NNModel, dtm_test)

# Evaluate the model's performance with a confusion matrix
confusionMatrix(NNPredictions, as.factor(dtm_test$Brand))
# ──────────────────────────────────────────────────────────────


# Section: Fasttext

library(fastTextR)

set.seed(123)
# Split data into training and testing sets
data_train <- dt[sample(nrow(dt), nrow(dt) * 0.8), ]
data_test <- dt[-sample(nrow(dt), nrow(dt) * 0.8), ]

# Prepare training and testing data
prepare_data <- function{(data, file_name)
 labels_texts <- paste0("__label__", tolower(data$Brand), " ", tolower(data$Content))
 normalized <- ft_normalize(labels_texts)
 writeLines(normalized, con = file_name)


prepare_data(data_train, "tablets.train")
prepare_data(data_test, "tablets.test")

# Set training parameters
cntrl <- ft_control(word_vec_size = 10L, learning_rate = 0.3, max_len_ngram = 2L,
 min_count = 1L, nbuckets = 10000000L, epoch = 10L, nthreads = 4L)

# Train model and save
model <- ft_train(file = "tablets.train", method = "supervised", control = cntrl)
ft_save(model, "tablets.bin")

# Load model and predict
model <- ft_load("tablets.bin")
test_pred <- ft_predict(model, newdata = ft_normalize(paste0("__label__", tolower(data_test$Content))), k = 1L)

# Evaluate model
confusion_matrix <- table(Truth = paste0("__label__", tolower(data_test$Brand)),
 Prediction = test_pred$label)
print(confusion_matrix)
# ──────────────────────────────────────────────────────────────


# Section: Fasttext

# Calculate and print accuracy
accuracy <- sum(diag(confusion_matrix)) / sum(confusion_matrix)
print(sprintf("Accuracy: %0.4f", accuracy))
# ──────────────────────────────────────────────────────────────

