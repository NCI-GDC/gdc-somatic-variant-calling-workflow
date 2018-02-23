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
      position: 2
    secondaryFiles:
      - '^.bai'

  region:
    type: File
    inputBinding:
      loadContents: true
      valueFrom: $(null)

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/g, '_'))_$(inputs.input_bam_path.basename)

baseCommand: ['samtools', 'view']
arguments:
  - valueFrom: '-b'
    position: 1
  - valueFrom: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/, ':').replace(/\t/, '-'))
    position: 3
stdout: $(inputs.region.contents.replace(/\n/g, '').replace(/\t/g, '_'))_$(inputs.input_bam_path.basename)
