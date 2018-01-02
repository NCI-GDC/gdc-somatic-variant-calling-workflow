#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/awscli:1
  - class: EnvVarRequirement
    envDef:
      - envName: "AWS_CONFIG_FILE"
        envValue: $(inputs.aws_config_file.path)
      - envName: "AWS_SHARED_CREDENTIALS_FILE"
        envValue: $(inputs.aws_shared_credentials_file.path)
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  aws_config_file:
    type: File

  aws_shared_credentials_file:
    type: File

  s3cfg_section:
    type: string
    inputBinding:
      prefix: --profile
      position: 0

  endpoint_url:
    type: string
    inputBinding:
      prefix: --endpoint-url
      position: 1

  local_file:
    type: File
    inputBinding:
      position: 4

  s3url:
    type: string
    inputBinding:
      position: 5

outputs:
  output:
    type: File
    outputBinding:
      glob: "output"

baseCommand: ['aws', '--no-verify-ssl']

arguments:
  - valueFrom: s3
    position: 2

  - valueFrom: cp
    position: 3

stdout: 'output'
