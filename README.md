GDC Somatic Variant Calling Workflow
---

The main runner is `gdc-somatic-variant-calling.cwl`

(#Note: the runner uses prestaged reference files, and build index for input bam. There is a draft `utils/download_all_reference.cwl` to download all the reference file, but not tested yet.)

The bioclient `config_file` example is:
```
{
    "s3_config": {
        "gdc-cephb-objstore.osdc.io": {
            "alias": "ceph.service.consul",
            "access_key": "XXX",
            "secret_key": "XXX",
            "default_bucket": "bioinformatics_scratch",
            "is_secure": "False"
        },
        "gdc-accessors.osdc.io": {
            "alias": "cleversafe.service.consul",
            "access_key": "XXX",
            "secret_key": "XXX",
            "default_bucket": "bioinformatics_scratch",
            "is_secure": "False"
        }
    },
    "indexd_config": {
        "host": "indexd.service.consul",
        "username": "XXX",
        "pwd": "XXX"
    },
    "signpost_host": "http://signpost.service.consul",
    "chunk_size": 104857600
}
```

The example for input json is:
```
{
    "config_file": {
        "path": "/mnt/benchmark/config.json",
        "class": "File"
    },
    "reference": {
        "path": "/mnt/reference/GRCh38.d1.vd1.fa",
        "class": "File"
    },
    "tumor_download_handle": "c5bcceee-1c3c-4349-b4a8-cf056531ab19",
    "pon": {
        "path": "/mnt/reference/MuTect2.PON.5210.vcf.gz",
        "class": "File"
    },
    "dbsnp": {
        "path": "/mnt/reference/dbsnp_144.hg38.vcf.gz",
        "class": "File"
    },
    "normal_download_handle": "30f4bf30-ab75-4d6a-9861-aa55b01b579d",
    "reference_dict": {
      "path": "/mnt/reference/GRCh38.d1.vd1.dict",
      "class": "File"
  },
  "job_id": "XXX",
  "reference_faidx": {
      "path": "/mnt/reference/GRCh38.d1.vd1.fa.fai",
      "class": "File"
  },
  "cosmic": {
      "path": "/mnt/reference/CosmicCombined.srt.vcf.gz",
      "class": "File"
  },
  "upload_bucket": "s3://cleversafe.service.consul/bioinformatics_scratch"
}      
```
