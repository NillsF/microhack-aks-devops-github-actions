# Microhack: AKS CI/CD using GitHub Actions
A microhack to learn more about the CI/CD process for AKS using Github Actions.

This microhack consists of 5 steps:
1. Setup the required infrastructure
2. Update a raw Kubernetes deployment (CD only)
3. Update an Helm chart (CD only)
4. Build an image and update a Helm chart (CI and CD)
5. Build an image and do a blue/green deployment (CI and CD)

Each step is contained in a folder, with the required explanation. 

It is recommended to fork this repository, and then iteratively build your own GitHub actions.
After forking the repo, you can delete the .github/workflows folder if you want to build the workflows from scratch.

# Optional: visualization tool
A totally optional add-on to this Microhack is the clusterinfo tool built by Mark Kizhnerman. This tool can show you what is deployed on your cluster, and will show you live updates.

To install the tool, follow the following steps:
1. Download the tool (link will be shared while running the microhack)
2. Extract zip file
3. Navigate to helm chart directory
4. Install using helm (```helm install clusterinfo .```)
5. Port-forward the clusterinfo service (```kubectl port-forward svc/clusterinfo 5252 -n clusterinfo``` )
6. If running in localhost, browse to http://localhost:5252. If running in cloud shell, expose the 5252 in cloud shell.

Things to look for in the clusterinfo tool
1. Pods supporting a service and version of that pod
2. Pods in a deployment and how the deployment updates
3. (only in blue-green sample) color coded pods in the clusterinfo tool.
