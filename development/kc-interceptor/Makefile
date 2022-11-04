namespace ?= camunda
release ?= camunda
chart ?= camunda/camunda-platform
chartValues ?= camunda-values.yaml

.PHONY: all
all: camunda

.PHONY: zb-kc-interceptor-config
zb-kc-interceptor-config: 
	kubectl create namespace $(namespace)
	kubectl apply -f zb-kc-interceptor-config.yaml -n $(namespace)

.PHONY: clean
clean: clean-camunda

include ../../include/camunda.mk