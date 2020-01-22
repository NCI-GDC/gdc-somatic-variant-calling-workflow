# GDC Samtools mpileup cwl
![Version badge](https://img.shields.io/badge/samtools-1.1-<COLOR>.svg)

Original samtools: https://www.htslib.org/

## Docker

All the docker images are built from `Dockerfile`s at https://github.com/NCI-GDC/samtools-mpileup-tool.

## CWL

https://www.commonwl.org/

The CWL are tested under multiple `cwltools` environments. The most tested one is:
* cwltool 1.0.20180306163216


## For external users

There is a production-ready GDC CWL workflow at https://github.com/NCI-GDC/gdc-somatic-variant-calling-workflow, which uses this repo as a git submodule.

Please notice that you may want to change the docker image host of `dockerPull:` for each CWL.

To use CWL directly from this repo, we recommend to run `tools/samtools_mpileup.cwl` or `tools/multi_samtools_mpileup.cwl`.

To run multithreading samtools mpileup CWL:

```
>>>>>>>>>>Multithreading samtools mpileup<<<<<<<<<<
cwltool multi_samtools_mpileup.cwl -h
/home/ubuntu/.virtualenvs/p2/bin/cwltool 1.0.20180306163216
Resolved 'multi_samtools_mpileup.cwl' to 'file:///mnt/SCRATCH/githubs/samtools-mpileup-cwl/tools/multi_samtools_mpileup.cwl'
usage: multi_samtools_mpileup.cwl [-h] [--min_MQ MIN_MQ] --normal_bam
                                  NORMAL_BAM --ref REF --region REGION
                                  --thread_count THREAD_COUNT --tumor_bam
                                  TUMOR_BAM
                                  [job_order]

positional arguments:
  job_order             Job input json file

optional arguments:
  -h, --help            show this help message and exit
  --min_MQ MIN_MQ
  --normal_bam NORMAL_BAM
  --ref REF
  --region REGION
  --thread_count THREAD_COUNT
  --tumor_bam TUMOR_BAM
```

## For GDC users

See https://github.com/NCI-GDC/gdc-somatic-variant-calling-workflow.
