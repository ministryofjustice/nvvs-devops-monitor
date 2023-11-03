{{ define "cloudwatchMetrics.default" }}
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
    regions:
      - eu-west-2
    metrics:
      - name: CPUUtilization
        statistics:
          - Average
          - Minimum
          - Maximum
          - Sum
        nilToZero: true
        period: 300
        length: 300
  - type: AWS/ECS
    regions:
      - eu-west-2
    metrics:
      - name: CPUUtilization
        statistics:
          - Average
          - Minimum
          - Maximum
        nilToZero: true
        period: 300
        length: 300
      - name: MemoryUtilization
        statistics: 
          - Average
          - Minimum
          - Maximum
        nilToZero: true
        period: 300
        length: 300
  - type: AWS/RDS
    regions:
      - eu-west-2
    metrics:
      - name: FreeStorageSpace
        statistics:
          - Average
          - Minimum
          - Maximum
        nilToZero: true
        period: 300
        length: 300
  - type: AWS/S3
    regions:
      - eu-west-2
    metrics:
      - name: BucketSizeBytes
        statistics:
          - Average
        nilToZero: true
        period: 300
        length: 300
{{ end }}