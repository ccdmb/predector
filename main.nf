#!/usr/bin/env nextflow

/*
vim: syntax=groovy
-*- mode: groovy;-*-
*/


def helpMessage() {
    log.info"""
    =================================
    pannot
    =================================

    Usage:

    abaaab

    Mandatory Arguments:
      --seqs               description

    Options:
      --min_size



    Outputs:

    """.stripIndent()
}

if (params.help){
    helpMessage()
    exit 0
}

params.proteins = false

params.noeffector = false
params.noapoplastp = false
params.nolocalizer = false

params.signalp3 = false
params.signalp4 = false
params.signalp5 = false
params.tmhmm = false
params.phobius = false
params.targetp = false

params.signalp3_results = false
params.signalp4_results = false
params.signalp5_results = false
params.tmhmm_results = false
params.targetp_results = false
params.effectorp1_results = false
params.effectorp2_results = false
params.apoplastp_results = false
params.localizer_results = false

run_signalp3 = params.signalp3 && !params.signalp3_results
run_signalp4 = params.signalp4 && !params.signalp4_results
run_signalp5 = params.signalp5 && !params.signalp5_results
run_tmhmm = params.tmhmm && !params.tmhmm_results
run_targetp = params.targetp && !params.targetp_results

run_effectorp1 = !params.noeffector && !params.effectorp1_results
run_effectorp2 = !params.noeffector && !params.effectorp2_results
run_apoplastp = !params.noapoplastp && !params.apoplastp_results
run_localizer = !params.nolocalizer && !params.localizer_results


if ( !params.proteins ) {
    log.info "I need some sequences to work with please."
    exit 1
} else {
    Channel
        .fromPath(params.proteins, checkIfExists: true, type: "file")
        .first()
        .set { proteins }
}


process getChunkedProteinDB {

    label "ffindex"
    label "small_task"

    input:
    file "proteins.fasta" from proteins

    output:
    file "subdb_*" into chunkedProteinDB mode flatten

    script:
    """
    ffdb fasta \
      -d "big.ffdata" \
      -i "big.ffindex" \
      --size 200 \
      "proteins.fasta"

    ffdb split \
      --size 100 \
      --basename "tmp_subdb_{index}.{ext}" \
      "big.ffdata" \
      "big.ffindex"

    for f in tmp_subdb_*.ffindex
    do
        BASENAME="\${f%.ffindex}"
        DIRNAME="\${BASENAME#tmp_}"

        mkdir "\${DIRNAME}"
        mv "\${f}" "\${DIRNAME}/db.ffindex"
        mv "\${BASENAME}.ffdata" "\${DIRNAME}/db.ffdata"
    done

    rm big.ff{data,index}
    """
}


process getChunkedFasta {

    label "posix"
    label "small_task"

    input:
    file "proteins.fasta" from proteins

    output:
    file "subfasta_*" into chunkedFasta mode flatten

    script:
    """
    awk -v size=20000 -v pre=subfasta -v pad=9 '
        /^>/ {
            n++;
            if (n % size == 1) {
                close(fname);
                fname = sprintf("%s_%0.faa" pad "d", pre, n);
            }
        }
        { print >> fname }
    ' proteins.fasta
    """
}


process getIndivProteinDB {

    label "ffindex"
    label "small_task"

    input:
    file "proteins.fasta" from proteins

    output:
    file "subdb_*" into indivProteinDB mode flatten

    script:
    """
    ffdb fasta \
      -d "big.ffdata" \
      -i "big.ffindex" \
      --size 1 \
      "proteins.fasta"

    ffdb split \
      --size 20000 \
      --basename "tmp_subdb_{index}.{ext}" \
      "big.ffdata" \
      "big.ffindex"

    for f in tmp_subdb_*.ffindex
    do
        BASENAME="\${f%.ffindex}"
        DIRNAME="\${BASENAME#tmp_}"

        mkdir "\${DIRNAME}"
        mv "\${f}" "\${DIRNAME}/db.ffindex"
        mv "\${BASENAME}.ffdata" "\${DIRNAME}/db.ffdata"
    done

    rm big.ff{data,index}
    """
}



