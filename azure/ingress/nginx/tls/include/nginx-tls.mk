# create nginx ingress controller with dns and tls
.PHONY: nginx-dns-tls
nginx-dns-tls: 
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update ingress-nginx
	helm search repo ingress-nginx
	helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --wait \
	--set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=$(dnsLabel) \
	--set controller.service.annotations."nginx\.ingress.kubernetes.io/ssl-redirect"="true" \
	--set controller.service.annotations."cert-manager.io/cluster-issuer"="letsencrypt"

# create camunda-values-nginx-tls.yaml with tls enabled and fully qualified domain name
.PHONY: camunda-values-nginx-tls.yaml
camunda-values-nginx-tls.yaml: ingress-ip-from-service
	@echo Ingress controller will use fqdn: $(fqdn)
	@sed "s/dnslabel.location.cloudapp.azure.com/$(fqdn)/g;" camunda-values.yaml > ./$(chartValues)
