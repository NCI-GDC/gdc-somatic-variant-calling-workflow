#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard@sha256:e22300e94040a4ad93256b911157493b9344b82c4c7df7e8cae61432adb952e4
  - class: ResourceRequirement
    coresMax: 1

inputs:
  ref_dict:
    type: File
    inputBinding:
      position: 3
      prefix: 'SEQUENCE_DICTIONARY='
      separate: false

  output_vcf:
    type: string
    inputBinding:
      position: 4
      prefix: 'OUTPUT='
      separate: false

  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: 'I='
        separate: false
    inputBinding:
      position: 5

outputs:
  sorted_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)
    secondaryFiles:
      - '.tbi'

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '16G'
    prefix: '-Xmx'
    separate: false
    position: 0
  - valueFrom: '/usr/local/bin/picard.jar'
    prefix: '-jar'
    position: 1
  - valueFrom: 'SortVcf'
    position: 2
  - valueFrom: 'true'
    position: 6
    prefix: 'CREATE_INDEX='
    separate: false
