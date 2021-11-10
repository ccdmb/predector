process download {

    label 'download'
    label 'cpu_low'
    label 'memory_low'
    label 'time_long'

    input:
    val outfile
    val url

    output:
    path "${outfile}"

    script:
    """
    wget -O "${outfile}" "${url}"
    """
}


// Here we remove duplicate sequences and split them into chunks for
// parallel processing.
// Eventually, we should also take precomputed results and filter them
// out here.
// Note that we split this here because the nextflow split fasta thing
// seems to not work well with checkpointing.
process encode_seqs {

    label 'predectorutils'
    label 'cpu_low'
    label 'memory_medium'
    label 'time_medium'

    input:
    val chunk_size
    path "in/*"


    output:
    path "combined/*"
    path "combined.tsv"

    script:
    """
    predutils encode \
      --prefix "P" \
      --length 8 \
      combined.fasta \
      combined.tsv \
      in/*

    predutils split_fasta \
      --size "${chunk_size}" \
      --template "combined/chunk{index:0>4}.fasta" \
      combined.fasta
    """
}


process decode_seqs {

    label 'predectorutils'
    label 'cpu_low'
    label 'memory_medium'
    label 'time_medium'

    input:
    val stripext
    path "combined.tsv"
    path "results/*.ldjson"

    output:
    path "decoded/*.ldjson"

    script:
    if (stripext) {
        templ = "decoded/{filename_noext}.ldjson"
    } else {
        templ = "decoded/{filename}.ldjson"
    }

    """
    cat results/* \
    | predutils decode \
      --template '${templ}' \
      combined.tsv \
      -
    """
}


process sanitise_phibase {

    label 'posix'
    label 'cpu_low'
    label 'memory_low'
    label 'time_low'

    input:
    path "phibase.fasta"

    output:
    path "tidied_phibase.fasta"

    script:
    """
    LANG=C sed 's/[^[:print:]]//g' < phibase.fasta > tidied_phibase.fasta
    """
}

process gff_results {

    label 'predectorutils'
    label 'cpu_low'
    label 'memory_medium'
    label 'time_medium'

    tag "${name}"

    input:
    tuple val(name), path("results.ldjson")

    output:
    tuple val(name), path("${name}.gff3")

    script:
    """
    predutils gff \
      --outfile "${name}.gff3" \
      results.ldjson
    """
}


process tabular_results {

    label 'predectorutils'
    label 'cpu_low'
    label 'memory_medium'
    label 'time_medium'

    tag "${name}"

    input:
    tuple val(name), path("results.ldjson")

    output:
    tuple val(name), path("${name}-*.tsv")

    script:
    """
    predutils tables \
      --template "${name}-{analysis}.tsv" \
      results.ldjson
    """
}


process rank_results {

    label 'predectorutils'
    label 'cpu_low'
    label 'memory_medium'
    label 'time_medium'

    tag "${name}"

    input:
    val secreted_weight
    val sigpep_good_weight
    val sigpep_ok_weight
    val single_transmembrane_weight
    val multiple_transmembrane_weight
    val deeploc_extracellular_weight
    val deeploc_intracellular_weight
    val deeploc_membrane_weight
    val targetp_mitochondrial_weight
    val effectorp1_weight
    val effectorp2_weight
    val effector_homology_weight
    val virulence_homology_weight
    val lethal_homology_weight
    val tmhmm_first60_threshold
    path "dbcan.txt"
    path "pfam.txt"
    tuple val(name), path("results.ldjson")

    output:
    tuple val(name), path("${name}-ranked.tsv")

    script:
    """
    predutils rank \
      --dbcan dbcan.txt \
      --pfam pfam.txt \
      --outfile "${name}-ranked.tsv" \
      --secreted-weight "${secreted_weight}" \
      --sigpep-good-weight "${sigpep_good_weight}" \
      --sigpep-ok-weight "${sigpep_ok_weight}" \
      --single-transmembrane-weight "${single_transmembrane_weight}" \
      --multiple-transmembrane-weight "${multiple_transmembrane_weight}" \
      --deeploc-extracellular-weight "${deeploc_extracellular_weight}" \
      --deeploc-intracellular-weight "${deeploc_intracellular_weight}" \
      --deeploc-membrane-weight "${deeploc_membrane_weight}" \
      --targetp-mitochondrial-weight "${targetp_mitochondrial_weight}" \
      --effectorp1-weight "${effectorp1_weight}" \
      --effectorp2-weight "${effectorp2_weight}" \
      --effector-homology-weight "${effector_homology_weight}" \
      --virulence-homology-weight "${virulence_homology_weight}" \
      --lethal-homology-weight "${lethal_homology_weight}" \
      --tmhmm-first-60-threshold "${tmhmm_first60_threshold}" \
      results.ldjson
    """
}



