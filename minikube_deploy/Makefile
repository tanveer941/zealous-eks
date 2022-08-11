
start_minikube:
	minikube start "–driver=hyperv"

deploy_zealous_in_mini:
	kubectl create -f zealous_mini_deploy.yaml

start_zealous_app: deploy_zealous_in_mini
	kubectl expose deployment zealous --type=NodePort && \
	minikube service zealous

stop_zealous_app:
	kubectl delete -f zealous_mini_deploy.yaml && \
	kubectl delete svc zealous

run_zealous_job:
	kubectl create -f simplejob.yaml

run_zealous_cron_job:
	kubectl create -f cronjob.yaml