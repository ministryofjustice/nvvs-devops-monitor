from diagrams import Cluster, Diagram, Edge
from diagrams.k8s.compute import Pod, RS
from diagrams.k8s.network import Ing, SVC
from diagrams.aws.storage import S3
from diagrams.aws.general import Client
from diagrams.onprem.monitoring import Prometheus
from diagrams.k8s.storage import PV
from diagrams.aws.management import Cloudwatch
from diagrams.programming.framework import Fastapi
from diagrams.saas.chat import Slack

with Diagram("Detailed EKS cluster diagram", show=False, direction="TB"):
  client = Client("User")
  other_prometheus = Prometheus("Other prometheus")
  slack = Slack("Slack channels")
  s3_bucket = S3("Storage")

  with Cluster("EKS Cluster"):
    grafana_ingress = Ing("Grafana ingress")
    persistent_volume = PV("Grafana persistent\nvolume")
    thanos_receive_ingress = Ing("Thanos receive ingress")
    prometheus = Pod("Prometheus")
    grafana = RS("Grafana")
    alertmanager = Pod("Alertmanager")

    with Cluster("Thanos stack"):
      thanos_receive = Pod("Thanos receive")
      thanos_query = Pod("Thanos query")
      thanos_storage_gateway = Pod("Thanos storage gateway")
      thanos_compactor = Pod("Thanos compactor")

    with Cluster("Exporters"):
      blackbox_exporter = Pod("Blackbox exporter")
      cloudwatch_exporter = Pod("Cloudwatch exporter")
      json_exporter = Pod("JSON exporter")

    grafana_service = SVC("Grafana service")

  client >> Edge(color="blue", style="bold") >> \
  grafana_ingress >> Edge(color="blue", style="bold") >> \
  grafana_service >> Edge(color="blue", style="bold") >> \
  grafana >> Edge(color="red", style="bold") >> \
  thanos_query

  persistent_volume << Edge(color="brown", style="bold") << grafana

  other_prometheus >> Edge(color="darkgreen", style="bold") >> thanos_receive_ingress >> Edge(color="darkgreen", style="bold") >> thanos_receive

  thanos_query >> Edge(color="red", style="bold") >> \
  prometheus >> Edge(color="green", style="bold", label="Stores metrics in") >> \
  s3_bucket

  thanos_query >> Edge(color="red", style="bold") >> \
  thanos_storage_gateway >> Edge(color="purple", style="bold") >> \
  s3_bucket

  thanos_query >> Edge(color="red", style="bold") >> \
  thanos_receive >>Edge(color="green", style="bold", label="Stores metrics in") >> \
  s3_bucket

  slack << Edge(color="orange", style="bold") << alertmanager << Edge(color="orange", style="bold") << prometheus
  thanos_compactor >> Edge(color="magenta", style="dashed") >> s3_bucket
  blackbox_exporter >> Edge(color="black", style="bold") >> prometheus
  cloudwatch_exporter >> Edge(color="crimson", style="bold") >> prometheus
  json_exporter >> Edge(color="crimson", style="bold") >> prometheus
