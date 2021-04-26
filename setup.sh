#rm -rf $HOME/.brew && git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew && export PATH=$HOME/.brew/bin:$PATH && brew update && echo "export PATH=$HOME/.brew/bin:$PATH" >> ~/.zshrc

#brew install minikube
minikube start --driver=virtualbox
# minikube start --driver=hyperkit
minikube status
MINIKUBE_IP=$(minikube ip)
eval $(minikube -p minikube docker-env)

echo "metalLB setup start"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" srcs/metallb-config_format.yaml > srcs/metallb-config.yaml
kubectl apply -f srcs/metallb-config.yaml
#kubectl apply -f metallb-config.yaml >> $LOG_PATH

echo "nginx setup start"
docker build -t alpine-nginx srcs/nginx_test2/
kubectl apply -f ./srcs/nginx_test2/nginx-ssh-configmap.yaml
kubectl apply -f ./srcs/nginx_test2/nginx.yaml
kubectl get all
