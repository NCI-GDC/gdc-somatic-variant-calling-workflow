#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/bio-client:c5581c5429a9920db12a94381d8c22a7f1436dc1b0e2ec3d56317642250038ac

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
