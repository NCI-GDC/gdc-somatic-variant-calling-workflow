#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard@sha256:e22300e94040a4ad93256b911157493b9344b82c4c7df7e8cae61432adb952e4
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.input_bam)
        entryname: $(inputs.input_bam.basename)
  - class: ResourceRequirement
    coresMax: 1

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: 'I='
      separate: false
      position: 6
      valueFrom: $(self.basename)

outputs:
  bam_with_index:
    type: File
    outputBinding:
      glob: $(inputs.input_bam.basename)
    secondaryFiles:
      - '^.bai'

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '16G'
    prefix: '-Xmx'
    separate: false
    position: 3
  - valueFrom: '/usr/local/bin/picard.jar'
    prefix: '-jar'
    position: 4
  - valueFrom: 'BuildBamIndex'
    position: 5
