# Section: Proximity and similarity
#   Subsection: Euclidean distance

library(tidyverse)
# Example, the word bank (appears 20 times in the first document),
# engine (appears 11 times in the same document)
doc1 <- c(20, 11)
doc2 <- c(22, 12)
doc3 <- c(12, 27)

docs <- rbind(doc1, doc2, doc3) %>%
 as.data.frame %>%
 rename(bank=1, engine=2)

ggplot(docs, aes(x=bank, y=engine)) +
 geom_point() +
 labs(x="bank", y="engine") +
 geom_label(label=rownames(docs), nudge_x = 0.35, nudge_y = 0.35)
# ──────────────────────────────────────────────────────────────


# Section: Proximity and similarity
#   Subsection: Euclidean distance

# Compute pariwise distances between documents
dist(docs)
# ──────────────────────────────────────────────────────────────


# Section: Proximity and similarity
#   Subsection: Cosine similarity

library(lsa)

# Example data: term frequencies
doc1 <- c(20, 11)
doc2 <- c(22, 12)
doc3 <- c(12, 27)

# Combine into a matrix
docs <- rbind(doc1, doc2, doc3)

# Calculate cosine similarity matrix
cosine_sim_matrix <- cosine(t(docs))

# View the cosine similarity matrix
cosine_sim_matrix
# ──────────────────────────────────────────────────────────────


# Section: Hierarchical agglomerative clustering

# Create a data frame for six words and their frequencies in two documents
words_data <- data.frame(
 Word = c("Word1", "Word2", "Word3", "Word4", "Word5", "Word6"),
 Document1 = c(40, 22, 35, 26, 8, 45),
 Document2 = c(53, 38, 32, 19, 41, 30)
)

# Calculate Euclidean distances
dist_matrix <- dist(words_data[, -1], method = "euclidean")
print(dist_matrix)

# Plotting using ggplot2
library(ggplot2)
ggplot(words_data, aes(x = Document1, y = Document2, label = Word)) +
 geom_point() +
 geom_text(vjust = "inward", hjust = "inward") +
 labs(x = "Frequency in Document 1", y = "Frequency in Document 2") +
 theme_minimal()
# ──────────────────────────────────────────────────────────────


# Section: Hierarchical agglomerative clustering

# Loading libraries
library(factoextra)
library(NbClust)
library(proxy)

# Convert 'docs' to matrix
m <- as.matrix(docs)

# Canberra distance matrix
d <- dist(m, method = "canberra")

# Ward's method clustering
hc <- hclust(d, method = "ward.D")

# Optimal cluster count
nb <- NbClust(m, distance = "canberra", min.nc = 2, max.nc = 5,
 method = "ward.D", index = "all")
# ──────────────────────────────────────────────────────────────


# Section: Hierarchical agglomerative clustering

optimal_clusters <- nb$Best.nc[1]

# Clustering result
hc_result <- hcut(d, k = optimal_clusters, hc_method = "ward.D")
# ──────────────────────────────────────────────────────────────


# Section: Hierarchical agglomerative clustering

# Dendrogram visualization
fviz_dend(hc_result, rect = TRUE, rect_border = "jco", rect_lty = 2, cex = 0.5)
# ──────────────────────────────────────────────────────────────


# Section: Hierarchical agglomerative clustering

# Cluster visualization
fviz_cluster(hc_result, data=m, ellipse.type = "norm")
# ──────────────────────────────────────────────────────────────


# Section: Hierarchical agglomerative clustering

library(proxy) # for cosine similarity calculation
library(cluster) # for hierarchical clustering

# Compute the similarity matrix
similarity_matrix <- simil(m, method = "cosine")

# Converting similarity to distance
distance_matrix <- 1 - similarity_matrix

# Performing hierarchical clustering
hc <- hclust(as.dist(distance_matrix), method = "ward.D") # or any other method

# Plotting the dendrogram
fviz_dend(hc, cex = 0.5, rect = TRUE, k_colors = "jco", rect_border = "jco", rect_lty = 2)
# ──────────────────────────────────────────────────────────────


# Section: K-means clustering

library(animation)

# Example, six words with their frequencies
Rowname <- c("Word1", "Word2", "Word3", "Word4", "Word5", "Word6")
Document1 <- c(40, 22, 35, 26, 8, 45)
Document2 <- c(53, 38, 32, 19, 41, 30)

# Create the dataset
dt <- cbind(Document1, Document2) %>%
 as.data.frame %>%
 `rownames<-`(Rowname)

# Set a random seed for reproducibility
set.seed(123)

# Perform animated k-means with 2 clusters
kmeans.ani(dt, 2)
# ──────────────────────────────────────────────────────────────


