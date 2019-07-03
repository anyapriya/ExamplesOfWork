# ST446 Distributed Computing for Big Data
## Homework 2
---


* P1: [Using Spark and Graphframes to query the YAGO semantic knowledge base](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/hw_yago_localfinal.ipynb)
* P2: [Using Kafka for Spark streaming of tweets](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/hw_tweet.ipynb)
* P3: [NLP Topic modelling for DBLP](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/hw_dblp.ipynb)



# Problem 1: Using Spark and Graphframes to query the YAGO semantic knowledge base
* Instructions below
* Code and Summary: [here](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/hw_yago_localfinal.ipynb)


### 1) Create bucket and cluster 

Command Line - my computer
```
gsutil mb gs://anyabucket01apr2019/


gcloud dataproc clusters create anyacluster02apr2019 \
 --project my-project-1519696393583 \
 --bucket anyabucket01apr2019 \
 --properties=^#^spark:spark.jars.packages=graphframes:graphframes:0.5.0-spark2.1-s_2.11,com.databricks:spark-xml_2.11:0.4.1 \
 --initialization-actions 'gs://dataproc-initialization-actions/jupyter/jupyter.sh','gs://dataproc-initialization-actions/python/pip-install.sh','gs://dataproc-initialization-actions/zookeeper/zookeeper.sh','gs://dataproc-initialization-actions/kafka/kafka.sh' \
 --metadata 'PIP_PACKAGES=sklearn nltk pandas graphframes pyspark kafka-python tweepy' \
 --subnet default --zone europe-west2-a --master-machine-type n1-standard-4 --master-boot-disk-size 500 --num-workers 2 --worker-machine-type n1-standard-4 --worker-boot-disk-size 500 --image-version 1.3-deb9 
```

### 2) Move notebook file to bucket 

Command Line - my computer
```
cd Documents/GitHub/hw2-summative-2019-anyapriya
gsutil cp hw_yago_local.ipynb gs://anyabucket01apr2019/notebooks/

```

### 3) Set up Jupyter notebook book

Command Line - my computer
```
export PORT=8123
export HOSTNAME="anyacluster02apr2019-m"
export PROJECT="my-project-1519696393583"
export ZONE="europe-west2-a"


gcloud compute ssh ${HOSTNAME} \
    --project=${PROJECT} --zone=${ZONE}  -- \
    -D ${PORT} -N &

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      --proxy-server="socks5://localhost:${PORT}" \
      --user-data-dir=/tmp/${HOSTNAME}
      
```

Address bar of chrome that opens up
```
http://anyacluster02apr2019-m:8123
```


### 4) Open ssh to cluster

Command Line - my computer
```
gcloud compute --project "my-project-1519696393583" ssh --zone "europe-west2-a" "anyacluster02apr2019-m"
```


### 5) Download and extract the YAGO data, and add the files to Hadoop file system

Command Line - VM
```
wget http://resources.mpi-inf.mpg.de/yago-naga/yago3.1/yagoFacts.tsv.7z
wget http://resources.mpi-inf.mpg.de/yago-naga/yago3.1/yagoTransitiveType.tsv.7z

sudo apt-get install p7zip-full
7z x yagoTransitiveType.tsv.7z 
7z x yagoFacts.tsv.7z

hadoop fs -put -f /home/Anya/yagoFacts.tsv hdfs://anyacluster02apr2019-m/user/Anya/yagoFacts.tsv

hadoop fs -put -f /home/Anya/yagoTransitiveType.tsv hdfs://anyacluster02apr2019-m/user/Anya/yagoTransitiveType.tsv
```

### 6) Return to the chrome browser on the vm which is set up for Jupyter notebooks, and run [file](hw_yago_localfinal.ipynb)






# Problem 2: Using Kafka for Spark streaming of tweets
* Instructions: below
* Math derivations: [here](Part2-Kafka/HW2Part2Math.pdf)
* Code: [here](Part2-Kafka/kafka_twitter_producer.py) and [here](Part2-Kafka/pysparkStatefulTweetSummaryStatsFinal.py)
* Output: [here](Part2-Kafka/KafkaTweetsOutput_1.png) and [here](Part2-Kafka/KafkaTweetsOutput_2.png)
* Summary: [here](Part2-Kafka/hw_tweet.ipynb)

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

### 7) Run the [file](Part2-Kafka/kafka_twitter_producer.py) to create a stream of tweets about jazz, then return to screen 1

Command Line - VM (screen 0)
```
python kafka_twitter_producer.py
```

ctrl+a 1

### 8) Run the [file](pysparkStatefulTweetSummaryStatsFinal.py) to recursively estimate mean and variance of tweet word counts

Command Line - VM (screen 1)
```
mkdir checkpoint
spark-submit --packages org.apache.spark:spark-streaming-kafka-0-8_2.11:2.3.2 ./pysparkStatefulTweetSummaryStatsFinal.py
```


# Problem 3: NLP Topic modelling for DBLP
* Instructions below
* Code and Summary: [here](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/hw_dblp.ipynb)

### 1) Create bucket and cluster 

Command Line - my computer
```
gsutil mb gs://anyabucket01apr2019/


gcloud dataproc clusters create anyacluster02apr2019 \
 --project my-project-1519696393583 \
 --bucket anyabucket01apr2019 \
 --subnet default --zone europe-west2-a --master-machine-type n1-standard-4 --master-boot-disk-size 500 --num-workers 2 --worker-machine-type n1-standard-4 --worker-boot-disk-size 500 --image-version 1.3-deb9 \
 --initialization-actions 'gs://dataproc-initialization-actions/jupyter/jupyter.sh','gs://dataproc-initialization-actions/python/pip-install.sh','gs://anyabucket01apr2019/my-actions.sh' \
 --metadata 'PIP_PACKAGES=sklearn nltk pandas numpy'
```


### 2) Copy the sh file and author file to the bucket

Command Line - my computer
```
cd Documents/GitHub/lectures2019/week08/class/
gsutil cp my-actions.sh gs://anyabucket01apr2019/

gsutil cp "/Users/Anya/Documents/Grad School/LSE/Dist Comp for Big Data/author-large.txt" gs://anyabucket01apr2019/
```

### 3) Set up Jupyter notebook book

Command Line - my computer
```
export PORT=8123
export HOSTNAME="anyacluster02apr2019-m"
export PROJECT="my-project-1519696393583"
export ZONE="europe-west2-a"


gcloud compute ssh ${HOSTNAME} \
    --project=${PROJECT} --zone=${ZONE}  -- \
    -D ${PORT} -N &

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      --proxy-server="socks5://localhost:${PORT}" \
      --user-data-dir=/tmp/${HOSTNAME}
      
```

Address bar of chrome that opens up
```
http://anyacluster02apr2019-m:8123
```

### 4) Run [file](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/hw_dblp.ipynb)

