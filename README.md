# zealous-eks
Launch a web application on AWS EKS cluster with AWS load balancer as ingress

## Application launch in Minikube
`cd .\src\`

`make push_to_dockerio DOCKER_IO_PWD=MY_DOCKER_IO_PASSWORD`

`make run_locally`

try accessing : http://localhost:5000/

[//]: # (### Build docker image for minikube)

Install minikube    
`minikube start –driver=hyperv`

`make start_minikube`   
`make start_zealous_app`    
`make stop_zealous_app`

Minikube simple job deploy  
`cd .\minikube_deploy\`      
`make run_zealous_job`        
`make run_zealous_cron_job`     


## Application launch in EKS
`cd .\eks_deploy\eks_src\`      

Build and push to ECR       
`make ecr-deploy ACCOUNT_ID=MY_AWS_ACC_ID REGION=us-east-1 TAG_VERSION=latest`      

Create the AWS infra for AWS EKS    
`cd .\infra\`   
`make eks_cluster_setup`    
`make eks_cluster_teardown`     

Deploy in EKS   
`cd .\eks_deploy`   
`make install_zealous_eks`      
`make uninstall_zealous_eks`        
`make check_load_balancer_status`       
`make get_status`       

EKS simple job deploy
`make run_zealous_job`      

To check job status and logs        
`kubectl get jobs`      
`kubectl get pods`      
`kubectl logs zealous-finalcountdown-fznp6`     

To delete the job
`kubectl delete -f simplejob.yaml`      

