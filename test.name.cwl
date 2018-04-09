#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    GDC Somatic Variant Calling Workflow

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  normal_with_index:
    type: File
    secondaryFiles:
      - '^.bai'
  tumor_with_index:
    type: File
    secondaryFiles:
      - '^.bai'
  reference_with_index:
    type: File
    secondaryFiles:
      - '.fai'
      - '^.dict'
  known_indel_with_index:
    type: File
    secondaryFiles:
      - '.tbi'
  rtc_intervals:
    type: File

###GENERAL_INPUTS###
  job_uuid:
    type: string
    doc: Job id. Served as a prefix for most VCF outputs.
  usedecoy:
    type: boolean
    default: false
    doc: If specified, it will include all the decoy sequences in the faidx. GDC default is false.

###GATK_INPUTS###
  gatk_logging_level:
    default: INFO
    type: string
  ir_consensusDeterminationModel:
    type: string
    default: USE_READS
  ir_entropyThreshold:
    type: double
    default: 0.15
  ir_LODThresholdForCleaning:
    type: double
    default: 5.0
  ir_maxConsensuses:
    type: int
    default: 30
  ir_maxIsizeForMovement:
    type: int
    default: 3000
  ir_maxPositionalMoveAllowed:
    type: int
    default: 200
  ir_maxReadsForConsensuses:
    type: int
    default: 120
  ir_maxReadsForRealignment:
    type: int
    default: 20000
  ir_maxReadsInMemory:
    type: int
    default: 150000
  ir_noOriginalAlignmentTags:
    type: boolean
    default: true
  ir_nWayOut:
    type: string
    default: "_realn.bam"

outputs:
  t:
    type: File
    outputSource: make_tumor_bam/output
  n:
    type: File
    outputSource: make_normal_bam/output

steps:

###PREPARATION###

  faidx_to_bed:
    run: utils-cwl/faidxtobed/tools/faidx_to_bed.no_chunk.cwl
    in:
      ref_fai:
        source: reference_with_index
        valueFrom: $(self.secondaryFiles[0])
      usedecoy: usedecoy
    out: [output_bed]

  indelrealigner:
    run: utils-cwl/gatk/tools/gatk_indelrealigner.cwl
    in:
      consensusDeterminationModel: ir_consensusDeterminationModel
      entropyThreshold: ir_entropyThreshold
      input_file: [normal_with_index, tumor_with_index]
      knownAlleles: known_indel_with_index
      log_to_file:
        source: job_uuid
        valueFrom: $(self + '.indelrealigner.log')
      logging_level: gatk_logging_level
      LODThresholdForCleaning: ir_LODThresholdForCleaning
      maxConsensuses: ir_maxConsensuses
      maxIsizeForMovement: ir_maxIsizeForMovement
      maxPositionalMoveAllowed: ir_maxPositionalMoveAllowed
      maxReadsForConsensuses: ir_maxReadsForConsensuses
      maxReadsForRealignment: ir_maxReadsForRealignment
      maxReadsInMemory: ir_maxReadsInMemory
      noOriginalAlignmentTags: ir_noOriginalAlignmentTags
      nWayOut: ir_nWayOut
      reference_sequence: reference_with_index
      targetIntervals: rtc_intervals
    out: [output_bam, output_log]

  get_cocleaned_normal:
    run: utils-cwl/get_file_from_array.cwl
    in:
      filearray: indelrealigner/output_bam
      filename:
        source: normal_with_index
        valueFrom: $(self.nameroot + '_realn.bam')
    out: [output]

  get_cocleaned_tumor:
    run: utils-cwl/get_file_from_array.cwl
    in:
      filearray: indelrealigner/output_bam
      filename:
        source: tumor_with_index
        valueFrom: $(self.nameroot + '_realn.bam')
    out: [output]

  rename_normal_input_bai:
    run: utils-cwl/rename_file.cwl
    in:
      input_file:
        source: get_cocleaned_normal/output
        valueFrom: $(self.secondaryFiles[0])
      output_filename:
        source: get_cocleaned_normal/output
        valueFrom: $(self.basename + '.bai')
    out: [ out_file ]

  make_normal_bam:
    run: utils-cwl/make_secondary.cwl
    in:
      parent_file: get_cocleaned_normal/output
      children:
        source: rename_normal_input_bai/out_file
        valueFrom: $([self])
    out: [ output ]

  rename_tumor_input_bai:
    run: utils-cwl/rename_file.cwl
    in:
      input_file:
        source: get_cocleaned_tumor/output
        valueFrom: $(self.secondaryFiles[0])
      output_filename:
        source: get_cocleaned_tumor/output
        valueFrom: $(self.basename + '.bai')
    out: [ out_file ]

  make_tumor_bam:
    run: utils-cwl/make_secondary.cwl
    in:
      parent_file: get_cocleaned_tumor/output
      children:
        source: rename_tumor_input_bai/out_file
        valueFrom: $([self])
    out: [ output ]
