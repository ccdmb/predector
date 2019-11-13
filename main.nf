#!/usr/bin/env nextflow


/*
 * Define the default parameters 
 */

params.proteome   	= "test/*.fasta"
params.phibase		= false
params.domain		= "euk"


/*
 *  Parse the input parameters
 */
Channel
    .fromPath(params.proteome)
    .map { f -> [ f.simpleName, f ] }
    .into {from proteome_ch_signal3_hmm; signalp3_nn_ch; signalp3_hmm_ch}

domain			= params.domain	

/*
 * Process 1A: Identify signal peptides using SignalP v3 hmm
 */

process 'SignalP_v3_hmm' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/signalp3:predector-v0.0.1'

  input:
      set val(name), file ("in.fasta") from proteome_ch_signal3_hmm

  output:
      file "${name}.signalp3_hmm" into signalp3_hmm_ch 

  script:
  """
  signalp -type $domain -method "hmm" -short in.fasta > "${name}.signalp3_hmm"
  """
}

/*
 * Process 2A: Identify signal peptides using SignalP v3 nn
 */

process 'SignalP_v3_nn' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/signalp3:predector-v0.0.1'

  input:
      set val(name), file ("in.fasta") from proteome_ch_signalp3_nn

  output:
      file "${name}.signalp3_nn" into signalp3_nn_ch 

  script:
  """
  signalp -type $domain -method "nn" -short in.fasta > "${name}.signalp3_nn"
  """
}


/*
 * Process 3A: Identify signal peptides using SignalP v4
 

process 'SignalP_v4' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/signalp4:predector-v0.0.1'

  input:
      set val(name), file ("in.fasta") from proteome_ch_signalp4

  output:
      file "${name}.signalp4" into signalp4_ch 

  script:
  """
  signalp -t $domain -f short in.fasta > "${name}.signalp4"
  """
}
*/

/*
 * Process 4A: Identify signal peptides using SignalP v5
 */

process 'SignalP_v5' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/signalp5:predector-v0.0.1'

  input:
      set val(name), file ("in.fasta") from proteome_ch_signalp5

  output:
      file "${name}_summary.signalp5" into signalp5_ch 

  script:
  """
  mkdir -p tmpdir
  signalp -org $domain -format short -tmp tmpdir -fasta in.fasta -prefix "${name}"
  rm -rf -- tmpdir
  """
}

/*
 * Process 5A: Subcellular location using TargetP
 */

process 'TargetP' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/targetp:predector-v0.0.1'

  input:
      set val(name), file ("in.fasta") from proteome_ch_targetp

  output:
      file "${name}_summary.targetp2" into targetp_ch 

  script:
  """
  mkdir -p tmpdir
  targetp -fasta in.fasta -org non-pl -format short -prefix "${name}"
  rm -rf -- tmpdir
  """
}

/*
 * Process 6A: Subcellular location using DeepLoc
 */

process 'DeepLoc' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/deeploc:predector-v0.0.1'

  input:
      set val(name), file ("in.fasta") from proteome_ch_deeploc

  output:
      file "${name}.deeploc" into targetp_ch 

  script:
  """
  deeploc -f in.fasta -o "${name}"
  mv "${name}_output.txt" "${name}.deeploc"
  """
}

/*
 * Process 7A: Effector ML using EffectorP v1
 */

process 'EffectorP_v1' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/effectorp1:predector-v0.0.1'

  input:
      file proteome from proteome_file

  output:
      file "${proteome}.deeploc" into targetp_ch 

  script:
  """
  deeploc -f $proteome -o "${proteome}.deeploc"
  """
}

/*
 * Process 8A: Effector ML using EffectorP v2
 */

process 'EffectorP_v2' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/effectorp2:predector-v0.0.1'

  input:
      file proteome from proteome_file

  output:
      file "${proteome}.deeploc" into targetp_ch 

  script:
  """
  EffectorP.py -s -i $proteome > "${proteome}.d"
  """
}
