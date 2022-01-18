class: Workflow
cwlVersion: v1.0
id: somaticsniper_workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    GDC SomaticSniper

inputs:
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    doc: Human genome reference file with .fai, ^.dict secondary files.
  normal_bam:
    type: File
    secondaryFiles: .bai
    doc: Normal BAM file with .bai index.
  tumor_bam:
    type: File
    secondaryFiles: .bai
    doc: Tumor BAM file with .bai index.
  mpileups:
    type: File[]
    doc: Tumor/Normal mpileup files.
  threads:
    type: int
    default: 8
    doc: Threads for internal multithreading dockers.
  output_prefix:
    type: string
    doc: Output filename prefix.
  map_q:
    type: int
    default: 1
    doc: Somaticsniper parameter. GDC default is 1. Filtering reads with mapping quality less than this value.
  base_q:
    type: int
    default: 15
    doc: Somaticsniper parameter. GDC default is 15. Filtering somatic snv output with somatic quality less than this value.
  loh:
    type: boolean
    default: true
    doc: Somaticsniper parameter. GDC default is True. Do not report LOH variants as determined by genotypes. (T/F)
  gor:
    type: boolean
    default: true
    doc: Somaticsniper parameter. GDC default is True. Do not report Gain of Reference variants as determined by genotypes. (T/F)
  psc:
    type: boolean
    default: false
    doc: Somaticsniper parameter. GDC default is False. Disable priors in the somatic calculation. Increases sensitivity for solid tumors. (T/F)
  ppa:
    type: boolean
    default: false
    doc: Somaticsniper parameter. GDC default is False. Use prior probabilities accounting for the somatic mutation rate. (T/F)
  pps:
    type: float
    default: 0.01
    doc: Somaticsniper parameter. GDC default is 0.01. Prior probability of a somatic mutation. (implies -J)
  theta:
    type: float
    default: 0.85
    doc: Somaticsniper parameter. GDC default is 0.85. Theta in maq consensus calling model. (for -c/-g)
  nhap:
    type: int
    default: 2
    doc: Somaticsniper parameter. GDC default is 2. Number of haplotypes in the sample.
  pd:
    type: float
    default: 0.001
    doc: Somaticsniper parameter. GDC default is 0.001. Prior of a difference between two haplotypes.
  fout:
    type: string
    default: 'vcf'
    doc: Somaticsniper parameter. GDC default is vcf. Output format. (classic/vcf/bed)
  timeout:
    type: int?
    doc: SomaticSniper max runtime.
outputs:
  somaticsniper_vcf:
    type: File
    outputSource: sort_somaticsniper_vcf/sorted_vcf

steps:
  somaticsniper:
    run: ../../submodules/somaticsniper-cwl/tools/multi_somaticsniper.cwl
    in:
      normal_input: normal_bam
      tumor_input: tumor_bam
      thread_count: threads
      mpileup: mpileups
      reference: reference
      map_q: map_q
      base_q: base_q
      loh: loh
      gor: gor
      psc: psc
      ppa: ppa
      pps: pps
      theta: theta
      nhap: nhap
      pd: pd
      fout: fout
      timeout: timeout
    out: [ANNOTATED_VCF]

  update_seqdict:
    run: ../../submodules/variant-filtration-cwl/tools/picard_update_sequence_dictionary.cwl
    in:
      input_vcf: somaticsniper/ANNOTATED_VCF
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.upseqdict.vcf')
      sequence_dictionary:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
    out: [output_file]

  remove_non_standard_variants:
    run: ../../submodules/variant-filtration-cwl/tools/filter_nonstandard_variants.cwl
    in:
      input_vcf: update_seqdict/output_file
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.standard_unsorted.vcf')
    out: [output_file]

  sort_somaticsniper_vcf:
    run: ../../tools/picard/picard_sortvcf.cwl
    in:
      ref_dict:
        source: reference
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: output_prefix
        valueFrom: $(self + '.raw_somatic_mutation.vcf.gz')
      input_vcf:
        source: remove_non_standard_variants/output_file
        valueFrom: $([self])
    out: [sorted_vcf]
