#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/samtools:1.1

inputs:
  ref:
    type: File
    inputBinding:
      position: 0
      prefix: -f
    secondaryFiles:
      - '.fai'

  min_MQ:
    type: int
    default: 1
    inputBinding:
      position: 1
      prefix: -q

  region:
    type: File
    inputBinding:
      loadContents: true
      valueFrom: $(null)

  normal_bam:
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - '.bai'

  tumor_bam:
    type: File
    inputBinding:
      position: 5
    secondaryFiles:
      - '.bai'

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/g, '_') + '.mpileup')

baseCommand: ['samtools', 'mpileup']
stdout: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/g, '_') + '.mpileup')
arguments:
  - valueFrom: '-B'
    position: 2
  - valueFrom: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/, ':').replace(/\t/, '-'))
    prefix: '-r'
    position: 3