/*
 * Identify signal peptides using SignalP v3 hmm
 */
process signalp_v3_hmm {

    label 'signalp3'
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_medium'

    input:
    val domain
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    # This has a tendency to fail randomly, we just have 1 per chunk
    # so that we don't lose everything

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N 1 \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        'signalp3 -type "${domain}" -method "hmm" -short "{}"' \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        signalp3_hmm out.txt in.fasta
    """
}


/*
 * Identify signal peptides using SignalP v3 nn
 */
process signalp_v3_nn {

    label 'signalp3'
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_medium'

    input:
    val domain
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    # This has a tendency to fail randomly, we just have 1 per chunk
    # so that we don't lose everything

    # Signalp3 nn fails if a sequence is longer than 6000 AAs.
    fasta_to_tsv.sh in.fasta \
    | awk -F'\t' '{ s=substr(\$2, 1, 6000); print \$1"\t"s }' \
    | tsv_to_fasta.sh \
    > trunc.fasta

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N 1 \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        'signalp3 -type "${domain}" -method nn -short "{}"' \
    < trunc.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        signalp3_nn \
        out.txt in.fasta
    """
}


/*
 * Identify signal peptides using SignalP v4
 */
process signalp_v4 {

    label 'signalp4'
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_medium'

    input:
    val domain
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        'signalp4 -t "${domain}" -f short "{}"' \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        signalp4 out.txt in.fasta
    """
}


/*
 * Identify signal peptides using SignalP v5
 */
process signalp_v5 {

    label 'signalp5'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val domain
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
      set -e

      # Signalp5 just uses all available cores afaik.
      # Although it seems to use omp, i don't seem to be able to force it
      # to use a specific number of cores.

      export OMP_NUM_THREADS="${task.cpus}"
      TMPDIR="tmpdir\$\$"
      mkdir \${TMPDIR}

      OUT="tmp\$\$"
      signalp5 \
        -org "${domain}" \
        -format short \
        -tmp "\${TMPDIR}" \
        -fasta "\${1}" \
        -prefix "\${OUT}" \
        1>&2

      cat "\${OUT}_summary.signalp5"
      rm -rf "\${OUT}"* "\${TMPDIR}"
    }

    export -f run

    parallel \
      --halt now,fail=1 \
      --joblog log.txt \
      -j 1 \
      -N "1000" \
      --line-buffer  \
      --recstart '>' \
      --cat \
      run \
      < in.fasta \
    | cat > signalp5.txt

    predutils r2js \
      --pipeline-version "${workflow.manifest.version}" \
      --software-version "${software_version}" \
      signalp5 signalp5.txt in.fasta \
    > "out.ldjson"

    rm -f signalp5.txt
    rm -rf -- tmpdir
    """
}


/*
 * Identify signal peptides using SignalP v6
 */
process signalp_v6 {

    label 'signalp6'
    label 'cpu_high'
    label 'memory_high'
    label 'time_long'

    input:
    val domain
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    export OMP_NUM_THREADS="${task.cpus}"

    run () {
        set -e
        TMPDIR="tmpdir\$\$"
        mkdir "\${TMPDIR}"

        signalp6 \
          --fastafile "\${1}" \
          --output_dir "\${TMPDIR}" \
          --format txt \
          --organism eukarya \
          --mode fast \
          1>&2

        cat "\${TMPDIR}"/prediction_results.txt
        rm -rf -- "\${TMPDIR}"
    }

    export -f run

    parallel \
      --halt now,fail=1 \
      --joblog log.txt \
      -j 1 \
      -N 1000 \
      --line-buffer \
      --recstart '>' \
      --cat \
      run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
      --pipeline-version "${workflow.manifest.version}" \
      --software-version "${software_version}" \
      signalp6 "out.txt" in.fasta \
    > "out.ldjson"
    """
}


/*
 * Identify signal peptides using DeepSig
 */
process deepsig {

    label "deepsig"
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_medium'

    input:
    val domain
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    run () {
        set -e
        OUT="tmp\$\$"
        deepsig.py -f \$1 -k euk -o "\${OUT}" 1>&2
        cat "\${OUT}"
        rm -f "\${OUT}"
    }

    export -f run


    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        deepsig out.txt in.fasta
    """
}


/*
 * Phobius for signal peptide and tm domain prediction.
 */
