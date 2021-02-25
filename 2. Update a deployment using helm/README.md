# Update a deployment using helm
The goal of this section is to build a GitHub Actions pipeline that will update a deployment on Kubernetes using helm.


## needed
helm chart
    variables in helm --> one of those will be image + tag
pipeline.yaml --> run the action
    1. Login to Azure
    2. Get kubernetes credentials
    3. Update the deployment using helm --> --set tag=updated version (for example)
    4. Test the pipeline
    5. Put a trigger filter on the pipeline, so it only get triggered when changes to directory 1. or the deployment.yaml get made
