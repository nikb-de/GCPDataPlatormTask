import os
import json
import avro.schema
import avro.io
from google.cloud import storage
from datetime import datetime
import io

# Define Avro schema for your records
schema_str = '''
{
  "namespace": "com.example.offer",
  "type": "record",
  "name": "OfferEvent",
  "fields": [
    {"name": "event_type", "type": "string"},
    {"name": "event_id", "type": "string"},
    {"name": "event_timestamp", "type": "long"},
    {"name": "offer_id", "type": "string"},
    {"name": "data", "type": "string"}  # Replace with the actual structure if needed
  ]
}
'''
schema = avro.schema.parse(schema_str)


def ingest_offer_event(event, context):
    client = storage.Client()
    bucket_name = os.getenv('BUCKET_NAME')
    bucket = client.get_bucket(bucket_name)

    # Parse the JSON message directly
    pubsub_message = json.loads(event['data'])

    # Prepare Avro data
    datum_writer = avro.io.DatumWriter(schema)
    bytes_writer = io.BytesIO()
    encoder = avro.io.BinaryEncoder(bytes_writer)
    datum_writer.write(pubsub_message, encoder)

    # Create a filename based on timestamp
    timestamp = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
    filename = f"avro/{timestamp}.avro"

    # Upload Avro data to GCS
    blob = bucket.blob(filename)
    blob.upload_from_string(bytes_writer.getvalue(), content_type="application/avro")

    print(f"Message ingested as {filename} in bucket {bucket_name}.")
