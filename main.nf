#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include {get_file; is_null; param_unexpected_error} from './modules/cli'
include {check_env} from './modules/versions'
include {
    download as download_phibase;
    download as download_pfam_hmm;
    download as download_pfam_dat;
    download as download_dbcan;
    download as download_effectordb;
    encode_seqs;
    decode_seqs;
    filter_precomputed;
    split_fasta;
    sanitise_phibase;
    gff_results;
    tabular_results;
    rank_results;
    signalp_v3_hmm;
    signalp_v3_nn;
    signalp_v4;
    signalp_v5;
    signalp_v6;
    deepsig;
    phobius;
    tmhmm;
    targetp;
    deeploc;
    apoplastp;
    localizer;
    effectorp_v1;
    effectorp_v2;
    effectorp_v3;
    deepredeff_fungi_v1;
    deepredeff_oomycete_v1;
    pepstats;
    press_pfam_hmmer;
    pfamscan;
    press_hmmer as press_dbcan_hmmer;
    press_hmmer as press_effectordb_hmmer;
    hmmscan as hmmscan_dbcan;
    hmmscan as hmmscan_effectordb;
    mmseqs_index as mmseqs_index_proteomes;
    mmseqs_index as mmseqs_index_phibase;
    mmseqs_search as mmseqs_search_phibase;
    run_regex as kex2_regex;
    run_regex as rxlrlike_regex;
    gen_target_table
} from './modules/processes'


