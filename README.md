---
owner_slack: "#mojo-cloud-ops"
title: NVV DevOps Monitoring - README
last_reviewed_on: 2022-09-30
review_in: 3 months
---

# NVV DevOps Monitoring

[![Deployment](https://github.com/ministryofjustice/staff-infrastructure-monitoring-cluster/actions/workflows/deployment.yml/badge.svg)](https://github.com/ministryofjustice/staff-infrastructure-monitoring-cluster/actions/workflows/deployment.yml)

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.data%5B%3F%28%40.name%20%3D%3D%20%22template-repository%22%29%5D.status&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fgithub_repositories)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/github_repositories#template-repository "Link to report")

## What is it?

Monitoring solution developed by the CNS team (Core Network Service team) to monitor the applications that this team currently manages.

### What applications are being monitored by this solution?

- [MoJO DNS Service](https://github.com/ministryofjustice/staff-device-dns-server)
- [MoJO DHCP Service](https://github.com/ministryofjustice/staff-device-dhcp-server)
- [DNS and DHCP Administration Portal](https://github.com/ministryofjustice/staff-device-dns-dhcp-admin)
- [SMTP Relay](https://github.com/ministryofjustice/staff-infrastructure-smtp-relay-server)
- [Network Access Control Service (NACS)](https://github.com/ministryofjustice/network-access-control-server)
- [Public Key Infrastructure (PKI)](https://github.com/ministryofjustice/staff-infrastructure-certificate-services)
- Monitoring Solution itself (EKS Cluster)

### What metrics are monitored?

This is a high level list of metrics which are monitored, if a metric is not mentioned here this does not necessarily mean it is not monitored.

- MoJO DNS:
  - Uptime
  - Bandwidth
- MoJO DHCP:
  - Uptime
  - Subnet usage
  - Bandwidth
  - Runtime errors
- DNS / DHCP Admin Portal
- SMTP Relay:
  - Message count
  - Deferred messages count
- Network Access Control Service:
  - Uptime
  - Resource
  - Errors
  - Authentication success / failures
- Monitoring infrastructure (EKS Cluster):
  - Uptime
  - Resource
  - Bandwidth / Network

### Where do we send alerts to?
Alerts are sent to various slack channels and pagerduty.

### How it works?
This solution consists of [Prometheus](https://github.com/prometheus/prometheus), [Thanos](https://github.com/thanos-io/thanos), [Grafana](https://github.com/grafana/grafana) and other exporters. Exporters enable Prometheus to scrape metrics from different sources and Grafana produces dashboards with those metrics. Thanos leverages the Prometheus storage format to cost-efficiently store historical metric data in a S3 bucket while retaining fast query latencies. Additionally, it provides a global query view across all Prometheus installations. This means Prometheus instances running elsewhere can remotely write metrics to this system, Grafana can then visualise them and metrics are stored in the central storage.

Helm charts used in this solution:

- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [thanos](https://artifacthub.io/packages/helm/bitnami/thanos)

To access the dashboards and query metrics use grafana at the below address.
| 📊 Grafana |
|:-----|
| https://monitoring-alerting.staff.service.justice.gov.uk |

Logon access to grafana is managed on Production Azure AD. Please contact azure team to gain access.

To consume metrics from _other_ Prometheus instances using the remote write functionality, configure your prometheus to remote write to the below url:
| ✍️ Prometheus Remote Write |
|:-----|
| https://thanos-receive.monitoring-alerting.staff.service.justice.gov.uk/api/v1/receive |

For technical details, HLDs, LLDs and developer instructions, please visit the [technical documentation page](documentation/technical-documentation.md).
