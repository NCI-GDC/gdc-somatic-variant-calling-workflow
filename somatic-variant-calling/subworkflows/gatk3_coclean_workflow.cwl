class: Workflow
cwlVersion: v1.0
id: gatk3_coclean_workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    GDC GATK3 coclean

inputs:
  job_uuid:
    type: string
    doc: Job id. Served as filename prefix.
  normal_bam:
    type: File
    secondaryFiles: ^.bai
    doc: Normal BAM file with ^.bai index.
  tumor_bam:
    type: File
    secondaryFiles: ^.bai
    doc: Tumor BAM file with ^.bai index.
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    doc: Human genome reference file with .fai, ^.dict secondary files.
  known_indel:
    type: File
    secondaryFiles: .tbi
    doc: INDEL reference file.
  bed_file:
    type: File
    doc: BED file.
  gatk_logging_level:
    default: INFO
    type: string
  rtc_maxIntervalSize:
    type: int
    default: 500
  rtc_minReadsAtLocus:
    type: int
    default: 4
  rtc_mismatchFraction:
    type: double
    default: 0.0
  rtc_num_threads:
    type: int
    default: 1
  rtc_windowSize:
    type: int
    default: 10
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
    default: 1500000
  ir_noOriginalAlignmentTags:
    type: boolean
    default: true
  ir_nWayOut:
    type: string
    default: "_realn.bam"

outputs:
  cocleaned_normal_bam:
    type: File
    outputSource: make_normal_bam/output
  cocleaned_tumor_bam:
    type: File
    outputSource: make_tumor_bam/output

steps:
  realignertargetcreator:
    run: ../../tools/gatk3_coclean/gatk_realignertargetcreator.cwl
    in:
      input_file: [normal_bam, tumor_bam]
      known: known_indel
      log_to_file:
        source: job_uuid
        valueFrom: $(self + '.realignertargetcreator.log')
      logging_level: gatk_logging_level
      maxIntervalSize: rtc_maxIntervalSize
      minReadsAtLocus: rtc_minReadsAtLocus
      mismatchFraction: rtc_mismatchFraction
      output_name:
        source: job_uuid
        valueFrom: $(self + '.intervals')
      num_threads: rtc_num_threads
      windowSize: rtc_windowSize
      reference_sequence: reference
      intervals: bed_file
    out: [output_intervals, output_log]

  indelrealigner:
    run: ../../tools/gatk3_coclean/gatk_indelrealigner.cwl
    in:
      consensusDeterminationModel: ir_consensusDeterminationModel
      entropyThreshold: ir_entropyThreshold
      input_file: [normal_bam, tumor_bam]
      knownAlleles: known_indel
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
      reference_sequence: reference
      targetIntervals: realignertargetcreator/output_intervals
    out: [output_bam, output_log]

  get_cocleaned_normal:
    run: ../../tools/util/get_file_from_array.cwl
    in:
      filearray: indelrealigner/output_bam
      filename:
        source: normal_bam
        valueFrom: $(self.nameroot + '_realn.bam')
    out: [output]

  get_cocleaned_tumor:
    run: ../../tools/util/get_file_from_array.cwl
    in:
      filearray: indelrealigner/output_bam
      filename:
        source: tumor_bam
        valueFrom: $(self.nameroot + '_realn.bam')
    out: [output]

  rename_normal_input_bai:
    run: ../../tools/util/rename_file.cwl
    in:
      input_file:
        source: get_cocleaned_normal/output
        valueFrom: $(self.secondaryFiles[0])
      output_filename:
        source: get_cocleaned_normal/output
        valueFrom: $(self.basename + '.bai')
    out: [ out_file ]

  make_normal_bam:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: get_cocleaned_normal/output
      children: rename_normal_input_bai/out_file
    out: [ output ]

  rename_tumor_input_bai:
    run: ../../tools/util/rename_file.cwl
    in:
      input_file:
        source: get_cocleaned_tumor/output
        valueFrom: $(self.secondaryFiles[0])
      output_filename:
        source: get_cocleaned_tumor/output
        valueFrom: $(self.basename + '.bai')
    out: [ out_file ]

  make_tumor_bam:
    run: ../../tools/util/make_secondary.cwl
    in:
      parent_file: get_cocleaned_tumor/output
      children: rename_tumor_input_bai/out_file
    out: [ output ]
