COLOR=`kubectl get svc bg-pipeline-blue-green -o yaml | grep " color" | awk -F ' ' '{print $2}'`
echo "Current prod is $COLOR"
if [ "$COLOR" = "blue" ];then
  echo "UPDATE=green" >> GITHUB_ENV
else
  echo "UPDATE=blue" >> GITHUB_ENV
fi
helm upgrade bg-pipeline "4. Simple blue green/website" --reuse-values \
    --set $UPDATE.repository=$ACRNAME.azurecr.io/microhack/website \
    --set $UPDATE.tag=${{ github.run_number }} \
kubectl rollout status deployment bg-pipeline-blue-green-$UPDATE