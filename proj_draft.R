library(twitteR)
library(sentiment)
library(plyr)
library(ROAuth)
library(ggplot2)
library(wordcloud) 
library(RColorBrewer)
library(base64enc)

#download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

#Connecting to live twitter Data

api_key <- "nDNpCS3kxon6Lae7OcUIHYrr3"

api_secret <- "yR9rTbhxQH6NhVnguKRwgO13nITdl4cte8CxrWk8PlGAbtPgaI"

access_token <- "4679453280-SRwoTsEZ90u9ziEl3A8nXLQlzTsYdJeYMDJgPLs"

access_token_secret <- "3ce3R0s0RXQz9enqWzmVxcfzb5dyXVd0B5XZjuRQ8hcMu"

setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)

movie_tweets = searchTwitter("NJIT", n=1500, lang="en")

# get the text
movie_data_text = sapply(movie_tweets, function(x) x$getText())

#Remove NA's from Text'
movie_data_text = movie_data_text[!is.na(movie_data_text)]
names(movie_data_text) = NULL

# remove numbers
movie_data_text = gsub("[[:digit:]]", "", movie_data_text)
# remove html links
movie_data_text = gsub("http\\w+", "", movie_data_text)
movie_data_text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", movie_data_text)
# remove at people
movie_data_text = gsub("@\\w+", "", movie_data_text)
# remove punctuation
movie_data_text = gsub("[[:punct:]]", "", movie_data_text)
# remove unnecessary spaces
movie_data_text = gsub("[ \t]{2,}", "", movie_data_text)
movie_data_text = gsub("^\\s+|\\s+$", "", movie_data_text)


# classify emotion 
class_emo = classify_emotion(movie_data_text, algorithm="bayes", prior=1.0)
# get emotion best fit
emotion = class_emo[,7]
# substitute NA's by "unknown"
emotion[is.na(emotion)] = "uncertain"

# classify polarity using sentiment package
class_pol = classify_polarity(movie_data_text, algorithm="bayes")
# get polarity best fit
polarity = class_pol[,4]

# data frame with results
dframe = data.frame(text=movie_data_text, emotion=emotion,
                     polarity=polarity, stringsAsFactors=FALSE)

# sort data frame
dframe = within(dframe,
                 emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))

#bargraph for the emotions
ggplot(dframe, aes(x=emotion)) +
  geom_bar(aes(y=..count.., fill=emotion)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="emotion categories", y="number of tweets") +
  labs(title = "Sentiment Analysis of Tweets about Brexit\n(classification by emotion)")

#bargraph for polarity of words
ggplot(dframe, aes(x=polarity)) +
  geom_bar(aes(y=..count.., fill=polarity)) +
  labs(x="polarity", y="number of tweets") +
  labs(title = "Sentiment Analysis of Tweets about Movies\n(classification by emotion)")

#error handling function
t.error=function(x){
  n=NA
checkerror = tryCatch(tolower(x), error=function(e) e)
if (!inherits(checkerror, "error"))
  n=tolower(x)
return(n)
}
movie_data_text = sapply(movie_data_text, t.error)

#saparate text by emotions

em = levels(factor(dframe$emotion))
num_emo = length(em)
emo.doc = rep("", num_emo)
for (i in 1:num_emo)
{
  tmp = movie_data_text[emotion == em[i]]
  emo.doc[i] = paste(tmp, collapse=" ")
}

# remove stopwords
emo.doc = removeWords(emo.doc, c(stopwords("english"),"get","just","maybe"))
# create corpus
corpus = Corpus(VectorSource(emo.doc))
ter_doc_mat = TermDocumentMatrix(corpus)
ter_doc_mat = as.matrix(ter_doc_mat)
colnames(ter_doc_mat) = em

# comparison word cloud
comparison.cloud(ter_doc_mat, max.words=600, colors = brewer.pal(num_emo, "Dark2"),
                 scale = c(3,.5), random.order = FALSE, title.size = 1.5)




  