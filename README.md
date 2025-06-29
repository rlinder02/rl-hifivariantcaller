[![GitHub Actions CI Status](https://github.com/rlinder02/rl-hifivariantcaller/actions/workflows/ci.yml/badge.svg)](https://github.com/rlinder02/rl-hifivariantcaller/actions/workflows/ci.yml)
[![nf-test](https://img.shields.io/badge/unit_tests-nf--test-337ab7.svg)](https://www.nf-test.com)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Seqera Platform](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Seqera%20Platform-%234256e7)](https://cloud.seqera.io/launch?pipeline=https://github.com/rl/hifivariantcaller)

## Introduction

**rlinder02/rl-hifivariantcaller** is a bioinformatics pipeline that call and annotates variants from PacBio HiFi data. 

## Usage

![alt text](docs/images/docs/images/LongReadVariantCalling_Metromap.drawio.png)

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,tx_bam,ctl_bam,ind_fasta,ind_fasta_fai,ref_fasta,ref_fai,chain
J20_FC_APP,data/J20_FC_APP_m84137_240223_225931_s2.hifi_reads.bc2069.bam,data/J20_FC_CTL_m84137_240224_005830_s3.hifi_reads.bc2070.bam,data/J20_CTL.primary.scaffolded.fasta,data/J20_CTL.primary.scaffolded.fasta.fai,data/mm10.chrs.fasta,data/mm10.chrs.fasta.fai,data/J20_CTL.primary.scaffoldedToMm10.chrs.over.chain.gz
```

Each row represents a treatment/normal pair of bam files, as well as a genome fasta assembled from each individual sample, a genome fasta from the reference genome to use for annotation purposes, and a chain file to lift-over genomic coordinates from the individuals' genome to the reference genome. If there are no matched normal controls, use tumor-only mode by adding `--treatment_only` to the command line argument. 

-->

Now, you can run the pipeline using:

```bash
nextflow run rl/hifivariantcaller \
   -profile docker \
   --input assets/samplesheet.csv \
   --outdir ./results
```

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

## Credits

rl/hifivariantcaller was originally written by Rob Linder.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use rl/hifivariantcaller for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
