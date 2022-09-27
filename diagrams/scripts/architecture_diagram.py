from diagrams import Cluster, Diagram
from diagrams.aws.compute import EKS
from diagrams.aws.database import RDS
from diagrams.aws.network import NLB, Route53, PublicSubnet, PrivateSubnet, InternetGateway, NATGateway, TransitGateway
from diagrams.aws.general import Client, InternetAlt1
from diagrams.onprem.monitoring import Prometheus
from diagrams.onprem.compute import Server

with Diagram("Core network services monitoring architecture diagram", show=False):
  client = Client("user\naccessing\nGrafana dashboards")
  prometheus = Prometheus("other prometheus\nremotely writes metrics")
  dns = Route53("dns")
  tgw = TransitGateway("tgw")
  int = InternetAlt1("public_internet")
  ark_dc = Server("ark_data_centres")

  with Cluster("vpc"):
    nlb = NLB("nlb")

    with Cluster("private_subnet_eu-west-2"):
      eks = EKS("eks_cluster")

    with Cluster("public_subnet_eu-west-2"):
      ngw = NATGateway("nat_gateway")
      igw = InternetGateway("internet_gateway")

  eks >> ngw
  eks >> igw >> int
  client >> dns >> nlb >> eks
  prometheus >> dns
  ngw >> tgw >> ark_dc
