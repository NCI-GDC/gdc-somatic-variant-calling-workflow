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
