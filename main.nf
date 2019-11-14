#!/usr/bin/env nextflow


/*
 * Parameters are defined inside nextflow.config
 * this allows you to provide a config file if command line arguments
 * are too long.
 */

println "$workflow.runName"
println "$workflow.sessionId"
println "$workflow.start"
println "$workflow.revision"
println "$workflow.manifest.version"

/*
 *  Parse the input parameters
 */
if ( params.proteome ) {
    Channel
        .fromPath(params.proteome, checkIfExists: true, type: 'file')
        .map { f -> [ f.simpleName, f ] }
        .into {
            proteome_ch_signalp3_hmm;
            proteome_ch_signalp3_nn;
            proteome_ch_signalp4;
            proteome_ch_signalp5;
            proteome_ch_deepsig;
            proteome_ch_targetp;
            proteome_ch_deeploc;
            proteome_ch_effectorp1;
            proteome_ch_effectorp2;
            proteome_ch_tmhmm;
            proteome_ch_apoplastp;
            proteome_ch_emboss;
            proteome_ch_localizer;
            proteome_ch_phobius;
        }

} else {
    log.error "Please provide some proteomes to the `--proteome` parameter."
    exit 1
}


if ( params.phibase ) {
    phibase = Channel.value(file(params.phibase, checkIfExists: true, type: 'file'))
} else {
    phibase = Channel.empty()
}


if ( params.pfam_hmm ) {
    pfam_hmm_file = file(params.pfam_hmm, checkIfExists: true, type: 'file')

} else {

    process 'DownloadPfamHMMs' {

        publishDir "${params.outdir}/downloads"
        label "download"
        label "process_low"

        when:
        !params.pfam_hmm

        output:
        path "Pfam-A.hmm.gz" into pfam_hmm_file

        script:
        """
        wget -O Pfam-A.hmm.gz "${params.pfam_hmm_url}"
        """
    }

}


if ( params.pfam_dat ) {
    pfam_dat_file = file(params.pfam_dat, checkIfExists: true, type: 'file')

} else {

    process 'DownloadPfamDat' {

        publishDir "${params.outdir}/downloads"
        label "download"
        label "process_low"

        when:
        !params.pfam_dat

        output:
        path "Pfam-A.hmm.dat.gz" into pfam_dat_file

        script:
        """
        wget -O Pfam-A.hmm.dat.gz "${params.pfam_dat_url}"
        """
    }

}


if ( params.pfam_active_site ) {
    pfam_active_site_file = file(params.pfam_active_site, checkIfExists: true, type: 'file')

} else {

    process 'DownloadPfamActiveSites' {

        publishDir "${params.outdir}/downloads"
        label "download"
        label "process_low"

        when:
        !params.pfam_active_site

        output:
        path "active_site.dat.gz" into pfam_active_site_file

        script:
        """
        wget -O active_site.dat.gz "${params.pfam_active_site_url}"
        """
    }

}


if ( params.dbcan ) {
    dbcan_file = file(params.dbcan, checkIfExists: true, type: 'file')
} else {

    process 'DownloadDbcan' {

        publishDir "${params.outdir}/downloads"
        label "download"
        label "process_low"

        when:
        !params.dbcan

        output:
        path "dbCAN.txt" into dbcan_file

        script:
        """
        wget -O dbCAN.txt "${params.dbcan_url}"
        """

    }
}


if ( params.phibase ) {
    phibase_file = Channel.value(
        file(params.phibase, checkIfExists: true, type: 'file')
    )
} else {
    phibase_file = Channel.empty()
}


if ( !["euk", "gramp", "gramn"].contains(params.domain)  ) {
    log.error "Invalid argument to `--domain`: ${params.domain}."
    log.error "Must be one of 'euk', 'gramp', 'gramn'."
    exit 1
}

signalp_domain_map = ["euk": "euk", "gramp": "gram+", "gramn": "gram-"]
signalp_domain = signalp_domain_map.get(params.domain)



//
// STEP 1: identify likely localisation signals.
//


/*
 * Identify signal peptides using SignalP v3 hmm
 */
process 'SignalP_v3_hmm' {

    publishDir "${params.outdir}/raw"

    label 'signalp3'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_signalp3_hmm

    output:
    tuple val(name), path("${name}_signalp3_hmm.txt") into signalp3_hmm_ch

    script:
    """
    signalp -type "${signalp_domain}" -method "hmm" -short in.fasta > "${name}_signalp3_hmm.txt"
    """
}


/*
 * Identify signal peptides using SignalP v3 nn
 */
process 'SignalP_v3_nn' {

    publishDir "${params.outdir}/raw"

    label 'signalp3'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_signalp3_nn

    output:
    tuple val(name), path("${name}_signalp3_nn.txt") into signalp3_nn_ch

    script:
    """
    signalp -type "${signalp_domain}" -method "nn" -short in.fasta > "${name}_signalp3_nn.txt"
    """
}


/*
 * Identify signal peptides using SignalP v4
 */
