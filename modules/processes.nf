process download {

    label 'download'
    label 'process_low'

    input:
    val url
    val outfile

    output:
    path "${outfile}"

    script:
    """
    wget -O "${outfile}" "${url}"
    """
}


process add_name_to_id {

    label "posix"
    label "process_low"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("out.fasta")

    script:
    """
    sed '/^>/s/^>/>${name}|/' < in.fasta > out.fasta
    """
}


process seqrenamer_encode {

    label 'seqrenamer'
    label 'process_low'

    input:
    path "in/*"

    output:
    path "combined.fasta"
    path "combined.tsv"

    script:
    """
    sr encode \
      --format fasta \
      --column id \
      --deduplicate \
      --upper \
      --drop-desc \
      --strip "*-" \
      --map "combined.tsv" \
      --outfile "combined.fasta" \
      in/*
    """

}


/*
 * Identify signal peptides using SignalP v3 hmm
 */
process signalp_v3_hmm {

    label 'signalp3'
    label 'process_high'

    tag "${name}"

    input:
    val domain
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_signalp3_hmm.txt")

    script:
    """
    ffdb fasta -d db.ffdata -i db.ffindex --size 1 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      signalp -type "${domain}" -method "hmm" -short "/dev/stdin"

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        signalp3_hmm -

    ffdb collect ld.ff{data,index} > "${name}_signalp3_hmm.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
    """
}


/*
 * Identify signal peptides using SignalP v3 nn
 */
process signalp_v3_nn {

    label 'signalp3'
    label 'process_high'

    tag "${name}"

    input:
    val domain
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_signalp3_nn.txt")

    script:
    """
    ffdb fasta -d db.ffdata -i db.ffindex --size 1 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      signalp -type "${domain}" -method "nn" -short "/dev/stdin"

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        signalp3_nn -

    ffdb collect ld.ff{data,index} > "${name}_signalp3_nn.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
    """
}


/*
 * Identify signal peptides using SignalP v4
 */
process signalp_v4 {

    label 'signalp4'
    label 'process_high'

    tag "${name}"

    input:
    val domain
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_signalp4.txt")

    script:
    """
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      signalp -t "${domain}" -f short "/dev/stdin"

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        signalp4 -

    ffdb collect ld.ff{data,index} > "${name}_signalp4.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
    """
}


/*
 * Identify signal peptides using SignalP v5
 */
process signalp_v5 {

    label 'signalp5'
    label 'process_high'

    tag "${name}"

    input:
    val domain
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_signalp5.txt")
    tuple val(name), path("${name}_signalp5_mature.fasta")

    script:
    """
    mkdir -p tmpdir
    # This just uses all available cores by default.
    signalp \
      -org "${domain}" \
      -format short \
      -tmp tmpdir \
      -mature \
      -fasta in.fasta \
      -prefix "${name}"

    predector r2js \
      --run-name "${workflow.runName}" \
      --session-id "${workflow.sessionId}" \
      --start "${workflow.start}" \
      signalp5 "${name}_summary.signalp5" \
    > "${name}_signalp5.txt"

    mv "${name}_mature.fasta" "${name}_signalp5_mature.fasta"
    rm -rf -- tmpdir
    """
}


/*
 * Identify signal peptides using DeepSig
 */
process deepsig {

    label "deepsig"
    label "process_low"

    tag "${name}"

    input:
    val domain
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_deepsig.txt")

    script:
    """
    deepsig.py \
      -f in.fasta \
      -k "${domain}" \
      -o "${name}_deepsig.txt"
    """
}


/*
 * Phobius for signal peptide and tm domain prediction.
 */
process phobius {

    label 'phobius'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_phobius.txt")

    script:
    """
    phobius.pl -short in.fasta > "${name}_phobius.txt"
    """
}


/*
 * TMHMM
 */
