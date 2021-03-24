class: Workflow
cwlVersion: v1.0
id: gatk3_mutect2_workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    GDC GATK3 MuTect2

inputs:
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    doc: Human genome reference file with .fai, ^.dict secondary files.
  bed:
    type: File
    doc: BED file.
  normal_bam:
    type: File
    secondaryFiles: .bai
    doc: Normal BAM file with .bai index.
  tumor_bam:
    type: File
    secondaryFiles: .bai
    doc: Tumor BAM file with .bai index.
  threads:
    type: int
    default: 8
    doc: Threads for internal multithreading dockers.
  dbsnp:
    type: File
    secondaryFiles: .tbi
    doc: dbSNP reference file. GDC default is dbSNP build-144.
  cosmic:
    type: File
    secondaryFiles: .tbi
    doc: COSMIC reference file. GDC default is COSMICv75.
  pon:
    type: File
    secondaryFiles: .tbi
    doc: Panel of Normals. GDC default is 4136 TCGA curated normal samples.
  output_prefix:
    type: string
    doc: Output filename prefix.
  java_opts:
    type: string
    default: '3G'
    doc: Java option flags for all the java cmd. GDC default is 3G.
  cont:
    type: float
    default: 0.02
    doc: MuTect2 parameter. GDC default is 0.02. Contamination estimation score.
  duscb:
    type: boolean
    default: false
    doc: MuTect2 parameter. GDC default is False. If set, MuTect2 will not use soft clipped bases.
  timeout:
    type: int?
    doc: MuTect2 max runtime.

outputs:
  mutect2_vcf:
    type: File
    outputSource: sort_mutect2_vcf/sorted_vcf

steps:
  mutect2:
    run: ../../submodules/mutect2-cwl/tools/multi_mutect2_svc.cwl
    in:
      java_heap: java_opts
      ref: reference
      region: bed
      normal_bam: normal_bam
      tumor_bam: tumor_bam
      pon: pon
      cosmic: cosmic
      dbsnp: dbsnp
      cont: cont
      duscb: duscb
      thread_count: threads
      timeout: timeout
    out: [MUTECT2_OUTPUT]

  remove_non_standard_variants:
    run: ../../submodules/variant-filtration-cwl/tools/RemoveNonStandardVariants.cwl
    in:
      input_vcf: mutect2/MUTECT2_OUTPUT
      output_filename:
        source: output_prefix
        valueFrom: $(self + '.standard_unsorted.vcf')
    out: [output_file]

  sort_mutect2_vcf:
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
