namespace ?= camunda
release ?= camunda
chart ?= camunda/camunda-platform
chartValues ?= camunda-values.yaml

.PHONY: all
all: zb-kc-interceptor-config
	@echo "Installing camunda using chartValues: $(chartValues)"
	helm install --namespace $(namespace) $(release) $(chart) -f $(chartValues) --skip-crds --create-namespace
	-kubectl config set-context --current --namespace=$(namespace)

.PHONY: zb-kc-interceptor-config
zb-kc-interceptor-config: 
	kubectl create namespace $(namespace)
	kubectl apply -f zb-kc-interceptor-config.yaml -n $(namespace)

.PHONY: update-zb-kc-interceptor-config
update-zb-kc-interceptor-config: 
	kubectl apply -f zb-kc-interceptor-config.yaml -n $(namespace)

.PHONY: clean
clean: clean-camunda

include ../../include/camunda.mk