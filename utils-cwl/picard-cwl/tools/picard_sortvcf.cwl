#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard
  - class: ResourceRequirement
  
inputs:
  - id: ref_dict
    type: File
    inputBinding:
      position: 3
      prefix: 'SEQUENCE_DICTIONARY='
      separate: false

  - id: output_vcf
    type: string
    inputBinding:
      position: 4
      prefix: 'OUTPUT='
      separate: false

  - id: input_vcf
    type:
      type: array
      items: File
      inputBinding:
        prefix: 'I='
        separate: false
    inputBinding:
      position: 5

outputs:
  - id: sorted_vcf
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
