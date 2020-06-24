#!/usr/bin/env nextflow
nextflow.preview.dsl=2

include {get_file; is_null; param_unexpected_error} from './modules/cli'
include check_env from './modules/versions'
include {
    download as download_pfam_hmm;
    download as download_pfam_dat;
    download as download_pfam_active_site;
    download as download_dbcan;
    encode_seqs;
    decode_seqs;
    gff_results;
    tabular_results;
    rank_results;
    signalp_v3_hmm;
    signalp_v3_nn;
    signalp_v4;
    signalp_v5;
    deepsig;
    phobius;
    tmhmm;
    targetp;
    deeploc;
    apoplastp;
    localizer;
    effectorp_v1;
    effectorp_v2;
    pepstats;
    press_pfam_hmmer;
    pfamscan;
    press_hmmer as press_dbcan_hmmer;
    hmmscan as hmmscan_dbcan;
    extract_effector_seqs;
    mmseqs_index as mmseqs_index_proteomes;
    mmseqs_index as mmseqs_index_phibase;
    mmseqs_index as mmseqs_index_effectors;
    mmseqs_search as mmseqs_search_phibase;
    mmseqs_search as mmseqs_search_effectors;
} from './modules/processes'


def helpMessage() {
    log.info "# Predector pipeline"

    log.info"""

    ## Usage

    ```bash
    nextflow run ccdmb/predector --proteome proteins.fasta --phibase phibase.fas

    nextflow run ccdmb/predector \
      -with-conda /path/to/conda/env \
      --proteome proteins.fasta \
      --phibase phibase.fas

    nextflow run ccdmb/predector \
      -with-singularity /path/to/singularity_container.sif \
      --proteome proteins.fasta \
      --phibase phibase.fas

    nextflow run ccdmb/predector \
      -profile docker \
      --proteome proteins.fasta \
      --phibase phibase.fas
    ```

    ## Mandatory parameters

      --proteome <path or glob>
          Path to the fasta formatted protein sequences.
          Multiple files can be specified using globbing patterns in quotes.
      --phibase <path>
          Path to the PHI-base fasta dataset.

    ## Useful parameters

      -profile <string>
          Specify a pre-set configuration profile to use.
          Multiple profiles can be specified by separating them with a comma.
          Common choices: test, docker, docker_sudo

      -c | -config <path>
          Provide a custom configuration file.
          If you want to customise things like how many CPUs different tasks
          can use, whether to use the SLURM scheduler etc, this is the way
          to do it. See the predector or nextflow documentation for details
          on how to write these.

      -with-conda <path>
          The path to a conda environment to use for dependencies.

      -with-singularity <path>
          Path to the singularity container file to use for dependencies.

      --outdir <path>
          Base directory to store the pipeline results
          default: '${params.outdir}'

      --tracedir <path>
          Directory to store pipeline runtime information
          default: '${params.outdir}/pipeline_info'

      --chunk_size <int>
          The number of proteins to run as a single chunk in the pipeline
          default: '${params.chunk_size}'

      --nostrip
          Don't strip the proteome filename extension when creating the output filenames
          default: false

      --help
          Print this message and exit

      --version
          Print the pipeline version and exit

      --license
          Print the license information and exit

    ## Additional arguments

      --pfam_hmm <path>
          Path to already downloaded gzipped pfam HMM database
          default: download the hmms

      --pfam_hmm_url <url>
          URL to download the pfam HMM database from if --pfam_hmm is not provided
          default: '${params.pfam_hmm_url}'

      --pfam_dat <path>
          Path to already downloaded gzipped pfam DAT database
          default: download the DAT file

      --pfam_dat_url <url>
          URL to download the pfam DAT database from if --pfam_dat is not provided
          default: '${params.pfam_dat_url}'

      --pfam_active_site <path>
          Path to already downloaded gzipped pfam active sites database
          default: download the active sites file

      --pfam_active_site_url <url>
          URL to download the pfam active sites database from if --pfam_active_site is not provided
          default: '${params.pfam_active_site_url}'

      --dbcan <path>
          Path to already downloaded gzipped dbCAN HMM database
          default: download the hmms

      --dbcan_url <url>
          URL to download the dbcan HMM database from if --dbcan is not provided
          default: '${params.dbcan_url}'

      --pfam_targets <path>
          Path to a text file containing PFAM ids considered predictive of effector function.
          Ids should be separated by newlines.
          default: '${params.pfam_targets}'

      --effector_table <path>
          Path to a table containing known effector sequences.
          default: '${params.effector_table}'

      --secreted_weight = 3
      --sigpep_good_weight = 0.5
      --sigpep_ok_weight = 0.25
      --transmembrane_weight = -6
      --deeploc_extracellular_weight = 0.5
      --deeploc_intracellular_weight = -0.5
      --deeploc_membrane_weight = -0.5
      --targetp_secreted_weight = 1
      --targetp_mitochondrial_weight = -0.5
      --effectorp1_weight = 3
      --effectorp2_weight = 3
      --effector_homology_weight = 5
      --virulence_homology_weight = 1
      --lethal_homology_weight = -5
      --sigpep_tm_coverage_threshold = 0.58

    ## Output

      - List
      - the
      - folders/files

    Detailed documentation can be found at <https://github.com/ccdmb/predector>

    """.stripIndent()
}


