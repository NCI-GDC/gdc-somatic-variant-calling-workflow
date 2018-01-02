#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - $import: ../submodules/variant-filtration-cwl/tools/schemas.cwl

inputs:
###COMMON###
  tumor_bam:
    type: File
    doc: The tumor BAM file
  tumor_bam_index:
    type: File
    doc: The tumor BAI file
  output_uuid:
    type: string
    doc: UUID to use for output files
  oxoq_score:
    doc: oxoq score from picard
    type: float
###REF###
  full_ref_fasta:
    doc: Full reference fasta containing all scaffolds
    type: File
  full_ref_fasta_index:
    doc: Full reference fasta index
    type: File
  full_ref_dictionary:
    doc: Full reference fasta sequence dictionary
    type: File
  main_ref_fasta:
    doc: Main chromosomes only fasta
    type: File
  main_ref_fasta_index:
    doc: Main chromosomes only fasta index
    type: File
  main_ref_dictionary:
    doc: Main chromosomes only fasta sequence dictionary
    type: File
###MUSE###
  muse_input_vcf:
    type: File
    doc: The VCF file you want to filter
  muse_vcf_metadata:
    doc: VCF metadata record
    type: "../submodules/variant-filtration-cwl/tools/schemas.cwl#vcf_metadata_record"
###MUTECT2###
  mutect2_input_vcf:
    type: File
    doc: The VCF file you want to filter
  mutect2_vcf_metadata:
    doc: VCF metadata record
    type: "../submodules/variant-filtration-cwl/tools/schemas.cwl#vcf_metadata_record"
###VARSCAN2###
  varscan2_input_vcf:
    type: File
    doc: The VCF file you want to filter
  varscan2_vcf_metadata:
    doc: VCF metadata record
    type: "../submodules/variant-filtration-cwl/tools/schemas.cwl#vcf_metadata_record"
###SOMATICSNIPER###
  somaticsniper_input_vcf:
    type: File
    doc: The VCF file you want to filter
  somaticsniper_vcf_metadata:
    doc: VCF metadata record
    type: "../submodules/variant-filtration-cwl/tools/schemas.cwl#vcf_metadata_record"
  drop_somatic_score:
    doc: If the somatic score is less than this value, remove it from VCF
    type: int?
    default: 25
  min_somatic_score:
    doc: If the somatic score is less than this value, add filter tag
    type: int?
    default: 40

outputs:
  muse_final_vcf:
    type: File
    outputSource: muse_filtration/final_vcf
  mutect2_final_vcf:
    type: File
    outputSource: mutect2_filtration/final_vcf
  varscan2_final_vcf:
    type: File
    outputSource: varscan2_filtration/final_vcf
  somaticsniper_final_vcf:
    type: File
    outputSource: somaticsniper_filtration/final_vcf

steps:
  muse_filtration:
    run: ../submodules/variant-filtration-cwl/workflows/gdc-filters.minimal.cwl
    in:
      input_vcf: muse_input_vcf
      tumor_bam: tumor_bam
      tumor_bam_index: tumor_bam_index
      output_uuid:
        source: output_uuid
        valueFrom: $(self + '-muse')
      full_ref_fasta: full_ref_fasta
      full_ref_fasta_index: full_ref_fasta_index
      full_ref_dictionary: full_ref_dictionary
      main_ref_fasta: main_ref_fasta
      main_ref_fasta_index: main_ref_fasta_index
      main_ref_dictionary: main_ref_dictionary
      vcf_metadata: muse_vcf_metadata
      oxoq_score: oxoq_score
    out: [dkfz_time, dkfz_qc_archive, dtoxog_archive, final_vcf]

  mutect2_filtration:
    run: ../submodules/variant-filtration-cwl/workflows/gdc-filters.minimal.cwl
    in:
      input_vcf: mutect2_input_vcf
      tumor_bam: tumor_bam
      tumor_bam_index: tumor_bam_index
      output_uuid:
        source: output_uuid
        valueFrom: $(self + '-mutect2')
      full_ref_fasta: full_ref_fasta
      full_ref_fasta_index: full_ref_fasta_index
      full_ref_dictionary: full_ref_dictionary
      main_ref_fasta: main_ref_fasta
      main_ref_fasta_index: main_ref_fasta_index
      main_ref_dictionary: main_ref_dictionary
      vcf_metadata: mutect2_vcf_metadata
      oxoq_score: oxoq_score
    out: [dkfz_time, dkfz_qc_archive, dtoxog_archive, final_vcf]

  varscan2_filtration:
    run: ../submodules/variant-filtration-cwl/workflows/gdc-filters.with-fpfilter.cwl
    in:
      input_vcf: varscan2_input_vcf
      tumor_bam: tumor_bam
      tumor_bam_index: tumor_bam_index
      output_uuid:
        source: output_uuid
        valueFrom: $(self + '-varscan2')
      full_ref_fasta: full_ref_fasta
      full_ref_fasta_index: full_ref_fasta_index
      full_ref_dictionary: full_ref_dictionary
      main_ref_fasta: main_ref_fasta
      main_ref_fasta_index: main_ref_fasta_index
      main_ref_dictionary: main_ref_dictionary
      vcf_metadata: varscan2_vcf_metadata
      oxoq_score: oxoq_score
    out: [fpfilter_time, dkfz_time, dkfz_qc_archive, dtoxog_archive, final_vcf]

  somaticsniper_filtration:
    run: ../submodules/variant-filtration-cwl/workflows/gdc-filters.with-fpfilter.with-somaticscore.cwl
    in:
      input_vcf: somaticsniper_input_vcf
      tumor_bam: tumor_bam
      tumor_bam_index: tumor_bam_index
      output_uuid:
        source: output_uuid
        valueFrom: $(self + '-somaticsniper')
      full_ref_fasta: full_ref_fasta
      full_ref_fasta_index: full_ref_fasta_index
      full_ref_dictionary: full_ref_dictionary
      main_ref_fasta: main_ref_fasta
      main_ref_fasta_index: main_ref_fasta_index
      main_ref_dictionary: main_ref_dictionary
      vcf_metadata: somaticsniper_vcf_metadata
      drop_somatic_score: drop_somatic_score
      min_somatic_score: min_somatic_score
      oxoq_score: oxoq_score
    out: [fpfilter_time, dkfz_time, dkfz_qc_archive, dtoxog_archive, final_vcf]
