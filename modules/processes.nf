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

    input:
    val domain
    path "in.fasta"

    output:
    path "out.ldjson"

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

    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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

    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    path "${name}_signalp4.txt"

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

    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    signalp \
      -org "${domain}" \
      -format short \
      -tmp tmpdir \
      -mature \
      -fasta in.fasta \
      -prefix "out"

    predector r2js \
      --run-name "${workflow.runName}" \
      --session-id "${workflow.sessionId}" \
      --start "${workflow.start}" \
      signalp5 "out_summary.signalp5" \
    > "out.ldjson"

    mv "out_mature.fasta" "out.fasta"
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
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      deepsig.py \
        -f /dev/stdin \
        -k "${domain}" \
        -o /dev/stdout

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        deepsig -
     
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      phobius.pl -short /dev/stdin

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        phobius -
 
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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

    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- TMHMM_*
    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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

    predector r2js \
      --run-name "${workflow.runName}" \
      --session-id "${workflow.sessionId}" \
      --start "${workflow.start}" \
      targetp "out_summary.targetp2" \
    > "out.ldjson"

    mv "out_summary.targetp2"
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
    deeploc -f in.fasta -o out

    predector r2js \
      --run-name "${workflow.runName}" \
      --session-id "${workflow.sessionId}" \
      --start "${workflow.start}" \
      deeploc "out.txt" \
    > "out.ldjson"

    rm out.txt
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
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      ApoplastP.py -s -i /dev/stdin

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        apoplastp -

    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 mature.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      bin/run_localizer.sh

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        deepsig -
     
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      EffectorP.py -s -i /dev/stdin

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        effectorp1 -
     
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      EffectorP.py -s -i /dev/stdin

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        effectorp2 -
     
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      pepstats -sequence /dev/stdin -outfile /dev/stdout

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        pepstats -
     
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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

    input:
    path 'pfam_db'
    path 'in.fasta'

    output:
    path "out.ldjson"

    script:
    """
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      pfam_scan.pl -fasta /dev/stdin -dir pfam_db -as

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        pfamscan -
     
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
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
    label 'process_high'

    input:
    val database
    path "db"
    path 'in.fasta'

    output:
    path "out.ldjson"

    script:
    """
    ffdb fasta -d db.ffdata -i db.ffindex --size 100 in.fasta

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      db.ff{data,index} \
      -d sp.ffdata \
      -i sp.ffindex \
      -- \
      hmmscan \
        --domtblout /dev/stdout \
        db/db.hmm \
        /dev/stdin

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
      sp.ff{data,index} \
      -d ld.ffdata \
      -i ld.ffindex \
      -- \
      predector r2js \
        --run-name "${workflow.runName}" \
        --session-id "${workflow.sessionId}" \
        --start "${workflow.start}" \
        "${database}" -
     
    ffdb collect ld.ff{data,index} > "out.ldjson"

    rm -rf -- ld.ff{data,index} sp.ff{data,index} db.ff{data,index}
    """
}


process mmseqs_index {

    label "mmseqs"
    label "process_low"

    tag "${name}"

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
    label 'process_high'

    tag "${database}"

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

    predector r2js \
      --run-name "${workflow.runName}" \
      --session-id "${workflow.sessionId}" \
      --start "${workflow.start}" \
      "${database}" search.tsv \
    > out.ldjson

    rm -rf -- tmp matches search.tsv
    """
}