process phobius {

    label 'phobius'
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    # tail -n+2 is to remove header
    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        'phobius.pl -short "{}" | tail -n+2' \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        phobius out.txt in.fasta
    """
}


/*
 * TMHMM
 */
process tmhmm {

    label 'tmhmm'
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    # tail -n+2 is to remove header
    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --pipe \
        'tmhmm -short -d' \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        tmhmm out.txt in.fasta

    rm -rf -- TMHMM_*
    """
}


/*
 * Subcellular location using TargetP
 */
process targetp {

    label 'targetp'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    mkdir -p tmpdir

    # targetp2 just uses all available cores afaik.
    # Although it seems to use omp, i don't seem to be able to force it
    # to use a specific number of cores.
    export OMP_NUM_THREADS="${task.cpus}"

    targetp -fasta in.fasta -org non-pl -format short -prefix "out"

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
      targetp_non_plant "out_summary.targetp2" in.fasta \
    > "out.ldjson"

    rm -f "out_summary.targetp2"
    rm -rf -- tmpdir
    """
}



/*
 * Subcellular location using DeepLoc
 */
process deeploc {

    label 'deeploc'
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
        set -e
        TMPDIR="\${PWD}/tmp\$\$"
        mkdir -p "\${TMPDIR}"
        TMPFILE="tmp\$\$.out"

        # The base_compiledir is the important bit here.
        # This is where cache-ing happens. But it also creates a lock
        # for parallel operations.
        export THEANO_FLAGS="device=cpu,floatX=float32,optimizer=fast_compile,cxx=\${CXX},base_compiledir=\${TMPDIR}"

        deeploc -f "\$1" -o "\${TMPFILE}" 1>&2
        cat "\${TMPFILE}.txt"

        rm -rf -- "\${TMPFILE}.txt" "\${TMPDIR}"
    }
    export -f run

    # This just always divides it up into even chunks for each cpu.
    # Since deeploc caches compilation, it's more efficient to run big chunks
    # and waste a bit of cpu time at the end if one finishes early.
    NSEQS="\$(grep -c '^>' in.fasta || echo 0)"
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" "\${NSEQS}")"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        deeploc out.txt in.fasta
    """
}


/*
 * ApoplastP
 */
process apoplastp {

    label 'apoplastp'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
        set -e
        TMPFILE="tmp\$\$"
        ApoplastP.py -s -i "\$1" -o "\${TMPFILE}" 1>&2
        cat "\${TMPFILE}"

        rm -f "\${TMPFILE}"
    }
    export -f run

    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        apoplastp out.txt in.fasta
    """
}


/*
 * Localizer
 */
process localizer {

    label 'localizer'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
        set -e
        TMP="tmp\$\$"
        LOCALIZER.py -e -i "\$1" -o "\${TMP}" 1>&2
        cat "\${TMP}/Results.txt"

        rm -rf -- "\${TMP}"
    }
    export -f run

    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        localizer out.txt in.fasta
    """
}


/*
 * Effector ML using EffectorP v1
 */
process effectorp_v1 {

    label 'effectorp1'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
        set -e
        TMPFILE="tmp\$\$"
        EffectorP1.py -s -i "\$1" -o "\${TMPFILE}" 1>&2
        cat "\${TMPFILE}"

        rm -f "\${TMPFILE}"
    }
    export -f run

    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        effectorp1 out.txt in.fasta
    """
}


/*
 * Effector ML using EffectorP v2
 */
process effectorp_v2 {

    label 'effectorp2'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
        set -e
        TMPFILE="tmp\$\$"
        EffectorP2.py -s -i "\$1" -o "\${TMPFILE}" 1>&2
        cat "\${TMPFILE}"

        rm -f "\${TMPFILE}"
    }
    export -f run

    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        effectorp2 out.txt in.fasta
    """
}


/*
 * Effector ML using EffectorP v3
 */
process effectorp_v3 {

    label 'effectorp3'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
        set -e
        TMPFILE="tmp\$\$"
        EffectorP3.py -i "\$1" -o "\${TMPFILE}" 1>&2
        cat "\${TMPFILE}"

        rm -f "\${TMPFILE}"
    }
    export -f run

    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        effectorp3 out.txt in.fasta
    """
}


/*
 * Effector ML using Deepredeff v0.1.1
 */
process deepredeff_v1 {

    label 'deepredeff'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    export OMP_NUM_THREADS="${task.cpus}"
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 1000)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        'deepredeff.R -i "{}" --taxon fungi | tail -n+2' \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        deepredeff_fungi out.txt in.fasta
    """
}


/*
 * Emboss
 */
