# HiFi *de novo* genome assembly workflow

HiFi-assembly-workflow is a bioinformatics pipeline that can be used to analyse Pacbio CCS reads for *de novo* genome assembly using PacBio Circular Consensus Sequencing (CCS)  reads. This workflow is implemented in Nextflow and has 3 major sections. 
 
Please refer to the following documentation for detailed description of each workflow section:
 
- [Adapter filteration and Pre-assembly quality control (QC)](https://github.com/AusARG/hifi-assembly-workflow/blob/master/recommendations.md#stage-1-adapter-filteration-and-pre-assembly-quality-control)
- [Assembly](https://github.com/AusARG/hifi-assembly-workflow/blob/master/recommendations.md#stage-2-assembly)
- [Post-assembly QC](https://github.com/AusARG/hifi-assembly-workflow/blob/master/recommendations.md#stage-3-post-assembly-quality-control)

---

# General recommendations 

A more detailed module and workflow description as well as execution examples on GADI and setonix are [available here](workflows.md).

---

# Resources available here

This repository contains structured documentation for dependencies and usage, including links to existing repositories and community resources, as well as a description of the optimisations achieved on the following compute systems:

- [Gadi @ the National Computational Infrastructure (NCI)](infrastructure_optimisation.md)
- ...

---

# Attributions

This work was developed at AGRF and supported by the Australian BioCommons via Bioplatforms Australia funding, the Australian Research Data Commons (https://doi.org/10.47486/PL105) and the Queensland Government RICF programme. Bioplatforms Australia and the Australian Research Data Commons are enabled by the National Collaborative Research Infrastructure Strategy (NCRIS).

The documentation in this repository is based on Australian BioCommons guidelines. 
