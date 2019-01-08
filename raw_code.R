# Set the working directory
setwd("~/projects/week_2/")

set.seed(1234)
options(width = 100)

# libraries
library(readr)
library(tidytext)
library(dplyr)
library(stringr)
library(tidyr)
library(lexicon)
library(ggplot2)
library(textclean)
library(wordnet)
library(wordcloud)

# Exploring the Corpora

# load dataset
blog_us_raw_input_file <- "./data/en_US.blogs.txt"
twitter_us_raw_input_file <- "./data/en_US.twitter.txt"
news_us_raw_input_file <- "./data/en_US.news.txt"

#-------------------------------------------------------------------------------

# read lines
blog_us_raw <- 
  read_lines(file = blog_us_raw_input_file, n_max = -1, progress = FALSE)
twitter_us_raw <- 
  read_lines(file = twitter_us_raw_input_file, n_max = -1, progress = FALSE)
news_us_raw <- 
  read_lines(file = news_us_raw_input_file, n_max = -1, progress = FALSE)

# convert to dplyr's version of data_frame
blog_us_raw <- data_frame(obs = blog_us_raw)
twitter_us_raw <- data_frame(obs = twitter_us_raw)
news_us_raw <- data_frame(obs = news_us_raw)

# summarize
to_save <- rbind(blog_us_raw %>% mutate(`CorpusName` = "blog"), 
                 twitter_us_raw %>% mutate(`CorpusName` = "twitter"), 
                 news_us_raw %>% mutate(`CorpusName` = "news")) %>%
  group_by(`CorpusName`) %>%
  mutate(count = str_count(obs, " ")) %>%
  summarize(`NumOfObs` = n(),
            `MeanWordCount` = (sum(count) / n()),
            `Preview` = first(obs))
write_csv(to_save, path = "./data/01_exploring_the_corpora.csv")
read_csv("./data/01_exploring_the_corpora.csv", 
         col_names = TRUE, 
         col_types = cols(`CorpusName` = col_character(),
                          `NumOfObs` = col_double(),
                          `MeanWordCount` = col_double(),
                          `Preview` = col_character()))

#------------------------------------------------------------------------------

# B. Finding the Right Amount of Sample from each Corpus

# NOTES
# for unnest_tokens:
# • Other columns, such as the line number each word came from, are retained.
# • Punctuation has been stripped.
# • By default, unnest_tokens() converts the tokens to lowercase, which makes
# them easier to compare or combine with other datasets.
tokenize_ngram <- function(data, n = 1, retokenize = FALSE) {
  if (retokenize == TRUE) {
    ngrams <- data %>%
      unnest_tokens(output = ngrams, 
                    input = ngrams, 
                    token = "ngrams",
                    n = n,
                    to_lower = TRUE)
  } else {
    ngrams <- data %>%
      unnest_tokens(output = ngrams, 
                    input = lines, 
                    token = "ngrams",
                    n = n,
                    to_lower = TRUE)
  }
  
  return(ngrams)
}

# Get unique words in corpora
# This is useful to determine the baseline for finding the best sample size to 
# represent the English language.
get_unique_tokens <- function(input_file_location, size = 1) {
  raw_lines <- read_lines(file = input_file_location, n_max = -1, 
                          progress = FALSE)
  
  # convert raw data to data_frame that adheres to tidy format
  raw_df <- data_frame(lines = raw_lines)
  
  # get a fraction of raw df (default is 100%)
  sample_df <- sample_frac(tbl = raw_df, size = size)
  
  # tokenize corpus 1-gram
  one_gram <- tokenize_ngram(data = sample_df, n = 1)
  
  unique_tokens <- one_gram %>% unique()
  
  return(unique_tokens)
}

# Create a custom special operator in R that is the opposite of %in%
'%!in%' <- function(x, y) {
  !('%in%'(x,y))
}

# for each corpus, find unique tokens
blog_unique <- get_unique_tokens(input_file_location = blog_us_raw_input_file)
twitter_unique <- get_unique_tokens(input_file_location = twitter_us_raw_input_file)
news_unique <- get_unique_tokens(input_file_location = news_us_raw_input_file)
# for the whole english corpora (blog, twitter and news tokens altogether)
english_unique <- data_frame(
  ngrams = c(blog_unique$ngrams, twitter_unique$ngrams, news_unique$ngrams) %>%
    unique()
)
# number of words in grady augmented dataset that are present in english corpora
num_of_english_tokens <- sum(grady_augmented %in% english_unique$ngrams)
# number of words in grady augmented dataset that are NOT present in english 
# corpora
num_of_non_englis_tokens <- sum(grady_augmented %!in% english_unique) # 47856 

# The question is:
# How many unique words do you need in a frequency sorted dictionary to cover 
# 50% of all word instances in the language? 90%?
# grady augmented has 122806 unique english words
# 50% of it is 61403
# the sample must at least capture 61403 valid english words
# Can we do that for 10%, 20%, 25%?

to_save <- rbind(
  english_unique %>% 
    mutate(`Corpus Name` = "all"),
  blog_unique %>% 
    mutate(`Corpus Name` = "blog"),
  twitter_unique %>% 
    mutate(`Corpus Name` = "twitter"),
  news_unique %>% 
    mutate(`Corpus Name` = "news")
) %>%
  group_by(`Corpus Name`) %>%
  summarize(`Count Valid English Words` = sum(grady_augmented %in% ngrams))
write_csv(to_save, path = "./data/02_finding_the_right_sample_part_2.csv")
read_csv("./data/02_finding_the_right_sample_part_2.csv",
         col_names = TRUE, 
         col_types = cols(
           `Corpus Name` = col_character(),
           `Count Valid English Words` = col_double()
         ))

# we see that there are 67621 valid english words in the blog dataset. 
# There are 60448 valid english words in the news dataset and there are only 
# 55935 valid english words in the twitter dataset.
# All of these are based on the grady augmented dictionary.

# our task is to determine if we can achieve 61403 valid English words if we chose
# to sample 10%, 20% or 25% from every corpus.

# all corpuses have a total of 74950 unique and valid english words.
# Let us sample each of them intuitively to get better representation.
# formula is: 
# (number of valid english words per corpus) / (number of valid english words from the corpora) * percent sample

