# Set the provider to Google Cloud
provider "google" {
  credentials = file("./service-account-key.json") # Authenticate using the service account key file
  project     = "gcp-competence-group"             # The project ID
  region      = "europe-central2"                  # The default region to deploy resources
  zone        = "europe-central2-a"                # The default zone within the region
}

######################## pubsub topics ########################

# Create the first Pub/Sub topic
resource "google_pubsub_topic" "topic_image_to_text_results" {
  name = "domen-image-to-text-results-tf" # The name of the topic
}

# Create the second Pub/Sub topic
resource "google_pubsub_topic" "topic_image_to_text_translation" {
  name = "domen-image-to-text-translation-tf" # The name of the topic
}

######################## buckets ########################

# Create the input Cloud Storage bucket
resource "google_storage_bucket" "input_bucket" {
  name          = "image-text-extraction-input-bucket-domen" # The name of the bucket
  location      = "europe-central2"
  storage_class = "STANDARD"
}

# Create the output Cloud Storage bucket
resource "google_storage_bucket" "output_bucket" {
  name          = "image-text-extraction-output-bucket-domen" # The name of the bucket
  location      = "europe-central2"
  storage_class = "STANDARD"
}

# Create the cloud functions source code Cloud Storage bucket
resource "google_storage_bucket" "cloud_functions_bucket" {
  name     = "cloud-functions-bucket-domen"
  location = "europe-central2"
}

######################## functions ########################

# function 1
data "archive_file" "source_code_extract_text_from_image" {
  type        = "zip"                                       # The archive type
  source_dir  = "./cloud-functions/extract-text-from-image" # The directory containing the source code
  output_path = "./extract-text-from-image.zip"             # The output path of the zip file
}

resource "google_storage_bucket_object" "archive_extract_text_from_image" {
  name   = "extract-text-from-image.zip"
  bucket = google_storage_bucket.cloud_functions_bucket.name
  source = data.archive_file.source_code_extract_text_from_image.output_path
}

resource "google_cloudfunctions_function" "function_extract_text_from_image" {
  name                  = "domen-extract-text-from-image-tf"
  description           = "domen-extract-text-from-image-tf"
  runtime               = "nodejs18"
  source_archive_bucket = google_storage_bucket.cloud_functions_bucket.name
  source_archive_object = google_storage_bucket_object.archive_extract_text_from_image.name
  entry_point           = "processImage"
  timeout               = "60"
  available_memory_mb   = 256

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.input_bucket.name
  }

  environment_variables = {
    "TRANSLATE_TOPIC" = google_pubsub_topic.topic_image_to_text_translation.name
    "RESULT_TOPIC"    = google_pubsub_topic.topic_image_to_text_results.name
  }
}

# function 2

# Create a zip file of the Cloud Function source code
data "archive_file" "source_code_translate_text" {
  type        = "zip"                              # The archive type
  source_dir  = "./cloud-functions/translate-text" # The directory containing the source code
  output_path = "./translate-text.zip"             # The output path of the zip file
}

resource "google_storage_bucket_object" "archive_translate_text" {
  name   = "translate-text.zip"
  bucket = google_storage_bucket.cloud_functions_bucket.name
  source = data.archive_file.source_code_translate_text.output_path
}

resource "google_cloudfunctions_function" "function_translate_text" {
  name                  = "domen-translate-text-tf"
  description           = "domen-translate-text-tf"
  runtime               = "nodejs18"
  source_archive_bucket = google_storage_bucket.cloud_functions_bucket.name
  source_archive_object = google_storage_bucket_object.archive_translate_text.name
  entry_point           = "translateText"
  timeout               = "60"
  available_memory_mb   = 256

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.topic_image_to_text_translation.id
  }

  environment_variables = {
    "RESULT_TOPIC" = google_pubsub_topic.topic_image_to_text_results.name
  }
}

# function 3

# Create a zip file of the Cloud Function source code
data "archive_file" "source_code_save_results_to_bucket" {
  type        = "zip" # The archive type
  source_dir  = "./cloud-functions/save-results-to-bucket" # The directory containing the source code
  output_path = "./save-results-to-bucket.zip" # The output path of the zip file
}

resource "google_storage_bucket_object" "archive_save_results_to_bucket" {
  name   = "save-results-to-bucket.zip"
  bucket = google_storage_bucket.cloud_functions_bucket.name
  source = data.archive_file.source_code_save_results_to_bucket.output_path
}

resource "google_cloudfunctions_function" "function_save_results_to_bucket" {
  name                  = "domen-save-results-to-bucket-tf"
  description           = "domen-save-results-to-bucket-tf"
  runtime               = "nodejs18"
  source_archive_bucket = google_storage_bucket.cloud_functions_bucket.name
  source_archive_object = google_storage_bucket_object.archive_save_results_to_bucket.name
  entry_point           = "saveResult"
  timeout               = "60"
  available_memory_mb   = 256

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.topic_image_to_text_results.id
  }

  environment_variables = {
    "RESULT_BUCKET" = google_storage_bucket.output_bucket.name
  }
}
