namespace ?= camunda
release ?= camunda
chart ?= camunda/camunda-platform
chartValues ?= ../camunda-values.yaml, camunda-values-kc.yaml

.PHONY: all
all: zb-kc-interceptor-config
	@echo "Installing camunda using chartValues: $(chartValues)"
	helm repo add camunda https://helm.camunda.io
	helm repo update camunda
	helm search repo $(chart)
	helm install --namespace $(namespace) $(release) $(chart) -f $(chartValues) --skip-crds --create-namespace
	-kubectl config set-context --current --namespace=$(namespace)

.PHONY: clean
clean: clean-camunda

include ../../include/camunda.mk