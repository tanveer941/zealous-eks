
build_app:
	docker build -t zealous . && \
	docker tag zealous tanveer941/zealous

push_to_dockerio:build_app
	docker login --username tanveer941 --password $(DOCKER_IO_PWD) docker.io && \
	docker push tanveer941/zealous

run_locally:
	docker run -p 5000:5000/tcp "tanveer941/zealous:latest"

########################### MINIKUBE #########################################