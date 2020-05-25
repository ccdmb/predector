#!/usr/bin/env nextflow

nextflow.preview.dsl = 2

include check_env from './modules/versions'

workflow {

    main:
    versions = check_env()
    versions.signalp3_version.view { "SignalP3 ${it}" }
    versions.signalp4_version.view { "SignalP4 ${it}" }
    versions.signalp5_version.view { "SignalP5 ${it}" }
    versions.targetp2_version.view { "TargetP ${it}" }
    versions.tmhmm2_version.view { "TMHMM ${it}" }
    versions.deeploc1_version.view { "DeepLoc ${it}" }
    versions.phobius_version.view { "Phobius ${it}" }
    versions.effectorp1_version.view { "EffectorP1 ${it}" }
    versions.effectorp2_version.view { "EffectorP2 ${it}" }
    versions.localizer_version.view { "LOCALIZER ${it}" }
    versions.apoplastp_version.view { "ApoplastP ${it}" }
    versions.deepsig_version.view { "Deepsig ${it}" }
    versions.emboss_version.view { "EMBOSS ${it}" }
    versions.mmseqs2_version.view { "MMSeqs2 ${it}" }
    versions.hmmer_version.view { "HMMER ${it}" }
}
