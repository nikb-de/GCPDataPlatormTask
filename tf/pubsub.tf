resource "google_pubsub_schema" "offers_schema" {
  name       = "offers-event-schema"
  type       = "AVRO"
  definition = <<EOF
{
  "type": "record",
  "name": "OfferEvent",
  "namespace": "com.example.offer",
  "fields": [
    {
      "name": "event_type",
      "type": {
        "type": "enum",
        "name": "EventType",
        "symbols": ["created", "updated", "deleted"]
      }
    },
    {
      "name": "event_id",
      "type": "string",
      "doc": "A unique identifier for the event"
    },
    {
      "name": "event_timestamp",
      "type": "long",
      "logicalType": "timestamp-micros",
      "doc": "Timestamp when the event occurred"
    },
    {
      "name": "offer_id",
      "type": "string",
      "doc": "Unique identifier of the offer"
    },
    {
      "name": "data",
      "type": [
        "null",
        {
          "type": "record",
          "name": "OfferData",
          "fields": [
            {"name": "name", "type": ["null", "string"], "default": null},
            {"name": "slug", "type": ["null", "string"], "default": null},
            {"name": "description", "type": ["null", "string"], "default": null},
            {"name": "requirements", "type": ["null", "string"], "default": null},
            {"name": "thumbnail", "type": ["null", "string"], "default": null},
            {"name": "box_size", "type": ["null", "string"], "default": null},
            {"name": "is_desktop", "type": ["null", "boolean"], "default": null},
            {"name": "is_android", "type": ["null", "boolean"], "default": null},
            {"name": "is_ios", "type": ["null", "boolean"], "default": null},
            {"name": "is_ios_app", "type": ["null", "boolean"], "default": null},
            {"name": "allow_multi_platform", "type": ["null", "boolean"], "default": null},
            {"name": "offer_url_template", "type": ["null", "string"], "default": null},
            {"name": "provider_name", "type": ["null", "string"], "default": null},
            {"name": "wall_name", "type": ["null", "string"], "default": null},
            {"name": "external_offer_id", "type": ["null", "string"], "default": null},
            {"name": "limit_hit", "type": ["null", "boolean"], "default": null},
            {"name": "is_enabled", "type": ["null", "boolean"], "default": null},
            {"name": "is_available", "type": ["null", "boolean"], "default": null},
            {"name": "created_at", "type": ["null", {"type": "long", "logicalType": "timestamp-micros"}], "default": null},
            {"name": "updated_at", "type": ["null", {"type": "long", "logicalType": "timestamp-micros"}], "default": null},
            {"name": "deleted_at", "type": ["null", {"type": "long", "logicalType": "timestamp-micros"}], "default": null},
            {"name": "total_coins", "type": ["null", "int"], "default": null},
            {"name": "tips", "type": ["null", {"type": "bytes", "logicalType": "decimal", "precision": 10, "scale": 2}], "default": null},
            {"name": "split_test_key", "type": ["null", "string"], "default": null},
            {"name": "provider_conversion_rate", "type": ["null", "float"], "default": null},
            {"name": "adjust_cost_type", "type": ["null", "string"], "default": null},
            {"name": "payout_budget", "type": ["null", {"type": "bytes", "logicalType": "decimal", "precision": 10, "scale": 2}], "default": null},
            {"name": "game_id", "type": ["null", "int"], "default": null},
            {"name": "datastream_metadata", "type": ["null", {"type": "record", "name": "DatastreamMetadata", "fields": [{"name": "source_timestamp", "type": "long"}, {"name": "uuid", "type": "string"}]}], "default": null},
            {"name": "default_payout_structure_id", "type": ["null", "int"], "default": null},
            {"name": "weekly_limit", "type": ["null", "int"], "default": null},
            {"name": "daily_click_limit", "type": ["null", "int"], "default": null},
            {"name": "weekly_click_limit", "type": ["null", "int"], "default": null}
          ]
        }
      ],
      "default": null,
      "doc": "The actual data of the offer. It can be null for a deletion event."
    }
  ]
}
EOF
}

resource "google_pubsub_topic" "offer_topic" {
  name  = "offer"
  schema_settings {
    schema   = google_pubsub_schema.offers_schema.id
    encoding = "JSON"
  }
}

resource "google_pubsub_subscription" "offer_subscription" {
  name  = "offer-ingest-subscription"
  topic = google_pubsub_topic.offer_topic.id
}