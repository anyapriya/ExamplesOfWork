#!/usr/bin/env python


# import required libraries
from kafka import SimpleProducer, KafkaClient
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
import tweepy
import time
import traceback

# update the following to your own key and token
consumer_key = "PhrEcpR5joPX6RE0QdPgGI31J"
consumer_secret = "3GtflK7JDZVdNUwBN3jSGqEtO4q3TmQ74v4WKlfCdbSwc68ukS"
access_token = "1114120017698807808-VNWRp9h26QBLrIHVFE8MZHW2sJ7vMI"
access_token_secret = "PdAJaT1TiEgpk3ooLYTlXYsWg5zEYxG7Kr3ewu0YzPyLY"

# Kafka settings
topic = 'twitter-stream'
# setting up Kafka producer
kafka = KafkaClient('localhost:9092')
producer = SimpleProducer(kafka)


#This is a basic listener that just sends received tweets to kafka
class StdOutListener(StreamListener):
    def on_data(self, data):
        producer.send_messages(topic, data.encode('utf-8'))
        print(len(data))
        return True

    def on_error(self, status):
        print(status)
        return False

if __name__ == '__main__':
    print('running the twitter-stream python code')
    #This handles Twitter authetification and the connection to Twitter Streaming API
    l = StdOutListener()
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)
    public_tweets = api.home_timeline()
    stream = Stream(auth, l)
    # Goal is to keep this process always going
    while True:
        try:
           # stream.sample()
           stream.filter(track=["jazz"])
        except:
           print(traceback.format_exc())
        time.sleep(10)
