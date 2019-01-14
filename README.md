---
title: "Exploring the Sample English Corpora for Predictive Text Modeling"
author: "Alexander N. Villasoto"
date: "13 January 2019"
output: html_document
---

## Overview

Mobile users worldwide invest significant amounts of time interacting with other people through social media, instant messaging and email among other things that the need for robust input methods cannot be overstated. In response to this need, digital keyboards with smart typing mechanisms became commonplace. As efficient and fast these smart keyboards could be, under the hood it is essential to have an effective and efficient predictive text models that would spit out the "best" next word to aid users in fast typing. Also, being English as the primary language in these devices, it is also essential on the side of the data analyst to understand the corpora that will be representative of general population of mobile phone users. 

The corpora is grouped into three categories - blog, twitter and news that are conveniently separated into files for analysis. Every files have anonymized entries tagged with their date of publication. For this project's purpose, a total of three files will be used in the analysis.

In this project, the goal is to filter out words or tokens that are not useful for prediction and analyze these useful tokens of their intrinsic structures. Ultimately, the end product of this analysis is a 'cleaned' corpora that is the basis for the subsequent predictive modeling. After the analysis, the author will also list down his plans in realizing the most effective model and how it would be used as a data product similar to the approaches applied to smart keyboard applications.

## Directory Structure