def helpMessage() {
    log.info "# Predector"
    log.info ""

    log.info"""
    Predector predicts effectors in your proteomes.

    ## Usage

    ```bash
    nextflow run ccdmb/predector --proteome proteins.fasta --phibase phibase.fas

    nextflow run ccdmb/predector \\
      -with-conda /path/to/conda/env \\
      --proteome proteins.fasta \\
      --phibase phibase.fas

    nextflow run ccdmb/predector \\
      -with-singularity /path/to/singularity_container.sif \\
      --proteome proteins.fasta \\
      --phibase phibase.fas

    nextflow run ccdmb/predector \\
      -profile docker \\
      --proteome proteins.fasta \\
      --phibase phibase.fas
    ```

    ## Mandatory parameters

      --proteome <path or glob>
          Path to the fasta formatted protein sequences.
          Multiple files can be specified using globbing patterns in quotes.

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
      --phibase <path>
          Path to the PHI-base fasta dataset.
          default: download from '${params.private_phibase_url}'

      --pfam_hmm <path>
          Path to already downloaded gzipped pfam HMM database
          default: download from '${params.private_pfam_hmm_url}'

      --pfam_dat <path>
          Path to already downloaded gzipped pfam DAT database
          default: download from '${params.private_pfam_dat_url}'

      --dbcan <path>
          Path to already downloaded dbCAN HMM database
          default: download from '${params.private_dbcan_url}'

      --effectordb <path>
          Path to already downloaded gzipped effectordb HMM database.
          default: download from '${params.private_effectordb_url}'

      --precomputed_ldjson <path>
          Path to an ldjson formatted file from previous Predector runs.
          These records will be skipped when re-running the pipeline
          where the sequence is identical and the versions of software
          and databases (where applicable) are the same.
          default: don't use any precomputed results.

      --precomputed <path>
          Path to an SQlite formatted database of precomputed results.
          Currently this is mostly a placeholder for future versions of the pipeline.
          The `--precomputed_ldjson` option is more convenient for now.
          default: don't use any precomputed results.

      --secreted_weight <float>
          The weight to give a protein if it is predicted to be secreted.
          default: ${params.secreted_weight}

      --sigpep_good_weight <float>
          The weight to give a protein if it is predicted to have a signal
          peptide by one of the more reliable methods (SignalP4 or 5, or DeepSig).
          default: ${params.sigpep_good_weight}

      --sigpep_ok_weight <float>
          The weight to give a protein if it is predicted to have a signal
          peptide by one of the reasonably reliable methods (SignalP3 or Phobius).
          default: ${params.sigpep_ok_weight}

      --single_transmembrane_weight <float>
          The weight to give a protein if it is predicted to have a single
          transmembrane domain. Use negative numbers to penalise.
          default: ${params.single_transmembrane_weight}

      --multiple_transmembrane_weight <float>
          The weight to give a protein if it is predicted to have multiple
          transmembrane domains. Use negative numbers to penalise.
          default: ${params.multiple_transmembrane_weight}

      --deeploc_extracellular_weight <float>
          The weight to give a protein if it is predicted to be
          extracellular by deeploc.
          default: ${params.deeploc_extracellular_weight}

      --deeploc_intracellular_weight <float>
          The score to give a protein if it is predicted to be
          intracellular by deeploc. Use negative numbers to penalise.
          default: ${params.deeploc_intracellular_weight}

      --deeploc_membrane_weight <float>
          The score to give a protein if it is predicted to be
          membrane associated by deeploc. Use negative numbers to penalise.
          default: ${params.deeploc_membrane_weight}

      --targetp_secreted_weight <float>
          The weight to give a protein if it is predicted to be
          secreted by targetp.
          default: ${params.targetp_secreted_weight}

      --targetp_mitochondrial_weight <float>
          The weight to give a protein if it is predicted to be
          mitochondrial by targetp. Use negative numbers to penalise.
          default: ${params.targetp_mitochondrial_weight}

      --effectorp1_weight <float>
          The weight to give a protein if it is predicted to be
          an effector by effectorp1.
          default: ${params.effectorp1_weight}

      --effectorp2_weight <float>
          The weight to give a protein if it is predicted to be
          an effector by effectorp2.
          default: ${params.effectorp2_weight}

      --effectorp3_apoplastic_weight <float>
          The weight given to a protein if it has an apoplastic prediction
          from effectorp3.
          default: ${params.effectorp3_apoplastic_weight}

      --effectorp3_cytoplastmic_weight <float>
          The weight given to a protein if it has a cytoplasmic prediction
          from effectorp3.
          default: ${params.effectorp3_cytoplasmic_weight}

      --effectorp3_noneffector_weight <float>
          The weight given to a protein if it has a non-effector prediction
          from effectorp3.
          default: ${params.effectorp3_noneffector_weight}

      --deepredeff_fungi_weight <float>
          The weight given to a protein if it has an effector prediction
          given by the deepredeff fungal model.
          default: ${params.deepredeff_fungi_weight}

      --deepredeff_oomycete_weight <float>
          The weight given to a protein if it has an effector prediction
          given by the deepredeff oomycete model.
          default: ${params.deepredeff_oomycete_weight}

      --effector_homology_weight <float>
          The weight to give a protein if it is similar to a known
          effector or effector domain.
          default: ${params.effector_homology_weight}

      --virulence_homology_weight <float>
          The weight to give a protein if it is similar to a known
          protein that may be involved in virulence.
          default: ${params.virulence_homology_weight}

      --lethal_homology_weight <float>
          The weight to give a protein if it is similar to a known
          protein in phibase which caused a lethal phenotype.
          default: ${params.lethal_homology_weight}

      --tmhmm_first60_threshold <float [0, 60]>
          The minimum number of expected AAs to be TM associated in the first
          60 residues for a single TM domain match to be caused by a signal
          peptide. Only applied if there is a signal peptide detected.
          default: ${params.tmhmm_first60_threshold}


    ## Output

      - `downloads` Contains the downloaded databases.

      - `deduplicated/`
        Contains the deduplicated sequences that we run through the pipeline.
        - `deduplicated/chunk*.fasta`
          The deduplicated fasta chunks with simplified names.
        - `deduplicated/combined.tsv`
          A file mapping the simplified names to the input filenames and
          original sequence ids.

      - `{input}/` Contains the results for each input proteome.
        If you use the `--nostrip` option, the folder name will be the same
        as the input filename, otherwise it will have the first extension
        removed.
        - `{input}/{input}-ranked.tsv`
          The final ranked output summary table.
        - `{input}/{input}.gff3`
          A GFF3 version of the results of analyses with location coordinates.
        - `{input}/{input}.ldjson`
          The raw results for each protein as a newline delimited JSON file.
        - `{input}/{input}-{analysis}.tsv`
          Tabular versions of the individual analysis results.


    Detailed documentation can be found at <https://github.com/ccdmb/predector>

    """.stripIndent()
    log.info ""
}

