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
  gdc_muse_vcf:
    type: File
    secondaryFiles: .tbi
  gdc_mutect2_vcf:
    type: File
    secondaryFiles: .tbi
  gdc_varscan2_vcf:
    type: File
    secondaryFiles: .tbi

outputs:
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
  varscan2_uuid:
    type: string
    outputSource: uuid_varscan2/output
  varscan2_index_uuid:
    type: string
    outputSource: uuid_varscan2_index/output

steps:
###UPLOAD###
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