# Section: K-means clustering

library(RColorBrewer)
set.seed(123)


tdm_matrix <- as.matrix(docs)

# Calculate the optimal number of clusters using NbClust
nckm <- NbClust(tdm_matrix, distance = "canberra", min.nc = 2, max.nc = 10,
 method = "kmeans", index = "ch")
nbc <- as.vector(nckm$Best.nc[1]) # Extracting the optimal cluster number

# Perform k-means clustering with the optimal number of clusters
km <- kmeans(tdm_matrix, centers = nbc, nstart = 30)

# Generate a color palette based on the number of clusters
palette <- brewer.pal(nbc, "Set1")

# Visualize the clusters using the same data matrix used in kmeans
fviz_cluster(list(data = tdm_matrix, cluster = km$cluster),
 palette = palette,
 main = "Partitioning Clustering Plot",
 ellipse.type = "norm",
 repel = TRUE,
 show.clust.cent = TRUE
)
# ──────────────────────────────────────────────────────────────


# Section: K-means clustering

# Print cluster assignments
km$cluster
# ──────────────────────────────────────────────────────────────


# Section: Gaussian mixtures clustering

library(ClusterR)

# Convert 'docs' to distance matrix and then to a data frame
dist_matrix_df <- as.matrix(docs) %>%
 dist() %>%
 as.matrix() %>%
 as.data.frame()

# Set the number of clusters
nbc <- 3

# Create Gaussian mixture model (use Mahalanobis distance)
gmc_model <- GMM(dist_matrix_df, gaussian_comps = nbc,
 dist_mode = "maha_dist", seed_mode = "random_subset",
 km_iter = 10, em_iter = 5, verbose = FALSE,
 var_floor = 1e{-10}, seed = 1)

# Predict cluster labels
gmc_labels <- predict_GMM(dist_matrix_df, CENTROIDS = gmc_model$centroids,
 COVARIANCE = gmc_model$covariance_matrices,
 WEIGHTS = gmc_model$weights)$cluster_labels

# Visualize the clusters
fviz_cluster(list(data = dist_matrix_df, cluster = gmc_labels),
 ellipse.type = "norm", repel = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Gaussian mixtures clustering

# Create a data frame of words and their cluster labels
df <- data.frame(words = rownames(dist_matrix_df), cluster = gmc_labels)

# Display some results
print(head(df))
# ──────────────────────────────────────────────────────────────


# Section: Density-based clustering

library(dbscan)

# calculate the hdbscan cluster
clustering.dbscan <- hdbscan(docs, minPts = 2)
clustering.dbscan$cluster
# ──────────────────────────────────────────────────────────────


# Section: Density-based clustering

# visualize the clusters created with hdbscan
fviz_cluster(list(data = as.matrix(docs), cluster = clustering.dbscan$cluster),
 ellipse.type = "norm",
 repel = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Density-based clustering

library(dbscan)
library(factoextra)

# Perform HDBSCAN clustering
clustering_hdbscan <- hdbscan(as.matrix(docs), minPts = 2)

# Check clustering results
clustering_hdbscan
# ──────────────────────────────────────────────────────────────


# Section: Density-based clustering

# Create a list structure that is compatible with fviz_cluster
cluster_data <- list(data = as.matrix(docs), cluster = clustering_hdbscan$cluster)

# Visualize the clusters using fviz_cluster
fviz_cluster(cluster_data, ellipse.type = "norm", repel = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Affinity propagation clustering

# affinity propagation
library(apcluster)
library(reshape2)


# negDistMat computes the similarity matrix
similarity_matrix <- negDistMat(docs, r=2)

# Apply clustering
apck <- apclusterK(s=similarity_matrix, K=3)
# ──────────────────────────────────────────────────────────────


# Section: Affinity propagation clustering

# Convert data from a cluster type into a data frame
apckmelt <- melt(apck@clusters)

# Visualize the data
fviz_cluster(list(data = as.matrix(docs)[apckmelt$value,], cluster = apckmelt$L1),
 ellipse.type = "norm",
 repel = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Affinity propagation clustering

# Check which words belong to each cluster
apck
# ──────────────────────────────────────────────────────────────


# Section: Document clustering

library(dbscan)

# Matrix transposition
dtm <- t(docs)

# Calculate the hdbscan cluster
clustering.dbscan <- hdbscan(dtm, minPts = 2)

# Visualize the clusters created with hdbscan
fviz_cluster(list(data = as.matrix(dtm), cluster = clustering.dbscan$cluster),
 ellipse.type = "norm",
 repel = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Document clustering

# Clustering details
clustering.dbscan
# ──────────────────────────────────────────────────────────────

