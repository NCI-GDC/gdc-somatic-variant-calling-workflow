#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard

inputs:
  - id: java_opts
    type: string
    default: '16G'
    doc: |
      'JVM arguments should be a quoted, space separated list (e.g. -Xmx8g -Xmx16g -Xms128m -Xmx512m)'
    inputBinding:
      position: 3
      prefix: '-Xmx'
      separate: false

  - id: nthreads
    type: int
    default: 8
    inputBinding:
      position: 4
      prefix: '-XX:ParallelGCThreads='
      separate: false

  - id: ref_dict
    type: File
    inputBinding:
      position: 7
      prefix: 'SEQUENCE_DICTIONARY='
      separate: false

  - id: output_vcf
    type: string
    inputBinding:
      position: 8
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
      position: 9

outputs:
  - id: sorted_output_vcf
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)
    secondaryFiles:
      - '.tbi'

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/usr/local/bin/picard.jar'
    prefix: '-jar'
    position: 5
  - valueFrom: 'SortVcf'
    position: 6
  - valueFrom: 'true'
    position: 10
    prefix: 'CREATE_INDEX='
    separate: false
