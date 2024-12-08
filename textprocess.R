# Load required libraries
library(rvest)
library(tidyverse)
library(tidytext)
library(textdata)
library(ggplot2)

# URL of the article
url <- "https://www.asianinvestor.net/article/adb-aims-to-launch-12bn-climate-finance-platform-at-cop-29/497747"

# Step 1: Web Scraping
# Extract the content of the article
page <- read_html(url)
article_text <- page %>%
  html_nodes("p") %>%   # Assuming the article text is in paragraph tags
  html_text() %>%
  paste(collapse = " ") # Combine paragraphs into a single string

# Preview the scraped text
cat("Scraped Text Preview:\n", substr(article_text, 1, 500), "...", "\n")

# Step 2: Text Cleaning
cleaned_text <- article_text %>%
  tolower() %>%                        # Convert to lowercase
  str_replace_all("[[:punct:]]", " ") %>% # Remove punctuation
  str_replace_all("\\s+", " ") %>%      # Replace multiple spaces with single space
  str_trim()                            # Trim leading/trailing spaces

# Convert cleaned text into a tibble
text_data <- tibble(line = 1, text = cleaned_text)

# Step 3: Tokenization
tokens <- text_data %>%
  unnest_tokens(word, text)

# Step 4: Remove Stop Words
data("stop_words") # Load built-in stop words
tokens <- tokens %>%
  anti_join(stop_words, by = "word")

# Step 5: Sentiment Analysis
# Use the Bing sentiment lexicon
bing_sentiments <- get_sentiments("bing")

# Join tokens with sentiment lexicon
sentiment_data <- tokens %>%
  inner_join(bing_sentiments, by = "word") %>%
  count(sentiment, sort = TRUE)

# Step 6: Visualization
# Bar plot of sentiment counts
sentiment_plot <- sentiment_data %>%
  ggplot(aes(x = sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  labs(
    title = "Sentiment Analysis of Climate Finance Article",
    x = "Sentiment",
    y = "Count",
    caption = "Source: AsianInvestor.net"
  ) +
  theme_minimal()

# Save and display the plot
ggsave("sentiment_plot.png", sentiment_plot, width = 8, height = 6)
print(sentiment_plot)

# Step 7: Word Contribution to Sentiment
# Identify words contributing to positive and negative sentiments
word_contribution <- tokens %>%
  inner_join(bing_sentiments, by = "word") %>%
  count(word, sentiment, sort = TRUE)

# Visualize top contributing words
word_plot <- word_contribution %>%
  group_by(sentiment) %>%
  slice_max(order_by = n, n = 10) %>%
  ungroup() %>%
  ggplot(aes(x = reorder(word, n), y = n, fill = sentiment)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~sentiment, scales = "free") +
  labs(
    title = "Top Words Contributing to Sentiments",
    x = "Words",
    y = "Frequency",
    caption = "Source: AsianInvestor.net"
  ) +
  theme_minimal()

# Save and display the word contribution plot
ggsave("word_contribution_plot.png", word_plot, width = 10, height = 6)
print(word_plot)

