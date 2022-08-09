update_kubectl_config:
	aws eks update-kubeconfig --name eih-zealous

install_aws_load_balancer:
	helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=eih-zealous --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller

associate_oidc_provider:
	eksctl utils associate-iam-oidc-provider --cluster eih-zealous --approve

oidc_aws_elb_status:
	aws iam list-open-id-connect-providers

install_zealous_eks: update_kubectl_config
	helm upgrade --atomic --install zealous-website ./chart

uninstall_zealous_eks:
	helm uninstall zealous-website

check_load_balancer_status:
	kubectl describe ingress zealous-com

get_status:
	kubectl get ingress zealous-com

get_all:
	kubectl get all