def licenseMessage() {
    log.info"""
    ## License

    Predector is released under the Apache 2.0 license.
    See the full license at <https://github.com/ccdmb/predector/blob/master/LICENSE>.

    If this license is somehow restrictive for you, please let us know.
    We really just want to make sure it's free for people to use.
    """.stripIndent()
    log.info ""
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
    log.info ""
}


// Until we get some clarity on what will replace the publish
// workflow section, this is the workaround.
// I don't love it.
process publish_it {

    label "cpu_low"
    label "memory_low"
    label "time_short"
    label "posix"

    tag "${name}"

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

    dups = check_duplicates(params.nostrip, proteome_ch)

    if ( params.pfam_hmm ) {
        pfam_hmm_val = get_file(params.pfam_hmm)
    } else {
        pfam_hmm_val = download_pfam_hmm("Pfam-A.hmm.gz", params.private_pfam_hmm_url)
    }

    if ( params.pfam_dat ) {
        pfam_dat_val = get_file(params.pfam_dat)
    } else {
        pfam_dat_val = download_pfam_dat("Pfam-A.hmm.dat.gz", params.private_pfam_dat_url)
    }

    if ( params.pfam_dat || params.pfam_hmm ) {
        pfam_version = false
    } else {
        pfam_version = params.private_pfam_version
    }

    if ( params.dbcan ) {
        dbcan_val = get_file(params.dbcan)
        dbcan_version = false
    } else {
        dbcan_val = download_dbcan("dbCAN.txt", params.private_dbcan_url)
        dbcan_version = params.private_dbcan_version
    }

    if ( params.phibase ) {
        phibase_val = get_file(params.phibase)
        phibase_version = false
    } else {
        // Should this error out?
        phibase_val = download_phibase("phi-base_current.fas", params.private_phibase_url)
        phibase_version = params.private_phibase_version
    }

    if ( params.effectordb ) {
        effectordb_val = get_file(params.effectordb)
        effectordb_version = false
    } else {
        effectordb_val = download_effectordb("effectordb.hmm.gz", params.private_effectordb_url)
        effectordb_version = params.private_effectordb_version
    }

    use_precomputed = false

    if ( params.precomputed ) {
        use_precomputed = true
        precomputed_val = get_file(params.precomputed)
    } else {
        precomputed_val = file("DOESNT_EXIST_DB")
    }

    if ( params.precomputed_ldjson ) {
        use_precomputed = true
        precomputed_ldjson_val = get_file(params.precomputed_ldjson)
    } else {
        precomputed_ldjson_val = file("DOESNT_EXIST_LDJSON")
    }

    // This has a default value set, so it shouldn't be possible to not specify the parameter.
    pfam_targets_val = get_file(params.pfam_targets)
    dbcan_targets_val = get_file(params.dbcan_targets)

    if ( !["euk", "gramp", "gramn"].contains(params.domain)  ) {
        log.error "Invalid argument to `--domain`: ${params.domain}."
        log.error "Must be one of 'euk', 'gramp', 'gramn'."
        exit 1
    }

    emit:
    proteome_ch
    pfam_version
    pfam_hmm_val
    pfam_dat_val
    dbcan_version
    dbcan_val
    phibase_version
    phibase_val
    effectordb_version
    effectordb_val
    pfam_targets_val
    dbcan_targets_val
    use_precomputed
    precomputed_val
    precomputed_ldjson_val
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

    target_table_val = gen_target_table(
        versions.signalp3,
        versions.signalp4,
        versions.signalp5,
        versions.signalp6,
        versions.targetp2,
        versions.tmhmm2,
        versions.deeploc1,
        versions.phobius,
        versions.effectorp1,
        versions.effectorp2,
        versions.effectorp3,
        versions.localizer,
        versions.apoplastp,
        versions.deepsig,
        versions.emboss,
        versions.mmseqs2,
        versions.hmmer,
        versions.deepredeff1,
        versions.pfamscan,
        versions.predutils,
        input.pfam_version,
        input.dbcan_version,
        input.phibase_version,
        input.effectordb_version
    )

    tidied_phibase_val = sanitise_phibase(input.phibase_val)

    // Remove duplicates and split fasta(s) into chunks to run in parallel.
    // Maybe download precomputed results?
    (combined_proteomes_val, combined_proteomes_tsv_val) = encode_seqs(
        input.proteome_ch.collect()
    )

    // The precomputed splitting thing creates a lot more files and takes longer.
    // If not using it, we can just skip it.
    if ( params.precomputed || params.precomputed_ldjson ) {
        (precomputed_results_val, remaining_proteomes_val) = filter_precomputed(
            combined_proteomes_val,
            target_table_val,
            input.precomputed_ldjson_val,
            input.precomputed_val
        )

        split_proteomes_ch = split_fasta(
            params.chunk_size,
            remaining_proteomes_val
              .flatten()
              .map { f -> [f.baseName, f] }
        ).flatMap { a, fs -> fs instanceof List ? fs.collect { f -> [a, f]} : [[a, fs]] }

    } else {
        target_table_split_ch = target_table_val
            .splitText()
            .splitCsv(sep: '\t', header: ['analysis', 'software_version', 'database_version'])
            .map { it.analysis } 

        tmp_split_proteomes_ch = split_fasta(
                params.chunk_size,
                combined_proteomes_val
                  .map { f -> ["deduplicated", f] }
            ).map { a, fs -> fs }
            .flatten()

        split_proteomes_ch = target_table_split_ch.combine(tmp_split_proteomes_ch)
        precomputed_results_val = Channel.empty()
    }


    // Run the machine-learning/simple statistics analyses.
    signalp_v3_hmm_ch = signalp_v3_hmm(
        signalp_domain,
        versions.signalp3,
        split_proteomes_ch.filter { a, f -> a == "signalp3_hmm" }.map { a, f -> f }
    )
    signalp_v3_nn_ch = signalp_v3_nn(
        signalp_domain,
        versions.signalp3,
        split_proteomes_ch.filter { a, f -> a == "signalp3_nn" }.map { a, f -> f }
    )
    signalp_v4_ch = signalp_v4(
        signalp_domain,
        versions.signalp4,
        split_proteomes_ch.filter { a, f -> a == "signalp4" }.map { a, f -> f }
    )
    signalp_v5_ch = signalp_v5(
        signalp_domain,
        versions.signalp5,
        split_proteomes_ch.filter { a, f -> a == "signalp5" }.map { a, f -> f }
    )
    signalp_v6_ch = signalp_v6(
        signalp_domain,
        versions.signalp6,
        split_proteomes_ch.filter { a, f -> a == "signalp6" }.map { a, f -> f }
    )

    deepsig_ch = deepsig(
        params.domain,
        versions.deepsig,
        split_proteomes_ch.filter { a, f -> a == "deepsig" }.map { a, f -> f }
    )

    phobius_ch = phobius(
        versions.phobius,
        split_proteomes_ch.filter { a, f -> a == "phobius" }.map { a, f -> f }
    )

    tmhmm_ch = tmhmm(
        versions.tmhmm2,
        split_proteomes_ch.filter { a, f -> a == "tmhmm" }.map { a, f -> f }
    )

    targetp_ch = targetp(
        versions.targetp2,
        split_proteomes_ch.filter { a, f -> a == "targetp_non_plant" }.map { a, f -> f }
    )

    deeploc_ch = deeploc(
        versions.deeploc1,
        split_proteomes_ch.filter { a, f -> a == "deeploc" }.map { a, f -> f }
    )

    apoplastp_ch = apoplastp(
        versions.apoplastp,
        split_proteomes_ch.filter { a, f -> a == "apoplastp" }.map { a, f -> f }
    )

    localizer_ch = localizer(
        versions.localizer,
        split_proteomes_ch.filter { a, f -> a == "localizer" }.map { a, f -> f }
    )

    effectorp_v1_ch = effectorp_v1(
        versions.effectorp1,
        split_proteomes_ch.filter { a, f -> a == "effectorp1" }.map { a, f -> f }
    )

    effectorp_v2_ch = effectorp_v2(
        versions.effectorp2,
        split_proteomes_ch.filter { a, f -> a == "effectorp2" }.map { a, f -> f }
    )

    effectorp_v3_ch = effectorp_v3(
        versions.effectorp3,
        split_proteomes_ch.filter { a, f -> a == "effectorp3" }.map { a, f -> f }
    )

    deepredeff_fungi_v1_ch = deepredeff_fungi_v1(
        versions.deepredeff1,
        split_proteomes_ch.filter { a, f -> a == "deepredeff_fungi" }.map { a, f -> f }
    )

    deepredeff_oomycete_v1_ch = deepredeff_oomycete_v1(
        versions.deepredeff1,
        split_proteomes_ch.filter { a, f -> a == "deepredeff_oomycete" }.map { a, f -> f }
    )

    kex2_regex_ch = kex2_regex(
        "kex2_cutsite",
        versions.predutils,
        split_proteomes_ch.filter { a, f -> a == "kex2_cutsite" }.map { a, f -> f }
    )

    rxlrlike_regex_ch = rxlrlike_regex(
        "rxlr_like_motif",
        versions.predutils,
        split_proteomes_ch.filter { a, f -> a == "rxlr_like_motif" }.map { a, f -> f }
    )

    pepstats_ch = pepstats(
        versions.emboss,
        split_proteomes_ch.filter { a, f -> a == "pepstats" }.map { a, f -> f }
    )

    // Run the domain and database searches
    pressed_pfam_hmmer_val = press_pfam_hmmer(
        input.pfam_version,
        input.pfam_hmm_val,
        input.pfam_dat_val
    )

    pfamscan_ch = pfamscan(
        versions.pfamscan + "-" + versions.hmmer,
        pressed_pfam_hmmer_val,
        split_proteomes_ch.filter { a, f -> a == "pfamscan" }.map { a, f -> f }
    )

    pressed_dbcan_hmmer_val = press_dbcan_hmmer(
        "dbcan",
        input.dbcan_version,
        input.dbcan_val
    )

    dbcan_hmmer_ch = hmmscan_dbcan(
        versions.hmmer,
        pressed_dbcan_hmmer_val,
        split_proteomes_ch.filter { a, f -> a == "dbcan" }.map { a, f -> f }
    )

    pressed_effectordb_hmmer_val = press_effectordb_hmmer(
        "effectordb",
        input.effectordb_version,
        input.effectordb_val
    )
    effectordb_hmmer_ch = hmmscan_effectordb(
        versions.hmmer,
        pressed_effectordb_hmmer_val,
        split_proteomes_ch.filter { a, f -> a == "effectordb" }.map { a, f -> f }
    )

    proteome_mmseqs_index_ch = mmseqs_index_proteomes(
        split_proteomes_ch.filter { a, f -> a == "phibase" }
    )

    phibase_mmseqs_index_val = mmseqs_index_phibase(
        tidied_phibase_val
        .map { f -> ["phibase", f] }
    ).combine(input.phibase_version)
     .map { d, f, v -> [d, v, f] }

    phibase_mmseqs_matches_ch = mmseqs_search_phibase(
        versions.mmseqs2,
        phibase_mmseqs_index_val,
        proteome_mmseqs_index_ch
          .filter { a, f -> a == "phibase" }
          .map { a, f -> f }
    )

    // At this point, all of the analyses have their own ldjson files.
    // Here we just merge that all into one big file.
    (combined_ldjson_ch, decoded_ch) = decode_seqs(
        !params.nostrip,
        combined_proteomes_tsv_val,
        precomputed_results_val
        .mix(
            signalp_v3_hmm_ch,
            signalp_v3_nn_ch,
            signalp_v4_ch,
            signalp_v5_ch,
            signalp_v6_ch,
            deepsig_ch,
            phobius_ch,
            tmhmm_ch,
            targetp_ch,
            deeploc_ch,
            apoplastp_ch,
            localizer_ch,
            effectorp_v1_ch,
            effectorp_v2_ch,
            effectorp_v3_ch,
            deepredeff_fungi_v1_ch,
            deepredeff_oomycete_v1_ch,
            kex2_regex_ch,
            rxlrlike_regex_ch,
            pepstats_ch,
            pfamscan_ch,
            dbcan_hmmer_ch,
            phibase_mmseqs_matches_ch,
            effectordb_hmmer_ch
        )
        .collect()
    )

    // Get the original protein names and input filename back
    decoded_with_names_ch = decoded_ch.flatten().map { f -> [f.baseName, f] }

    // Get the summarised results
    gff_ch = gff_results(decoded_with_names_ch)
    tabular_ch = tabular_results(decoded_with_names_ch)

    ranked_ch = rank_results(
        params.secreted_weight,
        params.sigpep_good_weight,
        params.sigpep_ok_weight,
        params.single_transmembrane_weight,
        params.multiple_transmembrane_weight,
        params.deeploc_extracellular_weight,
        params.deeploc_intracellular_weight,
        params.deeploc_membrane_weight,
        params.targetp_mitochondrial_weight,
        params.effectorp1_weight,
        params.effectorp2_weight,
        params.effectorp3_apoplastic_weight,
        params.effectorp3_cytoplastmic_weight,
        params.effectorp3_noneffector_weight,
        params.deepredeff_fungi_weight,
        params.deepredeff_oomycete_weight,
        params.effector_homology_weight,
        params.virulence_homology_weight,
        params.lethal_homology_weight,
        params.tmhmm_first60_threshold,
        input.dbcan_targets_val,
        input.pfam_targets_val,
        decoded_with_names_ch
    )

    signalp_v3_hmm_ch
    .mix(
        signalp_v3_nn_ch,
        signalp_v4_ch,
        signalp_v5_ch,
        signalp_v6_ch,
        deepsig_ch,
        phobius_ch,
        tmhmm_ch,
        targetp_ch,
        deeploc_ch,
        apoplastp_ch,
        localizer_ch,
        effectorp_v1_ch,
        effectorp_v2_ch,
        effectorp_v3_ch,
        deepredeff_fungi_v1_ch,
        deepredeff_oomycete_v1_ch,
        kex2_regex_ch,
        rxlrlike_regex_ch,
        pepstats_ch,
        pfamscan_ch,
        dbcan_hmmer_ch,
        phibase_mmseqs_matches_ch,
        effectordb_hmmer_ch
    )
    .collectFile(
        name: "new_results.ldjson",
        storeDir: "${params.outdir}/deduplicated",
        newLine: true,
        sort: true,
        keepHeader: false
    )
        

    // Publish the results to an output folder.
    // This is a temporary workaround for the publish workflow section being depreciated.
    // Make sure you flatten channels if necessary, one file per publish call.
    input.pfam_hmm_val.map { ["downloads/${it.name}", it]}
        .mix(
            input.pfam_dat_val.map { ["downloads/${it.name}", it] },
            input.dbcan_val.map { ["downloads/${it.name}", it] },
            input.phibase_val.map { ["downloads/${it.name}", it] },
            input.effectordb_val.map { ["downloads/${it.name}", it] },
            target_table_val.map { ["analysis_software_versions.tsv", it] },
            combined_proteomes_val.map { ["deduplicated/${it.name}", it] },
            combined_proteomes_tsv_val.map { ["deduplicated/${it.name}", it] },
            combined_ldjson_ch.map { ["deduplicated/${it.name}", it] },
            decoded_with_names_ch.map { n, f -> ["${n}/${n}.ldjson", f] },
            gff_ch.map { n, f -> ["${n}/${f.name}", f] },
            ranked_ch.map { n, f -> ["${n}/${f.name}", f] },
            tabular_ch.flatMap { n, fs -> fs.collect { f -> ["${n}/${f.name}", f] } }
        ) \
    | publish_it
}
