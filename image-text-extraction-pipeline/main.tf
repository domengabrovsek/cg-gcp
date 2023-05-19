# Set the provider to Google Cloud
provider "google" {
  credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY_JSON_FILE>") # Authenticate using the service account key file
  project     = "<YOUR_GCP_PROJECT_ID>" # The project ID
  region      = "us-central1" # The default region to deploy resources
  zone        = "us-central1-a" # The default zone within the region
}

# Create the input Cloud Storage bucket
resource "google_storage_bucket" "input_bucket" {
  name = "<INPUT_BUCKET_NAME>" # The name of the bucket
}

# Create the output Cloud Storage bucket
resource "google_storage_bucket" "output_bucket" {
  name = "<OUTPUT_BUCKET_NAME>" # The name of the bucket
}

# Create a zip file of the Cloud Function source code
data "archive_file" "source_code_zip" {
  type        = "zip" # The archive type
  source_dir  = "<PATH_TO_YOUR_SOURCE_CODE_DIRECTORY>" # The directory containing the source code
  output_path = "<PATH_WHERE_YOU_WANT_YOUR_ZIP>" # The output path of the zip file
}

# Define the first Cloud Function
resource "google_cloudfunctions_function" "function1" {
  name                  = "function1" # The name of the function
  description           = "Function triggered by Bucket" # A description of the function
  available_memory_mb   = 256 # The amount of memory available to the function
  source_archive_bucket = google_storage_bucket.function_bucket.name # The bucket containing the function source code
  source_archive_object = data.archive_file.source_code_zip.output_path # The zip file containing the function source code
  trigger_http          = true # Enable HTTP trigger
  entry_point           = "handler" # The entry point of the function
  runtime               = "python39" # The runtime of the function
}

# Define the second Cloud Function
resource "google_cloudfunctions_function" "function2" {
  // Similar to function1
}

# Define the third Cloud Function
resource "google_cloudfunctions_function" "function3" {
  // Similar to function2
}

# Create the first Pub/Sub topic
resource "google_pubsub_topic" "topic1" {
  name = "<TOPIC1_NAME>" # The name of the topic
}

# Create the second Pub/Sub topic
resource "google_pubsub_topic" "topic2" {
  name = "<TOPIC2_NAME>" # The name of the topic
}

# Trigger function1 when an object is created in the input bucket
resource "google_storage_notification" "bucket_notification" {
  bucket        = google_storage_bucket.input_bucket.name # The bucket to monitor
  payload_format = "JSON_API_V1" # The format of the notification payload
  event_types   = ["OBJECT_FINALIZE"] # The events to trigger the notification
  custom_attributes = {
    function1 = google_cloudfunctions_function.function1.https_trigger_url # The URL of the function to trigger
  }
}

# Trigger function2 when a message is published to topic1
resource "google_pubsub_subscription" "subscription1" {
  name  = "<SUBSCRIPTION_NAME>" # The name of the subscription
  topic = google_pubsub_topic.topic1.name # The topic to subscribe to

  ack_deadline_seconds = 20 # The number of seconds to wait for acknowledgement

  push_config {
    push_endpoint = google_cloudfunctions_function.function2.https_trigger_url # The URL of the function to trigger
  }
}

# Trigger function3 when a message is published to topic2
resource "google_pubsub_subscription" "subscription2" {
  name  = "<SUBSCRIPTION_NAME>" # The name of the subscription
  topic = google_pubsub_topic.topic2.name # The topic to subscribe to

  ack_deadline_seconds = 20 # The number of seconds to wait for acknowledgement

  push_config {
    push_endpoint = google_cloudfunctions_function.function3.https_trigger_url # The URL of the function to trigger
  }
}