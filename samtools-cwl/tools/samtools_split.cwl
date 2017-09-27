#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/samtools:9bbccff355bf

inputs:
  - id: input_bam_path
    type: File
    inputBinding:
      position: 2
    secondaryFiles:
      - '^.bai'

  - id: region
    type: string
    inputBinding:
      position: 3

  - id: output_bam_path
    type: string
    inputBinding:
      position: 4
      prefix: ">"

outputs:
  - id: output_file
    type: File
    outputBinding:
      glob: $(inputs.output_bam_path)

baseCommand: ['samtools', 'view']
arguments:
  - valueFrom: "-b"
    position: 1
