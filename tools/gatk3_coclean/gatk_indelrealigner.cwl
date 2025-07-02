class: CommandLineTool
cwlVersion: v1.0
id: gatk_indelrealigner
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/gatk:{{ gatk }}"
  - class: InlineJavascriptRequirement
doc: |
  GATK3 IndelRealigner

inputs:
  consensusDeterminationModel:
    type: string
    default: USE_READS
    inputBinding:
      prefix: --consensusDeterminationModel

  entropyThreshold:
    type: double
    default: 0.15
    inputBinding:
      prefix: --entropyThreshold

  input_file:
    type:
      type: array
      items: File
      inputBinding:
        prefix: --input_file
    secondaryFiles:
      - ^.bai

  knownAlleles:
    type: File
    inputBinding:
      prefix: --knownAlleles
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

  LODThresholdForCleaning:
    type: double
    default: 5.0
    inputBinding:
      prefix: --LODThresholdForCleaning

  maxConsensuses:
    type: int
    default: 30
    inputBinding:
      prefix: --maxConsensuses

  maxIsizeForMovement:
    type: int
    default: 3000
    inputBinding:
      prefix: --maxIsizeForMovement

  maxPositionalMoveAllowed:
    type: int
    default: 200
    inputBinding:
      prefix: --maxPositionalMoveAllowed

  maxReadsForConsensuses:
    type: int
    default: 120
    inputBinding:
      prefix: --maxReadsForConsensuses

  maxReadsForRealignment:
    type: int
    default: 20000
    inputBinding:
      prefix: --maxReadsForRealignment

  maxReadsInMemory:
    type: int
    default: 1500000
    inputBinding:
      prefix: --maxReadsInMemory

  noOriginalAlignmentTags:
    type: boolean
    default: true
    inputBinding:
      prefix: --noOriginalAlignmentTags

  nWayOut:
    type: string
    default: "_realn.bam"
    inputBinding:
      prefix: --nWayOut

  reference_sequence:
    type: File
    inputBinding:
      prefix: --reference_sequence
    secondaryFiles:
      - ^.dict
      - .fai

  targetIntervals:
    type: File
    inputBinding:
      prefix: --targetIntervals

outputs:
  output_bam:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.bam"
      outputEval: |
        ${ return self.sort(function(a,b) { return a.location > b.location ? 1 : (a.location < b.location ? -1 : 0) }) }
    secondaryFiles:
      - ^.bai

  output_log:
    type: File
    outputBinding:
      glob: $(inputs.log_to_file)

baseCommand: [-T, IndelRealigner]
