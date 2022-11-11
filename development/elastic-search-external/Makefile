# ------------------------------------
# The following variables should not be changed except for advanced use cases
root ?= $(shell pwd)/../..

# Camunda components will be installed into the following Kubernetes namespace
namespace ?= camunda
# Helm release name
release ?= camunda
# Helm chart coordinates for Camunda
chart ?= camunda/camunda-platform

#chartValues ?= $(root)/development/camunda-values.yaml
chartValues ?= $(root)/development/elastic-search-external/camunda-values.yaml

.PHONY: all
all: elastic-search camunda

.PHONY: elastic-search
elastic-search: 
	helm repo add elastic https://helm.elastic.co
	helm repo update
	helm install elastic-search elastic/elasticsearch -n elastic-search --create-namespace -f elastic-search-values.yaml

.PHONY: clean-elastic-search
clean-elastic-search:
	helm uninstall elastic-search -n elastic-search
	kubectl delete -n elastic-search pvc -l app=elasticsearch-master
	kubectl delete -n elastic-search pv -l app=elasticsearch-master
	kubectl delete namespace elastic-search

.PHONY: clean
clean: clean-camunda

include $(root)/include/camunda.mk