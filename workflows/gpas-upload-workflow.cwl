class: Workflow
cwlVersion: v1.0
id: gpas-upload-workflow
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
doc: |
    Upload and pull uuid for gdc somatic variant calling workflow in GPAS.

inputs:
  job_uuid: string
  bioclient_config: File
  upload_bucket: string
  tumor_bam:
    type: File
    secondaryFiles: .bai
  gdc_muse_vcf:
    type: File
    secondaryFiles: .tbi
  gdc_mutect2_vcf:
    type: File
    secondaryFiles: .tbi
  gdc_somaticsniper_vcf:
    type: File
    secondaryFiles: .tbi
  gdc_varscan2_vcf:
    type: File
    secondaryFiles: .tbi

outputs:
  tumor_coclean_bam_uuid:
    type: string
    outputSource: uuid_bam/output
  tumor_coclean_bai_uuid:
    type: string
    outputSource: uuid_bam_index/output
  muse_uuid:
    type: string
    outputSource: uuid_muse/output
  muse_index_uuid:
    type: string
    outputSource: uuid_muse_index/output
  mutect2_uuid:
    type: string
    outputSource: uuid_mutect2/output
  mutect2_index_uuid:
    type: string
    outputSource: uuid_mutect2_index/output
  somaticsniper_uuid:
    type: string
    outputSource: uuid_somaticsniper/output
  somaticsniper_index_uuid:
    type: string
    outputSource: uuid_somaticsniper_index/output
  varscan2_uuid:
    type: string
    outputSource: uuid_varscan2/output
  varscan2_index_uuid:
    type: string
    outputSource: uuid_varscan2_index/output

steps:
###UPLOAD###
  rename_tumor_bam:
    run: ../tools/util/rename_file.cwl
    in:
      input_file: tumor_bam
      output_filename:
        source: job_uuid
        valueFrom: $(self + '.tumor_cocleaned.bam')
    out: [out_file]

  rename_tumor_bai:
    run: ../tools/util/rename_file.cwl
    in:
      input_file:
        source: tumor_bam
        valueFrom: $(self.secondaryFiles[0])
      output_filename:
        source: job_uuid
        valueFrom: $(self + '.tumor_cocleaned.bai')
    out: [out_file]

  upload_bam:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, rename_tumor_bam/out_file]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: rename_tumor_bam/out_file
    out: [output]

  upload_bam_index:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, rename_tumor_bai/out_file]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: rename_tumor_bai/out_file
    out: [output]

  upload_muse:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_muse_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: gdc_muse_vcf
    out: [output]

  upload_muse_index:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_muse_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: gdc_muse_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_mutect2:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_mutect2_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: gdc_mutect2_vcf
    out: [output]

  upload_mutect2_index:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_mutect2_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: gdc_mutect2_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_somaticsniper:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_somaticsniper_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: gdc_somaticsniper_vcf
    out: [output]

  upload_somaticsniper_index:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_somaticsniper_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: gdc_somaticsniper_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_varscan2:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_varscan2_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: gdc_varscan2_vcf
    out: [output]

  upload_varscan2_index:
    run: ../tools/util/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gdc_varscan2_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: gdc_varscan2_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

###EXTRACT_UUID###
  uuid_bam:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_bam/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_bam_index:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_bam_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_muse:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_muse/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_muse_index:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_muse_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_mutect2:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_mutect2/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_mutect2_index:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_mutect2_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_somaticsniper:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_somaticsniper/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_somaticsniper_index:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_somaticsniper_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_varscan2:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_varscan2/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_varscan2_index:
    run: ../tools/util/emit_json_value.cwl
    in:
      input: upload_varscan2_index/output
      key:
        valueFrom: 'did'
    out: [output]
