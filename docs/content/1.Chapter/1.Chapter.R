# Section: The Tools Used
#   Subsection: Packages

# Check for installed packages
installed.packages()

# List all packages, this also checks if an update is available
old.packages()

# Update all (available) packages
update.packages()

# Update, without prompts for permission/clarification
update.packages(ask = FALSE)

# Updating only one package is like overwriting on top of the old one, it uses the same command
install.packages("package")
# ──────────────────────────────────────────────────────────────


# Section: The Tools Used
#   Subsection: Packages

numbers <- c(1, 4, 9, 16, 25)

# Square root
sqrt_numbers <- sqrt(numbers)

# Round to two decimals
rounded_numbers <- round(sqrt_numbers, 2)

# Filter numbers greater than 4
filtered_numbers <- rounded_numbers[rounded_numbers > 2]

print(filtered_numbers)
# ──────────────────────────────────────────────────────────────


# Section: The Tools Used
#   Subsection: Packages

library(magrittr)

numbers <- c(1, 4, 9, 16, 25)

filtered_numbers <- numbers %>%
 sqrt() %>% # Step 1: Take the square root
 round(2) %>% # Step 2: Round to two decimals
 .[. > 2] # Step 3: Filter numbers greater than 4

print(filtered_numbers)
# ──────────────────────────────────────────────────────────────

