pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "us-east-1"
    }
    stages {
        stage("Create an EKS Cluster") {
            steps {
                script {
                    dir('eks-cluster') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                    }
                }
            }
        }
        stage("Deploy to EKS") {
            steps {
                script {
                    dir('fms-deployments') {
                        sh "aws eks update-kubeconfig --region us-east-1 --name project-eks --profile vscode"
                        sh "kubectl apply -f mongo-stack.yaml"
                        sh "kubectl apply -f storage.yaml"
                        sh "kubectl apply -f workloads.yaml"
                        sh "kubectl apply -f services.yaml"
        //                sh "kubectl apply -f ingress-nginx-controller.yaml"
        //                sh "kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s"
        //                sh "kubectl apply -f ingress.yaml"
                        sh "helm repo add nginx-stable https://helm.nginx.com/stable"
                        sh "helm repo update"
                        sh "helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace"
                        sh "helm repo add jetstack https://charts.jetstack.io"
                        sh "helm repo update"
                        sh "helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true"
                        sh "kubectl apply -f issuer.yaml"
                        sh "kubectl apply -f ingress.yaml"
                    }
                }
            }
        }
    }
}