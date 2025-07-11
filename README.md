# GDC DNA-Seq Somatic Variant Calling Workflow
![Version badge](https://img.shields.io/badge/MuSE-v1.0rc__submission__c039ffa-brightgreen.svg)
![Version badge](https://img.shields.io/badge/GATK3.6-nightly--2016--02--25--gf39d340-brightgreen.svg)
![Version badge](https://img.shields.io/badge/SomaticSniper-1.0.5.0-brightgreen.svg)
![Version badge](https://img.shields.io/badge/VarScan-v2.3.9-brightgreen.svg)<br>
![Version badge](https://img.shields.io/badge/samtools-1.1-yellowgreen.svg)
![Version badge](https://img.shields.io/badge/Picard-2.18.4--SNAPSHOT-yellowgreen.svg)<br>

GDC Documentation: https://docs.gdc.cancer.gov/Data/Bioinformatics_Pipelines/DNA_Seq_Variant_Calling_Pipeline/#somatic-variant-calling-workflow

## Submodules
This repo uses individual caller's CWL as its submodule. To fully download:
```
git clone https://github.com/NCI-GDC/gdc-somatic-variant-calling-workflow --recursive
```

* [GDC-MuSE-CWL](https://github.com/NCI-GDC/muse-cwl "GDC-MuSE-CWL")
* [GDC-GATK3-MuTect2-CWL](https://github.com/NCI-GDC/mutect2-cwl "GDC-GATK3-MuTect2-CWL")
* [GDC-SomaticSniper-CWL](https://github.com/NCI-GDC/somaticsniper-cwl "GDC-SomaticSniper-CWL")
* [GDC-VarScan2-CWL](https://github.com/NCI-GDC/varscan-cwl "GDC-VarScan2-CWL")
* [GDC-Samtools-mpileup-CWL](https://github.com/NCI-GDC/samtools-mpileup-cwl "GDC-Samtools-mpileup-CWL")
* [GDC-Variant-filtration-CWL](https://github.com/NCI-GDC/variant-filtration-cwl "GDC-Variant-filtration-CWL")

## CWL

https://www.commonwl.org/

The CWL are tested under multiple `cwltools` environments. The most tested one is:
* cwltool 1.0.20180306163216


## For external users

The repository has only been tested on GDC data and in the particular environment GDC is running in. Some of the reference data required for the workflow production are hosted in [GDC reference files](https://gdc.cancer.gov/about-data/data-harmonization-and-generation/gdc-reference-files "GDC reference files"). For any questions related to GDC data, please contact the GDC Help Desk at support@nci-gdc.datacommons.io.

### Individual caller CWL workflow
You could find individual caller's CWL workflow under `workflows/subworkflows`.
* [MuSE workflow](workflows/subworkflows/muse_workflow.cwl "MuSE workflow")
* [GATK3-MuTect2 workflow](workflows/subworkflows/gatk3_mutect2_workflow.cwl "GATK3-MuTect2 workflow")
* [SomaticSniper workflow](workflows/subworkflows/somaticsniper_workflow.cwl "SomaticSniper workflow")
* [VarScan2 workflow](workflows/subworkflows/varscan2_workflow.cwl "VarScan2 workflow")

For more information, please visit the above submodule links.

### GDC workflow entrypoint
GDC workflow contains GATK3 IndelRealignment and all four callers, `workflows/gdc-somatic-variant-calling-workflow.cwl`.<br>

The example of input json in `example/main_workflow.example.input.json`.

General inputs<br>

| Name | type | Description |
| ---- | ---- | ----------- |
| project_id | string? | Project id. Served as file name prefix. |
| muse_caller_id | string | MuSE caller id. Served as file name prefix. |
| mutect2_caller_id | string | MuTect2 caller id. Served as file name prefix. |
| somaticsniper_caller_id | string | SomaticSniper caller id. Served as file name prefix. |
| varscan2_caller_id | string | VarScan2 caller id. Served as file name prefix. |
| experimental_strategy | string | Experimental strategy. Used for `MuSE sump` GDC default is WXS. |
| tumor_bam | File | Tumor BAM file with index. |
| normal_bam | File | Normal BAM file with index. |
| reference | File | Human genome reference. GDC default is GRCh38. |
| known_indel | File | INDEL reference file. |
| known_snp | File | dbSNP reference file. GDC default is dbSNP build-144. |
| panel_of_normal | File | Panel of normal reference file. |
| cosmic | File | Cosmic reference file. GDC default is COSMICv75. |
| job_uuid | string | Job id. Served as a prefix for all VCF outputs. |
| java_opts | string | Java `-Xmx` option flags for all the java cmd. GDC default is 3G. |
| threads | int | Threads for internal multithreading dockers. |
| usedecoy | boolean | If specified, it will include all the decoy sequences in the faidx. GDC default is false. |
<br>

Step inputs<br>

| Step | Name | Description |
| ---- | ---- | ----------- |
| GATK3 coclean | --gatk_\*<br> --rtc_\*<br> --ir_\* | GATK3 `RealignerTargetCreator` and `IndelRealigner` parameters |
| MuSE | None | No parameters for MuSE |
| GATK3 MuTect2 | --cont<br> --duscb  | `-contamination` and `-dontUseSoftClippedBases` from GATK3 `MuTect2` parameters |
| SomaticSniper | --map_q<br> --base_q<br> --loh<br> --gor<br> --psc<br> --ppa<br> --pps<br> --theta<br> --nhap<br> --pd<br> --fout<br> | All SomaticSniper parameters |
| VarScan2 | --min_coverage<br> --min_cov_normal<br> --min_cov_tumor<br> --min_var_freq<br> --min_freq_for_hom<br>  --normal_purity<br> --tumor_purity<br> --vs_ps_value<br> --somatic_p_value<br> --strand_filter<br> --validation<br> --output_vcf<br> --min_tumor_freq<br> --max_normal_freq<br> --vps_p_value<br> |All parameters from VarScan2 `somatic` and `processSomatic` function |


## For GDC users

The entrypoint CWL workflow for GDC users is `gpas-somatic-mutation-calling-workflow.cwl`.