process 'SignalP_v4' {

    publishDir "${params.outdir}/raw"

    label 'signalp4'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_signalp4

    output:
    tuple val(name), path("${name}_signalp4.txt") into signalp4_ch

    script:
    """
    signalp -t "${signalp_domain}" -f short in.fasta > "${name}_signalp4.txt"
    """
}


/*
 * Identify signal peptides using SignalP v5
 */
process 'SignalP_v5' {

    publishDir "${params.outdir}/raw"

    label 'signalp5'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_signalp5

    output:
    tuple val(name), path("${name}_signalp5.txt") into signalp5_ch
    tuple val(name), path("${name}_signalp5_mature.fasta") into signalp5_mature_ch

    script:
    """
    mkdir -p tmpdir
    signalp -org "${signalp_domain}" -format short -tmp tmpdir -mature -fasta in.fasta -prefix "${name}"
    mv "${name}_summary.signalp5" "${name}_signalp5.txt"
    mv "${name}_mature.fasta" "${name}_signalp5_mature.fasta"
    rm -rf -- tmpdir
    """
}


/*
 * Identify signal peptides using DeepSig
 */
process 'DeepSig' {

    publishDir "${params.outdir}/raw"

    label "deepsig"
    label "process_low"

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_deepsig

    output:
    tuple val(name), path("${name}_deepsig.txt") into deepsig_ch

    script:
    """
    deepsig.py -f in.fasta -k "${params.domain}" -o "${name}_deepsig.txt"
    """
}


/*
 * Phobius for signal peptide and tm domain prediction.
 */
process 'Phobius' {

    publishDir "${params.outdir}/raw"

    label 'phobius'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_phobius

    output:
    tuple val(name), path("${name}_phobius.txt") into phobius_ch

    script:
    """
    phobius.pl -short in.fasta > "${name}_phobius.txt"
    """
}


/*
 * TMHMM
 */
process 'TMHMM' {

    publishDir "${params.outdir}/raw"

    label 'tmhmm'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_tmhmm

    output:
    tuple val(name), path("${name}_tmhmm.txt") into tmhmm_ch

    script:
    """
    tmhmm -short -d < in.fasta > "${name}_tmhmm.txt"
    rm -rf -- TMHMM_*
    """
}


/*
 * Subcellular location using TargetP
 */
process 'TargetP' {

    publishDir "${params.outdir}/raw"

    label 'targetp'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_targetp

    output:
    tuple val(name), path("${name}_targetp2.txt") into targetp_ch

    script:
    """
    mkdir -p tmpdir
    targetp -fasta in.fasta -org non-pl -format short -prefix "${name}"
    mv "${name}_summary.targetp2" "${name}_targetp2.txt"
    rm -rf -- tmpdir
    """
}


/*
 * Subcellular location using DeepLoc
 */
process 'DeepLoc' {

    publishDir "${params.outdir}/raw"

    label 'deeploc'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_deeploc

    output:
    tuple val(name), path("${name}_deeploc.txt") into deeploc_ch

    script:
    """
    deeploc -f in.fasta -o "${name}"
    mv "${name}.txt" "${name}_deeploc.txt"
    """
}


/*
 * ApoplastP
 */
process 'ApoplastP' {

    publishDir "${params.outdir}/raw"

    label 'apoplastp'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_apoplastp

    output:
    tuple val(name), path("${name}_apoplastp.txt") into apoplastp_ch

    script:
    """
    ApoplastP.py -s -i in.fasta > "${name}_apoplastp.txt"
    """
}


/*
 * Localizer
 */
process 'Localizer' {

    publishDir "${params.outdir}/raw"

    label 'localizer'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("mature.fasta") from signalp5_mature_ch

    output:
    tuple val(name), path("${name}_localizer.txt") into lozalizer_ch

    script:
    """
    LOCALIZER.py -e -M -i mature.fasta -o "run"

    mv run/Results.txt "${name}_localizer.txt"
    rm -rf -- run
    """
}


//
// STEP2 get protein properties and effector-characteristics stats.
//


/*
 * Effector ML using EffectorP v1
 */
process 'EffectorP_v1' {

    publishDir "${params.outdir}/raw"

    label 'effectorp1'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_effectorp1

    output:
    tuple val(name), path("${name}_effectorp1.txt") into effectorp1_ch

    script:
    """
    EffectorP.py -s -i in.fasta > "${name}_effectorp1.txt"
    """
}


/*
 * Effector ML using EffectorP v2
 */
process 'EffectorP_v2' {

    publishDir "${params.outdir}/raw"

    label 'effectorp2'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_effectorp2

    output:
    tuple val(name), path("${name}_effectorp2.txt") into effectorp2_ch

    script:
    """
    EffectorP.py -s -i in.fasta > "${name}_effectorp2.txt"
    """
}


/*
 * Emboss
 */
process 'Emboss' {

    publishDir "${params.outdir}/raw"

    label 'emboss'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta") from proteome_ch_emboss

    output:
    tuple val(name), path("${name}_emboss.txt") into emboss_ch

    script:
    """
    pepstats -sequence in.fasta -outfile "${name}_emboss.txt"
    """
}


//
// STEP 3: find domain & database matches.
//





