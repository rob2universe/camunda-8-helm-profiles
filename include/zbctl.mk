# Show zeebe status
# T: test/fix with new ingress
.PHONY: zb-status
zb-status:
	ZEEBE_ADDRESS=zeebe.$(fqdn):26500
	zbctl status --insecure

# zbctl --insecure deploy /mnt/c/Users/Rob/Downloads/onetask.bpmn
# zbctl --insecure create instance MyProcess
