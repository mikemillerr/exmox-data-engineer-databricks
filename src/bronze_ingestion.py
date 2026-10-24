import dlt
from pyspark.sql import functions as F
from pyspark.sql import types as T


LANDING_PATH = spark.conf.get("landing_path")


def read_csv(source, schema):
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("cloudFiles.rescuedDataColumn", "_rescued_data")
        .option("header", "true")
        .schema(schema)
        .load(f"{LANDING_PATH}/{source}")
        .withColumn("_source_file", F.col("_metadata.file_path"))
        .withColumn("_loaded_at", F.current_timestamp())
    )


@dlt.table(name="installs", comment="Typed installs CSV ingestion")
def installs():
    schema = T.StructType(
        [
            T.StructField("user_id", T.StringType()),
            T.StructField("install_ts", T.TimestampType()),
            T.StructField("country", T.StringType()),
            T.StructField("platform", T.StringType()),
            T.StructField("media_source", T.StringType()),
            T.StructField("device_model", T.StringType()),
            T.StructField("campaign_id", T.StringType()),
        ]
    )
    return read_csv("installs", schema)


@dlt.table(name="events", comment="Typed events CSV ingestion")
def events():
    schema = T.StructType(
        [
            T.StructField("user_id", T.StringType()),
            T.StructField("event_ts", T.TimestampType()),
            T.StructField("event_name", T.StringType()),
            T.StructField("offer_id", T.StringType()),
            T.StructField("event_id", T.StringType()),
            T.StructField("ingest_ts", T.TimestampType()),
        ]
    )
    return read_csv("events", schema)


@dlt.table(name="offers", comment="Typed offers CSV ingestion")
def offers():
    schema = T.StructType(
        [
            T.StructField("offer_id", T.StringType()),
            T.StructField("offer_category", T.StringType()),
            T.StructField("payout_type", T.StringType()),
            T.StructField("payout_eur", T.DecimalType(10, 2)),
        ]
    )
    return read_csv("offers", schema)


@dlt.table(name="user_profile", comment="Typed user profile CSV ingestion")
def user_profile():
    schema = T.StructType(
        [
            T.StructField("user_id", T.StringType()),
            T.StructField("events_lifetime", T.LongType()),
            T.StructField("last_seen_ts", T.TimestampType()),
            T.StructField("revenue_30d_eur", T.DecimalType(10, 2)),
            T.StructField("is_payer", T.BooleanType()),
        ]
    )
    return read_csv("user_profile", schema)
