import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

import requests
import json
from awsglue import DynamicFrame

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME','api_url','api_key','bucket','key'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)


# Coleta de dados da API openweathermap:
def get_base_from_api(url, key, cidades):
    lang   = "pt_br"
    units  = "metric"
    payload= {}
    params = {}
    headers= {}
    result = []
    
    for cidade in cidades:
        link = f"{url}?appid={key}&q={cidade}&lang={lang}&units={units}"
        response = requests.request("GET", link, headers=headers, params=params, data=payload)    
        if response.status_code == 200:
            content = json.loads(response.content)
            result.append(content)
    
    str = json.dumps(result)
    
    return spark.read.json(sc.parallelize([str]))


# Salva dados no bucket
def record_raw_data(raw_weather_node, bucket, key):
    s3_bucket_node = glueContext.getSink(
        path="s3://"+bucket+"/"+key,
        connection_type="s3",
        updateBehavior="UPDATE_IN_DATABASE",
        partitionKeys=['name','dt'],
        enableUpdateCatalog=True,
        transformation_ctx="weather_raw_zone",
    )
    s3_bucket_node.setCatalogInfo(
        catalogDatabase="xpe-rawzone", catalogTableName="openweathermap"
    )
    s3_bucket_node.setFormat("glueparquet")
    s3_bucket_node.writeFrame(raw_weather_node)


def start():
    # Lista de Cidades 
    cidades = ["rio de janeiro","sao paulo","belo horizonte"]
    
    # Coleta de dados metereológicos
    df = get_base_from_api(args['api_url'], args['api_key'], cidades)
    
    # Transforma o dataframe do spark em dynamic Frame do Glue
    raw_weather_node = DynamicFrame.fromDF(df, glueContext, "raw_weather_node")
    
    # Armazena os dados em camada raw-zone no Bucket
    record_raw_data(raw_weather_node, args['bucket'], args['key'])


start()

job.commit()