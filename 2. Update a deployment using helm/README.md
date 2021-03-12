# Update a deployment using helm
The goal of this section is to build a GitHub Actions pipeline that will update a deployment on Kubernetes using helm.

**Before proceeding to the below steps delete the aks deployment which you done previously with the command "kubectl delete service website"**

# Update the Deployment Document
In this step we are going to update the cluster with the v2 image. Open the deployment.yaml document in the "1. Update a deployment" folder and change the image version under containers from "image: nfranssens/simple-website:v1" to "image: nfranssens/simple-website:v2".  Save and Commit the changes to the repository.


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
 
 7.  Deploy the helm chart  and get the public ip . Copy the below code next

        - name: Helm upgrade
          run: |
          helm upgrade website "2. Update a deployment using helm/website" --install \
            --set image.repository=nfranssens/simple-website \
            --set image.tag=v2

        - name: Get service IP
                run: |
                  PUBLICIP=""
                  while [ -z $PUBLICIP ]; do
                    echo "Waiting for public IP..."
                    PUBLICIP=$(kubectl get service website -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                    [ -z "$PUBLICIP" ] && sleep 10
                  done
                  echo $PUBLICIP                 
  
   9. Save and commit the file.
   10. Test the pipeline by clicking the "Run Workflow" after selecting your pipeline under the workflows.
