#!/usr/bin/env nextflow


/*
 * Define the default parameters 
 */

params.proteome   	= "test/test_set.fasta"
params.phibase		  = false
params.domain		    = "euk"


/*
 *  Parse the input parameters
 */
Channel
    .fromPath(params.proteome)
    .map { f -> [ f.simpleName, f ] }
    .into {
      proteome_ch_signalp3_hmm; 
      proteome_ch_signalp3_nn; 
      proteome_ch_signalp4;
      proteome_ch_signalp5;
      proteome_ch_targetp;
      proteome_ch_deeploc;
      proteome_ch_effectorp1;
      proteome_ch_effectorp2;
      proteome_ch_tmhmm;
      proteome_ch_apoplastp;
      proteome_ch_emboss;
      proteome_ch_localizer;
      proteome_ch_phobius      
    }

domain			= params.domain	

/*
 * Process 1A: Identify signal peptides using SignalP v3 hmm
 */

process 'SignalP_v3_hmm' { 
  publishDir "${params.outdir}"
  
  label 'signalp3'

  input:
      set val(name), file ("in.fasta") from proteome_ch_signalp3_hmm

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
  
  label 'signalp3'

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
 */

process 'SignalP_v4' { 
  publishDir "${params.outdir}"
  
  label 'signalp4'

  input:
      set val(name), file ("in.fasta") from proteome_ch_signalp4

  output:
      file "${name}.signalp4" into signalp4_ch 

  script:
  """
  signalp -t $domain -f short in.fasta > "${name}.signalp4"
  """
}


/*
 * Process 4A: Identify signal peptides using SignalP v5
 */

process 'SignalP_v5' { 
  publishDir "${params.outdir}"
  
  label 'signalp5'

  input:
      set val(name), file ("in.fasta") from proteome_ch_signalp5

  output:
      file "${name}_summary.signalp5" into signalp5_ch 
      set val(name), file ("${name}_mature.fasta") into signalp5_mature_ch 
  script:
  """
  mkdir -p tmpdir
  signalp -org $domain -format short -tmp tmpdir -mature -fasta in.fasta -prefix "${name}"
  rm -rf -- tmpdir
  """
}

/*
 * Process 5A: Subcellular location using TargetP
 */

process 'TargetP' { 
  publishDir "${params.outdir}"
  
  label 'targetp'

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
  
  label 'deeploc'

  input:
      set val(name), file ("in.fasta") from proteome_ch_deeploc

  output:
      file "${name}.deeploc" into deeploc_ch 

  script:
  """
  deeploc -f in.fasta -o "${name}"
  mv "${name}.txt" "${name}.deeploc"
  """
}

/*
 * Process 7A: Effector ML using EffectorP v1
 */

process 'EffectorP_v1' { 
  publishDir "${params.outdir}"
  
  label 'effectorp1'

  input:
      set val(name), file ("in.fasta") from proteome_ch_effectorp1

  output:
      file "${name}.effectorp1" into effectorp1_ch 

  script:
  """
  EffectorP.py -s -i in.fasta > "${name}.effectorp1"
  """
}

/*
 * Process 8A: Effector ML using EffectorP v2
 */

process 'EffectorP_v2' { 
  publishDir "${params.outdir}"
  
  label 'effectorp2'

  input:
      set val(name), file ("in.fasta") from proteome_ch_effectorp2

  output:
      file "${name}.effectorp2" into effectorp2_ch 

  script:
  """
  EffectorP.py -s -i in.fasta > "${name}.effectorp2"
  """
}

/*
 * Process 9A: TMHMM
 */

process 'TMHMM' { 
  publishDir "${params.outdir}"
  
  label 'tmhmm'

  input:
      set val(name), file ("in.fasta") from proteome_ch_tmhmm

  output:
      file "${name}.tmhmm" into tmhmm_ch 

  script:
  """
  tmhmm -short -d < in.fasta > "${name}.tmhmm"
  rm -rf -- TMHMM_*
  """
}

/*
 * Process 10A: ApoplastP
 */

process 'ApoplastP' { 
  publishDir "${params.outdir}"
  
  label 'apoplastp'

  input:
      set val(name), file ("in.fasta") from proteome_ch_apoplastp

  output:
      file "${name}.apoplastp" into apoplastp_ch 

  script:
  """
  ApoplastP.py -s -i in.fasta > "${name}.apoplastp"
  """
}


/*
 * Process 10A: Emboss
 */

process 'Emboss' { 
  publishDir "${params.outdir}"
  
  label 'emboss'

  input:
      set val(name), file ("in.fasta") from proteome_ch_emboss

  output:
      file "${name}.emboss" into emboss_ch 

  script:
  """
  pepstats -sequence in.fasta -outfile "${name}.emboss"
  """
}

/*
 * Process 10A: Localizer
 */

process 'Localizer' { 
  publishDir "${params.outdir}"
  
  label 'localizer'

  input:
      set val(name), file ("mature.fasta") from signalp5_mature_ch

  output:
      file "${name}.localizer" into lozalizer_ch 

  script:
  """
  LOCALIZER.py -e -M -i mature.fasta -o "${name}.localizer"
  """
}

/*
 * Process 10A: Phobius
 */

process 'Phobius' { 
  publishDir "${params.outdir}"
  
  label 'phobius'

  input:
      set val(name), file ("in.fasta") from proteome_ch_phobius

  output:
      file "${name}.phobius" into phobius_ch 

  script:
  """
  phobius.pl -short in.fasta > "${name}.phobius"
  """
}