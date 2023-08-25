process assembly {
tag "Denovo assembly on sample: $bam_tag"
label 'assembly'

conda (params.enable_conda ? "${projectDir}/assets/ipa.yml" : null)
container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    '' :
    'australianbiocommons/pbipa' }"

publishDir params.resultsassembly, mode: 'copy', saveAs: { filename -> filename.endsWith('p_ctg.fasta') ? "${bam_tag}_primary.fasta" : "${bam_tag}_associate.fasta" }
// module 'ipa'


input:
file(bamFile)

output:
tuple file("RUN/19-final/final.p_ctg.fasta"), file("RUN/19-final/final.a_ctg.fasta"), val("$bam_tag")


shell:
bam_tag = bamFile.baseName

script:
"""
ipa local --nthreads ${params.ipa_threads} --njobs ${params.ipa_jobs} -i ${bamFile}
"""
}
