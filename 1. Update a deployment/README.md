# Update a deployment with GitHub Actions
GitHub Actions enables you to automate, customize, and execute development workflows in your repository with GitHub Actions. The goal of this section is to build a GitHub Actions pipeline that will update a deployment on Kubernetes to a new version.

**Before proceeding to the below steps fork this repository "https://github.com/NillsF/microhack-aks-devops-github-actions" to your github account.**

# Update the Deployment Document
In our initial deployment we have deployed the website v1 image in the AKS cluster from the docker repository. In this step we are going to update the cluster with the v2 image.
Open the deployment.yaml document in the "0. Prerequisites" folder and change the image version under containers from "image: nfranssens/simple-website:v1" to "image: nfranssens/simple-website:v2".  Save and Commit the changes to the repository.

# Create Secret
We need the service principal credentials for the pipelines to deploy the application into the AKS Cluster. The credentials needs to be stored in GitHub for the pipelines to access during the run. 

Copy the Service Principal JSON output that you created and stored in the previous step.
Click Settings tab and click "Secrets" in the left menu. Click "New repository secret" button and enter Name as "AZURE_CREDENTIALS"  and the copied JSON in the value text box.
Click Add Secret button.

# Create and run the Actions workflow
Now we are going to create the CD pipeline to deploy the updated deployment manifest document into the AKS cluster.

1. Click Actions Tab in the repository.
2. Click "New Workflow "button. 
3. Click the link "setup a workflow yourself" under "Choose a workflow template" label.
4. Name the file as pipelinecd.yml. 
5. In the file go to Steps under Jobs. Remove every thing under the line "- uses: actions/checkout@v2"
6. Setting the AKS Context - Copy the below code next to the line "- uses: actions/checkout@v2". Replace $rgName and $clusterName with your resource group and cluster names respectively.
        - name: Azure Kubernetes set context
          uses: Azure/aks-set-context@v1
          with:
            creds: ${{ secrets.AZURE_CREDENTIALS }}
            resource-group: $rgName
            cluster-name: $clusterName
 
 7.  Deploying the updated manifest (deployment.yaml) and get the public ip . Copy the below code next

        - name: App Yaml Deployment
          uses: Azure/k8s-deploy@v1.4
          with:
            manifests: |
              "1. Update a deployment/deployment.yaml"
            kubectl-version: 'latest'

        - name: Get service IP
                run: |
                  PUBLICIP=""
                  while [ -z $PUBLICIP ]; do
                    echo "Waiting for public IP..."
                    PUBLICIP=$(kubectl get service website -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                    [ -z "$PUBLICIP" ] && sleep 10
                  done
                  echo $PUBLICIP
                  
   8. If you would like to run this pipeline when there is a change in the deployment.yaml then add the file under push at the top. Example below.
        paths: 
        - microhack-aks-devops-github-actions/**
        - "1. Update a deployment/deployment.yaml"
   10. Save and commit the file.
   11. Test the pipeline by clicking the "Run Workflow" after selecting your pipeline under the workflows.
