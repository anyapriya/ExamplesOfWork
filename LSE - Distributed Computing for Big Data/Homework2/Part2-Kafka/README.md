

# Problem 2: Using Kafka for Spark streaming of tweets
* Instructions: below
* Math derivations: [HW2Part2Math.pdf](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/HW2Part2Math.pdf)
* Code: [kafka_twitter_producer.py](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/kafka_twitter_producer.py) and [pysparkStatefulTweetSummaryStatsFinal.py](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/pysparkStatefulTweetSummaryStatsFinal.py)
* Output: [KafkaTweetsOutput_1.png](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/KafkaTweetsOutput_1.png) and [KafkaTweetsOutput_2.png](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/KafkaTweetsOutput_2.png)
* Summary: [hw_tweet.ipynb](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/hw_tweet.ipynb)

### 1) Create bucket and cluster 

Command Line - my computer
```
gsutil mb gs://anyabucket01apr2019/


gcloud dataproc clusters create anyacluster02apr2019 \
 --project my-project-1519696393583 \
 --bucket anyabucket01apr2019 \
 --subnet default --zone europe-west2-a --master-machine-type n1-standard-4 --master-boot-disk-size 500 --num-workers 0 --worker-machine-type n1-standard-4 --worker-boot-disk-size 500 --image-version 1.3-deb9 \
 --initialization-actions 'gs://dataproc-initialization-actions/jupyter/jupyter.sh','gs://dataproc-initialization-actions/python/pip-install.sh','gs://dataproc-initialization-actions/zookeeper/zookeeper.sh','gs://dataproc-initialization-actions/kafka/kafka.sh' \
 --metadata 'PIP_PACKAGES=sklearn nltk pandas graphframes pyspark kafka-python tweepy'
```

### 2) Copy required files from my computer to bucket 

Command Line - my computer
```
cd Documents/Grad\ School/LSE/Dist\ Comp\ for\ Big\ Data/KafkaTwitter/

gsutil cp kafka_twitter_producer.py gs://anyabucket01apr2019/kafka_twitter_producer.py
gsutil cp pysparkStatefulTweetSummaryStatsFinal.py gs://anyabucket01apr2019/pysparkStatefulTweetSummaryStatsFinal.py
```

### 3) Open ssh to cluster

Command Line - my computer
```
gcloud compute --project "my-project-1519696393583" ssh --zone "europe-west2-a" "anyacluster02apr2019-m"
```


### 4) Copy required files from bucket to vm

Command Line - VM
```
gsutil cp gs://anyabucket01apr2019/kafka_twitter_producer.py kafka_twitter_producer.py
gsutil cp gs://anyabucket01apr2019/pysparkStatefulTweetSummaryStatsFinal.py pysparkStatefulTweetSummaryStatsFinal.py
```


### 5) Set up Kafka and return to main directory

Command Line - VM
```
cd ../../usr/lib/kafka
bin/kafka-server-start.sh config/server.properties &
cd
```

### 6) Set up screen, ending up on screen 0

Command Line - VM
```
screen
```

ctrl+a c
ctrl+a 0 
ctrl-a w 

(Last line is unnecessary but good to check.)  

### 7) Run the file [kafka_twitter_producer.py](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/kafka_twitter_producer.py) to create a stream of tweets about jazz, then return to screen 1

Command Line - VM (screen 0)
```
python kafka_twitter_producer.py
```

ctrl+a 1

### 8) Run the file [pysparkStatefulTweetSummaryStatsFinal.py](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part2-Kafka/pysparkStatefulTweetSummaryStatsFinal.py) to recursively estimate mean and variance of tweet word counts

Command Line - VM (screen 1)
```
mkdir checkpoint
spark-submit --packages org.apache.spark:spark-streaming-kafka-0-8_2.11:2.3.2 ./pysparkStatefulTweetSummaryStatsFinal.py
```

