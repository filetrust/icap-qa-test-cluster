# icap-qa-test-cluster

Purpose of this repo is to create a test environment for the QA team, so that create and destroy clusters with ease and when ever they want to.

There should be no manual processes outside of running scripts.

## To do

1. Move terraform code across for following
	- Cluster
	- Keyvault
	- Storage Account
	- Storage account for statefile - can be store in tfstate
2. Move scripts across
	- keyvault secrets script
	- Kube secret scripts
3. Adapt scripts or make one large script to stand up efficiently
4. Test