def licenseMessage() {
    log.info"""
    
    ## License

    Predector is released under the Apache 2.0 license.
    See the full license at <https://github.com/ccdmb/predector/blob/master/LICENSE>.

    If this license is somehow restrictive for you, please let us know.
    We really just want to make sure it's free for people to use.
    """.stripIndent()
}


def versionMessage() {
    log.info "${manifest.version}"
}


def contactMessage() {
    log.info"""
    
    ## Contact us

    The best way to contact us is to raise an issue on github.
      https://github.com/ccdmb/predector/issues

    If you prefer, you can also contact the main authors directly:
    - Darcy Jones <darcy.a.jones@postgrad.curtin.edu.au>
    - James Hane <james.hane@curtin.edu.au>

    """.stripIndent()

}


// Until we get some clarity on what will replace the publish
// workflow section, this is the workaround.
// I don't love it.
process publish_it {

    label "process_low"
    label "posix"

    publishDir "${params.outdir}", saveAs: { name }

    input:
    tuple val(name), path("infile")

    output:
    path "infile", includeInputs: true

    script:
    """
    """
}


workflow check_duplicates {

    take:
    nostrip
    proteomes

    main:
    if ( ! nostrip ) {
        proteomes
            .map { f -> [f.baseName, f] }
            .toList()
            .map { li ->
                // Find any duplicated basenames
                duplicates = li.countBy { it[0] }.findResults { it.value > 1 ? it.key : null }

                // Find the filenames with the duplicated basenames.
                duplicated = li.findAll { duplicates.contains(it[0]) }.collect { n, f -> f }

                // Raise an error if there are duplicates.
                if (duplicated.size() > 0) {
                    log.error(
                        "Some filenames are duplicated after stripping the final extension.\n" +
                        "We strip this extension from the end to make the output filenames a bit friendlier.\n" +
                        "The offending filenames are: ${duplicated}\n" +
                        "Please either rename the files or use the '--nostrip' option to disable the extension stripping for output filenames."
                    )
                    exit 1
                }
            }
    }


}


