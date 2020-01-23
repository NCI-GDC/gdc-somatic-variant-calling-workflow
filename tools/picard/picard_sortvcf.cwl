class: CommandLineTool
cwlVersion: v1.0
id: picard_sortvcf
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard:c967a1329fc014aa5c6a92b506b11ab4ac495854e9f2dfe51badf490191a612e
  - class: ResourceRequirement
    coresMax: 1
doc: |
  Picard SortVcfs.

inputs:
  ref_dict:
    type: File
    inputBinding:
      position: 3
      prefix: 'SEQUENCE_DICTIONARY='
      separate: false

  output_vcf:
    type: string
    inputBinding:
      position: 4
      prefix: 'OUTPUT='
      separate: false

  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: 'I='
        separate: false
    inputBinding:
      position: 5

outputs:
  sorted_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)
    secondaryFiles:
      - '.tbi'

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '16G'
    prefix: '-Xmx'
    separate: false
    position: 0
  - valueFrom: '/usr/local/bin/picard.jar'
    prefix: '-jar'
    position: 1
  - valueFrom: 'SortVcf'
    position: 2
  - valueFrom: 'true'
    position: 6
    prefix: 'CREATE_INDEX='
    separate: false
