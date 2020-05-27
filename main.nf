#!/usr/bin/env nextflow
nextflow.preview.dsl=2

include {get_file; is_null} from './modules/cli'
include check_env from './modules/versions'
include {
    download as download_pfam_hmm;
    download as download_pfam_dat;
    download as download_pfam_active_site;
    download as download_dbcan;
    encode_seqs;
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
    mmseqs_index as mmseqs_index_proteomes;
    mmseqs_index as mmseqs_index_phibase;
    mmseqs_search as mmseqs_search_phibase;
} from './modules/processes'


workflow validate_input {

    main:
    if ( params.proteome ) {
        Channel
            .fromPath(params.proteome, checkIfExists: true, type: 'file')
            .map { f -> [ f.baseName, f] }
            .set { proteome_ch }
    } else {
        log.error "Please provide some proteomes to the `--proteome` parameter."
        exit 1
    }

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
}


workflow {

    main:
    if ( params.help ) {
        log.error "Hey I'm really sorry but I haven't written the help thing yet."
        log.error "Please check out the nextflow.config file params section for current options."
        log.error "It's coming soon, i promise :)"
        exit 1
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
    (proteome_ch, pfam_hmm_val, pfam_dat_val,
     pfam_active_site_val, dbcan_val, phibase_val) = validate_input()

    // This checks that all of the software is installed and finds the version
    // info where it can.
    versions = check_env()

    // Remove duplicates and split fasta(s) into chunks to run in parallel.
    // Maybe download precomputed results?
    (combined_proteomes_ch, combined_proteomes_tsv_ch) = encode_seqs(
        params.chunk_size,
        proteome_ch.map {n, f -> f}.collect()
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
        pfam_hmm_val,
        pfam_dat_val,
        pfam_active_site_val
    )
    pfamscan_ch = pfamscan(pressed_pfam_hmmer_val, split_proteomes_ch)

    pressed_dbcan_hmmer_val = press_dbcan_hmmer(dbcan_val)
    dbcan_hmmer_ch = hmmscan_dbcan("dbcan", pressed_dbcan_hmmer_val, split_proteomes_ch)

    proteome_mmseqs_index_ch = mmseqs_index_proteomes(
        split_proteomes_ch.map { f -> ["chunk", f] }
    ).map { v, f -> f }

    phibase_mmseqs_index_val = mmseqs_index_phibase(phibase_val.map { f -> ["phibase", f] })
    phibase_mmseqs_matches_ch = mmseqs_search_phibase(
        phibase_mmseqs_index_val,
        proteome_mmseqs_index_ch
    )

    // At this point, all of the analyses have their own ldjson files.
    // Here we just merge that all into one big file.
    ldjson_ch = signalp_v3_hmm_ch
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
            phibase_mmseqs_matches_ch
        )
        .collectFile(name: "combined.ldjson", newLine: true)

    publish:
    ldjson_ch to: "${params.outdir}" // For some reason this puts it into a subfolder with a shasum.
    pfam_hmm_val to: "${params.outdir}/downloads"
    pfam_dat_val to: "${params.outdir}/downloads"
    pfam_active_site_val to: "${params.outdir}/downloads"
    dbcan_val to: "${params.outdir}/downloads"
}
