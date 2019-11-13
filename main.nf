#!/usr/bin/env nextflow


/*
 * Define the default parameters 
 */

params.proteome   	= "test/effectors.fasta"
params.phibase		= false
params.results   	= "results" 
params.domain		= "euk"

/*
 *  Parse the input parameters
 */

proteome_file	= file(params.proteome)
domain			= params.domain	

/*
 * Process 1A: Identify signal peptides using SignalP v3
 */

process 'SignalP_v3_hmm' { 
  publishDir 'my_results'
  
  

  input:
      file proteome from proteome_file

  output:
      file "${proteome}.out.txt" into proteome_index_ch 

  script:
  """
  signalp -type $domain -method "hmm" -short $proteome > "${proteome}.out.txt"
  """
}