to_save <- rbind(
  blog_unique %>% 
    mutate(corpus_name = "blog"),
  twitter_unique %>% 
    mutate(corpus_name = "twitter"),
  news_unique %>% 
    mutate(corpus_name = "news")
) %>%
  group_by(corpus_name) %>%
  summarize(`num_valid_english_words` = sum(grady_augmented %in% ngrams),
            `for 10% sample` = `num_valid_english_words` / 74950 * 0.10,
            `for 20% sample` = `num_valid_english_words` / 74950 * 0.20,
            `for 25% sample` = `num_valid_english_words` / 74950 * 0.25,
            `for 30% sample` = `num_valid_english_words` / 74950 * 0.30) %>%
  mutate(`num_valid_english_words` = NULL)
write_csv(to_save, path = "./data/02_finding_the_right_sample_part_3.csv")
read_csv("./data/02_finding_the_right_sample_part_3.csv", 
         col_names = TRUE, 
         col_types = cols(
           corpus_name = col_character(),
           `for 10% sample` = col_double(),
           `for 20% sample` = col_double(),
           `for 25% sample` = col_double(),
           `for 30% sample` = col_double()
         ))

# SAMPLING USING DISTRIBUTION OF PERCENTAGE GROUPS ABOVE
sample_each_corpus_and_return_unique_english_word_count <- 
  function(for_blog, for_twitter, for_news) {
    # for each corpus
    blog_unique_sample <- get_unique_tokens(
      input_file_location = blog_us_raw_input_file, size = for_blog)
    twitter_unique_sample <- get_unique_tokens(
      input_file_location = twitter_us_raw_input_file, size = for_twitter)
    news_unique_sample <- get_unique_tokens(
      input_file_location = news_us_raw_input_file, size = for_news)
    english_unique_sample <- c(blog_unique_sample, twitter_unique_sample, 
                               news_unique_sample) %>% unique()
    
    # compile into one data_frame
    english_unique <- data_frame(
      ngrams = c(blog_unique_sample$ngrams, twitter_unique_sample$ngrams, 
                 news_unique_sample$ngrams) %>%
        unique()
    )
    
    num_of_english_tokens <- sum(grady_augmented %in% english_unique$ngrams)
    
    return(num_of_english_tokens)
  }

for_10_percent_sample <-
  sample_each_corpus_and_return_unique_english_word_count(
    for_blog = 0.09, for_twitter = 0.07, for_news = 0.08)
for_20_percent_sample <-
  sample_each_corpus_and_return_unique_english_word_count(
    for_blog = 0.18, for_twitter = 0.15, for_news = 0.16)
for_25_percent_sample <-
  sample_each_corpus_and_return_unique_english_word_count(
    for_blog = 0.23, for_twitter = 0.19, for_news = 0.20)
for_30_percent_sample <-
  sample_each_corpus_and_return_unique_english_word_count(
    for_blog = 0.27, for_twitter = 0.22, for_news = 0.24)
to_save <- data_frame(
  `for 10 percent sample` = for_10_percent_sample,
  `for 20 percent sample` = for_20_percent_sample,
  `for 25 percent sample` = for_25_percent_sample,
  `for 30 percent sample` = for_30_percent_sample
) %>%
  gather(key = "Sample Size Per Corpus", 
         value = "Number of Valid English Tokens") %>%
  mutate(`Is Greater Than 61403` = 
           ifelse(`Number of Valid English Tokens` > 61403, "YES", "NO"))
write_csv(to_save, path = "./data/02_finding_the_right_sample_part_4.csv")
read_csv("./data/02_finding_the_right_sample_part_4.csv", 
         col_names = TRUE, 
         col_types = cols(
           `Sample Size Per Corpus` = col_character(),
           `Number of Valid English Tokens` = col_double(),
           `Is Greater Than 61403` = col_character()
         ))

# Now we can see that 30% of each corpus must be sampled to cover 50% of the 
# English language. Since it is adjusted due to the intrinsic properties of each
# raw corpus in terms of valid terms present based on Grady Augmented dictionary.

#------------------------------------------------------------------------------

# tokenize ngram function can be found above.

separate_ngrams <- function(data, n) {
  if (n == 1) {
    print("Only two or more words are accepted.")
    return()
  } 
  
  colnames = character()
  for(i in 1:n) {
    colnames <- c(colnames, paste("word", i, sep = ""))
  }
  
  # separate n-grams into columns
  ngrams_separated <- ngrams %>%
    separate(ngrams, colnames, sep = " ")
}

remove_tokens_with_numbers <- function(tokenized_corpus) {
  # remove tokens that are pure digits
  # stop words numbers
  custom_stop_words_digits <- 
    tokenized_corpus %>%
    filter(str_detect(ngrams, "\\w*[0-9]+\\w*\\s*")) %>%
    pull(var = ngrams) %>%
    unique()
  
  # convert to data_frame
  custom_stop_words_digits <- data_frame(word = custom_stop_words_digits)
  
  # remove pure number tokens
  pure_number_token_removed <- tokenized_corpus %>%
    anti_join(custom_stop_words_digits, by = c("ngrams" = "word"))
  
  return(pure_number_token_removed)
}

remove_profane_tokens <- function(tokenized_corpus) {
  # stop words profanity
  # unique profane words from the following sources:
  # (1) Alejandro U. Alvarez's List of Profane Words
  # (2) Stackoverflow user2592414's List of Profane Words
  # (3) bannedwordlist.com's List of Profane Words
  # (4) Google's List of Profane Words
  custom_stop_words_profanity <- 
    rbind(
      data_frame(word = profanity_alvarez)[, 1],
      data_frame(word = profanity_arr_bad)[, 1],
      data_frame(word = profanity_banned)[, 1],
      data_frame(word = profanity_racist)[, 1],
      data_frame(word = profanity_zac_anger)[, 1]
    ) %>%
    unique()
  
  profane_words_removed <- 
    tokenized_corpus %>%
    anti_join(custom_stop_words_profanity, by = c("ngrams" = "word"))
  
  return(profane_words_removed)
}