<pre>
.
├── data
│   ├── 01_exploring_the_corpora.csv
│   ├── 02_finding_the_right_sample_part_2.csv
│   ├── 02_finding_the_right_sample_part_3.csv
│   ├── 02_finding_the_right_sample_part_4.csv
│   ├── 03_cleaning_the_corpus_part_1.csv
│   ├── 03_cleaning_the_corpus_part_2.csv
│   ├── 03_cleaning_the_corpus_part_3.csv
│   ├── 03_cleaning_the_corpus_part_4.csv
│   ├── 03_cleaning_the_corpus_part_5.csv
│   ├── 03_cleaning_the_corpus_part_6.csv
│   ├── 03_cleaning_the_corpus_part_7.csv
│   ├── 04_results_and_insights_part_1.csv
│   ├── 04_results_and_insights_part_2.csv
│   └── 04_results_and_insights_part_3.csv
├── Exploring-the-Sample-English-Corpora-for-Predictive-Text-Modeling.Rproj
├── figures
│   ├── blog_top_10_most_common_words_corresponding_to_top_10_word_contractions.png
│   ├── blog_top_10_most_common_words_corresponding_to_top_10_word_contractions_second_iteration.png
│   ├── distribution_of_english_and_not_english_tokens_per_corpus.png
│   ├── most_frequent_four_grams_per_corpus.png
│   ├── most_frequent_one_grams_per_corpus.png
│   ├── most_frequent_three_grams_per_corpus.png
│   ├── most_frequent_two_grams_per_corpus.png
│   ├── news_top_10_most_common_words_corresponding_to_top_10_word_contractions.png
│   ├── news_top_10_most_common_words_corresponding_to_top_10_word_contractions_second_iteration.png
│   ├── top_10_most_common_word_contractions_of_blog_corpus_on_a_log10_scale.png
│   ├── top_10_most_common_word_contractions_of_blog_corpus_on_a_log10_scale_second_iteration.png
│   ├── top_10_most_common_word_contractions_of_news_corpus_on_a_log10_scale.png
│   ├── top_10_most_common_word_contractions_of_news_corpus_on_a_log10_scale_second_iteration.png
│   ├── top_10_most_common_word_contractions_of_twitter_corpus_on_a_log10_scale.png
│   ├── top_10_most_common_word_contractions_of_twitter_corpus_on_a_log10_scale_second_iteration.png
│   ├── twitter_top_10_most_common_words_corresponding_to_top_10_word_contractions.png
│   └── twitter_top_10_most_common_words_corresponding_to_top_10_word_contractions_second_iteration.png
├── raw_code.R
├── readme_cache
│   └── html
│       ├── 00_01_load_dependencies_d9a3ed35f7f037581f2aa89b666409dc.RData
│       ├── 00_01_load_dependencies_d9a3ed35f7f037581f2aa89b666409dc.rdb
│       ├── 00_01_load_dependencies_d9a3ed35f7f037581f2aa89b666409dc.rdx
│       ├── 01_exploring_the_corpora_3be628ef08f09b88db5e1c218b68adf0.RData
│       ├── 01_exploring_the_corpora_3be628ef08f09b88db5e1c218b68adf0.rdb
│       ├── 01_exploring_the_corpora_3be628ef08f09b88db5e1c218b68adf0.rdx
│       ├── 02_finding_the_right_sample_part_1_1dc1c23032d6f12ee7d141c15a5a1b5b.RData
│       ├── 02_finding_the_right_sample_part_1_1dc1c23032d6f12ee7d141c15a5a1b5b.rdb
│       ├── 02_finding_the_right_sample_part_1_1dc1c23032d6f12ee7d141c15a5a1b5b.rdx
│       ├── 02_finding_the_right_sample_part_2_d9d9fe605f7d34d103f34f407d827b08.RData
│       ├── 02_finding_the_right_sample_part_2_d9d9fe605f7d34d103f34f407d827b08.rdb
│       ├── 02_finding_the_right_sample_part_2_d9d9fe605f7d34d103f34f407d827b08.rdx
│       ├── 02_finding_the_right_sample_part_3_a00b3d6d2012f6b98b09c203953b0e8f.RData
│       ├── 02_finding_the_right_sample_part_3_a00b3d6d2012f6b98b09c203953b0e8f.rdb
│       ├── 02_finding_the_right_sample_part_3_a00b3d6d2012f6b98b09c203953b0e8f.rdx
│       ├── 02_finding_the_right_sample_part_4_c51e5e3a28e9747df679309c2a8a38bc.RData
│       ├── 02_finding_the_right_sample_part_4_c51e5e3a28e9747df679309c2a8a38bc.rdb
│       ├── 02_finding_the_right_sample_part_4_c51e5e3a28e9747df679309c2a8a38bc.rdx
│       ├── 03_cleaning_the_corpus_part_1_de3c90dc3e069c6df237cfb1b00a2021.RData
│       ├── 03_cleaning_the_corpus_part_1_de3c90dc3e069c6df237cfb1b00a2021.rdb
│       ├── 03_cleaning_the_corpus_part_1_de3c90dc3e069c6df237cfb1b00a2021.rdx
│       ├── 03_cleaning_the_corpus_part_2_3e3434c37a5d0a5effb7d0920b6ea6fd.RData
│       ├── 03_cleaning_the_corpus_part_2_3e3434c37a5d0a5effb7d0920b6ea6fd.rdb
│       ├── 03_cleaning_the_corpus_part_2_3e3434c37a5d0a5effb7d0920b6ea6fd.rdx
│       ├── 03_cleaning_the_corpus_part_3_c3a23358d0f1c7ab315735f5ec20d624.RData
│       ├── 03_cleaning_the_corpus_part_3_c3a23358d0f1c7ab315735f5ec20d624.rdb
│       ├── 03_cleaning_the_corpus_part_3_c3a23358d0f1c7ab315735f5ec20d624.rdx
│       ├── 03_cleaning_the_corpus_part_4_63320624f9de744fa05f962839371cb5.RData
│       ├── 03_cleaning_the_corpus_part_4_63320624f9de744fa05f962839371cb5.rdb
│       ├── 03_cleaning_the_corpus_part_4_63320624f9de744fa05f962839371cb5.rdx
│       ├── 03_cleaning_the_corpus_part_5_69219809d49fc27f4f2e354295f4b532.RData
│       ├── 03_cleaning_the_corpus_part_5_69219809d49fc27f4f2e354295f4b532.rdb
│       ├── 03_cleaning_the_corpus_part_5_69219809d49fc27f4f2e354295f4b532.rdx
│       ├── 03_cleaning_the_corpus_part_6_37d23999ebe6086d59e73a99c27a9801.RData
│       ├── 03_cleaning_the_corpus_part_6_37d23999ebe6086d59e73a99c27a9801.rdb
│       ├── 03_cleaning_the_corpus_part_6_37d23999ebe6086d59e73a99c27a9801.rdx
│       ├── 03_cleaning_the_corpus_part_7_dfd2141cbc36b1d977f4b333b8859202.RData
│       ├── 03_cleaning_the_corpus_part_7_dfd2141cbc36b1d977f4b333b8859202.rdb
│       ├── 03_cleaning_the_corpus_part_7_dfd2141cbc36b1d977f4b333b8859202.rdx
│       ├── 03_cleaning_the_corpus_part_8_7afe87bd113dc5ed8c71c8157734e650.RData
│       ├── 03_cleaning_the_corpus_part_8_7afe87bd113dc5ed8c71c8157734e650.rdb
│       ├── 03_cleaning_the_corpus_part_8_7afe87bd113dc5ed8c71c8157734e650.rdx
│       ├── 04_results_and_insights_part_1_c20ea563f90cf428ec607663c87474ef.RData
│       ├── 04_results_and_insights_part_1_c20ea563f90cf428ec607663c87474ef.rdb
│       ├── 04_results_and_insights_part_1_c20ea563f90cf428ec607663c87474ef.rdx
│       ├── 04_results_and_insights_part_2_e167f3e7ea91146b3ece101e74773cc8.RData
│       ├── 04_results_and_insights_part_2_e167f3e7ea91146b3ece101e74773cc8.rdb
│       ├── 04_results_and_insights_part_2_e167f3e7ea91146b3ece101e74773cc8.rdx
│       ├── 04_results_and_insights_part_3_5f46bda77d6119096d80ad412583197d.RData
│       ├── 04_results_and_insights_part_3_5f46bda77d6119096d80ad412583197d.rdb
│       ├── 04_results_and_insights_part_3_5f46bda77d6119096d80ad412583197d.rdx
│       ├── 04_results_and_insights_part_4_04a7508fa5ee55a707051779681a94d7.RData
│       ├── 04_results_and_insights_part_4_04a7508fa5ee55a707051779681a94d7.rdb
│       ├── 04_results_and_insights_part_4_04a7508fa5ee55a707051779681a94d7.rdx
│       ├── 04_results_and_insights_part_5_9f545909a9b4bca763f4b4378b635798.RData
│       ├── 04_results_and_insights_part_5_9f545909a9b4bca763f4b4378b635798.rdb
│       ├── 04_results_and_insights_part_5_9f545909a9b4bca763f4b4378b635798.rdx
│       ├── 04_results_and_insights_part_6_d7e9e633532652c04065203d67cc030e.RData
│       ├── 04_results_and_insights_part_6_d7e9e633532652c04065203d67cc030e.rdb
│       ├── 04_results_and_insights_part_6_d7e9e633532652c04065203d67cc030e.rdx
│       ├── 04_results_and_insights_part_7_90740570fda28813876a5d06d2de74e9.RData
│       ├── 04_results_and_insights_part_7_90740570fda28813876a5d06d2de74e9.rdb
│       ├── 04_results_and_insights_part_7_90740570fda28813876a5d06d2de74e9.rdx
│       ├── 04_results_and_insights_part_8_47a31b66c922c5fafafd13f5addfbf07.RData
│       ├── 04_results_and_insights_part_8_47a31b66c922c5fafafd13f5addfbf07.rdb
│       ├── 04_results_and_insights_part_8_47a31b66c922c5fafafd13f5addfbf07.rdx
│       ├── appendix_1_investigating_other_contractions_part_10_cf77fdf32ee38f1d6d8a053b5d3011ce.RData
│       ├── appendix_1_investigating_other_contractions_part_10_cf77fdf32ee38f1d6d8a053b5d3011ce.rdb
│       ├── appendix_1_investigating_other_contractions_part_10_cf77fdf32ee38f1d6d8a053b5d3011ce.rdx
│       ├── appendix_1_investigating_other_contractions_part_11_463d69d796a057f0a94e5a2778a1f9b9.RData
│       ├── appendix_1_investigating_other_contractions_part_11_463d69d796a057f0a94e5a2778a1f9b9.rdb
│       ├── appendix_1_investigating_other_contractions_part_11_463d69d796a057f0a94e5a2778a1f9b9.rdx
│       ├── appendix_1_investigating_other_contractions_part_12_26ddfc4296c1b454d7c074a348563927.RData
│       ├── appendix_1_investigating_other_contractions_part_12_26ddfc4296c1b454d7c074a348563927.rdb
│       ├── appendix_1_investigating_other_contractions_part_12_26ddfc4296c1b454d7c074a348563927.rdx
│       ├── appendix_1_investigating_other_contractions_part_13_682a533ca3d0846e6b2b2fde667811cc.RData
│       ├── appendix_1_investigating_other_contractions_part_13_682a533ca3d0846e6b2b2fde667811cc.rdb
│       ├── appendix_1_investigating_other_contractions_part_13_682a533ca3d0846e6b2b2fde667811cc.rdx
│       ├── appendix_1_investigating_other_contractions_part_14_2351893d58c712835385023c7408429b.RData
│       ├── appendix_1_investigating_other_contractions_part_14_2351893d58c712835385023c7408429b.rdb
│       ├── appendix_1_investigating_other_contractions_part_14_2351893d58c712835385023c7408429b.rdx
│       ├── appendix_1_investigating_other_contractions_part_1_eed818a95eab5869adcaff452b3588fb.RData
│       ├── appendix_1_investigating_other_contractions_part_1_eed818a95eab5869adcaff452b3588fb.rdb
│       ├── appendix_1_investigating_other_contractions_part_1_eed818a95eab5869adcaff452b3588fb.rdx
│       ├── appendix_1_investigating_other_contractions_part_2_e1de3bbd17860f98fc491ff6187a5bb8.RData
│       ├── appendix_1_investigating_other_contractions_part_2_e1de3bbd17860f98fc491ff6187a5bb8.rdb
│       ├── appendix_1_investigating_other_contractions_part_2_e1de3bbd17860f98fc491ff6187a5bb8.rdx
│       ├── appendix_1_investigating_other_contractions_part_3_3a43879a059db1f18c4772cb02156aea.RData
│       ├── appendix_1_investigating_other_contractions_part_3_3a43879a059db1f18c4772cb02156aea.rdb
│       ├── appendix_1_investigating_other_contractions_part_3_3a43879a059db1f18c4772cb02156aea.rdx
│       ├── appendix_1_investigating_other_contractions_part_4_e5801e14cba68978e8ecf5b708deeeff.RData
│       ├── appendix_1_investigating_other_contractions_part_4_e5801e14cba68978e8ecf5b708deeeff.rdb
│       ├── appendix_1_investigating_other_contractions_part_4_e5801e14cba68978e8ecf5b708deeeff.rdx
│       ├── appendix_1_investigating_other_contractions_part_5_e1f60da034339537362ea8d4748d97d3.RData
│       ├── appendix_1_investigating_other_contractions_part_5_e1f60da034339537362ea8d4748d97d3.rdb
│       ├── appendix_1_investigating_other_contractions_part_5_e1f60da034339537362ea8d4748d97d3.rdx
│       ├── appendix_1_investigating_other_contractions_part_6_f4a99e75314250b04c63400a2e4c8742.RData
│       ├── appendix_1_investigating_other_contractions_part_6_f4a99e75314250b04c63400a2e4c8742.rdb
│       ├── appendix_1_investigating_other_contractions_part_6_f4a99e75314250b04c63400a2e4c8742.rdx
│       ├── appendix_1_investigating_other_contractions_part_7_bf89b67b27a37e0378659c478ec971a7.RData
│       ├── appendix_1_investigating_other_contractions_part_7_bf89b67b27a37e0378659c478ec971a7.rdb
│       ├── appendix_1_investigating_other_contractions_part_7_bf89b67b27a37e0378659c478ec971a7.rdx
│       ├── appendix_1_investigating_other_contractions_part_8_985ab328ef6846319aae3f80880e60e7.RData
│       ├── appendix_1_investigating_other_contractions_part_8_985ab328ef6846319aae3f80880e60e7.rdb
│       ├── appendix_1_investigating_other_contractions_part_8_985ab328ef6846319aae3f80880e60e7.rdx
│       ├── appendix_1_investigating_other_contractions_part_9_e2467c4c013825b8e3382467c8052a11.RData
│       ├── appendix_1_investigating_other_contractions_part_9_e2467c4c013825b8e3382467c8052a11.rdb
│       ├── appendix_1_investigating_other_contractions_part_9_e2467c4c013825b8e3382467c8052a11.rdx
│       ├── __packages
│       ├── session_info_411a84202b8a0c82d4a09903acf71fd7.RData
│       ├── session_info_411a84202b8a0c82d4a09903acf71fd7.rdb
│       └── session_info_411a84202b8a0c82d4a09903acf71fd7.rdx
├── README_cache
│   └── html
│       ├── 00_01_load_dependencies_d9a3ed35f7f037581f2aa89b666409dc.RData
│       ├── 00_01_load_dependencies_d9a3ed35f7f037581f2aa89b666409dc.rdb
│       ├── 00_01_load_dependencies_d9a3ed35f7f037581f2aa89b666409dc.rdx
│       ├── 01_exploring_the_corpora_3be628ef08f09b88db5e1c218b68adf0.RData
│       ├── 01_exploring_the_corpora_3be628ef08f09b88db5e1c218b68adf0.rdb
│       ├── 01_exploring_the_corpora_3be628ef08f09b88db5e1c218b68adf0.rdx
│       ├── 02_finding_the_right_sample_part_1_1dc1c23032d6f12ee7d141c15a5a1b5b.RData
│       ├── 02_finding_the_right_sample_part_1_1dc1c23032d6f12ee7d141c15a5a1b5b.rdb
│       ├── 02_finding_the_right_sample_part_1_1dc1c23032d6f12ee7d141c15a5a1b5b.rdx
│       ├── 02_finding_the_right_sample_part_2_d9d9fe605f7d34d103f34f407d827b08.RData
│       ├── 02_finding_the_right_sample_part_2_d9d9fe605f7d34d103f34f407d827b08.rdb
│       ├── 02_finding_the_right_sample_part_2_d9d9fe605f7d34d103f34f407d827b08.rdx
│       ├── 02_finding_the_right_sample_part_3_a00b3d6d2012f6b98b09c203953b0e8f.RData
│       ├── 02_finding_the_right_sample_part_3_a00b3d6d2012f6b98b09c203953b0e8f.rdb
│       ├── 02_finding_the_right_sample_part_3_a00b3d6d2012f6b98b09c203953b0e8f.rdx
│       ├── 02_finding_the_right_sample_part_4_c51e5e3a28e9747df679309c2a8a38bc.RData
│       ├── 02_finding_the_right_sample_part_4_c51e5e3a28e9747df679309c2a8a38bc.rdb
│       ├── 02_finding_the_right_sample_part_4_c51e5e3a28e9747df679309c2a8a38bc.rdx
│       ├── 03_cleaning_the_corpus_part_1_de3c90dc3e069c6df237cfb1b00a2021.RData
│       ├── 03_cleaning_the_corpus_part_1_de3c90dc3e069c6df237cfb1b00a2021.rdb
│       ├── 03_cleaning_the_corpus_part_1_de3c90dc3e069c6df237cfb1b00a2021.rdx
│       ├── 03_cleaning_the_corpus_part_2_3e3434c37a5d0a5effb7d0920b6ea6fd.RData
│       ├── 03_cleaning_the_corpus_part_2_3e3434c37a5d0a5effb7d0920b6ea6fd.rdb
│       ├── 03_cleaning_the_corpus_part_2_3e3434c37a5d0a5effb7d0920b6ea6fd.rdx
│       ├── 03_cleaning_the_corpus_part_3_c3a23358d0f1c7ab315735f5ec20d624.RData
│       ├── 03_cleaning_the_corpus_part_3_c3a23358d0f1c7ab315735f5ec20d624.rdb
│       ├── 03_cleaning_the_corpus_part_3_c3a23358d0f1c7ab315735f5ec20d624.rdx
│       ├── 03_cleaning_the_corpus_part_4_63320624f9de744fa05f962839371cb5.RData
│       ├── 03_cleaning_the_corpus_part_4_63320624f9de744fa05f962839371cb5.rdb
│       ├── 03_cleaning_the_corpus_part_4_63320624f9de744fa05f962839371cb5.rdx
│       ├── 03_cleaning_the_corpus_part_5_69219809d49fc27f4f2e354295f4b532.RData
│       ├── 03_cleaning_the_corpus_part_5_69219809d49fc27f4f2e354295f4b532.rdb
│       ├── 03_cleaning_the_corpus_part_5_69219809d49fc27f4f2e354295f4b532.rdx
│       ├── 03_cleaning_the_corpus_part_6_37d23999ebe6086d59e73a99c27a9801.RData
│       ├── 03_cleaning_the_corpus_part_6_37d23999ebe6086d59e73a99c27a9801.rdb
│       ├── 03_cleaning_the_corpus_part_6_37d23999ebe6086d59e73a99c27a9801.rdx
│       ├── 03_cleaning_the_corpus_part_7_dfd2141cbc36b1d977f4b333b8859202.RData
│       ├── 03_cleaning_the_corpus_part_7_dfd2141cbc36b1d977f4b333b8859202.rdb
│       ├── 03_cleaning_the_corpus_part_7_dfd2141cbc36b1d977f4b333b8859202.rdx
│       ├── 03_cleaning_the_corpus_part_8_7afe87bd113dc5ed8c71c8157734e650.RData
│       ├── 03_cleaning_the_corpus_part_8_7afe87bd113dc5ed8c71c8157734e650.rdb
│       ├── 03_cleaning_the_corpus_part_8_7afe87bd113dc5ed8c71c8157734e650.rdx
│       ├── 04_results_and_insights_part_1_c20ea563f90cf428ec607663c87474ef.RData
│       ├── 04_results_and_insights_part_1_c20ea563f90cf428ec607663c87474ef.rdb
│       ├── 04_results_and_insights_part_1_c20ea563f90cf428ec607663c87474ef.rdx
│       ├── 04_results_and_insights_part_2_e167f3e7ea91146b3ece101e74773cc8.RData
│       ├── 04_results_and_insights_part_2_e167f3e7ea91146b3ece101e74773cc8.rdb
│       ├── 04_results_and_insights_part_2_e167f3e7ea91146b3ece101e74773cc8.rdx
│       ├── 04_results_and_insights_part_3_5f46bda77d6119096d80ad412583197d.RData
│       ├── 04_results_and_insights_part_3_5f46bda77d6119096d80ad412583197d.rdb
│       ├── 04_results_and_insights_part_3_5f46bda77d6119096d80ad412583197d.rdx
│       ├── 04_results_and_insights_part_4_04a7508fa5ee55a707051779681a94d7.RData
│       ├── 04_results_and_insights_part_4_04a7508fa5ee55a707051779681a94d7.rdb
│       ├── 04_results_and_insights_part_4_04a7508fa5ee55a707051779681a94d7.rdx
│       ├── 04_results_and_insights_part_5_9f545909a9b4bca763f4b4378b635798.RData
│       ├── 04_results_and_insights_part_5_9f545909a9b4bca763f4b4378b635798.rdb
│       ├── 04_results_and_insights_part_5_9f545909a9b4bca763f4b4378b635798.rdx
│       ├── 04_results_and_insights_part_6_d7e9e633532652c04065203d67cc030e.RData
│       ├── 04_results_and_insights_part_6_d7e9e633532652c04065203d67cc030e.rdb
│       ├── 04_results_and_insights_part_6_d7e9e633532652c04065203d67cc030e.rdx
│       ├── 04_results_and_insights_part_7_90740570fda28813876a5d06d2de74e9.RData
│       ├── 04_results_and_insights_part_7_90740570fda28813876a5d06d2de74e9.rdb
│       ├── 04_results_and_insights_part_7_90740570fda28813876a5d06d2de74e9.rdx
│       ├── 04_results_and_insights_part_8_47a31b66c922c5fafafd13f5addfbf07.RData
│       ├── 04_results_and_insights_part_8_47a31b66c922c5fafafd13f5addfbf07.rdb
│       ├── 04_results_and_insights_part_8_47a31b66c922c5fafafd13f5addfbf07.rdx
│       ├── appendix_1_investigating_other_contractions_part_10_cf77fdf32ee38f1d6d8a053b5d3011ce.RData
│       ├── appendix_1_investigating_other_contractions_part_10_cf77fdf32ee38f1d6d8a053b5d3011ce.rdb
│       ├── appendix_1_investigating_other_contractions_part_10_cf77fdf32ee38f1d6d8a053b5d3011ce.rdx
│       ├── appendix_1_investigating_other_contractions_part_11_463d69d796a057f0a94e5a2778a1f9b9.RData
│       ├── appendix_1_investigating_other_contractions_part_11_463d69d796a057f0a94e5a2778a1f9b9.rdb
│       ├── appendix_1_investigating_other_contractions_part_11_463d69d796a057f0a94e5a2778a1f9b9.rdx
│       ├── appendix_1_investigating_other_contractions_part_12_26ddfc4296c1b454d7c074a348563927.RData
│       ├── appendix_1_investigating_other_contractions_part_12_26ddfc4296c1b454d7c074a348563927.rdb
│       ├── appendix_1_investigating_other_contractions_part_12_26ddfc4296c1b454d7c074a348563927.rdx
│       ├── appendix_1_investigating_other_contractions_part_13_682a533ca3d0846e6b2b2fde667811cc.RData
│       ├── appendix_1_investigating_other_contractions_part_13_682a533ca3d0846e6b2b2fde667811cc.rdb
│       ├── appendix_1_investigating_other_contractions_part_13_682a533ca3d0846e6b2b2fde667811cc.rdx
│       ├── appendix_1_investigating_other_contractions_part_14_2351893d58c712835385023c7408429b.RData
│       ├── appendix_1_investigating_other_contractions_part_14_2351893d58c712835385023c7408429b.rdb
│       ├── appendix_1_investigating_other_contractions_part_14_2351893d58c712835385023c7408429b.rdx
│       ├── appendix_1_investigating_other_contractions_part_1_eed818a95eab5869adcaff452b3588fb.RData
│       ├── appendix_1_investigating_other_contractions_part_1_eed818a95eab5869adcaff452b3588fb.rdb
│       ├── appendix_1_investigating_other_contractions_part_1_eed818a95eab5869adcaff452b3588fb.rdx
│       ├── appendix_1_investigating_other_contractions_part_2_e1de3bbd17860f98fc491ff6187a5bb8.RData
│       ├── appendix_1_investigating_other_contractions_part_2_e1de3bbd17860f98fc491ff6187a5bb8.rdb
│       ├── appendix_1_investigating_other_contractions_part_2_e1de3bbd17860f98fc491ff6187a5bb8.rdx
│       ├── appendix_1_investigating_other_contractions_part_3_3a43879a059db1f18c4772cb02156aea.RData
│       ├── appendix_1_investigating_other_contractions_part_3_3a43879a059db1f18c4772cb02156aea.rdb
│       ├── appendix_1_investigating_other_contractions_part_3_3a43879a059db1f18c4772cb02156aea.rdx
│       ├── appendix_1_investigating_other_contractions_part_4_e5801e14cba68978e8ecf5b708deeeff.RData
│       ├── appendix_1_investigating_other_contractions_part_4_e5801e14cba68978e8ecf5b708deeeff.rdb
│       ├── appendix_1_investigating_other_contractions_part_4_e5801e14cba68978e8ecf5b708deeeff.rdx
│       ├── appendix_1_investigating_other_contractions_part_5_e1f60da034339537362ea8d4748d97d3.RData
│       ├── appendix_1_investigating_other_contractions_part_5_e1f60da034339537362ea8d4748d97d3.rdb
│       ├── appendix_1_investigating_other_contractions_part_5_e1f60da034339537362ea8d4748d97d3.rdx
│       ├── appendix_1_investigating_other_contractions_part_6_f4a99e75314250b04c63400a2e4c8742.RData
│       ├── appendix_1_investigating_other_contractions_part_6_f4a99e75314250b04c63400a2e4c8742.rdb
│       ├── appendix_1_investigating_other_contractions_part_6_f4a99e75314250b04c63400a2e4c8742.rdx
│       ├── appendix_1_investigating_other_contractions_part_7_bf89b67b27a37e0378659c478ec971a7.RData
│       ├── appendix_1_investigating_other_contractions_part_7_bf89b67b27a37e0378659c478ec971a7.rdb
│       ├── appendix_1_investigating_other_contractions_part_7_bf89b67b27a37e0378659c478ec971a7.rdx
│       ├── appendix_1_investigating_other_contractions_part_8_985ab328ef6846319aae3f80880e60e7.RData
│       ├── appendix_1_investigating_other_contractions_part_8_985ab328ef6846319aae3f80880e60e7.rdb
│       ├── appendix_1_investigating_other_contractions_part_8_985ab328ef6846319aae3f80880e60e7.rdx
│       ├── appendix_1_investigating_other_contractions_part_9_e2467c4c013825b8e3382467c8052a11.RData
│       ├── appendix_1_investigating_other_contractions_part_9_e2467c4c013825b8e3382467c8052a11.rdb
│       ├── appendix_1_investigating_other_contractions_part_9_e2467c4c013825b8e3382467c8052a11.rdx
│       ├── __packages
│       ├── session_info_411a84202b8a0c82d4a09903acf71fd7.RData
│       ├── session_info_411a84202b8a0c82d4a09903acf71fd7.rdb
│       └── session_info_411a84202b8a0c82d4a09903acf71fd7.rdx
├── README.html
├── README.md
├── rsconnect
│   └── documents
│       └── README.Rmd
│           └── rpubs.com
│               └── rpubs
│                   └── Document.dcf
└── temp
    ├── README.html
    └── README.Rmd


</pre>