process pepstats {

    label 'emboss'
    label 'cpu_low'
    label 'memory_low'
    label 'time_short'

    input:
    val software_version
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    pepstats -sequence in.fasta -outfile out.txt
    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        -o out.ldjson \
        pepstats out.txt in.fasta
    """
}


process press_pfam_hmmer {

    label 'hmmer3'
    label 'cpu_low'
    label 'memory_low'
    label 'time_medium'

    input:
    val version
    path "Pfam-A.hmm.gz"
    path "Pfam-A.hmm.dat.gz"

    output:
    tuple val(version), path("pfam_db")

    script:
    """
    mkdir -p pfam_db
    gunzip --force --stdout Pfam-A.hmm.gz > pfam_db/Pfam-A.hmm
    gunzip --force --stdout Pfam-A.hmm.dat.gz > pfam_db/Pfam-A.hmm.dat

    hmmpress pfam_db/Pfam-A.hmm
    """
}


process pfamscan {

    label 'pfamscan'
    label 'cpu_medium'
    label 'memory_medium'
    label 'time_long'

    input:
    val software_version
    tuple val(database_version), path('pfam_db')
    path 'in.fasta'

    output:
    path "out.ldjson"

    script:
    if (database_version) {
        db_version_str = "--database-version '${database_version}' "
    } else {
        db_version_str = ""
    }

    """
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --recstart '>' \
        --line-buffer  \
        --cat  \
        'pfam_scan.pl -fasta "{}" -dir pfam_db -cpu 1' \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        ${db_version_str} \
        -o out.ldjson \
        pfamscan out.txt in.fasta
    """
}


process press_hmmer {

    label 'hmmer3'
    label 'cpu_low'
    label 'memory_low'
    label 'time_short'

    input:
    val database
    val version
    path db

    output:
    tuple val(database), val(version), path("db")

    script:
    gzipped = db.getExtension() == "gz" ? "true" : "false"

    """
    mkdir -p db
    if [ "${gzipped}" = "true" ]
    then
      cp -L "${db}" db/db.hmm.gz
      gunzip db/db.hmm.gz
    else
      cp -L "${db}" db/db.hmm
    fi

    hmmpress db/db.hmm
    """
}


// DBCAN Optimized parameters for fungi E-value < 10−17; coverage > 0.45

process hmmscan {

    label 'hmmer3'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    tuple val(database), val(database_version), path("db")
    path 'in.fasta'

    output:
    path "out.ldjson"

    script:
    if (database_version) {
        db_version_str = "--database-version '${database_version}' "
    } else {
        db_version_str = ""
    }


    """
    run () {
        set -e
        TMPFILE="tmp\$\$"
        hmmscan \
          --domtblout "\${TMPFILE}" \
          db/db.hmm \
          "\$1" \
        > /dev/null

        cat "\${TMPFILE}"
        rm -f "\${TMPFILE}"
    }

    export -f run

    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --recstart '>' \
        --line-buffer  \
        --cat \
        run \
    < in.fasta \
    | cat > out.txt

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        --software-version "${software_version}" \
        ${db_version_str} \
        -o out.ldjson \
        "${database}" out.txt in.fasta
    """
}


process mmseqs_index {

    label "mmseqs"
    label 'cpu_low'
    label 'memory_low'
    label 'time_short'

    input:
    tuple val(name), path("db.fasta")

    output:
    tuple val(name), path("db")

    script:
    """
    mkdir -p db
    mmseqs createdb db.fasta db/db
    cp -L db.fasta db/db.fasta
    """
}


process mmseqs_search {

    label 'mmseqs'
    label 'process_high'
    label 'cpu_high'
    label 'memory_high'
    label 'time_medium'

    input:
    val software_version
    tuple val(database), val(database_version), path("target")
    path "query"

    output:
    path "out.ldjson"

    script:
    if (database_version) {
        db_version_str = "--database-version '${database_version}' "
    } else {
        db_version_str = ""
    }

    """
    mkdir -p tmp matches

    mmseqs search \
      "query/db" \
      "target/db" \
      "matches/db" \
      "tmp" \
      --threads "${task.cpus}" \
      --max-seqs 300 \
      -e 0.01 \
      -s 7 \
      --num-iterations 3 \
      --realign \
      -a

    mmseqs convertalis \
      query/db \
      target/db \
      matches/db \
      search.tsv \
      --threads "${task.cpus}" \
      --format-mode 0 \
      --format-output 'query,target,qstart,qend,qlen,tstart,tend,tlen,evalue,gapopen,pident,alnlen,raw,bits,cigar,mismatch,qcov,tcov'

    predutils r2js \
      --pipeline-version "${workflow.manifest.version}" \
      --software-version "${software_version}" \
      ${db_version_str} \
      "${database}" search.tsv query/db.fasta \
    > out.ldjson

    rm -rf -- tmp matches search.tsv
    """
}
