# Technical Documentation

This solution is hosted in a Amazon EKS cluster within the allocated VPC. This VPC has a CIDR block 10.180.100.0/22 and is attached to the MoJO TGW. Please refer to the architecture diagram below for a better understanding.

![Architecture diagram](/../main/documentation/diagrams/architecture_diagram.png)

Within the EKS cluster we have Grafana running as part of a replicaset with at least 2 replicas for higher availability. Prometheus is running with a Thanos sidecar which stores older metrics directly into a s3 bucket that is managed by thanos storage gateway. Prometheus has 10 days of retention period, however metrics are then held in the s3 bucket for up to 90 days. Please refer to the details EKS cluster diagram for more information:

![Detailed EKS cluster diagram](/../main/documentation/diagrams/detailed_eks_cluster_diagram.png)
