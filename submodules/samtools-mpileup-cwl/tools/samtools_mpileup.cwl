
class: CommandLineTool
cwlVersion: v1.0
id: samtools_mpileup
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/samtools:1.1
doc: |
  samtools mpileup

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
      position: 2
      prefix: -l

  normal_bam:
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - '.bai'

  tumor_bam:
    type: File
    inputBinding:
      position: 4
    secondaryFiles:
      - '.bai'

outputs:
  output_file:
    type: File
    outputBinding:
      glob: 'tn_pair.mpileup'

baseCommand: ['samtools', 'mpileup', '-B' ]
stdout: 'tn_pair.mpileup'
