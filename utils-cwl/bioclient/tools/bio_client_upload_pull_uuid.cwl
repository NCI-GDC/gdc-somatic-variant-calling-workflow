#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/bio-client:2730081f4e2efa4dd0fcca0bb7e843dfd73d2714415ffd8da0eee71193b9b751

inputs:
  config_file:
    type: File
    inputBinding:
      prefix: --config-file
      position: 0

  upload:
    type: string
    default: upload
    inputBinding:
      position: 1

  upload_bucket:
    type: string
    inputBinding:
      prefix: --upload-bucket
      position: 2

  upload_key:
    type: string
    inputBinding:
      prefix: --upload_key
      position: 3

  local_file:
    type: File
    inputBinding:
      position: 99

outputs:
  output:
    type: File
    outputBinding:
      glob: "*_upload.json"

baseCommand: [/usr/local/bin/bio_client.py]
