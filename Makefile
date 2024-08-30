.PHONY: package-ingest package-convert deploy-ingest deploy-convert deploy-all terraform-plan

INGEST_FUNCTION_DIR ?= cloud_functions/ingest_function
CONVERT_FUNCTION_DIR ?= cloud_functions/convert_function
TERRAFORM_DIR ?= tf
FUNCTION_BUCKET ?= your-function-source-bucket

package-ingest:
	zip -j $(INGEST_FUNCTION_DIR)/ingest_function.zip $(INGEST_FUNCTION_DIR)/main.py $(INGEST_FUNCTION_DIR)/requirements.txt

package-convert:
	zip -j $(CONVERT_FUNCTION_DIR)/convert_function.zip $(CONVERT_FUNCTION_DIR)/main.py $(CONVERT_FUNCTION_DIR)/requirements.txt

upload-ingest: package-ingest
	gsutil cp $(INGEST_FUNCTION_DIR)/ingest_function.zip gs://$(FUNCTION_BUCKET)/ingest_function.zip

upload-convert: package-convert
	gsutil cp $(CONVERT_FUNCTION_DIR)/convert_function.zip gs://$(FUNCTION_BUCKET)/convert_function.zip

deploy-ingest: upload-ingest
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve -var="project_id=$(GCP_PROJECT_ID)" -var="region=$(GCP_REGION)" -target=google_cloudfunctions_function.ingest_function

deploy-convert: upload-convert
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve -var="project_id=$(GCP_PROJECT_ID)" -var="region=$(GCP_REGION)" -target=google_cloudfunctions_function.convert_function

deploy-all: package-ingest package-convert upload-ingest upload-convert
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve -var="project_id=$(GCP_PROJECT_ID)" -var="region=$(GCP_REGION)"

terraform-plan:
	cd $(TERRAFORM_DIR) && terraform plan -var="project_id=$(GCP_PROJECT_ID)" -var="region=$(GCP_REGION)" -out=tfplan && terraform show -json tfplan > tfplan.json