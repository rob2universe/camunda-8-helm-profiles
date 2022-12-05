#k -n echo annotate ingress echo-server cert-manager.io/cluster-issuer=letsencrypt

.PHONY: echo
echo:
	kubectl apply -f ./echo-server/deployment.yaml -n $(namespace)
	cat ./echo-server/ingress.yaml | sed -E "s/dnslabel.location.cloudapp.azure.com/$(fqdn)/g" | kubectl apply -f -
# kubectl apply -f ingress.yaml -n $(namespace)

.PHONY: clean-echo
clean-echo:
	kubectl delete -f ./echo-server/deployment.yaml -n $(namespace)
	kubectl delete -f ./echo-server/ingress.yaml -n $(namespace)

