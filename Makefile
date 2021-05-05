RESOURCE_BUCKET = $(shell terraform -chdir=terraform output -raw resource_bucket)

OUTPUT_BUCKET = $(shell terraform -chdir=terraform output -raw output_bucket)

INPUT_BUCKET = $(shell terraform -chdir=terraform output -raw input_bucket)

AWS_PROFILE = $(shell terraform -chdir=terraform output -raw aws_profile)

.PHONY: setup
setup:
  terraform -chdir=terraform init
  terraform -chdir=terraform apply


.PHONY: upload-resource
upload-resource:
	aws --profile $(AWS_PROFILE) s3 cp resources/ s3://$(RESOURCE_BUCKET)/ --recursive

.PHONY: predictions
predictions:
	aws --profile $(AWS_PROFILE) s3 cp examples/ s3://$(INPUT_BUCKET)/ --recursive

.PHONY: download-output
download-output:
	aws --profile $(AWS_PROFILE) s3 cp s3://$(OUTPUT_BUCKET) results/ --recursive


.PHONY: cleanup
cleanup:
	aws --profile $(AWS_PROFILE) s3 rm s3://$(OUTPUT_BUCKET) --recursive

	aws --profile $(AWS_PROFILE) s3 rm s3://$(RESOURCE_BUCKET) --recursive

	aws --profile $(AWS_PROFILE) s3 rm s3://$(INPUT_BUCKET) --recursive

	terraform -chdir=terraform destroy