remove_tokens_with_special_characters <- function(tokenized_corpus) {
  # remove tokens with any special characters
  # EXCEPT APOSTROPHE
  
  custom_stop_words_special_characters <- 
    tokenized_corpus %>%
    filter(str_detect(ngrams, "[^('\\p{Alphabetic}{1,})[:^punct:]]")) %>%
    pull(var = ngrams) %>%
    unique()
  
  if (length(custom_stop_words_special_characters) == 0) {
    print("No special characters found")
    return()
  }
  
  # convert to data_frame
  custom_stop_words_special_characters <- 
    data_frame(word = custom_stop_words_special_characters)
  
  # remove pure number tokens
  special_characters_token_removed <- tokenized_corpus %>%
    anti_join(custom_stop_words_special_characters, by = c("ngrams" = "word"))
  
  return(special_characters_token_removed)
}

# key contractions
# custom key contractions (second iteration).
# see Appendix below for details on how we got here
custom_key_contractions_second_iteration <- function() {
  # custom_key_contractions
  custom_key_contractions <- key_contractions
  custom_key_contractions <- 
    rbind(custom_key_contractions, 
          # FIRST ITERATION
          # contractions from first iteration (blog)
          c(contraction = "here's", expanded = "here is"),
          c(contraction = "it'd", expanded = "it would"),
          c(contraction = "that'd", expanded = "that would"),
          c(contraction = "there'd", expanded = "there would"),
          c(contraction = "y'all", expanded = "you and all"),
          c(contraction = "needn't", expanded = "need not"),
          c(contraction = "gov't", expanded = "government"),
          c(contraction = "n't", expanded = "not"),
          c(contraction = "ya'll", expanded = "you and all"),
          c(contraction = "those'll", expanded = "those will"),
          c(contraction = "this'll", expanded = "this will"),
          c(contraction = "than'll", expanded = "than will"),
          c(contraction = "c'mon", expanded = "come on"),
          c(contraction = "qur'an", expanded = "quran"),
          # additional from twitter
          c(contraction = "where'd", expanded = "where would"),
          c(contraction = "con't", expanded = "continued"),
          c(contraction = "nat'l", expanded = "national"),
          c(contraction = "int'l", expanded = "international"),
          c(contraction = "i'l", expanded = "i will"),
          c(contraction = "li'l", expanded = "little"),
          c(contraction = "add'l", expanded = "additional"),
          c(contraction = "ma'am", expanded = "madam"),
          # SECOND ITERATION
          # additional from blog
          c(contraction = "y'know", expanded = "you know"),
          c(contraction = "not've", expanded = "not have"),
          c(contraction = "that've", expanded = "that have"),
          c(contraction = "should've", expanded = "should have"),
          c(contraction = "may've", expanded = "may have"),
          c(contraction = "ne'er", expanded = "never"),
          c(contraction = "e're", expanded = "ever"),
          c(contraction = "whene'er", expanded = "whenever"),
          # additional from twitter
          c(contraction = "cont'd", expanded = "continued"),
          c(contraction = "how're", expanded = "how are"),
          c(contraction = "there're", expanded = "there are"),
          c(contraction = "where're", expanded = "when are"),
          c(contraction = "why're", expanded = "why are"),
          c(contraction = "that're", expanded = "that are"),
          c(contraction = "how've", expanded = "how have"),
          c(contraction = "there've", expanded = "there have"),
          c(contraction = "may've", expanded = "may have"),
          c(contraction = "she've", expanded = "she have"),
          c(contraction = "all've", expanded = "all have"),
          # additional from news
          c(contraction = "hawai'i", expanded = "hawaii"))
  
  return(custom_key_contractions)
}


expand_contracted_tokens <- 
  function (tokenized_corpus, custom_key_contractions) {
    # expand contracted tokens using custom key contractions supplied by the 
    # calling function
    tokenized_corpus <- 
      tokenized_corpus %>%
      mutate(end = str_match(ngrams, "'{1}\\D{1,5}$")) %>%
      group_by(is_na = is.na(end)) %>%
      mutate(ngrams = ifelse(is_na, ngrams, 
                             replace_contraction(ngrams, 
                                                 contraction.key = 
                                                   custom_key_contractions))) %>%
      mutate(end = NULL) %>%
      ungroup() %>%
      mutate(is_na = NULL)
    
    # since some tokens are expanded into at least two words, we need to 
    # retokenize it into 1-gram
    tokenized_corpus <- tokenize_ngram(tokenized_corpus, n = 1, retokenize = TRUE)
    
    return(tokenized_corpus)
  }

tokenize_and_clean_corpus <- 
  function(input_file_location, size = 0.25, 
           custom_key_contractions = key_contractions,
           english_language = grady_augmented) {
    set.seed(1234)
    raw_lines <- read_lines(file = input_file_location, n_max = -1, progress = FALSE)
    
    # convert raw data to data_frame that adheres to tidy format
    raw_df <- data_frame(lines = raw_lines)
    
    # get a fraction of raw df (default is 25%)
    sample_df <- sample_frac(tbl = raw_df, size = size)
    
    # tokenize corpus 1-gram
    one_gram <- tokenize_ngram(data = sample_df, n = 1)
    
    # convert apostrophe [’] to 0027
    one_gram <- 
      one_gram %>%
      mutate(ngrams = gsub(pattern = "’", "'", ngrams))
    
    # remove tokens with numbers
    one_gram <- remove_tokens_with_numbers(one_gram)
    
    # remove tokens with special characters
    one_gram <- remove_tokens_with_special_characters(one_gram)
    
    # remove tokens that are profane
    one_gram <- remove_profane_tokens(one_gram)
    
    # Expand contracted tokens using the default key_contractions dataset from
    # lexicon package
    one_gram_expanded <- 
      expand_contracted_tokens(one_gram, 
                               custom_key_contractions = custom_key_contractions)
    
    # add column that would initially determine if the word is english or not
    one_gram_expanded <-
      one_gram_expanded %>%
      mutate(is_english = ngrams %in% english_language)
    
    return(one_gram_expanded)
  }

# SET THE WORKING DIRECTORY
# working directory and corpus locations can be found on the preceding sections

# get custom key contractions
custom_key_contractions <- custom_key_contractions_second_iteration()

