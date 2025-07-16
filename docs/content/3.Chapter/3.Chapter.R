# Section: Handling electronic text
#   Subsection: Copy and paste

# Read the text file from the 'data' folder
text_data <- readLines("data/copied_text.txt")

# Display the content of the text file
print(text_data)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Downloaded text

# URL of the file
url <- "https://danieldanlab.github.io/data/sample.csv"

# Read CSV into dataframe
df <- read.csv(url, header = TRUE)

# Check dataset in viewer, uncomment
# View(df)

# Keep only first 5 columns
df <- df[, 1:5]

# Display first 6 rows
head(df)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Downloaded text

# Display last 6 rows
tail(df)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Downloaded text
#     Subsubsection: Common file-type extensions

# Installs the libpoppler-cpp-dev library on Debian/Ubuntu systems
sudo apt install libpoppler{-cpp-dev
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Downloaded text
#     Subsubsection: Common file-type extensions

# Load necessary libraries
library(pdftools)
library(stringr)

# Define URL of the PDF file
url <- "https://danieldanlab.github.io/data/sample.pdf"

# Download PDF file
download.file(url, "sample.pdf", mode = "wb")

# Read PDF; each page becomes an element in 'text'
text <- pdf_text("sample.pdf")

# Remove 'Sample text' from the text
text <- str_replace(text, "Sample text", "")

# Replace newline characters with space in page 1
text[1] <- str_replace_all(text[1], "\textbackslashn", " ")

# Split text at periods in page 1
text[1] <- str_split(text[1], "\\.")

# Convert to dataframe
mytext <- as.data.frame(text[1])

# Name the column as 'Sentence'
colnames(mytext) <- c("Sentence")

# Display first six rows
head(mytext)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Downloaded text
#     Subsubsection: Common file-type extensions

# Load tabulapdf library
library(tabulapdf)

# Extract table from second page of PDF
atable <- extract_tables(url, pages = 2, guess = TRUE, output = "tibble")

# Assign first table to mytable
mytable <- atable[[1]]

# Display top six rows of the table
head(mytable)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Scraping with your browser
#     Subsubsection: Other Plugins

# Set global options to limit text width

# Load tibble package
library(tibble)

# Read CSV as dataframe
tolkien <- read.csv("data/LordOR_amzn.csv", header = TRUE, stringsAsFactors = FALSE)

# Convert dataframe to tibble for readability
tolkien_t <- as_tibble(tolkien)

# Display tibble structure
str(tolkien_t)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Scraping with your browser
#     Subsubsection: Other Plugins

# Show first 2 entries
head(tolkien_t$content, 2)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Scraping by programming

 <!DOCTYPE html>
<html>
<head>
 <title>Book</title>
 <meta name="description" content="Marketing">
 <script type="text/javascript">
# // JavaScript code can go here
 </script>
 <link rel="stylesheet" href="style.css">
</head>
<body>
 <h1>Scraping</h1>
 <article>
 <p>
 Paragraph with <sub>subscript</sub> and <sup>superscript</sup> text.
 </p>
 <p id="par2">
 Paragraph with <i>italic</i> and <b>bold</b> text.
 </p>
 </article>
 <table>
<tr>
<td>Tablets</td>
</tr>
</table>
 <ul>
 <li>API</li>
 <li>DOM</li>
 </ul>
 <footer>
 <p>This is a footer paragraph.</p>
 <a href="https://www.danieldanlab.com"Link to a page</a>
 </footer>
</body>
</html>
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Scraping by programming

# Load necessary library
library(rvest)

# Define the URL to scrape
url <- "https://webscraper.io/test-sites/e-commerce/allinone"

# Read and parse the HTML from the URL
parsed_html <- read_html(url)

# Extract product titles
titles <- parsed_html %>%
 html_nodes("h4 .title") %>%
 html_text()

# Extract product descriptions
descriptions <- parsed_html %>%
 html_nodes(".description") %>%
 html_text()

# Extract product prices as text
prices_text <- parsed_html %>%
 html_nodes(".caption .pull-right") %>%
 html_text()

# Clean and convert prices to numeric
prices <- as.numeric(gsub("\\$", "", prices_text))

# Combine extracted data into a data frame
product_data <- data.frame(titles, descriptions, prices)

# Preview the first few rows of the data frame
head(product_data)
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Scraping by programming +

# Load RSelenium
library(RSelenium)

# Set URL
url <- "https://webscraper.io/test-sites/e-commerce/allinone"

# Initialize Selenium driver
driver <- rsDriver(verbose = FALSE)

# Create client
remote_driver <- driver$client

# Navigate to URL
remote_driver$navigate(url)

# Wait for page load
Sys.sleep(2)

# Click element by XPath
button_element <- remote_driver$findElement(using = "xpath",
 value = '//*[@id="side-menu"]/li[3]/a')
button_element$clickElement()

# Get and print new URL
url1 <- remote_driver$getCurrentUrl()
print(url1)

# Scrape data (code for scraping goes here)

# Close driver and stop server
remote_driver$close()
driver$server$stop()
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Data from databases: SQL, NoSQL

SELECT name, familyname, address FROM users WHERE user_id = 25
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Data from databases: SQL, NoSQL

SELECT * FROM users
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Data from databases: SQL, NoSQL

tbl(mydatabase, sql("SELECT name, familyname, address FROM users WHERE
 user_id = 25"))
# ──────────────────────────────────────────────────────────────


# Section: Handling electronic text
#   Subsection: Data from databases: SQL, NoSQL

myselection <- tbl(mydatabase, "users")
myselection %>%
 filter(user_id = 25) %>%
 select(name, familyname, address)
# ──────────────────────────────────────────────────────────────

