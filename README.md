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

