install_zealous_eks:
	helm upgrade --atomic --install zealous-website ./chart

uninstall_zealous_eks:
	helm uninstall zealous-website

check_load_balancer_status:
	kubectl describe ingress zealous-com

get_status:
	kubectl get ingress zealous-com

get_all:
	kubectl get all