# ---------- VARIABLES ----------
PROJECT_ID=ketan-gcp-playground
REGION=us-central1
REPO_NAME=devo-test-agent

# Define a unique name for the frontend service
SERVICE_NAME=devo-test-agent
IMAGE_TAG=latest

# Construct the full image URL in Artifact Registry
IMAGE_URL=$(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO_NAME)/$(SERVICE_NAME):$(IMAGE_TAG)

CREATE_URL=$(REPO_NAME) --repository-format=docker --location=$(REGION) --description="Devo Test Agent repository"


# ---------- COMMANDS ----------
.PHONY: help build deploy logs all

.DEFAULT_GOAL := help

help:
	@echo "Usage: make [command]"
	@echo ""
	@echo "Available commands for frontend:"
	@echo "  create     - Create the Artifact Registry repository for Docker images"
	@echo "  build      - Build the frontend Docker image using Cloud Build"
	@echo "  deploy     - Deploy the frontend container to Cloud Run"
	@echo "  logs       - Tail logs from the running frontend service"
	@echo "  all        - Build and deploy the frontend"

create:
	gcloud artifacts repositories create $(CREATE_URL)
build:
	@echo "🏗️  Building frontend image with Cloud Build..."
	gcloud builds submit --tag=$(IMAGE_URL)
deploy:
	@echo "🚀 Deploying frontend to Cloud Run..."
	gcloud run deploy $(SERVICE_NAME) \
		--image=$(IMAGE_URL) \
		--platform=managed \
		--region=$(REGION) \
		--service-account=$(SERVICE_ACCOUNT) \

logs:
	@echo "📜 Tailing logs for frontend service..."
	gcloud logs tail --project=$(PROJECT_ID) \
		--resource=cloud_run_revision \
		--limit=100 \
		--format="value(textPayload)" \
		--log-filter="resource.labels.service_name=$(SERVICE_NAME)"

all: build deploy