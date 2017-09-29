#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    Updates sequence dictionary with picard

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard

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
    type: File
    doc: input VCF file
    inputBinding:
      position: 6
      prefix: 'INPUT='
      separate: false

  - id: output_filename
    type: string
    doc: output filename of file
    inputBinding:
      position: 7
      prefix: 'OUTPUT='
      separate: false

  - id: ref_dict
    type: File
    doc: reference sequence dictionary file
    inputBinding:
      position: 8
      prefix: 'SEQUENCE_DICTIONARY='
      separate: false

outputs:
  output_vcf_file:
    type: File
    doc: Updated sequence dictionary vcf
    outputBinding:
      glob: $(inputs.output_filename)

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/usr/local/bin/picard.jar'
    prefix: "-jar"
    position: 4
  - valueFrom: 'UpdateVcfSequenceDictionary'
    position: 5
