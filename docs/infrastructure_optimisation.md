---
title: Workflow optimisation
description: Optimisation of the workflow on NCI Gadi and Pawsey Setonix HPCs
type: docs
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

## Running the workflow on GADI at NCI using if89 project

1. Login to Gadi with your credentials. 
2. Join the `if89 project`, if you have not already. [See this link](https://australianbiocommons.github.io/ables/if89/) for details on how to join.
3. Use the following script to run the workflow:

```
cd <hifi_genome_assembly_location>
hifi_assembly.nf --bam_folder <PATH_TO_BAM_FOLDER> -profile if89 
```



---
