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
args = getResolvedOptions(sys.argv, ['JOB_NAME','bucket','key'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)


def extract(glueContext, database, table) -> DynamicFrame:
    # Script generated for node AWS Glue Data Catalog
    extract_node = glueContext.create_dynamic_frame.from_catalog(
        database=database,
        table_name=table,
        transformation_ctx="extract_node",
    )
    
    return extract_node


def transform(glueContext, extract_node) -> DynamicFrame:
    df = extract_node.toDF()
    df.createOrReplaceTempView('table')
    
    df = spark.sql("""
        select
            name as city, w.main as description_en, w.description as description_pt, clouds.all as cloudiness, --rain.1h as rain_1h,     
            main.humidity, 
            main.temp, main.feels_like,  
            main.temp_max, main.temp_min, 
            visibility,
            main.pressure, 
            wind.deg as wind_direction, wind.speed as wind_speed, 
            sys.country, 
            coord.lat, coord.lon, 
            from_utc_timestamp( from_unixtime(sys.sunrise, "yyyy-MM-dd HH:mm:ss") , concat('UTC', CASE WHEN timezone < 0 THEN '-' ELSE '+' END, cast(abs(timezone) / 3600 as integer)) ) as sunrise,
            from_utc_timestamp( from_unixtime(sys.sunset, "yyyy-MM-dd HH:mm:ss") , concat('UTC', CASE WHEN timezone < 0 THEN '-' ELSE '+' END, cast(abs(timezone) / 3600 as integer)) ) as sunset,
            from_utc_timestamp( from_unixtime(dt, "yyyy-MM-dd HH:mm:ss") , concat('UTC', CASE WHEN timezone < 0 THEN '-' ELSE '+' END, cast(abs(timezone) / 3600 as integer)) ) as data_hora,
            concat('UTC', CASE WHEN timezone < 0 THEN '-' ELSE '+' END, cast(abs(timezone) / 3600 as integer)) as timezone
        from table lateral view explode(weather) as w
    """)
    
    return DynamicFrame.fromDF(df, glueContext, "transform_node")


def record_data(weather_node, bucket, key):
    # Armazena os dados em camada refined-zone no Bucket
    s3_bucket_node = glueContext.getSink(
        path="s3://"+bucket+"/"+key,
        connection_type="s3",
        updateBehavior="UPDATE_IN_DATABASE",
        partitionKeys=['city','data_hora'],
        enableUpdateCatalog=True,
        transformation_ctx="weather_refined_zone",
    )
    s3_bucket_node.setCatalogInfo(
        catalogDatabase="xpe-refinedzone", catalogTableName="openweathermap"
    )
    s3_bucket_node.setFormat("glueparquet")
    s3_bucket_node.writeFrame(weather_node)


def start():
    # Extract
    extract_node = extract(glueContext, "xpe-rawzone", "openweathermap")
    
    # Transform
    transform_node = transform(glueContext, extract_node)
    
    # Load
    record_data(transform_node, args['bucket'], args['key'])


start()

job.commit()