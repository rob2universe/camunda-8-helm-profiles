.PHONY: external-urls
external-urls:
	@echo https://$(fqdn)/auth
	@echo https://$(fqdn)/identity
	@echo https://$(fqdn)/operate
	@echo https://$(fqdn)/tasklist
	@echo https://$(fqdn)/optimize
	@echo zbctl status --address $(fqdn):443