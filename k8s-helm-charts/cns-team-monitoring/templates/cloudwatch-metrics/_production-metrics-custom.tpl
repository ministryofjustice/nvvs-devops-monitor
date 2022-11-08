{{ define "cloudwatchMetrics.production.custom" }}
- namespace: ECS/ContainerInsights
  name: "ECS - Container Insights"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  dimensions:
  - name: ClusterName
    value: staff-device-{{ .Values.environment }}-dhcp-cluster
  - name: ServiceName
    value: staff-device-{{ .Values.environment }}-dhcp-standby-service
  metrics:
  - name: RunningTaskCount
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
- namespace: ECS/ContainerInsights
  name: "ECS - Container Insights"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  dimensions:
  - name: ClusterName
    value: staff-device-{{ .Values.environment }}-dhcp-cluster
  - name: ServiceName
    value: staff-device-{{ .Values.environment }}-dhcp-primary-service
  metrics:
  - name: RunningTaskCount
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
- namespace: ECS/ContainerInsights
  name: "ECS - Container Insights"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  dimensions:
  - name: ClusterName
    value: staff-device-{{ .Values.environment }}-dhcp-cluster
  - name: ServiceName
    value: staff-device-{{ .Values.environment }}-dhcp-api-service
  metrics:
  - name: RunningTaskCount
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
- namespace: ECS/ContainerInsights
  name: "ECS - Container Insights"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  dimensions:
  - name: ClusterName
    value: staff-device-{{ .Values.environment }}-dns-cluster
  - name: ServiceName
    value: staff-device-{{ .Values.environment }}-dns-service
  metrics:
  - name: RunningTaskCount
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
- namespace: DNS-Bind-Server
  name: "DNS Bind Server"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  metrics:
  - name: CookieIn
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: CookieNew
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: Prefetch
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryAuthAns
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryDropped
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryDuplicate
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryNoauthAns
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryNXDOMAIN
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryNxrrset
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryRecursion
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryReferral
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QrySERVFAIL
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QrySuccess
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: QryUDP
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: RecursClients
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: ReqEdns0
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: Requestv4
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: RespEDNS0
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: Response
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
  - name: TruncatedResp
    statistics: [Average, Maximum, Minimum]
    nilToZero: true
    period: 300
    length: 300
- namespace: Kea-DHCP
  name: "Kea DHCP"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  dimensions:
  - name: Server
    value: primary
  metrics:
  - name: pkt4-offer-sent
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: pkt4-request-received
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: pkt4-ack-sent
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: pkt4-discover-received
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: pkt4-nak-received
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: pkt4-nak-sent
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: pkt4-decline-received
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
- namespace: Kea-DHCP
  name: "Kea DHCP"
  regions: [eu-west-2]
  dimensions:
  - name: Subnet
    value: 10.178.0.0/16
  - name: Subnet
    value: 10.86.176.0/24
  - name: Subnet
    value: 10.86.182.0/24
  - name: Subnet
    value: 10.92.112.0/24
  - name: Subnet
    value: 10.92.96.0/24
  metrics:
  - name: lease-percent-used
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
- namespace: Kea-DHCP
  name: "Kea DHCP"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  metrics:
  - name: STANDBY_WARN
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: STANDBY_ERROR
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: STANDBY_FATAL
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Configuration successful"
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Config reload failed"
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "STANDBY_Config reload failed"
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "STANDBY_Configuration successful"
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: HA_SYNC_FAILED
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: HA_HEARTBEAT_COMMUNICATIONS_FAILED
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: STANDBY_HA_HEARTBEAT_COMMUNICATIONS_FAILED
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: ALLOC_ENGINE_V4_ALLOC_ERROR
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: ALLOC_ENGINE_V4_ALLOC_FAIL
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: ALLOC_ENGINE_V4_ALLOC_FAIL_CLASSES
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: STANDBY_ALLOC_ENGINE_V4_ALLOC_FAIL
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: STANDBY_ALLOC_ENGINE_V4_ALLOC_FAIL_CLASSES
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: reclaimed-declined-addresses
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: reclaimed-leases
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: STANDBY_HA_SYNC_FAILED
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: ERROR
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: FATAL
    statistics: [Average, Sum]
    nilToZero: true
    period: 300
    length: 300
- namespace: mojo-nac-requests
  name: "mojo-nac-requests"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  metrics:
  - name: "Sent Access-Accept"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Sent Access-Reject"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Ignoring request to auth proto tcp address"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Ignoring request to auth address"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Error post_auth - Failed to find attribute"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Error python"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "All other errors"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Shared secret is incorrect"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "unknown CA"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "authorized_macs users Matched entry"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Health Check OK"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
  - name: "Failed to start task"
    statistics: [Sum]
    nilToZero: true
    period: 300
    length: 300
- namespace: GP_GATEWAY_VMseries
  name: "GP_GATEWAY_VMseries"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  metrics:
  - name: "panSessionUtilization"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionThroughputPps"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionThroughputKbps"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionSslProxyUtilization"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionConnectionsPerSecond"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionActive"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panGPGWUtilizationActiveTunnels"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panGPGatewayUtilizationPct"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "DataPlanePacketBufferUtilization"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "DataPlaneCPUUtilizationPct"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
- namespace: GP_PORTAL_VMseries
  name: "GP_PORTAL_VMseries"
  regions: [eu-west-2]
  roles:
    - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
    - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
    - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
  metrics:
  - name: "panSessionUtilization"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionThroughputPps"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionThroughputKbps"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionSslProxyUtilization"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionConnectionsPerSecond"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panSessionActive"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panGPGWUtilizationActiveTunnels"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "panGPGatewayUtilizationPct"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "DataPlanePacketBufferUtilization"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
  - name: "DataPlaneCPUUtilizationPct"
    statistics: [Average]
    nilToZero: true
    period: 300
    length: 300
{{ end }}
