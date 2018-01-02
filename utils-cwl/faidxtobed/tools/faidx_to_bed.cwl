#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/fadixtobed:1.0

inputs:
  ref_fai:
    type: File
    doc: Reference faidx path. (i.e. GRCh38.d1.vd1.fa.fai)
    inputBinding:
      position: 1
      prefix: -f

  blocksize:
    type: int
    default: 300000000
    doc: Parallel Block Size.
    inputBinding:
      position: 2
      prefix: -b

  usedecoy:
    type: boolean
    doc: If specified, it will include all the decoy sequences in the faidx.
    inputBinding:
      position: 3
      prefix: -a

outputs:
  output_bed:
    type:
      type: array
      items: File
    outputBinding:
      glob: '*.bed'

baseCommand: ['sudo', 'python', '/home/ubuntu/tools/FaidxtoBED.py']
