# Networking Access to Kubernetes
resource "aws_security_group" "gitpod-cluster" {
  name                   = "terraform-eks-gitpod-cluster"
  description            = "Cluster communication with worker nodes"
  vpc_id                 = aws_vpc.gitpod.id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-gitpod"
  }
}

# Allow me to Access Cluster from a workstation
resource "aws_security_group_rule" "gitpod-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.gitpod-cluster.id
  to_port           = 443
  type              = "ingress"
}

# The Kubernetes Cluster!
resource "aws_eks_cluster" "gitpod" {
  name     = var.kubernetes.cluster-name
  role_arn = aws_iam_role.gitpod-cluster.arn

  vpc_config {
    endpoint_public_access = true
    security_group_ids     = [aws_security_group.gitpod-cluster.id]
    subnet_ids             = aws_subnet.gitpod[*].id
  }

  provisioner "local-exec" {
    command     = <<EOF
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
helm upgrade --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .;
real_url=$(kubectl get svc | grep -E '^proxy' | awk '{print $4}');
sed -i "2s/.*/  hostname: $real_url/" values.yaml;
sed -i "14s/.*/      callBackUrl: \"https:\/\/$real_url\/auth\/github\/callback\"/" values.yaml;
sleep 10;
helm upgrade --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .;
EOF
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.gitpod-cluster-AmazonEKSServicePolicy,
  ]
}
