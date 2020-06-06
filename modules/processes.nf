process download {

    label 'download'
    label 'process_low'

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


process extract_effector_seqs {

    label 'posix'
    label 'process_low'

    input:
    path "effectors.tsv"

    output:
    path "effectors.fasta"

    script:
    """
    tail -n+2 effectors.tsv \
    | awk -F'\t' '{printf(">%s\\n%s\\n", \$4, \$12)}' \
    > effectors.fasta
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
    label 'process_low'

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


/*
 * Identify signal peptides using SignalP v3 hmm
 */
process signalp_v3_hmm {

    label 'signalp3'
    label 'process_high'

    input:
    val domain
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        signalp3_hmm -
    """
}


/*
 * Identify signal peptides using SignalP v3 nn
 */
process signalp_v3_nn {

    label 'signalp3'
    label 'process_high'

    input:
    val domain
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
        -o out.ldjson \
        signalp3_nn \
        out.txt
    """
}


/*
 * Identify signal peptides using SignalP v4
 */
process signalp_v4 {

    label 'signalp4'
    label 'process_high'

    input:
    val domain
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        signalp4 -
    """
}


/*
 * Identify signal peptides using SignalP v5
 */
process signalp_v5 {

    label 'signalp5'
    label 'process_high'

    input:
    val domain
    path "in.fasta"

    output:
    path "out.ldjson"
    path "out.fasta"

    script:
    """
    mkdir -p tmpdir
    # This just uses all available cores by default.
    signalp5 \
      -org "${domain}" \
      -format short \
      -tmp tmpdir \
      -mature \
      -fasta in.fasta \
      -prefix "out"

    predutils r2js \
      --pipeline-version "${workflow.manifest.version}" \
      signalp5 "out_summary.signalp5" \
    > "out.ldjson"

    mv "out_mature.fasta" "out.fasta"
    rm -f out_summary.signalp5
    rm -rf -- tmpdir
    """
}


/*
 * Identify signal peptides using DeepSig
 */
process deepsig {

    label "deepsig"
    label "process_high"

    input:
    val domain
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    run () {
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        deepsig -
    """
}


/*
 * Phobius for signal peptide and tm domain prediction.
 */
process phobius {

    label 'phobius'
    label 'process_high'

    input:
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        phobius -
    """
}


/*
 * TMHMM
 */
process tmhmm {

    label 'tmhmm'
    label 'process_high'

    input:
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        tmhmm -

    rm -rf -- TMHMM_*
    """
}


/*
 * Subcellular location using TargetP
 */
process targetp {

    label 'targetp'
    label 'process_high'

    input:
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    mkdir -p tmpdir
    targetp -fasta in.fasta -org non-pl -format short -prefix "out"

    predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
      targetp_non_plant "out_summary.targetp2" \
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
    label 'process_high'

    input:
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
        -o out.ldjson \
        deeploc out.txt
    """
}


/*
 * ApoplastP
 */
process apoplastp {

    label 'apoplastp'
    label 'process_high'

    input:
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        apoplastp -
    """
}


/*
 * Localizer
 */
process localizer {

    label 'localizer'
    label 'process_high'

    input:
    path "mature.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
        TMP="tmp\$\$"
        LOCALIZER.py -e -M -i "\$1" -o "\${TMP}" 1>&2
        cat "\${TMP}/Results.txt"

        rm -rf -- "\${TMP}"
    }
    export -f run

    CHUNKSIZE="\$(decide_task_chunksize.sh mature.fasta "${task.cpus}" 100)"

    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --line-buffer  \
        --recstart '>' \
        --cat  \
        run \
    < mature.fasta \
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        localizer -
    """
}


/*
 * Effector ML using EffectorP v1
 */
process effectorp_v1 {

    label 'effectorp1'
    label 'process_high'

    input:
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        effectorp1 -
    """
}


/*
 * Effector ML using EffectorP v2
 */
process effectorp_v2 {

    label 'effectorp2'
    label 'process_high'

    input:
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    run () {
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        effectorp2 -
    """
}


/*
 * Emboss
 */
process pepstats {

    label 'emboss'
    label 'process_high'

    input:
    path "in.fasta"

    output:
    path "out.ldjson"

    script:
    """
    CHUNKSIZE="\$(decide_task_chunksize.sh in.fasta "${task.cpus}" 100)"

    # NB linebuffer isn't safe here because pepstats is multiline.
    parallel \
        --halt now,fail=1 \
        --joblog log.txt \
        -j "${task.cpus}" \
        -N "\${CHUNKSIZE}" \
        --recstart '>' \
        --pipe  \
        'pepstats -sequence stdin -outfile stdout' \
    < in.fasta \
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        pepstats -
    """
}


process press_pfam_hmmer {

    label 'hmmer3'
    label 'process_low'

    input:
    path "Pfam-A.hmm.gz"
    path "Pfam-A.hmm.dat.gz"
    path "active_site.dat.gz"

    output:
    path "pfam_db"

    script:
    """
    mkdir -p pfam_db
    gunzip --force --stdout Pfam-A.hmm.gz > pfam_db/Pfam-A.hmm
    gunzip --force --stdout Pfam-A.hmm.dat.gz > pfam_db/Pfam-A.hmm.dat
    gunzip --force --stdout active_site.dat.gz > pfam_db/active_site.dat

    hmmpress pfam_db/Pfam-A.hmm
    """
}


process pfamscan {

    label 'pfamscan'
    label 'process_high'

    input:
    path 'pfam_db'
    path 'in.fasta'

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
        --recstart '>' \
        --line-buffer  \
        --cat  \
        'pfam_scan.pl -fasta "{}" -dir pfam_db -as' \
    < in.fasta \
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        pfamscan -
    """
}


process press_hmmer {

    label 'hmmer3'
    label 'process_low'

    input:
    path "db.txt"

    output:
    path "db"

    script:
    """
    mkdir -p db
    cp -L db.txt db/db.hmm
    hmmpress db/db.hmm
    """
}


// DBCAN Optimized parameters for fungi E-value < 10−17; coverage > 0.45

process hmmscan {

    label 'hmmer3'
    label 'process_high'

    input:
    val database
    path "db"
    path 'in.fasta'

    output:
    path "out.ldjson"

    script:
    """
    run () {
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
    | predutils r2js \
        --pipeline-version "${workflow.manifest.version}" \
        -o out.ldjson \
        "${database}" -
    """
}


process mmseqs_index {

    label "mmseqs"
    label "process_low"

    input:
    tuple val(name), path("db.fasta")

    output:
    tuple val(name), path("db")

    script:
    """
    mkdir -p db
    mmseqs createdb db.fasta db/db
    """
}


process mmseqs_search {

    label 'mmseqs'
    label 'process_high'

    input:
    tuple val(database), path("target")
    path "query"

    output:
    path "out.ldjson"

    script:
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
      "${database}" search.tsv \
    > out.ldjson

    rm -rf -- tmp matches search.tsv
    """
}
