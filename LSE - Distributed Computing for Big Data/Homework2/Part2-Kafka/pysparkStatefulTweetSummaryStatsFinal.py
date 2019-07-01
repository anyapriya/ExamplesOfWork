from __future__ import print_function
import sys
import json
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils

def returnText(x):
    try:
        return x['text']
    except:
        return ""

def wordcount(x):
    words = x.split(" ")
    return ("values", len(words))

if __name__ == "__main__":

    def updateFunc(new_wcs, last_vals):
        if new_wcs == None:
            return last_vals
        #last_vals = lastvalsRDD.lookup("values") 
        for i in new_wcs:
            i = float(i)
            n = last_vals[0] 
            last_vals[0] = last_vals[0] + 1

            wn = 1/(n + 1)
            last_vals[1] = (1-wn)*last_vals[1] + wn*(i)
            
            wn = 0.2
            last_vals[3] = (1-wn)*(last_vals[3]) + wn*(i)


            if n > 0:
                bn = 1/(n+1)
                an = (n-1)/n
                last_vals[2] = (an*last_vals[2]) + bn*(i-last_vals[1])**2
            
                bn = 0.2
                an = 1 - bn
                last_vals[4] = (an*last_vals[2]) + bn*(i - last_vals[3])**2
            

        return last_vals



    

    topic = 'twitter-stream'

    sc = SparkContext()
    ssc = StreamingContext(sc, 1) # 1 second intervals!
    ssc.checkpoint("checkpoint")

    Initdata = sc.parallelize([(u'values', [0,0,0,0,0])])

    zkQuorum = "localhost:2181"
    kafka_stream = KafkaUtils.createStream(ssc, zkQuorum, "spark-streaming-consumer", {topic: 1})
    lines = kafka_stream.map(lambda x: json.loads(x[1])).map(returnText)

    
    


    temp = lines.map(wordcount)
    results = temp.updateStateByKey(updateFunc, initialRDD=Initdata)






    results.pprint()

    ssc.start()
    ssc.awaitTermination()
