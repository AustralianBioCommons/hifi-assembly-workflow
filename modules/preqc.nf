process bam2fasta {
tag "Converting bam to fasta for sample: $bam_tag"
label 'bam2fasta'

conda (params.enable_conda ? "bioconda::samtools" : null)
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
'' :
'quay.io/biocontainers/samtools:1.16.1--h6899075_0' }"

publishDir params.resultsDirbam2fasta, mode: 'copy'


input:
file(bamFile)

output:
tuple file("*.fa"), val("$bam_tag")


shell:
bam_tag = bamFile.baseName

script:
"""
samtools fasta --threads ${task.cpus} ${bamFile} > ${bam_tag}.fa

"""
}


process jellyfish {
tag "Generating k-mer counts and histogram  on $name"
label 'jellyfish'

conda (params.enable_conda ? "bioconda::jellyfish" : null)
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
'' :
'quay.io/biocontainers/kmer-jellyfish:2.3.0--h9f5acd7_3' }"

cpus params.jellyfish_threads


publishDir params.resultsjellyfish, mode: 'copy'
// module 'jellyfish'

input:
tuple  file(fasta), val(name)

output:
tuple val(name), file("${name}.histo"), file("${name}.jf")

script:
"""
jellyfish count -C -m ${params.jellyfish_mer_len} -s ${params.jellyfish_hash_size} -t ${task.cpus} ${fasta} -o ${name}.jf 
jellyfish histo ${name}.jf > ${name}.histo
"""
}


process genomescope {
tag "Profiling genome characteristics on $name"
label 'genomescope'

conda (params.enable_conda ? "bioconda::genomescope2" : null)
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
'' :
'quay.io/biocontainers/genomescope2:2.0--py310r41hdfd78af_5' }"

publishDir params.resultsgenomescope, mode: 'copy'
// module 'genomescope'

input:
tuple val(name), file(histo), file(jf)

output:
file("${name}/summary.txt") 
file("${name}/linear_plot.png")


script:
//if ($workflow.profile=="nf_tower")
if (true)
    """
    genomescope2 -i ${histo} -o ${name}
    """
else
    """
    genomescope.R -i ${histo} -o ${name}
    """
}


// Added by Ziad Al Bkhetan
process hifiadapterfilter {
    tag "Converting bam to fasta and remove reads with remnant PacBio adapter sequences for sample: $bam_tag"
    label 'HiFiAdapterFilt'

    conda (params.enable_conda ? null : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    '' :
    'australianbiocommons/hifiadapterfilt' }"

    publishDir params.resultsDirbam2fasta, mode: 'copy'


    input:
    file(bamFile)

    output:
    tuple file("*.fa"), val("$bam_tag"), file("*.contaminant.blastout"), file("*.blocklist"), file("*.filt.fastq.gz"), file("*.stats")


    shell:
    bam_tag = bamFile.baseName

    script:

    """

    pbadapterfilt.sh -t ${task.cpus} -p  ${bam_tag} 

    gunzip -c ${bam_tag}.filt.fastq.gz | sed -n '1~4s/^@/>/p;2~4p' > ${bam_tag}.fa

    """
}