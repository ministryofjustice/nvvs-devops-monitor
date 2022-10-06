{{ define "cloudwatchMetrics.production" }}
discovery:
  exportedTagsOnMetrics:
    ec2:
      - Name
      - type
    ecs:
      - ClusterName
      - ServiceName
    s3:
      - BucketName
      - StorageType
  jobs:
  - type: AWS/EC2
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: CPUUtilization
        statistics: [Average, Minimum, Maximum, Sum]
        nilToZero: true
      - name: StatusCheckFailed
        statistics: [Average]
        nilToZero: true
      - name: StatusCheckFailed_Instance
        statistics: [Sum]
        nilToZero: true
      - name: StatusCheckFailed_System
        statistics: [Sum]
        nilToZero: true
      - name: NetworkIn
        statistics: [Average]
        nilToZero: true
      - name: NetworkOut
        statistics: [Average]
        nilToZero: true
      - name: NetworkPacketsIn
        statistics: [Average]
        nilToZero: true
      - name: NetworkPacketsOut
        statistics: [Average]
        nilToZero: true
      - name: DiskReadBytes
        statistics: [Average]
        nilToZero: true
      - name: DiskWriteBytes
        statistics: [Average]
        nilToZero: true
      - name: DiskReadOps
        statistics: [Average]
        nilToZero: true
      - name: DiskWriteOps
        statistics: [Average]
        nilToZero: true
  - type: AWS/ECS
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: CPUUtilization
        statistics: [Average, Minimum, Maximum]
        nilToZero: true
      - name: MemoryUtilization
        statistics: [Average]
        nilToZero: true
  - type: AWS/DX
    regions: [eu-west-2]
<<<<<<< Updated upstream
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
=======
>>>>>>> Stashed changes
    length: 300
    metrics:
      - name: VirtualInterfaceBpsEgress
        statistics: [Average]
        nilToZero: true
      - name: VirtualInterfaceBpsIngress
        statistics: [Average]
        nilToZero: true
      - name: ConnectionState
        statistics: [Average]
        nilToZero: true
  - type: AWS/RDS
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: FreeStorageSpace
        statistics: [Average]
        nilToZero: true
      - name: ReadIOPS
        statistics: [Average]
        nilToZero: true
      - name: WriteIOPS
        statistics: [Average]
        nilToZero: true
      - name: CPUUtilization
        statistics: [Average]
        nilToZero: true
  - type: AWS/S3
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: BucketSizeBytes
        statistics: [Average]
        nilToZero: true
  - type: AWS/RDS
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: FreeStorageSpace
        statistics: [Average]
        nilToZero: true
      - name: ReadIOPS
        statistics: [Average]
        nilToZero: true
      - name: WriteIOPS
        statistics: [Average]
        nilToZero: true
      - name: CPUUtilization
        statistics: [Average]
        nilToZero: true
  - type: AWS/VPN
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: TunnelDataOut
        statistics: [Average]
        nilToZero: true
      - name: TunnelState
        statistics: [Average]
        nilToZero: true
      - name: TunnelDataIn
        statistics: [Average]
        nilToZero: true
  - type: AWS/SQS
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: NumberOfMessagesDeleted
        statistics: [Average]
        nilToZero: true
      - name: NumberOfMessagesReceived
        statistics: [Average, Maximum, Sum]
        nilToZero: true
      - name: NumberOfMessagesSent
        statistics: [Average, Sum]
        nilToZero: true
      - name: ApproximateAgeOfOldestMessage
        statistics: [Average]
        nilToZero: true
      - name: ApproximateNumberOfMessagesVisible
        statistics: [Average]
        nilToZero: true
      - name: ApproximateNumberOfMessagesNotVisible
        statistics: [Average]
        nilToZero: true
      - name: ApproximateNumberOfMessagesDelayed
        statistics: [Average]
        nilToZero: true
      - name: NumberOfEmptyReceives
        statistics: [Average]
        nilToZero: true
      - name: SentMessageSize
        statistics: [Average]
        nilToZero: true
  - type: AWS/Kinesis
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: GetRecords.IteratorAge
        statistics: [Sum]
        nilToZero: true
      - name: IncomingRecords
        statistics: [Sum]
        nilToZero: true
  - type: AWS/ApiGateway
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: 4XXError
        statistics: [Maximum]
        nilToZero: true
      - name: 5XXError
        statistics: [Maximum]
        nilToZero: true
      - name: IntegrationLatency
        statistics: [Maximum]
        nilToZero: true
      - name: Latency
        statistics: [Maximum]
        nilToZero: true
      - name: Count
        statistics: [Sum]
        nilToZero: true
  - type: AWS/Lambda
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: ConcurrentExecutions
        statistics: [Sum]
        nilToZero: true
      - name: Invocations
        statistics: [Sum]
        nilToZero: true
      - name: Errors
        statistics: [Sum]
        nilToZero: true
      - name: Throttles
        statistics: [Sum]
        nilToZero: true
  - type: AWS/NetworkELB
    regions: [eu-west-2]
    roles:
      - roleArn: {{ .Values.cloudwatchExporterProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterPreProductionArn }}
      - roleArn: {{ .Values.cloudwatchExporterDevelopmentArn }}
      - roleArn: {{ .Values.cloudwatchExporterPkiArn }}
    length: 300
    metrics:
      - name: ProcessedBytes
        statistics: [Average]
        nilToZero: true
      - name: UnHealthyHostCount
        statistics: [Average, Sum, Maximum]
        nilToZero: true
      - name: HealthyHostCount
        statistics: [Average, Sum, Maximum]
        nilToZero: true
static:
{{- include "cloudwatchMetrics.production.custom" . }}
{{ end }}