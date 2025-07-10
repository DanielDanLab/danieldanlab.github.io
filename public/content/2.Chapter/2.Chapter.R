# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Empty Strings and Character Vectors

# Assign an empty string to the variable 'empty_string'
empty_string <- ""

# Display the value of 'empty_string'
empty_string
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Empty Strings and Character Vectors

# Check and display the class of 'empty_string'
class(empty_string)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Empty Strings and Character Vectors

# Create an empty character vector with a length of zero
empty_character <- character(length = 0)

# Display the content of 'empty_character'
empty_character
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Empty Strings and Character Vectors

# Check and display the class of 'empty_character'
class(empty_character)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Empty Strings and Character Vectors

# Create a character vector with 10 elements, initialized as empty strings
character_vector <- character(10)

# Display the contents of 'character_vector'
character_vector
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Assign the string "fifth" to the fifth element of the 'character_vector'
character_vector[5] <- "fifth"

# Display the contents of 'character_vector'
character_vector
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Assign a string to variable 'x'
x <- "really, is this a character?"

# Assign the result of the sum 9+8 to variable 'y'
y <- 9 + 8

# Check if 'x' is of character type
is.character(x)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Check if 'y' is of character type
is.character(y)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Get the class of 'x'
class(x)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Get the class of 'y'
class(y)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Convert 'y' from numeric to character type
y <- as.character(y)

# Get the class of 'y' after conversion
class(y)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Concatenating two strings
x <-paste("My favorite book", "has many chapters", sep = " ")
x
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Some basics on measurement representation in R
#     Subsubsection: Combining and Indexing Strings

# Concatenating 'Chapter' with numbers 1 to 5, separated by commas
x <- paste("Chapter", 1:5, sep = " ", collapse = ", ")
x
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Set global option to not automatically convert strings to factors
options(stringsAsFactors = FALSE)

# Read the CSV file 'Product Reviews.csv' into a dataframe 'prodreviews'
prodreviews <- read.csv("data/Product Reviews.csv")

# Convert the 'Title' column of 'prodreviews' to character type
# and store in 'prodtitle'
prodtitle <- as.character(prodreviews$Title)

# Set a seed for random number generation to ensure reproducibility
set.seed(123)

# Sample 20 titles randomly from 'prodtitle' and store them in 'prodtitle20'
(prodtitle20 <- sample(prodtitle, 20))
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Extracting the first four letters of each title
substr(prodtitle20, start = 1, stop = 4)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Apply the 'abbreviate()' function to the 'prodtitle20' vector
abbreviate(prodtitle20)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Calculate the length of each title
nchar(prodtitle20)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Find the maximum length among these titles
max(nchar(prodtitle20))
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Extract the titles from 'prodtitle20' that have the maximum length
prodtitle20[which(nchar(prodtitle20)==max(nchar(prodtitle20)))]
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Count total titles in 'prodtitle'
length(prodtitle)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Count unique titles in 'prodtitle'
length(unique(prodtitle))
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Get statistical summary of title lengths in 'prodtitle'
summary(nchar(prodtitle))
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: Working with strings

# Plot a histogram of string lengths in 'prodtitle'
hist(nchar(prodtitle),
 main = 'Histogram of Title Lengths', # Set the main title of the histogram
 breaks = 20, # Specify the number of bins as 20
 xlab = 'Number of Characters', # Label for the x{-axis
 ylab = 'Frequency of Titles') # Label for the y{-axis
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions

# Load re2r package
library(re2r)

# Visualize email regex pattern
show_regex("\\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}\\b")
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Create a vector of sample strings with varying patterns
strings <- c("x", "xy", "xz", "xzy", "xzzy", "xzzzy", "xzzzzy", "xzzzzyzy")
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Identify indices of elements in vector 'strings' that contain "xy"
grep("xy", strings)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Return elements in 'strings' that contain "xy"
grep("xy", strings, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Return elements matching 'xz*y' pattern in 'strings'
grep("xz*y", strings, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Return elements matching 'xz+y' pattern in 'strings'
grep("xz+y", strings, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Return elements matching 'xz?y' pattern in 'strings'
grep("xz?y", strings, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Find 'xz{3}y' (three 'z's before 'y') in 'strings'
grep("xz{3}y", strings, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Find 'xz{2,}y' (at least two 'z's before 'y') in 'strings'
grep("xz{2,}y", strings, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Quantifiers

# Find 'xz{0,2}y' (0 to 2 'z's before 'y') in 'strings'
grep("xz{0,2}y", strings, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Position of a pattern inside a string

# Find elements in 'prodtitle20' starting with "Ki"
grep("\^Ki", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Position of a pattern inside a string

# Find elements in 'prodtitle20' ending with "et"
grep("et$", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Position of a pattern inside a string

# Find elements in 'prodtitle20' with the word "Fire" as a whole word
grep("\\bFire\\b", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Position of a pattern inside a string

# Find elements in 'prodtitle20' where "able" is part of another word
grep("\\Bable\\B", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match 'fe' followed by any character in 'prodtitle20'
grep("fe.", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match 'p' followed by 'r' or 'u' in 'prodtitle20'
grep("p[ru]", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match 'p' followed by any letter from 'a' to 'i' in 'prodtitle20'
grep("p[a-i]", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match 'f' not followed by 'i' in 'prodtitle20'
grep("f[\^i]", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match 'fi' in 'prodtitle20'
grep("fi", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match 'er' or 're' in 'prodtitle20'
grep("er|re", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match one or more repetitions of 'ire' in 'prodtitle20'
grep("(ire)+", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Identify elements containing 'Kindle Fire'
matches <- grep("Kindle Fire", prodtitle20, value = TRUE)

# Apply gsub only to matched elements
modified <- gsub("(Kindle) Fire", "\\1 Big Fire", matches)

# Display modified elements
modified
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Swap 'Kindle' and 'Fire'
gsub("(Kindle) (Fire)", "\\2 \\1", matches)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Common operators

# Match literal dots in 'prodtitle20'
grep("\\.", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Character classes

# Find titles with punctuation in 'prodtitle20'
grep("[[:punct:]]", prodtitle20, value = TRUE)
# ──────────────────────────────────────────────────────────────


# Section: Text manipulation
#   Subsection: The foundations of regular expressions
#     Subsubsection: Regular expressions in search, and search and replace within RStudio

text_strings <- c("We have to extract these numbers 12, 47, 48",
"The integers numbers are also interestings: 189 2036 314",
"','is a separator, so please extract these numbers 125,789,1450
and also these 564,90456", "We like to to offer you 7890$ per
month in order to complete this task... we are joking", "You are
going to learn 3 things, the first one is not to extract, and
2 and 3 are simply digits.", "Have fun with our mighty test, you
are going to support science, progress, mankind wellness and you
are going to waste 30 or 60 minutes of your life.", "you can also
extract exotic stuff like a456 gb67 and 45678911ghth", "Writing 1
example is not funny, please consider that 66% is
validation+testing", "You you are a genius, I think that you like
arrays A LOT, [3,45,67,900,1974]", "Who loves arrays more than
me?", "{366,78,90,5}Yes, there are only 4 numbers inside",
"Integers are fine but sometimes you like 99 cents after the 99
dollars", "100 euro are better than 99 euro", "I like to give you
1000 numbers now: 12 3 56 21 67, and more, [45,67,7]", "Ok ok 1 2
3 4 5 and the last one is 6", "33 trentini entrarono a Trento,
tutti e 33 di tratto in tratto trotterellando")
# ──────────────────────────────────────────────────────────────

