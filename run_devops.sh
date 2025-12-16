cd infra
terraform init
terraform plan
terraform apply

cd ..

aws eks update-kubeconfig --region us-east-1 --name django-eks-cluster

docker build -t django-app:latest . --no-cache
docker tag django-app:latest 718533829649.dkr.ecr.us-east-1.amazonaws.com/django-app:latest
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 718533829649.dkr.ecr.us-east-1.amazonaws.com/django-app
docker push 718533829649.dkr.ecr.us-east-1.amazonaws.com/django-app:latest

ansible-playbook ./ansible/playbook.yaml -e "deploy_env=prod db_password=postgres"
ansible-playbook ./ansible/monitoring.yaml

PROMETHEUS_URL=$(kubectl get svc prometheus-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
GRAFANA_URL=$(kubectl get svc grafana-service -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
GRAFANA_PASSWORD=$(kubectl get secret grafana-credentials -n monitoring -o jsonpath='{.data.admin-password}' | base64 --decode)

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "Prometheus: http://$PROMETHEUS_URL:9090"
echo "Grafana: http://$GRAFANA_URL:3000"
echo "Grafana Login: admin/$GRAFANA_PASSWORD"
echo "=========================================="

kubectl get all -n django-app-prod
kubectl get all -n monitoring

# Access monitoring (wait 2-3 minutes for LoadBalancers)
# Open browser and go to Grafana URL
# Import Dashboard 9528 for Django metrics