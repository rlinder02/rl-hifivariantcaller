#!/usr/bin/env python 
# 4-space indented, v0.0.1
# File name: profile_mutations.py
# Description: Use sigprofiler to map mutation profiles onto samples from the COSMIC database.
# Author: Robert Linder
# Date: 2024-09-16

import argparse
from SigProfilerAssignment import Analyzer as Analyze

def parse_args():
	"""this enables users to provide input as command line arguments to minimize the need for directly modifying the script; please enter '-h' to see the full list of options"""
	parser = argparse.ArgumentParser(description="Map known mutational profiles to samples")
	parser.add_argument("vcf_path", type=str, help="path to the sample VCF to be analyzed")
	parser.add_argument("output_path", type=str, help="path to the output folder")
	parser.add_argument("reference", type=str, help="reference genome build")
	args = parser.parse_args()
	return args

def map_mut_profiles(vcf_dir, out_dir, ref):
    """Map known mutational profiles onto samples in VCF format"""
    Analyze.cosmic_fit(samples=vcf_dir, output=out_dir, input_type="vcf", context_type="96", genome_build=ref)

def main():
    inputs = parse_args()
    vcf_dir =  inputs.vcf_path
    out_dir = inputs.output_path
    ref = inputs.reference
    map_mut_profiles(vcf_dir, out_dir, ref)

if __name__ =="__main__":
    main()