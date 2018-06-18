#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    Updates sequence dictionary with picard

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard@sha256:e22300e94040a4ad93256b911157493b9344b82c4c7df7e8cae61432adb952e4
  - class: ResourceRequirement
    coresMax: 1

class: CommandLineTool

inputs:
  java_opts:
    type: string
    default: '3G'
    doc: |
      "JVM arguments should be a quoted, space separated list (e.g. -Xmx8g -Xmx16g -Xms128m -Xmx512m)"
    inputBinding:
      position: 3
      prefix: '-Xmx'
      separate: false

  input_vcf:
    type: File
    doc: input VCF file
    inputBinding:
      position: 6
      prefix: 'INPUT='
      separate: false

  output_filename:
    type: string
    doc: output filename of file
    inputBinding:
      position: 7
      prefix: 'OUTPUT='
      separate: false

  ref_dict:
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
