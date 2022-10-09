.PHONY: camunda
camunda: namespace
	@echo "Attempting to install camunda using chartValues: $(chartValues)"
	helm repo add camunda https://helm.camunda.io
	helm repo update camunda
	helm search repo $(chart)
	helm install --namespace $(namespace) $(release) $(chart) -f $(chartValues) --skip-crds

.PHONY: namespace
namespace:
	-kubectl create namespace $(namespace)
	-kubectl config set-context --current --namespace=$(namespace)

# Generates templates from the camunda helm charts, useful to make some more specific changes which are not doable by the values file.
.PHONY: template
template:
	helm template $(release) $(chart) -f $(chartValues) --skip-crds --output-dir .
	@echo "To apply the templates use: kubectl apply -f camunda-platform/templates/ -n $(namespace)"

.PHONY: keycloak-password
keycloak-password:
	kubectl get secret --namespace $(namespace) "$(release)-keycloak" -o jsonpath="{.data.admin-password}" | base64 --decode

.PHONY: update
update:
	helm repo update camunda
	helm search repo $(chart)
	OPERATE_SECRET=$$(kubectl get secret --namespace $(namespace) "$(release)-operate-identity-secret" -o jsonpath="{.data.operate-secret}" | base64 --decode); \
	TASKLIST_SECRET=$$(kubectl get secret --namespace $(namespace) "$(release)-tasklist-identity-secret" -o jsonpath="{.data.tasklist-secret}" | base64 --decode); \
	OPTIMIZE_SECRET=$$(kubectl get secret --namespace $(namespace) "$(release)-optimize-identity-secret" -o jsonpath="{.data.optimize-secret}" | base64 --decode); \
	KEYCLOAK_ADMIN_SECRET=$$(kubectl get secret --namespace $(namespace) "$(release)-keycloak" -o jsonpath="{.data.admin-password}" | base64 --decode) \
	KEYCLOAK_MANAGEMENT_SECRET=$$(kubectl get secret --namespace $(namespace) "$(release)-keycloak" -o jsonpath="{.data.management-password}" | base64 --decode) \
	POSTGRESQL_SECRET=$$(kubectl get secret --namespace $(namespace) "$(release)-postgresql" -o jsonpath="{.data.postgres-password}" | base64 --decode) \
	helm upgrade --namespace $(namespace) $(release) $(chart) -f $(chartValues) \
	  --set global.identity.auth.operate.existingSecret=$$OPERATE_SECRET \
	  --set global.identity.auth.tasklist.existingSecret=$$TASKLIST_SECRET \
	  --set global.identity.auth.optimize.existingSecret=$$OPTIMIZE_SECRET \
	  --set identity.keycloak.auth.adminPassword=$$KEYCLOAK_ADMIN_SECRET \
	  --set identity.keycloak.auth.managementPassword=$$KEYCLOAK_MANAGEMENT_SECRET \
	  --set identity.keycloak.postgresql.auth.password=$$POSTGRESQL_SECRET

.PHONY: clean-camunda
clean-camunda:
	-helm --namespace $(namespace) uninstall $(release)
	-kubectl delete -n $(namespace) pvc -l app.kubernetes.io/instance=$(release)
	-kubectl delete -n $(namespace) pvc -l app=elasticsearch-master
	-kubectl delete namespace $(namespace)

.PHONY: logs
logs:
	kubectl logs -f -n $(namespace) -l app.kubernetes.io/name=zeebe

.PHONY: watch
watch:
	kubectl get pods -w -n $(namespace)

.PHONY: watch-zeebe
watch-zeebe:
	kubectl get pods -w -n $(namespace) -l app.kubernetes.io/name=zeebe

.PHONY: await-zeebe
await-zeebe:
	kubectl wait --for=condition=Ready pod -n $(namespace) -l app.kubernetes.io/name=zeebe --timeout=900s

.PHONY: port-zeebe
port-zeebe:
	kubectl port-forward svc/$(release)-zeebe-gateway 26500:26500 -n $(namespace)

.PHONY: port-identity
port-identity:
	kubectl port-forward svc/$(release)-identity 8080:80 -n $(namespace)

.PHONY: port-keycloak
port-keycloak:
	kubectl port-forward svc/$(release)-keycloak 18080:80 -n $(namespace)

.PHONY: port-operate
port-operate:
	kubectl port-forward svc/$(release)-operate 8081:80 -n $(namespace)

.PHONY: port-tasklist
port-tasklist:
	kubectl port-forward svc/$(release)-tasklist 8082:80 -n $(namespace)

.PHONY: port-optimize
port-optimize:
	kubectl port-forward svc/$(release)-optimize 8083:80 -n $(namespace)

.PHONY: pods
pods:
	kubectl get pods --namespace $(namespace)

.PHONY: url-grafana
url-grafana:
	@echo "http://`kubectl get svc metrics-grafana-loadbalancer -n default -o 'custom-columns=ip:status.loadBalancer.ingress[0].ip' | tail -n 1`/d/I4lo7_EZk/zeebe?var-namespace=$(namespace)"

.PHONY: open-grafana
open-grafana:
	xdg-open http://$(shell kubectl get services metrics-grafana-loadbalancer -n default -o jsonpath={..ip})/d/I4lo7_EZk/zeebe?var-namespace=$(namespace) &

# create elf-signed certificate and pfx file
.PHONY: create-cert
create-cert:      
	openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -config ../cert/cert.cnf -keyout ../cert/private.key -out ../cert/appgwcert.crt
	openssl pkcs12 -export -out ../cert/appgwcert.pfx -inkey ../cert/private.key -in ../cert/appgwcert.crt -password  pass:camunda4tw