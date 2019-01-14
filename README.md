Exploring the Sample English Corpora for Predictive Text Modeling
================
Alexander N. Villasoto
13 January 2019

Notes:
-----

* You can access the full documentation via GitHub Pages [here](https://arseniusnott.github.io/Exploring-the-Sample-English-Corpora-for-Predictive-Text-Modeling/). I suggest expanding the code listings all at once.
* If you want to know more information about my analysis, you can email me [here](mailto:anvillasoto@gmail.com) or open an issue by visiting [this](https://github.com/ArseniusNott/Exploring-the-Sample-English-Corpora-for-Predictive-Text-Modeling/issues) link.

Overview
--------

Mobile users worldwide invest significant amounts of time interacting with other people through social media, instant messaging and email among other things that the need for robust input methods cannot be overstated. In response to this need, digital keyboards with smart typing mechanisms became commonplace. As efficient and fast these smart keyboards could be, under the hood it is essential to have an effective and efficient predictive text models that would spit out the "best" next word to aid users in fast typing. Also, being English as the primary language in these devices, it is also essential on the side of the data analyst to understand the corpora that will be representative of general population of mobile phone users.

The corpora is grouped into three categories - blog, twitter and news that are conveniently separated into files for analysis. Every files have anonymized entries tagged with their date of publication. For this project's purpose, a total of three files will be used in the analysis.

In this project, the goal is to filter out words or tokens that are not useful for prediction and analyze these useful tokens of their intrinsic structures. Ultimately, the end product of this analysis is a 'cleaned' corpora that is the basis for the subsequent predictive modeling. After the analysis, the author will also list down his plans in realizing the most effective model and how it would be used as a data product similar to the approaches applied to smart keyboard applications.

Directory Structure
-------------------

<pre>

.
├── docs
│   ├── data
│   │   ├── 01_exploring_the_corpora.csv
│   │   ├── 02_finding_the_right_sample_part_2.csv
│   │   ├── 02_finding_the_right_sample_part_3.csv
│   │   ├── 02_finding_the_right_sample_part_4.csv
│   │   ├── 03_cleaning_the_corpus_part_1.csv
│   │   ├── 03_cleaning_the_corpus_part_2.csv
│   │   ├── 03_cleaning_the_corpus_part_3.csv
│   │   ├── 03_cleaning_the_corpus_part_4.csv
│   │   ├── 03_cleaning_the_corpus_part_5.csv
│   │   ├── 03_cleaning_the_corpus_part_6.csv
│   │   ├── 03_cleaning_the_corpus_part_7.csv
│   │   ├── 04_results_and_insights_part_1.csv
│   │   ├── 04_results_and_insights_part_2.csv
│   │   └── 04_results_and_insights_part_3.csv
│   ├── figures
│   │   ├── blog_top_10_most_common_words_corresponding_to_top_10_word_contractions.png
│   │   ├── blog_top_10_most_common_words_corresponding_to_top_10_word_contractions_second_iteration.png
│   │   ├── distribution_of_english_and_not_english_tokens_per_corpus.png
│   │   ├── most_frequent_four_grams_per_corpus.png
│   │   ├── most_frequent_one_grams_per_corpus.png
│   │   ├── most_frequent_three_grams_per_corpus.png
│   │   ├── most_frequent_two_grams_per_corpus.png
│   │   ├── news_top_10_most_common_words_corresponding_to_top_10_word_contractions.png
│   │   ├── news_top_10_most_common_words_corresponding_to_top_10_word_contractions_second_iteration.png
│   │   ├── top_10_most_common_word_contractions_of_blog_corpus_on_a_log10_scale.png
│   │   ├── top_10_most_common_word_contractions_of_blog_corpus_on_a_log10_scale_second_iteration.png
│   │   ├── top_10_most_common_word_contractions_of_news_corpus_on_a_log10_scale.png
│   │   ├── top_10_most_common_word_contractions_of_news_corpus_on_a_log10_scale_second_iteration.png
│   │   ├── top_10_most_common_word_contractions_of_twitter_corpus_on_a_log10_scale.png
│   │   ├── top_10_most_common_word_contractions_of_twitter_corpus_on_a_log10_scale_second_iteration.png
│   │   ├── twitter_top_10_most_common_words_corresponding_to_top_10_word_contractions.png
│   │   └── twitter_top_10_most_common_words_corresponding_to_top_10_word_contractions_second_iteration.png
│   ├── index.html
│   └── index.Rmd
├── raw_code.R
├── README.html
└── README.md


</pre>

Due to storage and environment constraints on GitHub, the author reproduced a cache version of the analysis without the generated files. <i>docs</i> directory includes cached data and figures needed by index.Rmd. If you want to reproduce the analysis, visit the URL above and expand the code listings.