workflow validate_input {

    main:
    if ( params.proteome ) {
        Channel
            .fromPath(params.proteome, checkIfExists: true, type: 'file')
            .set { proteome_ch }
    } else {
        log.error "Please provide some proteomes to the `--proteome` parameter."
        exit 1
    }

    check_duplicates(params.nostrip, proteome_ch)

    // Check proteins for weirdness?

    if ( params.pfam_hmm ) {
        pfam_hmm_val = get_file(params.pfam_hmm)
    } else {
        pfam_hmm_val = download_pfam_hmm("Pfam-A.hmm.gz", params.pfam_hmm_url)
    }

    if ( params.pfam_dat ) {
        pfam_dat_val = get_file(params.pfam_dat)
    } else {
        pfam_dat_val = download_pfam_dat("Pfam-A.hmm.dat.gz", params.pfam_dat_url)
    }

    if ( params.pfam_active_site ) {
        pfam_active_site_val = get_file(params.pfam_active_site)
    } else {
        pfam_active_site_val = download_pfam_active_site(
            "active_site.dat.gz",
            params.pfam_active_site_url
        )
    }

    if ( params.dbcan ) {
        dbcan_val = get_file(params.dbcan)
    } else {
        dbcan_val = download_dbcan("dbCAN.txt", params.dbcan_url)
    }

    if ( params.phibase ) {
        phibase_val = get_file(params.phibase)
    } else {
        // Should this error out?
        phibase_val = Channel.empty()
    }

    // This has a default value set, so it shouldn't be possible to not specify the parameter.
    effector_val = get_file(params.effector_table)
    pfam_targets_val = get_file(params.pfam_targets)
    dbcan_targets_val = get_file(params.dbcan_targets)

    if ( !["euk", "gramp", "gramn"].contains(params.domain)  ) {
        log.error "Invalid argument to `--domain`: ${params.domain}."
        log.error "Must be one of 'euk', 'gramp', 'gramn'."
        exit 1
    }

    emit:
    proteome_ch
    pfam_hmm_val
    pfam_dat_val
    pfam_active_site_val
    dbcan_val
    phibase_val
    effector_val
    pfam_targets_val
    dbcan_targets_val
}