# tokenize and clean corpora
# for blog corpus
blog_tokenized_and_cleaned <- 
  tokenize_and_clean_corpus(input_file_location = blog_us_raw_input_file, 
                            custom_key_contractions = custom_key_contractions,
                            size = 0.27)
# for twitter corpus
twitter_tokenized_and_cleaned <-
  tokenize_and_clean_corpus(input_file_location = twitter_us_raw_input_file, 
                            custom_key_contractions = custom_key_contractions,
                            size = 0.22)
# for news corpus
news_tokenized_and_cleaned <-
  tokenize_and_clean_corpus(input_file_location = news_us_raw_input_file,
                            custom_key_contractions = custom_key_contractions,
                            size = 0.24)
to_save <- head(blog_tokenized_and_cleaned[
  blog_tokenized_and_cleaned$is_english == FALSE, ], n = 10)
write_csv(to_save, path = "./data/03_cleaning_the_corpus_part_1.csv")
read_csv("./data/03_cleaning_the_corpus_part_1.csv", 
         col_names = TRUE, 
         cols(
           ngrams = col_character(),
           is_english = col_logical()
         ))

to_save <- head(twitter_tokenized_and_cleaned[
  twitter_tokenized_and_cleaned$is_english == FALSE, ], n = 10)
write_csv(to_save, path = "./data/03_cleaning_the_corpus_part_2.csv")
read_csv("./data/03_cleaning_the_corpus_part_2.csv", 
         col_names = TRUE, 
         cols(
           ngrams = col_character(),
           is_english = col_logical()
         ))

to_save <- head(news_tokenized_and_cleaned[
  news_tokenized_and_cleaned$is_english == FALSE, ], n = 10)
write_csv(to_save, path = "./data/03_cleaning_the_corpus_part_3.csv")
read_csv("./data/03_cleaning_the_corpus_part_3.csv", 
         col_names = TRUE, 
         cols(
           ngrams = col_character(),
           is_english = col_logical()
         ))

#------------------------------------------------------------------------------

# Find if the remaining false english terms (via Grady Augmented) is in fact 
# English according to WordNet
in_wordnet <- function(w, pos =  c("ADJECTIVE", "ADVERB", "NOUN", "VERB")) {
  for (x in pos) {
    filter <- getTermFilter("ExactMatchFilter", w, TRUE)
    terms <- getIndexTerms(x, 5, filter)
    if (!is.null(terms)) return(TRUE)
  }
  return(FALSE)
}
in_wordnet_vectorized <- Vectorize(in_wordnet, vectorize.args = c("w", "pos"))

# for blog
blog_recheck_non_english_terms_using_wordnet <-
  blog_tokenized_and_cleaned %>%
  filter(is_english == FALSE) %>%
  group_by(ngrams) %>%
  count(ngrams, sort = TRUE) %>%
  filter(n > 10) %>%
  mutate(n = NULL,
         is_english = in_wordnet_vectorized(ngrams))
write_csv(blog_recheck_non_english_terms_using_wordnet, 
          path = "./data/blog_recheck_non_english_terms_using_wordnet.csv")

to_save <- head(blog_recheck_non_english_terms_using_wordnet, n = 10)
write_csv(to_save, path = "./data/03_cleaning_the_corpus_part_4.csv")
read_csv("./data/03_cleaning_the_corpus_part_4.csv", 
         col_names = TRUE, 
         col_types = cols(
           ngrams = col_character(),
           is_english = col_logical()
         ))

# for twitter
twitter_recheck_non_english_terms_using_wordnet <-
  twitter_tokenized_and_cleaned %>%
  filter(is_english == FALSE) %>%
  group_by(ngrams) %>%
  count(ngrams, sort = TRUE) %>%
  filter(n > 10) %>%
  mutate(n = NULL,
         is_english = in_wordnet_vectorized(ngrams))
write_csv(twitter_recheck_non_english_terms_using_wordnet, 
          path = "./data/twitter_recheck_non_english_terms_using_wordnet.csv")

to_save <- head(twitter_recheck_non_english_terms_using_wordnet, n = 10)
write_csv(to_save, path = "./data/03_cleaning_the_corpus_part_5.csv")
read_csv("./data/03_cleaning_the_corpus_part_5.csv", 
         col_names = TRUE, 
         col_types = cols(
           ngrams = col_character(),
           is_english = col_logical()
         ))
         
    
# for news
news_recheck_non_english_terms_using_wordnet <-
  news_tokenized_and_cleaned %>%
  filter(is_english == FALSE) %>%
  group_by(ngrams) %>%
  count(ngrams, sort = TRUE) %>%
  filter(n > 10) %>%
  mutate(n = NULL,
         is_english = in_wordnet_vectorized(ngrams))
write_csv(news_recheck_non_english_terms_using_wordnet, 
          path = "./data/news_recheck_non_english_terms_using_wordnet.csv")

to_save <- head(news_recheck_non_english_terms_using_wordnet, n = 10)
write_csv(to_save, path = "./data/03_cleaning_the_corpus_part_6.csv")
read_csv("./data/03_cleaning_the_corpus_part_6.csv", 
         col_names = TRUE, 
         col_types = cols(
           ngrams = col_character(),
           is_english = col_logical()
         ))

#-----------------------------------------------------------------------------------

# Verify if token with apostrophe s are english using grady augmented and wordnet
# If the condition is true for either Grady Augmented or WordNet, 
# consider the token as english.
verify_tokens_with_apostrophe_s_if_english <- function(contraction, one_gram) {
  contraction <- paste(contraction, "$", sep = "")
  tokens_outside_grady_augmented <-
    one_gram %>%
    mutate(end = str_match(ngrams, contraction)) %>%
    filter(!is.na(end)) %>%
    count(ngrams, sort = TRUE) %>%
    mutate(base_word = gsub(pattern = "'s", replacement = "", ngrams)) %>%
    filter(n > 1) %>%
    mutate(is_english_grady = base_word %in% grady_augmented,
           is_english_wordnet = in_wordnet_vectorized(base_word))
  return(tokens_outside_grady_augmented)
}

apostrophe_s_blog <- 
  verify_tokens_with_apostrophe_s_if_english(contraction = "'s",
                                             one_gram = blog_tokenized_and_cleaned)
