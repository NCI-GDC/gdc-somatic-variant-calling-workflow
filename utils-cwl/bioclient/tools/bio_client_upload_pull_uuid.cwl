#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/bio-client:ecfb12c2f41276f29862c1603f806b5478f9845405c5e2af5c7c0538f93425d9

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
