# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is **rl-hifivariantcaller**, a Nextflow pipeline that calls and annotates variants from PacBio HiFi WGS data. The pipeline can run in tumor-only mode (`--treatment_only`) or paired tumor/normal mode, processes data from individual-specific genomes, lifts variants to reference coordinates, and provides comprehensive annotation.

## Common Commands

### Running the Pipeline
```bash
# Basic run with Docker
nextflow run rl/hifivariantcaller -profile docker --input samplesheet.csv --outdir ./results

# Test run
nextflow run rl/hifivariantcaller -profile test,docker --outdir ./results

# Tumor-only mode
nextflow run rl/hifivariantcaller -profile docker --input samplesheet.csv --outdir ./results --treatment_only

# Resume a previous run
nextflow run rl/hifivariantcaller -profile docker --input samplesheet.csv --outdir ./results -resume
```

### Development Commands
```bash
# Pull latest version
nextflow pull rl/hifivariantcaller

# Run with specific revision
nextflow run rl/hifivariantcaller -r main -profile test,docker --outdir ./results
```

## Input Samplesheet Format

The pipeline requires a CSV samplesheet with different formats depending on mode:

### Paired Mode (default):
```csv
sample,tx_bam,ctl_bam,ind_fasta,ind_fasta_fai,ref_fasta,ref_fai,chain
J20_FC_APP,data/treatment.bam,data/control.bam,data/individual.fasta,data/individual.fasta.fai,data/mm10.fasta,data/mm10.fasta.fai,data/liftover.chain.gz
```

### Tumor-only Mode (`--treatment_only`):
```csv
sample,tx_bam,ind_fasta,ind_fasta_fai,ref_fasta,ref_fai,chain
J20_FC_APP,data/treatment.bam,data/individual.fasta,data/individual.fasta.fai,data/mm10.fasta,data/mm10.fasta.fai,data/liftover.chain.gz
```

## Pipeline Architecture

### Main Workflow Structure
- **main.nf**: Entry point that orchestrates the main pipeline workflow
- **workflows/hifivariantcaller.nf**: Core workflow logic with conditional branching for treatment-only vs paired mode
- **subworkflows/local/**: Custom subworkflows for alignment, variant calling, and annotation

### Key Subworkflows
1. **ALIGNMENT**: Aligns HiFi reads to individual-specific genome and runs QC (includes BAM processing and Qualimap)
2. **VARIANTCALLTN**: Calls variants in tumor/normal paired mode using ClairS
3. **VARIANTCALLTO**: Calls variants in tumor-only mode using ClairS  
4. **VARIANTANNOT**: Lifts variants to reference coordinates and annotates with snpEff

### Module Organization
- **modules/local/**: Custom modules for specific tools (align.nf, clairstn.nf, clairsto.nf, liftover.nf, etc.)
- **modules/nf-core/**: Standard nf-core modules (FastQC, MultiQC, Qualimap)

## Configuration Files

- **nextflow.config**: Main configuration with profiles (docker, singularity, conda, etc.)
- **conf/base.config**: Base process configurations 
- **conf/modules.config**: Module-specific configurations
- **conf/test.config**: Test dataset configuration
- **nextflow_schema.json**: Parameter validation schema

## Docker Configuration

The pipeline includes a custom Docker container at `docker/vcfliftover/`:
- **Dockerfile**: Ubuntu 24.04 base with conda environment and bcftools/SCORE plugin
- **conda.yml**: Conda environment specification for liftover tools

## Important Pipeline Features

- **Conditional Logic**: Pipeline automatically detects treatment-only vs paired mode based on `--treatment_only` parameter
- **Channel Management**: Complex channel manipulations to handle different input formats and combine related files
- **Resource Management**: Configurable max memory (1400GB), CPUs (50), and time (240h) with automatic retry logic
- **Quality Control**: Integrated FastQC, Qualimap BAM QC, and MultiQC reporting
- **Liftover Support**: Converts coordinates from individual genomes to reference genomes using chain files
- **Annotation**: SnpEff variant annotation with summary reporting

## Development Notes

- Uses Nextflow DSL2 syntax
- Follows nf-core pipeline standards and conventions
- Supports multiple container technologies (Docker, Singularity, Apptainer, etc.)
- Includes comprehensive error handling and process retries
- Generated execution reports, timelines, and DAG visualizations in `pipeline_info/`
- All intermediate work files stored in `work/` directory

## Testing

Use the test profile which downloads test data from AWS:
```bash
nextflow run rl/hifivariantcaller -profile test,docker --outdir ./test_results
```

Test dataset includes CHM13 chromosome 22 fragments with simulated HiFi reads and reference files.