#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/samtools:1.1

inputs:
  input_bam_path:
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - '^.bai'

  region:
    type: File
    inputBinding:
      position: 0
      prefix: -L 

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $('split_' + inputs.input_bam_path.basename)

baseCommand: ['samtools', 'view', '-b']

stdout: $('split_' + inputs.input_bam_path.basename)
