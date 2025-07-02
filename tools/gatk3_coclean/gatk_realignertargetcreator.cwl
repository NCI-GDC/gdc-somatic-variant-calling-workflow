class: CommandLineTool
cwlVersion: v1.0
id: gatk_realignertargetcreator
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/gatk:{{ gatk }}"
  - class: InlineJavascriptRequirement
doc: |
  GATK3 RealignerTargetCreator

inputs:
  input_file:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --input_file
    secondaryFiles:
      - ^.bai

  known:
    type: File
    inputBinding:
      prefix: --known
    secondaryFiles:
      - .tbi

  log_to_file:
    type: string
    inputBinding:
      prefix: --log_to_file

  logging_level:
    default: INFO
    type: string
    inputBinding:
      prefix: --logging_level

  maxIntervalSize:
    type: int
    default: 500
    inputBinding:
      prefix: --maxIntervalSize

  minReadsAtLocus:
    type: int
    default: 4
    inputBinding:
      prefix: --minReadsAtLocus

  mismatchFraction:
    type: double
    default: 0.0
    inputBinding:
      prefix: --mismatchFraction

  output_name:
    type: string
    inputBinding:
      prefix: --out

  num_threads:
    type: int
    default: 1
    inputBinding:
      prefix: --num_threads

  windowSize:
    type: int
    default: 10
    inputBinding:
      prefix: --windowSize

  reference_sequence:
    type: File
    inputBinding:
      prefix: --reference_sequence
    secondaryFiles:
      - ^.dict
      - .fai

  intervals:
    type: File?
    inputBinding:
      prefix: -L

outputs:
  output_intervals:
    type: File
    outputBinding:
      glob: $(inputs.output_name)

  output_log:
    type: File
    outputBinding:
      glob: $(inputs.log_to_file)

baseCommand: [-T, RealignerTargetCreator]