process tmhmm {

    label 'tmhmm'
    label 'process_high'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_tmhmm.txt")

    script:
    """
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      tmhmm -short -d

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        tmhmm -

    ffdb collect ld.ff{data,index} > "${name}_tmhmm.ldjson"

    rm -rf -- TMHMM_*
    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
    """
}


/*
 * Subcellular location using TargetP
 */
process targetp {

    label 'targetp'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_targetp2.txt")

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
process deeploc {

    label 'deeploc'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_deeploc.txt")

    script:
    """
    deeploc -f in.fasta -o "${name}"
    mv "${name}.txt" "${name}_deeploc.txt"
    """
}


/*
 * ApoplastP
 */
process apoplastp {

    label 'apoplastp'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_apoplastp.txt")

    script:
    """
    ApoplastP.py -s -i in.fasta > "${name}_apoplastp.txt"
    """
}


/*
 * Localizer
 */
process localizer {

    label 'localizer'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("mature.fasta")

    output:
    tuple val(name), path("${name}_localizer.txt")

    script:
    """
    LOCALIZER.py -e -M -i mature.fasta -o "run"

    mv run/Results.txt "${name}_localizer.txt"
    rm -rf -- run
    """
}


/*
 * Effector ML using EffectorP v1
 */
process effectorp_v1 {

    label 'effectorp1'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_effectorp1.txt")

    script:
    """
    EffectorP.py -s -i in.fasta > "${name}_effectorp1.txt"
    """
}


/*
 * Effector ML using EffectorP v2
 */
process effectorp_v2 {

    label 'effectorp2'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_effectorp2.txt")

    script:
    """
    EffectorP.py -s -i in.fasta > "${name}_effectorp2.txt"
    """
}


/*
 * Emboss
 */
process pepstats {

    label 'emboss'
    label 'process_low'

    tag "${name}"

    input:
    tuple val(name), path("in.fasta")

    output:
    tuple val(name), path("${name}_emboss.txt")

    script:
    """
    pepstats -sequence in.fasta -outfile "${name}_emboss.txt"
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
    label 'process_low'

    tag "${name}"

    input:
    path 'pfam_db'
    tuple val(name), path('in.fasta')

    output:
    tuple val(name), path("${name}_pfamscan.tab")

    script:
    """
    pfam_scan.pl -fasta in.fasta -dir pfam_db -as > "${name}_pfamscan.tab"
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


process hmmscan {

    label 'hmmer3'
    label 'process_low'

    tag "${name}"

    input:
    val database
    path "db"
    tuple val(name), path('in.fasta')

    output:
    tuple val(name), path("${name}_${database}.domtab")

    script:
    """
    hmmscan \
      --domtblout "${name}_${database}.domtab" \
      db/db.hmm \
      in.fasta
    """
}


process mmseqs_index {

    label "mmseqs"
    label "process_medium"

    label "${name}"

    input:
    tuple val(name), path("db.fasta")

    output:
    tuple val(name), path("db")

    script:
    """
    mkdir -p db
    mmseqs createdb db.fasta db/db --max-seq-len 15000
    """
}


process mmseqs_search {

    label 'mmseqs'
    label 'process_medium'

    tag "${name}"

    input:
    tuple val(database), path("target")
    tuple val(name), path("query")

    output:
    tuple val(name), path("${name}_${database}.tsv")

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
      search_tmp.tsv \
      --threads "${task.cpus}" \
      --format-mode 0 \
      --format-output 'query,target,qstart,qend,qlen,tstart,tend,tlen,evalue,gapopen,pident,alnlen,raw,bits,cigar,mismatch,qcov,tcov'

    sort -k1,1 -k3,3n -k4,4n -k2,2 search_tmp.tsv > "${name}_${database}.tsv"
    sed -i '1i #query\target\tqstart\tqend\tqlen\tttstart\ttend\ttlen\tevalue\tgapopen\tpident\talnlen\traw\tbits\tcigar\tmismatch\tqcov\ttcov' "${name}_${database}.tsv"

    rm -rf -- tmp matches search_tmp.tsv
    """
}
