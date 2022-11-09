# ------------------------------------
# The following variables should not be changed except for advanced use cases

root ?= $(shell pwd)/..

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

#chartValues ?= $(root)/development/camunda-values.yaml
chartValues ?= $(root)/development/camunda-values.yaml

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