#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/samtools:1.1

inputs:
  - id: ref
    type: File
    inputBinding:
      position: 1
      prefix: -f
    secondaryFiles:
      - '.fai'

  - id: region
    type: File
    inputBinding:
      position: 2
      loadContents: true
      valueFrom: null
      prefix: -l

  - id: normal_bam
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - '.bai'

  - id: tumor_bam
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - '.bai'

outputs:
  - id: output_file
    type: File
    outputBinding:
      glob: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/g, '_') + '.mpileup')

baseCommand: ['samtools', 'mpileup']
arguments:
  - valueFrom: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/g, '_') + '.mpileup')
    position: 5
    prefix: ">"
