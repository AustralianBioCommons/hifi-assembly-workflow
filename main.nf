#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def helpMessage() {
    log.info """
    ====================================
     Denovo HiFi assembly pipeline 
    ====================================
    Usage:
    The typical command for running the pipeline is as follows:
    
    nextflow run hifi_assembly.nf --bam_folder <HiFi BAM files> 

    Mandatory arguments:
      --bam_folder                 Folder containing BAM files (Only *HiFi* BAM file)

    Optional arguments:
      --out_dir                   Path to the otuput directory. Default: The input bam directory.
      
      --samtools_threads          Number of threads to use for samtools. Default is ${params.samtools_threads}.
      --samtools_memory           Memory to use for samtools. Default is ${params.samtools_memory}.
      
      --adapter_filteration       Apply adapter Filtration on the bam files. Default is ${params.adapter_filteration}.
      --hifi_adapter_threads      Number of threads used by hifi_adapter. Default is ${params.hifi_adapter_threads}.
      --hifi_adapter_memory       The memory to use for hifi_adapter. Default is ${params.hifi_adapter_memory}.
      
      --jellyfish_mer_len         The mer length for jellyfish. Default is ${params.jellyfish_mer_len}.
      --jellyfish_threads         The number of threads used by jellyfish. Default is ${params.jellyfish_threads}.
      --jellyfish_hash_size       The hash size used by jellyfish. Default is ${params.jellyfish_hash_size}.
      --jellyfish_memory          The memory used by jellyfish. Default is ${params.jellyfish_memory}.
      
      --genomescope_threads       The number of threads used by genome-cope. Default is ${params.genomescope_threads}.
      --genomescope_memory        The memory used by genomescope. Default is ${params.genomescope_memory}.
        
      --ipa_jobs                  Number of jobs used by ipa. Default is ${params.ipa_jobs}.
      --ipa_threads               Number of threads used by ipa. Default is ${params.ipa_threads}. The number of the requested cpus will `ipa_jobs * ipa_threads`.
      --ipa_memory                The memory used by ipa. Default is ${params.ipa_memory}.

      --quast_threads             The number of threads used by quast. Default is ${params.quast_threads}.
      --quast_memory              The memory used by quast. Default is ${params.quast_memory}.
        
      --busco_lineage             The lineage to use from the busco database. default is ${params.busco_lineage}.
      --busco_lineage_dir         The path to the lineage directory. if not provided or set to [] busco will download the lineage
      --busco_threads             The number of threads used by busco. Default is ${params.busco_threads}.
      --busco_memory              The memory requested for busco. Default is ${params.busco_memory}.
      
      --project_id                Project id on GADI/Setonix to submit jobs through. Mandatory when using if89/setonix profile. (Example: xl04 for AusARG).
      --storage_paths             Storage_paths on GADI to to be accessed from the compute nodes. Mandatory when using if89 profile. (Example: gdata/if89+gdata/xl04).
      --singularity_cache         The path to the singularity local cache directory.
      --aws_execution_role        The execution role to be used when running the pipline using aws batch on AWS cloud service. Mandatory when using `aws` profile. 
      --aws_region                The AWS region needed for configuring running the pipline using aws batch on AWS cloud service. Mandatory when using `aws` profile.
      --aws_queue                 The AWS batch queue to submit the jobs to. Mandatory when using `aws` profile.


"""
}


if ("${workflow.profile}" == "if89"){
    if (params.project_id == "") { exit 1, 'Input project_id is mandatory when using if89 profile!' }
    if (params.storage_paths == "") { exit 1, 'Input storage_paths is mandatory when using if89 profile!' }
}
if ("${workflow.profile}" == "setonix"){
    if (params.project_id == "") { exit 1, 'Input project_id is mandatory when using setonix profile!' }
}

if ("${workflow.profile}" == "aws"){
    if (params.aws_execution_role == "" || params.aws_queue == "" || params.aws_region == "") { 
        exit 1, 'aws_execution_role, aws_region, and aws_queue are mandatory when using aws profile!' 
    }
}

// Show help message
params.help = false
if (params.help) {
    helpMessage()
    exit 0
}

// General configuration variables


if (params.bam_folder == "") {
   	println("Please provide path to bam files\n")
    	helpMessage()
    	exit 1
}

if (params.busco_lineage_dir == "") {
    params.busco_lineage_dir = []
}

// Creating results folder
//results = "${outDir}/Results"
file("${params.out_dir}/Results").mkdir()

include { bam2fasta } from './modules/preqc'
include { hifiadapterfilter } from './modules/preqc'
include { jellyfish } from './modules/preqc'
include { genomescope } from './modules/preqc'
include { assembly } from './modules/assembly'
include { evaluate_assemblies } from './modules/postqc'
include { assemblies_completeness } from './modules/postqc'



 workflow {
    // Bam files
    Channel
        .fromPath("${params.bam_folder}/*bam", checkIfExists:true)  
        .ifEmpty { error "Cannot find any bam files: ${params.bam_folder}" }
    	.set { ch_bam  }

    

    // Load modules
    
    //Pre QC module

    if (params.adapter_filteration){
        println("Convert bam to fasta thorugh HiFiAdapterFilt. Adapter filteration will be applied!")
        hifiadapterfilter(ch_bam)
        ch_bam2fastaName = hifiadapterfilter.out[1]
        ch_bam2fastafile = hifiadapterfilter.out.map{[it[0], it[1]]}
        ch_assembly_input = hifiadapterfilter.out.map{it[0]}
    }else{
        println("Convert bam to fasta thorugh samtools. No adapter filteration!")
        // Parsing bam to fasta  - Default behaviur 
        ch_assembly_input = ch_bam
        bam2fasta( ch_bam )
        ch_bam2fastaName = bam2fasta.out[1]
        ch_bam2fastafile = bam2fasta.out[0]
        //ch_assembly_input = bam2fasta.out.map{it[0]}
    }
    
    
    // K-mer counts and histogram 
    jellyfish (ch_bam2fastafile)
    ch_jellyfishhisto = jellyfish.out[0]

    
    // Genome profiling
    genomescope(ch_jellyfishhisto)
    ch_genomescope = genomescope.out

    //ASSEMBLY
    assembly(ch_assembly_input)
    ch_assembly = assembly.out[0]

    // PostQC 
    // assembly evaluation
    evaluate_assemblies ( ch_assembly, ch_bam2fastafile )
    ch_assembly_evaluation = evaluate_assemblies.out[0]
    
    // assembly completeness
   assemblies_completeness(ch_assembly,params.busco_lineage,params.busco_lineage_dir)
   
}



// Display information about the completed run
// https://www.nextflow.io/docs/latest/metadata.html
workflow.onComplete {
	log.info "Pipeline completed at: $workflow.complete"
    log.info "Nextflow Version:	$workflow.nextflow.version"
  	log.info "Command Line:		$workflow.commandLine"
	// log.info "Container:		$workflow.container"
	log.info "Duration:		$workflow.duration"
	log.info "Output Directory:	$params.out_dir"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
}
