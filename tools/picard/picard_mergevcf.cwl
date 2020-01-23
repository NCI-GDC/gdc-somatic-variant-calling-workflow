class: CommandLineTool
cwlVersion: v1.0
id: picard_mergevcf
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard:c967a1329fc014aa5c6a92b506b11ab4ac495854e9f2dfe51badf490191a612e
  - class: ResourceRequirement
    coresMax: 1
doc: |
  Picard MergeVcfs

inputs:
  java_opts:
    type: string
    default: '3G'
    doc: |
      "JVM arguments should be a quoted, space separated list (e.g. -Xmx8g -Xmx16g -Xms128m -Xmx512m)"
    inputBinding:
      position: 3
      prefix: '-Xmx'
      separate: false

  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: 'I='
        separate: false
    doc: input VCF files
    inputBinding:
      position: 6

  output_filename:
    type: string
    doc: output filename of file
    inputBinding:
      position: 7
      prefix: 'O='
      separate: false

  ref_dict:
    type: File
    doc: reference sequence dictionary file
    inputBinding:
      position: 8
      prefix: 'D='
      separate: false

outputs:
  output_vcf_file:
    type: File
    doc: Merged vcf
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles:
      - '.tbi'

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/usr/local/bin/picard.jar'
    prefix: "-jar"
    position: 4
  - valueFrom: 'MergeVcfs'
    position: 5
