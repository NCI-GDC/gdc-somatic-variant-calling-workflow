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
      prefix: -c
      position: 0

  dir_path:
    type: string
    default: "."
    inputBinding:
      prefix: --dir_path
      position: 99

  download:
    type: string
    default: download
    inputBinding:
      position: 1

  download_handle:
    type: string
    inputBinding:
      position: 98

outputs:
  output:
    type: File
    outputBinding:
      glob: "*"

baseCommand: [/usr/local/bin/bio_client.py]