workflow {

    main:
    if ( params.help ) {
        helpMessage()
        licenseMessage()
        contactMessage()
        exit 0
    }

    if ( params.license ) {
        licenseMessage()
        contactMessage()
        exit 0
    }

    if ( params.version ) {
        versionMessage()
        exit 0
    }

    // println "$workflow.runName"
    // println "$workflow.sessionId"
    // println "$workflow.start"
    // println "$workflow.revision"
    // println "$workflow.manifest.version"

    // We're hard-coding this for now since a lot of analyses don't make sense
    // for bacteria and archaea
    params.domain = "euk"
    signalp_domain_map = ["euk": "euk", "gramp": "gram+", "gramn": "gram-"]
    signalp_domain = signalp_domain_map.get(params.domain)

    // This handles the user input, downloads required databases etc.
    input = validate_input()

    // This checks that all of the software is installed and finds the version
    // info where it can.
    versions = check_env()

    // Remove duplicates and split fasta(s) into chunks to run in parallel.
    // Maybe download precomputed results?
    (combined_proteomes_ch, combined_proteomes_tsv_ch) = encode_seqs(
        params.chunk_size,
        input.proteome_ch.collect()
    )

    split_proteomes_ch = combined_proteomes_ch.flatten()

    // Run the machine-learning/simple statistics analyses.
    signalp_v3_hmm_ch = signalp_v3_hmm(signalp_domain, split_proteomes_ch)
    signalp_v3_nn_ch = signalp_v3_nn(signalp_domain, split_proteomes_ch)
    signalp_v4_ch = signalp_v4(signalp_domain, split_proteomes_ch)
    (signalp_v5_ch, signalp_v5_mature_ch) = signalp_v5(signalp_domain, split_proteomes_ch)

    deepsig_ch = deepsig(params.domain, split_proteomes_ch)
    phobius_ch = phobius(split_proteomes_ch)
    tmhmm_ch = tmhmm(split_proteomes_ch)

    targetp_ch = targetp(split_proteomes_ch)
    deeploc_ch = deeploc(split_proteomes_ch)

    apoplastp_ch = apoplastp(split_proteomes_ch)
    localizer_ch = localizer(signalp_v5_mature_ch)
    effectorp_v1_ch = effectorp_v1(split_proteomes_ch)
    effectorp_v2_ch = effectorp_v2(split_proteomes_ch)

    pepstats_ch = pepstats(split_proteomes_ch)

    // Run the domain and database searches
    pressed_pfam_hmmer_val = press_pfam_hmmer(
        input.pfam_hmm_val,
        input.pfam_dat_val,
        input.pfam_active_site_val
    )
    pfamscan_ch = pfamscan(pressed_pfam_hmmer_val, split_proteomes_ch)

    pressed_dbcan_hmmer_val = press_dbcan_hmmer(input.dbcan_val)
    dbcan_hmmer_ch = hmmscan_dbcan("dbcan", pressed_dbcan_hmmer_val, split_proteomes_ch)

    proteome_mmseqs_index_ch = mmseqs_index_proteomes(
        split_proteomes_ch.map { f -> ["chunk", f] }
    ).map { v, f -> f }

    phibase_mmseqs_index_val = mmseqs_index_phibase(
        input
        .phibase_val
        .map { f -> ["phibase", f] }
    )

    phibase_mmseqs_matches_ch = mmseqs_search_phibase(
        phibase_mmseqs_index_val,
        proteome_mmseqs_index_ch
    )

    effectors_mmseqs_index_val = input.effector_val \
        | extract_effector_seqs \
        | map { f -> ["effectorsearch", f] } \
        | mmseqs_index_effectors

    effectors_mmseqs_matches_ch = mmseqs_search_effectors(
        effectors_mmseqs_index_val,
        proteome_mmseqs_index_ch
    )

    // At this point, all of the analyses have their own ldjson files.
    // Here we just merge that all into one big file.
    decoded_ch = decode_seqs(
        !params.nostrip,
        combined_proteomes_tsv_ch,
        signalp_v3_hmm_ch
        .mix(
            signalp_v3_nn_ch,
            signalp_v4_ch,
            signalp_v5_ch,
            deepsig_ch,
            phobius_ch,
            tmhmm_ch,
            targetp_ch,
            deeploc_ch,
            apoplastp_ch,
            localizer_ch,
            effectorp_v1_ch,
            effectorp_v2_ch,
            pepstats_ch,
            pfamscan_ch,
            dbcan_hmmer_ch,
            phibase_mmseqs_matches_ch,
            effectors_mmseqs_matches_ch
        )
        .collect()
    )

    decoded_with_names_ch = decoded_ch.flatten().map { f -> [f.baseName, f] }
    gff_ch = gff_results(decoded_with_names_ch)
    tabular_ch = tabular_results(decoded_with_names_ch)

    ranked_ch = rank_results(
        params.secreted_weight,
        params.sigpep_good_weight,
        params.sigpep_ok_weight,
        params.transmembrane_weight,
        params.deeploc_extracellular_weight,
        params.deeploc_intracellular_weight,
        params.deeploc_membrane_weight,
        params.targetp_secreted_weight,
        params.targetp_mitochondrial_weight,
        params.effectorp1_weight,
        params.effectorp2_weight,
        params.effector_homology_weight,
        params.virulence_homology_weight,
        params.lethal_homology_weight,
        params.sigpep_tm_coverage_threshold,
        input.dbcan_targets_val,
        input.pfam_targets_val,
        decoded_with_names_ch
    )

    input.pfam_hmm_val.map { ["downloads/${it.name}", it]}
        .mix(
            input.pfam_dat_val.map { ["downloads/${it.name}", it] },
            input.pfam_active_site_val.map { ["downloads/${it.name}", it] },
            input.dbcan_val.map { ["downloads/${it.name}", it] },
            combined_proteomes_ch.map { ["deduplicated/${it.name}", it] },
            combined_proteomes_tsv_ch.map { ["deduplicated/${it.name}", it] },
            decoded_with_names_ch.map { n, f -> ["${n}/${n}.ldjson", f] },
            gff_ch.map { n, f -> ["${n}/${f.name}", f] },
            ranked_ch.map { n, f -> ["${n}/${f.name}", f] },
            tabular_ch.flatMap { n, fs -> fs.collect { f -> ["${n}/${f.name}", f] } }
        ) \
    | publish_it
}
