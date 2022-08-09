ecr-login:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

build:
	docker build -t zealous_eks:$(TAG_VERSION) .

prepare: build
	docker tag zealous_eks:$(TAG_VERSION) $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/zealous_eks:$(TAG_VERSION)

ecr-deploy: prepare ecr-login
	docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/zealous_eks:$(TAG_VERSION)
