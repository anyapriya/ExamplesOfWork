
# Problem 3: NLP Topic modelling for DBLP
* Instructions below
* Code and Summary: [here](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/
Part3-NLP/hw_dblp.ipynb)

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

### 4) Run [file](https://github.com/anyapriya/ExamplesOfWork/blob/master/LSE%20-%20Distributed%20Computing%20for%20Big%20Data/Homework2/
Part3-NLP/hw_dblp.ipynb)

