
# Problem 1: Using Spark and Graphframes to query the YAGO semantic knowledge base
* Instructions below
* Code and Summary: [here](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/Part1-SparkGraphframes/hw_yago_localfinal.ipynb)


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