apostrophe_s_twitter <- 
  verify_tokens_with_apostrophe_s_if_english(contraction = "'s",
                                             one_gram = twitter_tokenized_and_cleaned)
apostrophe_s_news <- 
  verify_tokens_with_apostrophe_s_if_english(contraction = "'s",
                                             one_gram = news_tokenized_and_cleaned)

# see unique and valid english tokens for all corpus
valid_english_tokens_with_apostrophe_s <- bind_rows(
  apostrophe_s_blog %>%
  filter(is_english_grady == TRUE | is_english_wordnet == TRUE) %>%
  select(ngrams),
  apostrophe_s_twitter %>%
  filter(is_english_grady == TRUE | is_english_wordnet == TRUE) %>%
  select(ngrams),
  apostrophe_s_news %>%
  filter(is_english_grady == TRUE | is_english_wordnet == TRUE) %>%
  select(ngrams)
) %>%
  distinct(ngrams)
write_csv(valid_english_tokens_with_apostrophe_s, 
          path = "./data/valid_english_tokens_with_apostrophe_s.csv")
to_save <- head(valid_english_tokens_with_apostrophe_s)
write_csv(to_save, path = "./data/03_cleaning_the_corpus_part_7.csv")
read_csv("./data/03_cleaning_the_corpus_part_7.csv", 
         col_names = TRUE, 
         col_types = cols(
           ngrams = col_character())
         )

#----------------------------------------------------------------------------

# Custom English dictionary using tokens evaluated by both Grady Augmented
# and WordNet API as well as tokens with apostrophe s suffixes that are also
# evaluated by the said dictionaries.
additional_tokens <- bind_rows(
  blog_recheck_non_english_terms_using_wordnet %>%
    filter(is_english == TRUE) %>%
    mutate(is_english = NULL),
  twitter_recheck_non_english_terms_using_wordnet %>%
    filter(is_english == TRUE) %>%
    mutate(is_english = NULL),
  news_recheck_non_english_terms_using_wordnet %>%
    filter(is_english == TRUE) %>%
    mutate(is_english = NULL)
) %>%
  bind_rows(
    valid_english_tokens_with_apostrophe_s
  ) %>%
  distinct(ngrams)

# bind additional tokens to grady augmented
custom_english_dictionary <- 
  data_frame(
    ngrams = c( grady_augmented, additional_tokens$ngrams)
  )
# save to file
write_csv(custom_english_dictionary, 
          path = "./data/custom_english_dictionary.csv")

# Use the custom_english_dictionary and custom_key_contractions to reclean
# blog, twitter and news corpora (0.27, 0.22, 0.24)
blog_cleaned <- tokenize_and_clean_corpus(
  input_file_location = blog_us_raw_input_file, 
  size = 0.27, 
  custom_key_contractions = custom_key_contractions, 
  english_language = custom_english_dictionary$ngrams)
# save to file
write_csv(blog_cleaned, 
          path = "./data/blog_cleaned.csv")

twitter_cleaned <- tokenize_and_clean_corpus(
  input_file_location = twitter_us_raw_input_file, 
  size = 0.22, 
  custom_key_contractions = custom_key_contractions, 
  english_language = custom_english_dictionary$ngrams)
# save to file
write_csv(twitter_cleaned, 
          path = "./data/twitter_cleaned.csv")

news_cleaned <- tokenize_and_clean_corpus(
  input_file_location = news_us_raw_input_file, 
  size = 0.24, 
  custom_key_contractions = custom_key_contractions, 
  english_language = custom_english_dictionary$ngrams)
# save to file
write_csv(news_cleaned, 
          path = "./data/news_cleaned.csv")


#------------------------------------------------------------------------------

# see top 10 non-english words for blog
to_save <- blog_cleaned %>%
  filter(is_english == FALSE) %>%
  mutate(is_english = NULL) %>%
  top_n(10, ngrams)
write_csv(to_save, path = "./data/04_results_and_insights_part_1.csv")
read_csv("./data/04_results_and_insights_part_1.csv", col_names = TRUE, 
         col_types = cols(
           ngrams = col_character()
         ))

# see top 10 non-english words for twitter
to_save <- twitter_cleaned %>%
  filter(is_english == FALSE) %>%
  mutate(is_english = NULL) %>%
  top_n(10, ngrams)
write_csv(to_save, path = "./data/04_results_and_insights_part_2.csv")
read_csv("./data/04_results_and_insights_part_2.csv", col_names = TRUE, 
         col_types = cols(
           ngrams = col_character()
         ))

# see top 10 non-english words for news
to_save <- news_cleaned %>%
  filter(is_english == FALSE) %>%
  mutate(is_english = NULL) %>%
  top_n(10, ngrams)
write_csv(to_save, path = "./data/04_results_and_insights_part_3.csv")
read_csv("./data/04_results_and_insights_part_3.csv", col_names = TRUE, 
         col_types = cols(
           ngrams = col_character()
         ))

#------------------------------------------------------------------------------

# Count the number of non-English words per corpus
bind_rows(
  blog_cleaned %>%
    mutate(`Corpus Name` = "blog"),
  twitter_cleaned %>%
    mutate(`Corpus Name` = "twitter"),
  news_cleaned %>%
    mutate(`Corpus Name` = "news")
) %>%
  mutate(`Category` = ifelse(is_english, "English", "Not English"),
         is_english = NULL) %>%
  group_by(`Corpus Name`, `Category`) %>%
  summarize(`Count` = n()) %>%
  ggplot(aes(y = Count, x = `Corpus Name`, fill = Category)) + 
  geom_bar(stat="identity") +
  labs(y = NULL, x = "Distribution of English and Not English Tokens Per Corpus")


#------------------------------------------------------------------------------
# convert cleaned corpus to n-grams
# blog
blog_one_gram <- blog_cleaned %>%
  filter(is_english == TRUE) %>%
  mutate(is_english = NULL)
blog_two_gram <- tokenize_ngram(data = blog_one_gram, n = 2, retokenize = TRUE)
blog_three_gram <- tokenize_ngram(data = blog_one_gram, n = 3, retokenize = TRUE)
blog_four_gram <- tokenize_ngram(data = blog_one_gram, n = 4, retokenize = TRUE)

