GDC Somatic Variant Calling Workflow
---

The main runner is `gdc-somatic-variant-calling.cwl`

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
    "bioclient_config": {
        "path": "/path/to/config.json",
        "class": "File"
    },
    "tumor_gdc_id": "XXX",
    "tumor_index_gdc_id": "XXX",
    "normal_gdc_id": "XXX",
    "normal_index_gdc_id": "XXX",
    "reference_gdc_id": "XXX",
    "reference_faidx_gdc_id": "XXX",
    "reference_dict_gdc_id": "XXX",
    "known_indel_gdc_id": "XXX",
    "known_indel_index_gdc_id": "XXX",
    "known_snp_gdc_id": "XXX",
    "known_snp_index_gdc_id": "XXX",
    "panel_of_normal_gdc_id": "XXX",
    "panel_of_normal_index_gdc_id": "XXX",
    "cosmic_gdc_id": "XXX",
    "cosmic_index_gdc_id": "XXX",
    "upload_bucket": "XXX",
    "job_uuid": "XXX",
    "caller_id": ["MuTect2", "MuSE", "VarScan2", "SomaticSniper"],
    "experimental_strategy": "WXS"
}      
```
