# Build a container and push to ACR
The goal of this section is to build a GitHub Actions pipeline that will build a new container, push it to ACR and then update the deployed application on your cluster.


## needed
dockerfile
html
need to do az aks update --attach-acr (or we include this in the prerequisites??? maybe???)
helm chart
    variables in helm --> one of those will be image + tag
pipeline.yaml --> run the action
    1. Login to Azure
    2. login to ACR
    3. build image (tag - use either the github action runner version OR the SHA HASH from GIT)
    4. push image to registry
    2. Get kubernetes credentials
    3. Update the deployment using helm --> --set tag=updated version (for example)
    4. Test the pipeline
    5. Put a trigger filter on the pipeline, so it only get triggered when changes to directory 1. or the deployment.yaml get made


3. maybe we include a small script to run locally, that gets the current website and build a graph (how easy is this???) of what is returned as a value

