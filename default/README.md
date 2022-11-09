# Camunda 8 Helm Profile: Default

A configuration for Camunda Platform 8
that relies only on the defaults provided by the official Helm chart
and also serves as a template for creating new profiles.

This folder contains a [Helm](https://helm.sh/) [values file](camunda-values.yaml)
for installing the [Camunda Platform Helm Chart](https://helm.camunda.io/)
on an existing Kubernetes cluster (if you don't have one yet, see [Cloud-platform-specific Profiles](https://github.com/camunda-community-hub/camunda-8-helm-profiles/blob/master/README.md#cloud-platform-specific-profiles)).
A [Makefile](Makefile) is provided to automate the installation process.

## Install

Make sure you meet [these prerequisites](https://github.com/camunda-community-hub/camunda-8-helm-profiles/blob/master/README.md#prerequisites).

Configure the desired Kubernetes `namespace`, Helm `release` name, and Helm `chart` in [Makefile](Makefile)
and run:

```sh
make
```

If `make` is correctly configured, you should also get tab completion for all available make targets.

## Uninstall
```sh
make clean
```
