.PHONY: camunda
camunda:
	@echo "Attempting to install camunda using chartValues: $(chartValues)"
	helm repo add camunda https://helm.camunda.io
	helm repo update camunda
	helm search repo $(chart)
	helm install --namespace $(namespace) $(release) $(chart) -f $(chartValues) --skip-crds --create-namespace
	-kubectl config set-context --current --namespace=$(namespace)

# .PHONY: namespace
# namespace:
# 	-kubectl create namespace $(namespace)
# 	-kubectl config set-context --current --namespace=$(namespace)

# Generates templates from the camunda helm charts, useful to make some more specific changes which are not doable by the values file.
.PHONY: template
template:
	helm template $(release) $(chart) -f $(chartValues) --skip-crds --output-dir .
	@echo "To apply the templates use: kubectl apply -f camunda-platform/templates/ -n $(namespace)"

.PHONY: keycloak-password
keycloak-password:
	$(eval kcPassword := $(shell kubectl get secret --namespace $(namespace) "$(release)-keycloak" -o jsonpath="{.data.admin-password}" | base64 --decode))
	@echo KeyCloak Admin password: $(kcPassword)	

.PHONY: config-keycloak
config-keycloak: keycloak-password
	kubectl wait --for=condition=Ready pod -l app.kubernetes.io/component=keycloak --timeout=600s
	kubectl -n $(namespace) exec -it $(release)-keycloak-0 -- /opt/bitnami/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE --server http://localhost:8080/auth --realm master --user admin --password $(kcPassword)
	kubectl -n $(namespace) exec -it $(release)-keycloak-0 -- /opt/bitnami/keycloak/bin/kcadm.sh update realms/camunda-platform -s sslRequired=NONE --server http://localhost:8080/auth --realm master --user admin --password $(kcPassword)

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

.PHONY: zeebe-logs
zeebe-logs:
	kubectl logs -f -n $(namespace) -l app.kubernetes.io/name=zeebe

.PHONY: keycloak-logs
keycloak-logs:
	kubectl logs -f -n $(namespace) -l app.kubernetes.io/name=keycloak

.PHONY: identity-logs
identity-logs:
	kubectl logs -f -n $(namespace) -l app.kubernetes.io/name=identity

.PHONY: operate-logs
operate-logs:
	kubectl logs -f -n $(namespace) -l app.kubernetes.io/name=operate

.PHONY: tasklist-logs
tasklist-logs:
	kubectl logs -f -n $(namespace) -l app.kubernetes.io/name=tasklist

.PHONY: es-logs
es-logs:
	kubectl logs -f -n $(namespace) -l app=elasticsearch-master

.PHONY: get-ingress
get-ingress:
	kubectl get ingress -l app.kubernetes.io/name=camunda-platform -o yaml

.PHONY: watch
watch:
	kubectl get pods -w -n $(namespace)

.PHONY: watch-zeebe
watch-zeebe:
	kubectl get pods -w -n $(namespace) -l app.kubernetes.io/name=zeebe

.PHONY: await-zeebe
await-zeebe:
	kubectl rollout status --watch statefulset/$(release)-zeebe --timeout=900s -n $(namespace)

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