# twitter
twitter_one_gram <- twitter_cleaned %>%
  filter(is_english == TRUE) %>%
  mutate(is_english = NULL)
twitter_two_gram <- tokenize_ngram(data = twitter_one_gram, n = 2, retokenize = TRUE)
twitter_three_gram <- tokenize_ngram(data = twitter_one_gram, n = 3, retokenize = TRUE)
twitter_four_gram <- tokenize_ngram(data = twitter_one_gram, n = 4, retokenize = TRUE)

# news
news_one_gram <- news_cleaned %>%
  filter(is_english == TRUE) %>%
  mutate(is_english = NULL)
news_two_gram <- tokenize_ngram(data = news_one_gram, n = 2, retokenize = TRUE)
news_three_gram <- tokenize_ngram(data = news_one_gram, n = 3, retokenize = TRUE)
news_four_gram <- tokenize_ngram(data = news_one_gram, n = 4, retokenize = TRUE)

# TOP 10 Words Per Corpus
visualize_top_n_words_per_corpus <-
  function(tokenized_corpus, words_per_token, top_n = 10) {
    library(grid)
    library(gridExtra)
    
    ngrams_name <- ifelse(words_per_token == 1, "One-Grams", 
                     ifelse(words_per_token == 2, "Two-Grams", 
                     ifelse(words_per_token == 3, "Three-Grams", 
                     ifelse(words_per_token == 4, "Four-Grams", NULL))))
    
    i <- 2
    colors <- c("#F44336", "#2196F3", "#8BC34A", "#9C27B0")
    corpus_names <- c("All", "Blog", "Twitter", "News")
    plots <- list()
    plots[[1]] <- textGrob(paste("Most Frequent ", ngrams_name, " Per Corpus", 
                                 sep = ""))
    for(corpus_name in  corpus_names) {
      plots[[i]] <-
        tokenized_corpus %>%
        filter(CorpusName == corpus_name) %>%
        group_by(CorpusName) %>%
        count(ngrams, sort = TRUE) %>%
        top_n(top_n, n) %>%
        ggplot(aes(reorder(ngrams, n), n)) +
        geom_col(show.legend = FALSE, fill = colors[i - 1]) +
        labs(x = NULL, y = corpus_name) +
        coord_flip()
        
      i <- i + 1
    }
    
    grid.arrange(plots[[1]], plots[[2]], plots[[3]], plots[[4]], plots[[5]],
                 nrow = 3, layout_matrix = rbind(c(1, 1), c(2, 3), c(4, 5)),
                 heights = c(1, 5, 5), widths = c(10, 10))
  }

# for one-grams
one_gram_tokens <-
  bind_rows(
    blog_one_gram %>%
      mutate(CorpusName = "Blog"),
    twitter_one_gram %>%
      mutate(CorpusName = "Twitter"),
    news_one_gram %>%
       mutate(CorpusName = "News"),
    bind_rows(
      blog_one_gram,
      twitter_one_gram,
      news_one_gram
    ) %>%
      mutate(CorpusName = "All")
  )

# for two-grams
two_gram_tokens <-
  bind_rows(
    blog_two_gram %>%
      mutate(CorpusName = "Blog"),
    twitter_two_gram %>%
      mutate(CorpusName = "Twitter"),
    news_two_gram %>%
      mutate(CorpusName = "News"),
    bind_rows(
      blog_two_gram,
      twitter_two_gram,
      news_two_gram
    ) %>%
      mutate(CorpusName = "All")
  )

# for three-grams
three_gram_tokens <-
  bind_rows(
    blog_three_gram %>%
      mutate(CorpusName = "Blog"),
    twitter_three_gram %>%
      mutate(CorpusName = "Twitter"),
    news_three_gram %>%
      mutate(CorpusName = "News"),
    bind_rows(
      blog_three_gram,
      twitter_three_gram,
      news_three_gram
    ) %>%
      mutate(CorpusName = "All")
  )

# for four-grams
four_gram_tokens <-
  bind_rows(
    blog_four_gram %>%
      mutate(CorpusName = "Blog"),
    twitter_four_gram %>%
      mutate(CorpusName = "Twitter"),
    news_four_gram %>%
      mutate(CorpusName = "News"),
    bind_rows(
      blog_four_gram,
      twitter_four_gram,
      news_four_gram
    ) %>%
      mutate(CorpusName = "All")
  )

visualize_top_n_words_per_corpus(tokenized_corpus = one_gram_tokens, 
                                 words_per_token = 1, top_n = 10)
visualize_top_n_words_per_corpus(tokenized_corpus = two_gram_tokens, 
                                 words_per_token = 2, top_n = 10)
visualize_top_n_words_per_corpus(tokenized_corpus = three_gram_tokens, 
                                 words_per_token = 3, top_n = 10)
visualize_top_n_words_per_corpus(tokenized_corpus = four_gram_tokens, 
                                 words_per_token = 4, top_n = 10)

#------------------------------------------------------------------------------

# Appendix 1:

# Tokenize_and_clean_corpus function can be found on the code section of in section II-C
# See Section II-B for the more information on sample sizes
# for blog corpus
blog_tokenized_and_cleaned <- 
  tokenize_and_clean_corpus(input_file_location = blog_us_raw_input_file, 
                            size = 0.27)
# for twitter corpus
twitter_tokenized_and_cleaned <-
  tokenize_and_clean_corpus(input_file_location = twitter_us_raw_input_file, 
                            size = 0.22)
# for news corpus
news_tokenized_and_cleaned <-
  tokenize_and_clean_corpus(input_file_location = news_us_raw_input_file,
                            size = 0.24)


get_top_n_most_common_word_contractions <- 
  function(tokenized_corpus, n = 10, corpus_name) {
    top_n_most_common_word_contractions <- tokenized_corpus %>%
      filter(is_english != TRUE) %>%
      mutate(end = str_match(ngrams, "'{1}\\D{1,5}$")) %>%
      filter(!is.na(end)) %>%
      group_by(end) %>%
      count(end, sort = TRUE) %>%
      ungroup() %>%
      head(n) %>%
      arrange(desc(n))
    
    # plot most common word contractions
    plot <- top_n_most_common_word_contractions %>%
      ggplot(aes(x = reorder(end, n), y = log10(n))) +
      geom_col(show.legend = FALSE, fill = "#2196F3") +
      labs(y = toupper(paste("Top ", n, " most common word contractions of\n", 
                             corpus_name, " corpus on a log10 scale", sep = "")), 
           x = NULL) +
      coord_flip() +
      theme_light()
    
    to_return <- list()
    to_return$contractions <- top_n_most_common_word_contractions$end
    to_return$plot <- plot
    
    # return plot and data
    return(to_return)
  }

