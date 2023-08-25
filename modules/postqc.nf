process evaluate_assemblies {
    tag "$name"
    label 'evaluate_assemblies'
    cpus params.quast_threads

    conda (params.enable_conda ? "bioconda::quast" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    '' :
    'quay.io/biocontainers/quast:5.2.0--py310pl5321hc8f18ef_2' }"

	publishDir "${params.resultsQuast}/${name}", mode: "copy", saveAs: { filename -> filename.endsWith('primary') ? "primary_contig" : PASS } 
    publishDir "${params.resultsQuast}/${name}", mode: "copy", saveAs: { filename -> filename.endsWith('associate') ? "associate_contig" : PASS } 
        // module 'quast'

	input:
    tuple file(primary), file(secondary), val(name)
    tuple file(css_fasta), val(input)
	

	output:
	file("*")

	shell:
	"""
        #quast.py -o ${name}_primary -t ${task.cpus} -l primary_contig --pacbio ${css_fasta} ${primary}
        quast.py -o ${name}_primary -t ${task.cpus} -l primary_contig  ${primary}
        quast.py -o ${name}_associate -t ${task.cpus} -l associate_contig  ${secondary}
	"""	
}


process assemblies_completeness {
    tag "$name"
    label 'assemblies_completeness'
    cpus params.busco_threads

    conda (params.enable_conda ? "bioconda::busco" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    '' :
    'quay.io/biocontainers/busco:5.4.3--pyhdfd78af_0' }"

   
    publishDir "${params.resultsBusco}/${name}",  mode: 'copy',  saveAs: { filename -> filename.endsWith('primary_busco') ? "primary_contig" : PASS } 
    publishDir "${params.resultsBusco}/${name}",  mode: 'copy',  saveAs: { filename -> filename.endsWith('associate_busco') ? "associate_contig" : PASS } 

    input:
    tuple file(primary), file(secondary), val(name)
    val lineage
    path busco_lineages_path 
    
    output:
    file("*")

    script:
    def busco_lineage = lineage.equals('auto') ? '--auto-lineage' : "--lineage_dataset ${lineage}"
    def busco_lineage_dir = busco_lineages_path ? "--offline --download_path ${busco_lineages_path}" : ''
    """
    busco -f -i $primary -o primary_busco -c ${task.cpus} -m genome $busco_lineage $busco_lineage_dir
    busco -f -i $secondary -o associate_busco -c ${task.cpus} -m genome $busco_lineage $busco_lineage_dir
    """	
}
