#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    Merge VCFs with picard

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard
  - class: ResourceRequirement
    coresMax: 1

class: CommandLineTool

inputs:
  - id: java_opts
    type: string
    default: '3G'
    doc: |
      "JVM arguments should be a quoted, space separated list (e.g. -Xmx8g -Xmx16g -Xms128m -Xmx512m)"
    inputBinding:
      position: 3
      prefix: '-Xmx'
      separate: false

  - id: input_vcf
    type:
      type: array
      items: File
      inputBinding:
        prefix: 'I='
        separate: false
    doc: input VCF files
    inputBinding:
      position: 6

  - id: output_filename
    type: string
    doc: output filename of file
    inputBinding:
      position: 7
      prefix: 'O='
      separate: false

  - id: ref_dict
    type: File
    doc: reference sequence dictionary file
    inputBinding:
      position: 8
      prefix: 'D='
      separate: false

outputs:
  output_vcf_file:
    type: File
    doc: Merged vcf
    outputBinding:
      glob: $(inputs.output_filename)

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/usr/local/bin/picard.jar'
    prefix: "-jar"
    position: 4
  - valueFrom: 'MergeVcfs'
    position: 5