plot_top_n_words_corresponding_to_contractions_supplied <-
  function(tokenized_corpus, str_contractions, n = 10, corpus_name) {
    
    i <- 1
    
    contractions_outside_grady_augmented <- data_frame()
    # add a dollar sign at the end for regex
    for(str_contraction in  str_contractions) {
      contraction <- paste(str_contraction, "$", sep = "")
      
      tokens_outside_grady_augmented <-
        tokenized_corpus %>%
        filter(is_english == FALSE) %>%
        mutate(end = str_match(ngrams, contraction)) %>%
        filter(!is.na(end)) %>%
        count(ngrams, sort = TRUE) %>%
        mutate(ngrams = factor(ngrams, levels = ngrams, ordered = FALSE)) %>%
        head(n) %>%
        mutate(contraction = 
                 toupper(paste(letters[i], ". ", str_contraction, sep = "")))
      
      contractions_outside_grady_augmented <-
        rbind(contractions_outside_grady_augmented,
              tokens_outside_grady_augmented)
      
      i <- i + 1
    }
    
    contractions_outside_grady_augmented %>%
      ggplot(aes(reorder(ngrams, n), n, fill = contraction)) +
      geom_col(show.legend = FALSE) +
      labs(x = NULL, 
           y = toupper(paste(corpus_name, ": Top ", n, 
                             " Most Common Words Corresponding to \nTop ", n, 
                             " Word Contractions", sep = ""))) +
      facet_wrap(~contraction, ncol = 5, scales = "free") +
      coord_flip()
  }

# analyze remaining contractions
analyze_remaining_contractions <- 
  function(tokenized_corpus, n = 10, corpus_name) {
    
    remaining_contractions <- list()
    
    top_n_contractions <- 
      get_top_n_most_common_word_contractions(
        tokenized_corpus = tokenized_corpus, n = n, corpus_name = corpus_name)
    
    remaining_contractions$top_n_contractions <- top_n_contractions$contractions
    remaining_contractions$top_n_contractions_plot <- top_n_contractions$plot
    
    # Plotting top n words corresponding to top n contractions
    top_n_words_per_contraction_plot <-
      plot_top_n_words_corresponding_to_contractions_supplied(
        tokenized_corpus = tokenized_corpus, 
        str_contractions = top_n_contractions$contractions, 
        n = n, corpus_name = corpus_name)
    
    remaining_contractions$top_n_words_per_contraction_plot <-
      top_n_words_per_contraction_plot
    
    return(remaining_contractions)
  }

# FOR BLOG
blog_remaining_contractions <- analyze_remaining_contractions(
  tokenized_corpus = blog_tokenized_and_cleaned,
  n = 10, corpus_name = "blog")
# plot top 10 contractions
blog_remaining_contractions$top_n_contractions_plot
# plot most common words per contraction
blog_remaining_contractions$top_n_words_per_contraction_plot
# FOR TWITTER
twitter_remaining_contractions <-analyze_remaining_contractions(
  tokenized_corpus = twitter_tokenized_and_cleaned, n = 10, 
  corpus_name = "twitter")
# plot top 10 contractions
twitter_remaining_contractions$top_n_contractions_plot
# plot most common words per contraction
twitter_remaining_contractions$top_n_words_per_contraction_plot
# FOR NEWS
news_remaining_contractions <-analyze_remaining_contractions(
  tokenized_corpus = news_tokenized_and_cleaned, n = 10, 
  corpus_name = "news")
# plot top 10 contractions
news_remaining_contractions$top_n_contractions_plot
# plot most common words per contraction
news_remaining_contractions$top_n_words_per_contraction_plot


# compiling unique word contractions
custom_key_contractions_first_iteration <- function() {
  # REPLACE WORD CONTRACTIONS
  # Using custom_key_contractions
  # more information below at Appendix 1.
  
  # blog (first iteration)
  # s, 'd, 'all, 't, 'll, 'mon, 'brien, 'er, 'am
  # for 's <- here's
  # for 'd <- it'd, that'd, there'd
  # for 'all <- y'all
  # for 't <- needn't, gov't, n't
  # for 'll <- ya'll, those'll, this'll, than'll
  # for 'mon <- c'mon
  # for 'an <- qur'an
  
  # twitter (first iteration)
  # for 's <- here's
  # for 'all <- y'all
  # for 'd <- it'd, that'd, where'd, there'd
  # for 'll <- ya'll, this'll
  # for 'mon <- c'mon
  # for 't <- gov't, con't
  # for 'l <- nat'l, int'l, i'll, li'l, add'l
  # for 'am <- ma'am
  
  # news (first iteration)
  # for 's <- here's
  # for 'd <- it'd, there'd, that'd, where'd
  
  # custom_key_contractions
  custom_key_contractions <- key_contractions
  custom_key_contractions <- 
    rbind(custom_key_contractions, 
          # contractions from first iteration (blog)
          c(contraction = "here's", expanded = "here is"),
          c(contraction = "it'd", expanded = "it would"),
          c(contraction = "that'd", expanded = "that would"),
          c(contraction = "there'd", expanded = "there would"),
          c(contraction = "y'all", expanded = "you and all"),
          c(contraction = "needn't", expanded = "need not"),
          c(contraction = "gov't", expanded = "government"),
          c(contraction = "n't", expanded = "not"),
          c(contraction = "ya'll", expanded = "you and all"),
          c(contraction = "those'll", expanded = "those will"),
          c(contraction = "this'll", expanded = "this will"),
          c(contraction = "than'll", expanded = "than will"),
          c(contraction = "c'mon", expanded = "come on"),
          c(contraction = "qur'an", expanded = "quran"),
          # additional from twitter
          c(contraction = "where'd", expanded = "where would"),
          c(contraction = "con't", expanded = "continued"),
          c(contraction = "nat'l", expanded = "national"),
          c(contraction = "int'l", expanded = "international"),
          c(contraction = "i'l", expanded = "i will"),
          c(contraction = "li'l", expanded = "little"),
          c(contraction = "add'l", expanded = "additional"),
          c(contraction = "ma'am", expanded = "madam"))
  
  return(custom_key_contractions)
}

