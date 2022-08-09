create_dynomo_table:
	python create_dynamo_table.py

eks_cluster_setup: create_dynomo_table
	terraform init && \
	terraform apply -input=false -auto-approve

eks_cluster_teardown:
	terraform destroy -auto-approve