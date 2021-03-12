# Prerequisites
The goal of this section is to have you create an AKS cluster, an Azure Container Registry and deploy an initial application (deployment) on the cluster.

In this step, you deploy an AKS cluster and Azure Container Register (ACR) using an Azure Resource Manager template (ARM template).After the provision of the cluster you will be deploying the initial application with deployment.yaml file.

## Create Resource Group
Create a Resource group with the given Azure CLI Command. Replace {variable} with values. (Note : You can use Powershell, Portal as well)

**az group create --name {rgName} --location {rgRegion}**

## Create Service Principal
To interact with Azure APIs, an AKS cluster requires either an Azure Active Directory (AD) service principal or a managed identity. A service principal or managed identity is needed to dynamically create and manage other Azure resources such as an Azure load balancer or container registry (ACR).

Use the below command to create service prinicpal. Copy the JSON output and save it in a seperate file. You need this while configuring pipelines in GitHub Actions.

**az ad sp create-for-rbac --sdk-auth**

## Create an SSH key Pair
To access AKS nodes, you connect using an SSH key pair. Use the ssh-keygen command to generate SSH public and private key files.
The following command creates an SSH key pair using RSA encryption and a bit length of 2048. Copy the output and you will need it for the next step.

**ssh-keygen -t rsa -b 2048**

## Deploy AKS Cluster
We are now going to deploy the AKS Cluster along with ACR using the ARM templates. 
There are two templates in this folder : mh_azuredeploy.json and mh_azuredeploy.parameters.json.
Update clusterName, sshRSAPublicKey (copied from above step), acrName in the mh_azuredeploy.parameters.json and save it.

Run the below command to deploy AKS Cluster and ACR Service using the above templates. Replace resource group name with the one that you created in the first step.

**az deployment group create --resource-group {rgName} --template-file "mh_azuredeploy.json" --parameters "mh_azuredeploy.parameters.json"**

It will take several minutes to complete the deployment.

## Attach ACR for AKS Cluster

Once the above deployment completes, attach the AKS cluster with the ACR name using the below command.

**az aks update --resource-group {rgName} --name {aksClusterName} --attach-acr {acrName}**

## Initial deployment of Application in the cluster
To manage a Kubernetes cluster, you use kubectl, the Kubernetes command-line client. If you use Azure Cloud Shell, kubectl is already installed. To install kubectl locally, use the az aks install-cli command:

To configure kubectl to connect to your Kubernetes cluster use the below command
**az aks get-credentials --resource-group {rgName} --name {aksClusterName}**

To verify the connection to your cluster, use the below command

**kubectl get nodes**

The output shows the nodes created in the previous steps. Make sure that the status for all the nodes is Ready.

Deploy the sample application with the given manifest file (deployment.yaml)

**kubectl apply -f deployment.yaml**

The output shows the Deployments and Services created successfully.