# Retokenize using custom key contractions (first iteration)
retokenize_using_custom_key_contractions <- 
  function(tokenized_corpus, custom_key_contractions) {
    
    # Expand contracted tokens using the default key_contractions dataset from
    # lexicon package
    one_gram_expanded <- 
      expand_contracted_tokens(tokenized_corpus %>%
                                 mutate(is_english = NULL), 
                               custom_key_contractions = custom_key_contractions)
    
    # update column that would initially determine if the word is english or not
    one_gram_expanded <-
      one_gram_expanded %>%
      mutate(is_english = ngrams %in% grady_augmented)
    
    return(one_gram_expanded)
  }

# Retokenize each corpus (first iteration)
blog_retokenized_using_custom_key_contractions <-
  retokenize_using_custom_key_contractions(
    tokenized_corpus = blog_tokenized_and_cleaned, 
    custom_key_contractions = custom_key_contractions_first_iteration())
twitter_retokenized_using_custom_key_contractions <-
  retokenize_using_custom_key_contractions(
    tokenized_corpus = twitter_tokenized_and_cleaned, 
    custom_key_contractions = custom_key_contractions_first_iteration())
news_retokenized_using_custom_key_contractions <-
  retokenize_using_custom_key_contractions(
    tokenized_corpus = news_tokenized_and_cleaned, 
    custom_key_contractions = custom_key_contractions_first_iteration())


# Second Iteration
# FOR BLOG
blog_remaining_contractions_2nd <- analyze_remaining_contractions(
  tokenized_corpus = blog_retokenized_using_custom_key_contractions,
  n = 10, corpus_name = "blog")
# plot top 10 contractions
blog_remaining_contractions_2nd$top_n_contractions_plot
# plot most common words per contraction
blog_remaining_contractions_2nd$top_n_words_per_contraction_plot
# FOR TWITTER
twitter_remaining_contractions_2nd <-analyze_remaining_contractions(
  tokenized_corpus = twitter_retokenized_using_custom_key_contractions, 
  n = 10, corpus_name = "twitter")
# plot top 10 contractions
twitter_remaining_contractions_2nd$top_n_contractions_plot
# plot most common words per contraction
twitter_remaining_contractions_2nd$top_n_words_per_contraction_plot
# FOR NEWS
news_remaining_contractions_2nd <-analyze_remaining_contractions(
  tokenized_corpus = news_retokenized_using_custom_key_contractions, 
  n = 10, corpus_name = "news")
# plot top 10 contractions
news_remaining_contractions_2nd$top_n_contractions_plot
# plot most common words per contraction
news_remaining_contractions_2nd$top_n_words_per_contraction_plot

# augment custom key contractions
custom_key_contractions_second_iteration <- function() {
  # REPLACE WORD CONTRACTIONS
  # Using custom_key_contractions
  
  # for blog
  # 'know <- y'know
  # 've <- not've, that've, should've, may've
  # 'er <- ne'er, e'er, whene'er
  
  # for twitter
  # 'd <- cont'd
  # 're <- how're, there're, where're, when're, why're, that're
  # 've <- how've, there've, that've, may've, she've, all've
  
  # for news
  # for 'i <- hawai'i
  
  # custom_key_contractions
  custom_key_contractions <- key_contractions
  custom_key_contractions <- 
    rbind(custom_key_contractions, 
          # FIRST ITERATION
          # contractions from first iteration (blog)
          c(contraction = "here's", expanded = "here is"),
          c(contraction = "it'd", expanded = "it would"),
          c(contraction = "that'd", expanded = "that would"),
          c(contraction = "there'd", expanded = "there would"),
          c(contraction = "y'all", expanded = "you and all"),
          c(contraction = "needn't", expanded = "need not"),
          c(contraction = "gov't", expanded = "government"),
          c(contraction = "n't", expanded = "not"),
          c(contraction = "ya'll", expanded = "you and all"),
          c(contraction = "those'll", expanded = "those will"),
          c(contraction = "this'll", expanded = "this will"),
          c(contraction = "than'll", expanded = "than will"),
          c(contraction = "c'mon", expanded = "come on"),
          c(contraction = "qur'an", expanded = "quran"),
          # additional from twitter
          c(contraction = "where'd", expanded = "where would"),
          c(contraction = "con't", expanded = "continued"),
          c(contraction = "nat'l", expanded = "national"),
          c(contraction = "int'l", expanded = "international"),
          c(contraction = "i'l", expanded = "i will"),
          c(contraction = "li'l", expanded = "little"),
          c(contraction = "add'l", expanded = "additional"),
          c(contraction = "ma'am", expanded = "madam"),
          # SECOND ITERATION
          # additional from blog
          c(contraction = "y'know", expanded = "you know"),
          c(contraction = "not've", expanded = "not have"),
          c(contraction = "that've", expanded = "that have"),
          c(contraction = "should've", expanded = "should have"),
          c(contraction = "may've", expanded = "may have"),
          c(contraction = "ne'er", expanded = "never"),
          c(contraction = "e're", expanded = "ever"),
          c(contraction = "whene'er", expanded = "whenever"),
          # additional from twitter
          c(contraction = "cont'd", expanded = "continued"),
          c(contraction = "how're", expanded = "how are"),
          c(contraction = "there're", expanded = "there are"),
          c(contraction = "where're", expanded = "when are"),
          c(contraction = "why're", expanded = "why are"),
          c(contraction = "that're", expanded = "that are"),
          c(contraction = "how've", expanded = "how have"),
          c(contraction = "there've", expanded = "there have"),
          c(contraction = "may've", expanded = "may have"),
          c(contraction = "she've", expanded = "she have"),
          c(contraction = "all've", expanded = "all have"),
          # additional from news
          c(contraction = "hawai'i", expanded = "hawaii"))
  
  return(custom_key_contractions)
}