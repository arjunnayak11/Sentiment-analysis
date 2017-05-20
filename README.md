# Sentiment-analysis

project deals real time twitter data. In order to retrieve the data, initially an account was created and oAuth access token
was generated. For this, we used “twitter,” “Rcurl,” and “ROAuth” packages. The package twitter provides access to Twitter API, 
the RCurl package provides functions to allow one to compose general HTTP requests and provides convenient functions to fetch URIs, 
get & post forms. The package ROAuth provides an interface allowing users to authenticate via OAuth to the server of their choice. 
movie_tweets = searchTwitter("Movies", n=1500, lang="en") 
The above function was used to extract the data from Twitter
