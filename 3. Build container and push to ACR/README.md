# Build a container and push to ACR
The goal of this section is to build a GitHub Actions pipeline that will build a new container, push it to ACR and then update the deployed application on your cluster.

To do this, you'll create a new GitHub action. The second part of the GitHub action will be very similar to the one you used in step 2, just with a different image reference.

## Step 1: Adding Docker build to GitHub Action
### Introduction
You have been provided with an ```index.html``` and ```Dockerfile```. Both are kept as simple as possible to demonstrate this demo. The ```index.html``` file contains a rudementary web page, and the ```Dockerfile``` will copy that file into an nginx container.

When building a container image on your local machine, you would typically execute the following steps on your commend line:
```bash
docker build -t <registry-name>/container:tag
docker push -t <registry-name>/container:tag
```
You could do the same thing in the GitHub Action. The Docker CLI is installed on the hosted action runner, allowing you to build a workflow that way. 

However, there also is a prebuilt action that can do both steps at once. The following code snippet (if part of an action workflow) can build and push an image in one step:
```yaml
      - name: Build and push image
        uses: docker/build-push-action@v2
        with:
          context: ./<folder>
          push: true
          tags: <registry-name>/container:tag
```
A final note before building the actual action is about the usage of tags in containers and Kubernetes. As you build new versions of your container image, you'll need to tag them. One strategy that is discouraged is to tag container images with the latest tag and use that tag in your Kubernetes deployments. The latest tag is the default tag that Docker will add to images if no tag is supplied. The problem with the latest tag is that if the image with the latest tag changes in your container registry, Kubernetes will not pick up this change directly. On nodes that have a local copy of the image with the latest tag, Kubernetes will not pull the new image until a timeout expires; however nodes that don’t have a copy of the image, will pull the updated version when they need to run a pod with this image. This can cause you to have different versions running in a single deployment, which should be avoided.

For production images that you push to production, you can use semantic versioning as part of a release pipe. For build/testing pipelines, you can either use the github commit hash or the github action runner number to number to container. That way you can easily push a test version to a Kubernetes cluster, without having to worry too much about semantic versioning in your pipeline. 

In the example you'll build below, you will use the GitHub action runner number as the image tag.

### Building the pipeline

Let's go ahead and build the pipeline to build a container image and push that to kubernetes. As an outline for this action, you'll need to execute the following steps:
* CI job
    * Git checkout
    * Login to ACR 
    * Build and push image
* CD job
    * Git checkout
    * Login to AKS
    * Helm update to new image

Let's start by setting up the action itself. Create a new action and name the file ```3_build_and_push.yaml```, and past in the following code at the top. This is similar to what you've run in the previous examples:
```yaml
# This is a basic workflow to help you get started with Actions

name: Excersize 3, build container and update

# Controls when the action will run. 
on:
  # Triggers the workflow on push or pull request events but only for the main branch
  push:
    branches: [ main ]
    paths: 
    - 3. Build container and push to ACR/**
    - .github/workflows/3_build_and_push.yaml

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:
# Env to set reusable variables
env:
  ACRNAME: <your acr name>
```
This gives a name to the pipeline, and controls what triggers this pipeline. You also set a variable for the ACR name, so you can easily reuse this variable later.

Next, you'll need to build the CI job with its 3 steps. You can use the following code to execute the CI job:

```yaml
jobs:
  CI:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest
    
    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - name: Git checkout
        uses: actions/checkout@v2

      - name: az CLI login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: ACR login
        run: az acr login -n $ACRNAME
        
      
      - name: Build and push image
        uses: docker/build-push-action@v2
        with:
          context: "./3. Build container and push to ACR"
          push: true
          tags: $ACRNAME.azurecr.io/microhack/website:${{ github.run_number }}
```
As you can see, this executes 4 steps:
1. Git checkout
2. Azure CLI login as you've done in previous steps
3. ACR login using the command line. There is also a built-in action to do ACR login, but that uses docker credentials and not a service principal.
4. Build and push the image.

Now, save this file and watch the action run. Then go to the Azure portal, check your ACR and see whether or not the image tag is available.

## Step 2: Upgrade application
Now you can execute the second part of this pipeline, namely upgrading your application. This should be very similar to the second demo you did as part of this microhack, namely doing a helm upgrade. 

To do this helm upgrade, you'll need to execute the following steps in your pipeline:
* Git checkout
* Login to AKS
* Helm upgrade

You can use the following code to achieve this. Paste this code underneath the CI job in the action you built in step 1. Don't forget to input your cluster details.

```yaml
  CD:
    runs-on: ubuntu-latest
    needs: CI
    steps:
      - name: Git checkout
        uses: actions/checkout@v2

      - name: Azure Kubernetes set context
        uses: Azure/aks-set-context@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
          resource-group: <RG of cluster>
          cluster-name: <cluster name>

      - name: Helm upgrade
        run: |
          helm upgrade website Chapter15/website --install \
            --set image.repository=$ACRNAME.azurecr.io/microhack/website \
            --set image.tag=${{ github.run_number }}
```

Save this file and see the pipeline run. In GitHub actions, you should now see a pipeline with two stages. In the next demo you'll take this one step further and also include a manual approval. 

To test the end-to-end pipeline, you can also make changes to the ```index.html``` file. Watch those changes go through the pipeline, and finally browse to your website to see the changes be applied. 

Optionally, you can use the show-versions.sh script in either cloud shell or a local bash window to show the version that is returned. To run the script simply run:
```bash
sh show-versions.sh <ip address>
```
This will get the IP address 5 times per second and show you the current live version. As you're running this, you might notice that during the update you get a mix of v1 and v2 (or whatever version you're running). This is because by default kubernetes does a rolling update. In the next demo, you'll deploy a very basic version of a blue-green deployment in Kubernetes.

