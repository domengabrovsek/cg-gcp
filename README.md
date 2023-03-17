# gcp-cg-example

## Description

This GitHub repository contains an example of how to deploy a simple REST API to Cloud Run on Google Cloud Platform (GCP) using GitHub Actions with a service account and then using Workload Identity Federation to authenticate and authorize the application.

## Requirements

To use this example, you will need the following:

- A Google Cloud Platform (GCP) account with billing enabled.
- A project on GCP

## Using Google Cloud Shell (recommended)

To simplify the process of logging in, selecting the correct project, and setting up your Docker credentials when working locally, we can use cloud shell instead. Follow these steps:

Steps:

- Visit <https://console.cloud.google.com/run?project=gcp-competence-group> and click on the icon located at the top right to activate cloud shell.
- Fork this Git repository to your own profile.
- Clone your forked repository in the cloud shell using the https option.
- After completing these steps, your Git repository will be successfully cloned in your cloud shell environment.

## Using local development environment


## Getting started

### Build, tag and push Docker image to GCP Container Registry

To prepare our REST API for running in Cloud Run, we will package it in a Docker image, tag the image, and push it to the GCP Container Registry. This will make the image available for use in Cloud Run at a later time.

Steps:

- Replace luka with your name in all files to ensure unique naming that won't clash with other people's deployments.

- Build the Docker image locally using the prepared node script. Run the command npm run docker:build. This will build the Docker image locally and name it fastify-api-luka.

- Tag the image using the command npm run docker:tag. This will rename your image to gcr.io/gcp-competence-group/fastify-api-luka.

- Push the image using the command npm run docker:push. The "name" of the image equals the full repository URL to it.
- Check the URL <https://console.cloud.google.com/gcr/images/gcp-competence-group?project=gcp-competence-group> to see your pushed image.

### Deploying to Cloud Run manually using user account

- Manually run the command under "deploy" in package.json
- Go to <https://console.cloud.google.com/run?project=gcp-competence-group>. You should see your instance deployed by your user.

### Deploying to Cloud Run using Github Action and Service Account

- In the repository, find the GitHub action defined at .github/workflows/deploy-with-sa.yaml. This action will create a Cloud Run deployment using a service account JSON key to authenticate.
- Create a service account in Google Cloud Console.
- Assign two roles to the service account: Cloud Run Developer and Service Account User.
- Create a service account JSON key.
- Add a secret to your GitHub repository with the content of the service account key JSON as the value. Name it the same way as defined in the GitHub action.
- Manually trigger the action.
- Go to <https://console.cloud.google.com/run?project=gcp-competence-group>. You should see your instance deployed by the service account instead of your user.

### Deploying to Cloud Run using Github Action and Workload Identity Federation

TBD

## Troubleshooting

If you encounter an issue where your user or service account doesn't have the necessary permissions to perform an action, you can follow these steps:
- Visit https://codehex.dev/gcp_predefined_roles/ to see a list of predefined roles and their associated permissions.
- Identify the appropriate roles that need to be added to your user or service account.
- Add the necessary roles to your user or service account.
- Retry the action you were trying to perform, and verify that it is now successful.