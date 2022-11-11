# Helm Profiles for Camunda 8 Developers

A lightweight development configuration for Camunda Platform 8, which uses an 
external elastic search instead of an image included by the Camunda 8 helm chart.
The setup can be used locally via any minimal Kubernetes environment as well as
 on a "real" Kubernetes cluster in a public or private cloud.

This folder contains a [Helm](https://helm.sh/) [values file](camunda-values.yaml)
for installing the [Camunda Platform Helm Chart](https://helm.camunda.io/)
on an existing Kubernetes cluster (if you don't have one yet,
see the `kind` folder, or one of the cloud provider folders for more information).
A [Makefile](Makefile) is provided to automate the installation process.

## Install

Note: you should already have a Kubernetes cluster running before you run this profile. Your `kubectl` should be configured to connect to your existing cluster. If you need to create a cluster, see the main [README.md](../README.md) for guidance.  

Run the following to install Camunda using the `camunda-values.yaml` file found in this directory: 

```sh
cd development
make
```

## Uninstall
```sh
cd development
make clean
```
