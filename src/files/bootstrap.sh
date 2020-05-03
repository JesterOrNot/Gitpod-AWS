aws eks --region ${var.aws.region} update-kubeconfig --name ${var.kubernetes.cluster-name};
kubectl apply -f '${local.config_map_aws_auth}';
if ! [ -d self-hosted ]; then git clone "https://github.com/gitpod-io/self-hosted.git"; fi;
cd self-hosted;
kubectl create -f utils/helm-2-tiller-sa-crb.yaml || echo 'already configured';
helm repo add charts.gitpod.io "https://charts.gitpod.io";
helm dep update;
cat <<EOT >values.yaml
gitpod:
  hostname: ${var.gitpod.domain}
  components:
    proxy:
      loadBalancerIP: null
  authProviders:
  - id: "${var.gitpod.id}"
    host: "${var.gitpod.host-url}"
    protocol: "${var.gitpod.protocol}"
    type: "${var.gitpod.provider}"
    oauth:
      clientId: "${var.gitpod.client-id}"
      clientSecret: "${var.gitpod.client-secret}"
      callBackUrl: "${var.gitpod.protocol}://${var.gitpod.provider}/auth/github/callback"
      settingsUrl: "${var.gitpod.settings-url}"
  installPodSecurityPolicies: true

docker-registry:
  enabled: true

gitpod_selfhosted:
  variants:
    customRegistry: false
EOT;
echo 'values.yaml' >configuration.txt;
# helm upgrade --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .;
# real_url=$(kubectl get svc | grep -E '^proxy' | awk '{print $4}');
# sed -i "2s/.*/  hostname: $real_url/" values.yaml;
# sed -i "14s/.*/      callBackUrl: \"https:\/\/$real_url\/auth\/github\/callback\"/" values.yaml;
# sleep 10;
# helm upgrade --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .;
