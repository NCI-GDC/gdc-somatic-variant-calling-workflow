#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/somaticsniper_raw_annotation:1.0

inputs:
  raw_vcf:
    type: File
    doc: Raw vcf from somaticsniper calling.
    inputBinding:
      position: 1
      prefix: -r

  post_hc:
    type: File
    doc: Post highconfidence filter file.
    inputBinding:
      position: 2
      prefix: -p

  output_name:
    type: string
    doc: New file name.
    inputBinding:
      position: 3
      prefix: -n

outputs:
  annotated_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_name)

baseCommand: ['python', '/home/ubuntu/tools/annotation.py']
