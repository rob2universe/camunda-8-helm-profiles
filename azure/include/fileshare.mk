storageAccount ?= camstore39ed6doocbi7
# $(eval fsAccount := $(shell az storage account list --query "[?starts_with(name, 'camstore')].name" -o tsv))
fsRg ?= fileshare-rg
fsName ?= interceptors
haha ?= ""

.PHONY: storageAcc
storageAcc:
	$(eval storageAccount := camstore$(shell cat /dev/urandom | tr -dc 'a-z0-9' | fold -w $${1:-12} | head -n 1))
	az group create -n $(fsRg) -l $(region)
	echo Creating storage account: $(storageAccount)
	az storage account create -n $(storageAccount) -g $(fsRg) -l $(region) --sku Standard_LRS
	sleep 30

.PHONY: connectionString
connectionString:
	az storage account show-connection-string -n $(storageAccount) -g $(fsRg) --query 'connectionString' -o tsv

.PHONY: fileshare
fileshare:
	az storage share create -n $(fsName) --connection-string '$(shell az storage account show-connection-string -n $(storageAccount) -g $(fsRg) --query 'connectionString' -o tsv)'

.PHONY: fs-secret
fs-secret:
	$(eval fsAccountKey := $(shell az storage account keys list --resource-group $(fsRg) --account-name $(storageAccount) --query "[0].value" -o tsv))
	@echo Creating secret for storage account name: $(storageAccount) and key: $(fsAccountKey)
	kubectl create secret generic fs-secret --from-literal=azurestorageaccountname=$(storageAccount) --from-literal=azurestorageaccountkey=$(fsAccountKey)

.PHONY: clean-fs-secret
clean-fs-secret:
	kubectl delete secret fs-secret

.PHONY: clean-fileshare
clean-fileshare:
	az storage share delete -n $(fsShare) --connection-string '$(shell az storage account show-connection-string -n $(storageAccount) -g $(fsRg) --query 'connectionString' -o tsv)'
	az group delete -n $(fsRg)

.PHONY: upload-kc-interceptor
upload-kc-interceptor:
	$(eval fsConStr := $(shell az storage account show-connection-string -n $(storageAccount) -g $(fsRg) --query 'connectionString' -o tsv))
	az storage file upload -s $(fsName) --source ./zeebe-keycloak-interceptor-1.2.11-jar-with-dependencies.jar  --connection-string '$(fsConStr)'
