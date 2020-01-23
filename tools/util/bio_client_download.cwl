class: CommandLineTool
cwlVersion: v1.0
id: bio_client_download
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/bio-client:latest
doc: |
  Bioclient download.

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
