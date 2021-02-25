# Update a deployment
The goal of this section is to build a GitHub Actions pipeline that will update a deployment on Kubernetes to a new version.

## needed
in the background: build a docker container and push to dockerhub so people can use it.

deployment.yaml --> create/update the deployment 
create a new SP and upload credentials to GH secrets.
pipeline.yaml --> run the action
    1. Login to Azure
    2. Get kubernetes credentials
    3. Update the deployment
    4. Test the pipeline
    5. Put a trigger filter on the pipeline, so it only get triggered when changes to directory 1. or the deployment.yaml get made

