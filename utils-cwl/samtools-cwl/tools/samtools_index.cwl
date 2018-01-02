#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/samtools:1.1
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.input_bam_path)
        entryname: $(inputs.input_bam_path.basename)
        writable: True

inputs:
  input_bam_path:
    type: File
    inputBinding:
      position: 1
      valueFrom: $(self.basename)

outputs:
  bam_with_index:
    type: File
    outputBinding:
      glob: $(inputs.input_bam_path.basename)
    secondaryFiles:
      - '.bai'

baseCommand: ['samtools', 'index']