chunkedProteinDB.into {
    proteins4RunSignalP3HMM;
    proteins4RunSignalP3NN;
    proteins4RunSignalP4;
    proteins4RunTmhmm;
    proteins4RunEffectorP1;
    proteins4RunEffectorP2;
    proteins4RunApoplastP;
}

chunkedFasta.set {
    proteins4RunSignalP5;
}

indivProteinDB.set {
    proteins4RunTargetP
}


/*
 * Run signalp3 HMM predictions for each sequence.
 * This is known to be more sensitive for detecting oomycete effectors.
 * See doi: 10.3389/fpls.2015.01168
 */
process runSignalp3HMM {

    label "signalp3"
    label "big_task"

    when:
    run_signalp3

    input:
    file "in" from proteins4RunSignalP3HMM

    output:
    file "out" into signalp3HMMChunkedResults

    script:
    domain = "euk"

    """
    mkdir out
    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        signalp -type "${domain}" -method "hmm" -short "/dev/stdin"
    """
}


/*
 * Run signalp3 neural net predictions for each sequence.
 * This is known to be more sensitive for detecting fungal effectors.
 * See doi: 10.3389/fpls.2015.01168
 */
process runSignalp3NN {

    label "signalp3"
    label "big_task"

    when:
    run_signalp3

    input:
    file "in" from proteins4RunSignalP3NN

    output:
    file "out" into signalp3NNChunkedResults

    script:
    domain = "euk"

    """
    mkdir out
    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        signalp -type "${domain}" -method "nn" -short "/dev/stdin"
    """
}

/*
 * Run signalp4 for all sequences. Also get mature proteins for later use.
 * If there were no secreted proteins, don't emit fasta.
 */
process runSignalp4 {

    label "signalp4"
    label "big_task"

    when:
    run_signalp4

    input:
    file "in" from proteins4RunSignalP4

    output:
    file "out" into signalp4ChunkedResults

    script:
    domain = "euk"

    """
    mkdir out
    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        signalp -t "${domain}" -f short "/dev/stdin"
    """
}


/*
 */
process runSignalp5 {

    label "signalp5"
    label "big_task"

    when:
    run_signalp5

    input:
    file "in.fasta" from proteins4RunSignalP5

    output:
    file "out_summary.signalp5" into signalp5ChunkedResults

    script:
    domain = "euk"

    """
    mkdir ./tmp
    signalp \
        -fasta "in.fasta" \
        -prefix "out" \
        -format short \
        -org "${domain}" \
        -tmp "tmp"

    rm -rf -- tmp
    """
}


/*
 * Run tmhmm transmembrane domain prediction.
 */
process runTmhmm {

    label "tmhmm"
    label "big_task"

    when:
    run_tmhmm

    input:
    file "in" from proteins4RunTmhmm

    output:
    file "out" into tmhmmChunkedResults

    """
    mkdir out
    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        tmhmm -short -d

    rm -rf -- TMHMM_*
    """
}


/*
 * Run targetp using non-plant networks for chunks.
 */
process runTargetp {

    label "targetp"
    label "big_task"

    when:
    run_targetp

    input:
    file "in" from proteins4RunTargetP

    output:
    file "out" into targetpChunkedResults

    """
    mkdir out
    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        targetp -N
    """
}

/*
 * Run effectorp on each sequence.
 */
process runEffectorP1 {

    label "effectorp1"
    label "big_task"

    when:
    run_effectorp1

    input:
    file "in" from proteins4RunEffectorP1

    output:
    file "out" into effectorP1ChunkedResults

    """
    mkdir out

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        EffectorP.py -s -i "/dev/stdin"
    """
}


