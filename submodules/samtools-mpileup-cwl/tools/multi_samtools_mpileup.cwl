class: CommandLineTool
cwlVersion: v1.0
id: multi_samtools_mpileup
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/multi_mpileup:1.1
doc: |
  Multithreading on samtools mpileup function.

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
      prefix: -m

  region:
    type: File
    inputBinding:
      position: 2
      prefix: -r

  normal_bam:
    type: File
    inputBinding:
      position: 3
      prefix: -n
    secondaryFiles:
      - '.bai'

  tumor_bam:
    type: File
    inputBinding:
      position: 4
      prefix: -t
    secondaryFiles:
      - '.bai'

  thread_count:
    type: int
    inputBinding:
      position: 5
      prefix: -c

outputs:
  output_file:
    type: File[]
    outputBinding:
      glob: '*.mpileup'

baseCommand: ['python', '/opt/multi_samtools_mpileup.py']
