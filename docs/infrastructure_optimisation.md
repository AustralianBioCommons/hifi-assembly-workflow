---
title: Usage on different compute systems
description: Using the workflow on NCI Gadi and Pawsey Setonix HPCs
---


## Accessing tool/workflow

Workflow consists of three modules:

1.	Preqc module consists of bam to fasta conversion, k-mer analysis and genome profiling processes.
2.	Assembly module consists of processing CCS data using IPA
3.	Post assembly module consists of assembly evaluation and assessing completeness.


### Dependencies

The following packages are used by the pipeline.
```
nextflow/21.04.3
samtools/1.12
jellyfish/2.3.0
genomescope/2.0
ipa/1.3.1
quast/5.0.2
busco/5.4.3
HiFiAdapterFilt/2.0.0
```


## Pawsey

#### Running on Setonix at Pawsey
```
module load nextflow/23.04.1
module load singularity/3.8.6
nextflow run hifi_assembly.nf --bam_folder <PATH TO THE BAM FOLDER> --project_id director2172  -profile setonix
```


## NCI 

### Facility access

One should have a user account set with NCI to access gadi high performance computational facility. Setting up a NCI account is mentioned in detail at the following URL: https://opus.nci.org.au/display/Help/Setting+up+your+NCI+Account 
  
Documentation for a specific infrastructure should go into a infrastructure documentation template
https://github.com/AustralianBioCommons/doc_guidelines/blob/master/infrastructure_optimisation.md


### Running on GADI at NCI

Here is an example that can be used to run a phased assembly on Gadi utilising [if89](https://australianbiocommons.github.io/ables/if89/) (shared tools and workflow repository):

```
module load nextflow
module load singularity
nextflow run hifi_assembly.nf --bam_folder <PATH TO THE BAM FOLDER> --project_id xl04 --storage_paths gdata/if89+gdata/ll61 -profile if89
```


### Running the workflow on GADI at NCI using if89 project

1. Login to Gadi with your credentials. 
2. Join the `if89 project`, if you have not already. [See this link](https://australianbiocommons.github.io/ables/if89/) for details on how to join.
3. Use the following script to run the workflow:

```
cd <hifi_genome_assembly_location>
hifi_assembly.nf --bam_folder <PATH_TO_BAM_FOLDER> -profile if89 
```