process runEffectorP2 {
    label "effectorp2"
    label "big_task"

    input:
    file "in" from proteins4RunEffectorP2

    output:
    file "out" into effectorP2ChunkedResults

    when:
    run_effectorp2

    script:
    """
    mkdir out

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        EffectorP.py -s -i "/dev/stdin"
    """
}


process runApoplastP {
    label "apoplastp"
    label "big_task"

    when:
    run_apoplastp

    input:
    file "in" from proteins4RunApoplastP

    output:
    file "out" into ApoplastPChunkedResults

    script:
    """
    mkdir out

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        ApoplastP.py -s -i "/dev/stdin"
    """
}


/*
 * Will need a run script!
process runLocalizer {
    label "localizer"
    label "big_task"

    input:
    file "in" from proteins4RunLocalizer

    output:
    file "out" into LocalizerChunkedResults

    when:
    run_localizer

    """
    mkdir out

    mpirun -np "${task.cpus}" ffindex_apply_mpi \
        in/db.ff{data,index} \
        -d out/db.ffdata \
        -i out/db.ffindex \
        -- \
        LOCALIZER.py -e -M -i "${fasta}" -o results
    """
}
 */

    /*
if ( !params.nosignalp ) {


     * Combine signalp3 results into file.
    process gatherSignalp3HMM {
        label "posix"
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from signalp3HMMChunkedResults.collect()

        output:
        file "signalp3_hmm.tsv" into signalp3HMMResults

        """
        echo "seqid\tsecreted\tcmax\tpos\tpos_decision\tsprob\tsprob_decision" > signalp3_hmm.tsv
        cat tables* | grep -v "#" | sed "s/ \\+/\t/g" | sed "s/\t\$//g" >> signalp3_hmm.tsv
        """
    }


     * Run signalp3 neural net predictions for each sequence.
     * This is known to be more sensitive for detecting fungal effectors.
     * See doi: 10.3389/fpls.2015.01168
    process signalp3NN {
        label "signalp3"

        input:
        file fasta from seqs4Signalp3NN

        output:
        file "${fasta}.tsv" into signalp3NNChunkedResults

        """
        signalp -type euk -method "nn" -short "${fasta}" > "${fasta}.tsv"
        """
    }


     * Combine signalp3 results into file.
    process gatherSignalp3NN {
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from signalp3NNChunkedResults.collect()

        output:
        file "signalp3_nn.tsv" into signalp3NNResults

        """
        echo "seqid\tsecreted\tcmax\tpos\tpos_decision\tsprob\tsprob_decision" > signalp3_nn.tsv
        cat tables* | grep -v "#" | sed "s/ \\+/\t/g" >> signalp3_nn.tsv
        """
    }




     * Combine signalp4 chunks into file.
    process gatherSignalp4 {
        label "posix"
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from signalp4ChunkedResults.collect()

        output:
        file "signalp4.tsv" into signalp4Results

        """
        echo "seqid\tcmax\tcmax_pos\tymax\tymax_pos\tsmax\tsmax_pos\tsmean\td\tsecreted\tdmaxcut\tnetworks" > signalp4.tsv
        cat tables* | grep -v "#" | sed "s/ \\+/\t/g" >> signalp4.tsv
        """
    }
} // endif !nosignalp
     */


    /*
if ( !params.notmhmm ) {


     * Collect results into file
    process gatherTmhmm {
        label "posix"
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from tmhmmChunkedResults.collect()

        output:
        file "tmhmm.tsv" into tmhmmResults

        """
        echo "seqid\tlen\texpaa\tfirst60\tpredhel\ttopology" > tmhmm.tsv

        cat tables* \
        | sed "s/len=\\|ExpAA=\\|First60=\\|PredHel=\\|Topology=//g" \
        | sed "s/ \\+/\t/g" \
        >> tmhmm.tsv
        """
    }
}
     */


    /*
if ( !params.notargetp ) {
     * Because targetp is a bit finicky, process it in smaller chunks.
    seqs4Targetp
        .splitFasta(by: 100)
        .into {
            seqs4Targetp1;
            seqs4Targetp2;
        }


     * Run targetp using non-plant networks for chunks.
    process targetp {
        label "targetp"

        input:
        file fasta from seqs4Targetp1

        output:
        file "${fasta}.tsv" into targetpChunkedResults

        """
        targetp -c -N < ${fasta} | tail -n+9 | head -n-2 > "${fasta}.tsv"
        """
    }


     * Collect targetp chunks into file
    process gatherTargetp {
        label "posix"
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from targetpChunkedResults.collect()

        output:
        file "targetp.tsv" into targetpResults

        """
        echo "seqid\tlen\tmtp\tsp\tother\tloc\trc\ttplen" > targetp.tsv
        cat tables* | sed 's/ \\+/\t/g' >> targetp.tsv
        """
    }


     * Run targetp using plant networks for chunks.
    process targetpPlant {
        label "targetp"

        input:
        file fasta from seqs4Targetp2

        output:
        file "${fasta}.tsv" into targetpPlantChunkedResults

        """
        targetp -c -P < ${fasta} | tail -n+9 | head -n-2 > "${fasta}.tsv"
        """
    }


     * Collect targetp chunks into file.
    process gatherTargetpPlant {
        label "posix"
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from targetpPlantChunkedResults.collect()

        output:
        file "targetp_plant.tsv" into targetpPlantResults

        """
        echo "seqid\tlen\tctp\tmtp\tsp\tother\tloc\trc\ttplen" > targetp_plant.tsv
        cat tables* | sed 's/ \\+/\t/g' >> targetp_plant.tsv
        """
    }
} // endif !notargetp
     */


    /*
if ( !params.nophobius ) {
     * Run phobius predictions for chunks.
     * Phobius has comparable sensitivity to signalp nn models and also runs tm prediction.
    process phobius {
        label "phobius"

        input:
        file fasta from seqs4Phobius

        output:
        file "${fasta}.tsv" into phobiusChunkedResults

        """
        sed 's/\\*\$//g' "${fasta}" | sed '/>/!s/[\\*J]/X/g' | phobius -short | tail -n+2 > "${fasta}.tsv"
        """
    }


     * Collect phobius results into file.
    process gatherPhobius {
        label "posix"
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from phobiusChunkedResults.collect()

        output:
        file "phobius.tsv" into phobiusResults

        """
        echo "seqid\ttm\tsp\tprediction" > phobius.tsv
        cat tables* | sed 's/ \\+/\t/g' >> phobius.tsv
        """
    }
}
     */



    /*
if ( !params.nolocalizer ) {
     * Run localizer using plant mode.
    process localizerPlant {
        label "sperschneider"

        input:
        file fasta from seqs4LocalizerPlant

        output:
        file "${fasta}.tsv" into localizerPlantChunkedResults

        """
        LOCALIZER.py -p -i "${fasta}" -o results
        grep -v "^#" results/Results.txt \
        | tail -n+2 \
        | sed '/^\\s*\$/d' \
        | awk -F'\t' 'OFS="\t" { sub(/[[:space:]].*<DELETE_THIS>/, "", \$1); print \$1, \$2, \$3, \$4}' \
        > "${fasta}.tsv"
        """
    }


     * Collect localizer results into file.
    process gatherLocalizerPlant {
        label "posix"
        publishDir "${params.outdir}/annotations"

        input:
        file "tables" from localizerPlantChunkedResults.collect()

        output:
        file "localizer_plant.tsv" into localizerPlantResults

        """
        echo "seqid\tchloroplast\tmitochondria\tnucleus" > localizer_plant.tsv
        cat tables* >> localizer_plant.tsv
        """
    }
}
     */
