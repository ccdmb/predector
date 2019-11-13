#!/usr/bin/env nextflow


/*
 * Define the default parameters 
 */

params.proteome   	= "test/effectors.fasta"
params.phibase		= false
params.domain		= "euk"


/*
 *  Parse the input parameters
 */

proteome_file	= file(params.proteome)
domain			= params.domain	

/*
 * Process 1A: Identify signal peptides using SignalP v3 hmm
 */

process 'SignalP_v3_hmm' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/signalp3:predector-v0.0.1'

  input:
      file proteome from proteome_file

  output:
      file "${proteome}.signalp3_hmm" into signalp3_hmm_ch 

  script:
  """
  signalp -type $domain -method "hmm" -short $proteome > "${proteome}.signalp3_hmm"
  """
}

/*
 * Process 2A: Identify signal peptides using SignalP v3 nn
 */

process 'SignalP_v3_nn' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/signalp3:predector-v0.0.1'

  input:
      file proteome from proteome_file

  output:
      file "${proteome}.signalp3_nn" into signalp3_nn_ch 

  script:
  """
  signalp -type $domain -method "hmm" -short $proteome > "${proteome}.signalp3_nn"
  """
}

/*
 * Process 3A: Identify signal peptides using SignalP v4
 

process 'SignalP_v4' { 
  publishDir "${params.outdir}"
  
  container 'darcyabjones/signalp4:predector-v0.0.1'

  input:
      file proteome from proteome_file

  output:
      file "${proteome}.signalp4" into signalp4_ch 

  script:
  """
  signalp -t $domain -f short $proteome > "${proteome}.signalp4"
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
      file proteome from proteome_file

  output:
      file "${proteome}.signalp5" into signalp5_ch 

  script:
  """
  mkdir -p tmpdir
  signalp -org $domain -format short -tmp tmpdir -fasta $proteome -prefix "${proteome}.signalp5"
  rm -rf -- tmpdir
  """
}
