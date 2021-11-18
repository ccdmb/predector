## Pipeline output

Predector output several files for each input file that you provide, and some additional ones that can be useful for debugging results.

Results will always be placed under the directory specified by the parameter `--outdir` (`./results` by default).

Downloaded databases (i.e. Pfam and dbCAN) are stored in the `downloads` subdirectory.
Deduplicated sequences and a tab-separated values file mapping the deduplicated sequence ids to their filenames and original ids is in the `deduplicated` subdirectory.

Other directories will be named after the input filenames and each contain several tables.

### `*-ranked.tsv`

This is the main output table that includes the scores and most of the parameters that are important for effector or secretion prediction.
There are a lot of columns, though generally you'll only be interested in a few of them.

| Column | Data type | Description | Notes |
|:--------- |:-----------|:------------------------|:-----------|
| `seqid` | String | The protein name in the fasta input you provided |
| `effector_score` | Float | The predector machine learning effector score for this protein |
| `manual_effector_score` | Float | The manually created effector score, which is the sum of the products of several values in this spreadsheet | See [manual ranking scores](#manual-ranking-scores) for details |
| `manual_secretion_score` | Float | The manually created secretion score, which is the sum of the products of several values in this spreadsheet |
| `effector_matches` | String | A comma separated list of the significant matches to the curated set of fungal effector HMMs | If you are interested in knowing more about matches, see https://doi.org/10.6084/m9.figshare.16973665 under `effectordb.tsv` for details and links to papers describing functions |
| `phibase_genes` | String | A comma separated list of PHI-base gene names that were significant hits to this sequence |
| `phibase_phenotypes` | String | A comma separated list of the PHI-base phenotypes in the significant hits to PHI-base |
| `phibase_ids` | String | A comma separated list of the PHI-base entries that were significant hits | You can find out more details about PHI-base matches here http://www.phi-base.org/, which will include links to literature describing experimental results. If you do publish relevant experiments on virulence factors or effectors or know of entries not in PHI-base, please do consider helping them curate https://canto.phi-base.org/ |
| `has_phibase_effector_match` | Boolean [0, 1] | Indicates whether the protein had a significant hit to one of the phibase phenotypes: Effector, Hypervirulence, or loss of pathogenicity |
| `has_phibase_virulence_match` | Boolean [0, 1] | Indicating whether the protein had a significant hit with the phenotype "reduced virulence" |
| `has_phibase_lethal_match` | Boolean [0, 1] | Indicating whether the protein had a significant hit with the phenotype "lethal" |
| `pfam_ids` | List | A comma separated list of all Pfam HMM ids matched | You can find details on Pfam match entries at http://pfam.xfam.org (use the "Jump to" search boxes with this ID) |
| `pfam_names` | List | A comma separated list of all Pfam HMM names matched |
| `has_pfam_virulence_match` | Boolean [0, 1] | Indicating whether the protein had a significant hit to one of the selected Pfam HMMs associated with virulence function | A list of virulence associated Pfam entries is here: https://github.com/ccdmb/predector/blob/master/data/pfam_targets.txt |
| `dbcan_matches` | List | A comma separated list of all dbCAN matches | You can find details on CAZYme families at http://www.cazy.org/. For more on dbCAN specifically see here https://bcb.unl.edu/dbCAN2/ |
| `has_dbcan_virulence_match` | Boolean [0, 1] | Indicating whether the protein had a significant hit to one of the dbCAN domains associated with virulence function | A list of virulence associated dbCAN entries is here: https://github.com/ccdmb/predector/blob/master/data/dbcan_targets.txt |
| `effectorp1` | Float | The raw EffectorP v1 prediction pseudo-probability | Values above 0.5 are considered to be effector predictions |
| `effectorp2` | Float | The raw EffectorP v2 prediction pseudo-probability | Values above 0.5 are considered to be effector predictions, Values below 0.6 are annotated in the raw EffectorP output as "unlikely effectors" |
| `effectorp3_cytoplasmic` | Float or None '.'| The EffectorP v3 prediction pseudo-probability for cytoplasmic effectors | EffectorP only reports probabilities for classifiers over 0.5, '.' indicates where the value is not reported by EffectorP v3 |
| `effectorp3_apoplastic` | Float or None '.'| As for `effectorp3_cytoplasmic` but for apoplastic effector probability |
| `effectorp3_noneffector` | Float or None '.'| As for `effectorp3_cytoplasmic` but for non-effector probability |
| `deepredeff_fungi` | Float | The deepredeff fungal effector classifier pseudo probability | Values above 0.5 are considered to be effector predictions |
| `deepredeff_oomycete` | Float | The deepredeff oomycete effector classifier pseudo probability | Values above 0.5 are considered to be effector predictions |
| `apoplastp` | Float | The raw ApoplastP "apoplast" localised prediction pseudo probability | Values above 0.5 are considered to be apoplastically localised |
| `is_secreted` | Boolean [0, 1] | Indicates whether the protein had a signal peptide predicted by any method, and does not have $\ge$ 2 transmembrane domains predicted by either TMHMM or Phobius |
| `any_signal_peptide` | Boolean [0, 1] | Indicates whether any of the signal peptide prediction methods predict the protein to have a signal peptide |
| `single_transmembrane` | Boolean [0, 1] | Indicates whether the protein is predicted to have 1 transmembrane domain by TMHMM or Phobius (and not >1 for either), and in the case of TMHMM the predicted number of TM AAs in the first 60 residues is less than 10 |
| `multiple_transmembrane` | Boolean [0, 1] | Indicating whether a protein is predicted to have more than 1 transmembrane domain by either Phobius or TMHMM |
| `molecular_weight` | Float | The predicted molecular weight (Daltons) of the protein |
| `residue_number` | Integer | The length of the protein or number of residues/AAs |
| `charge` | Float | The overall predicted charge of the protein |
| `isoelectric_point` | Float |The predicted isoelectric point of the protein |
| `aa_c_number` | Integer | The number of Cysteine residues in the protein |
| `aa_tiny_number` | Integer | The number of tiny residues (A, C, G, S, or T) in the protein |
| `aa_small_number` | Integer | The number of small residues (A, B, C, D, G, N, P, S, T, or V) in the protein |
| `aa_aliphatic_number` | Integer | The number of aliphatic residues (A, I, L, or V) in the protein |
| `aa_aromatic_number` | Integer | The number of aromatic residues (F, H, W, or Y) in the protein |
| `aa_nonpolar_number` | Integer | The number of non-polar residues (A, C, F, G, I, L, M, P, V, W, or Y) in the protein |
| `aa_charged_number` | Integer | The number of charged residues (B, D, E, H, K, R, or Z) in the protein |
| `aa_basic_number` | Integer | The number of basic residues (H, K, or R) in the protein |
| `aa_acidic_number` | Integer | The number of acidic residues (B, D, E or Z) in the protein |
| `fykin_gap` | Float | The number of FYKIN residues + 1 divided by the number of GAP residues + 1 | [Testa et al. 2016](https://doi.org/10.1093/gbe/evw121) describe RIP affected regions as being enriched for FYKIN residues, and depleted in GAP residues |
| `kex2_cutsites` | List | A comma separated list of potential matches to Kex2 motifs | These each take the form of `<pattern>:<start>-<end>`. Where pattern is one of `[LIJVAP][A-Z][KRTPEI]R`, `L[A-Z][A-Z]R`, `[KR]R`. See [Outram et al. 2021](https://doi.org/10.1371/journal.ppat.1010000) for a recent brief review. Note that these are simple regular expression matches and there has been no processing. Use with some caution |
| `rxlr_like_motifs` | List | A comma separated list of potential RxLR-like motifs `[RKH][A-Z][LMIFYW][A-Z]` as described by [Kale et al. 2010](https://doi.org/10.1016/j.cell.2010.06.008) | Each take the form of `<start>-<end>`. Note that this is a simple regular expression match, it tends to be quite non-specific, and the function of these motifs remains controversial. Use with some caution |
| `localizer_nucleus` | Boolean [0, 1] | Indicates whether localiser predicted an internal nuclear localisation peptide. | These predictions are run on all proteins with the first 20 AAs trimmed from the start to remove any potential signal peptides |
| `localizer_chloro` | Boolean [0, 1] | Indicates whether localiser predicted an internal chloroplast localisation peptide |
| `localizer_mito` | Boolean [0, 1] | Indicates whether localiser predicted an internal mitochondrial localisation peptide |
| `signal_peptide_cutsites` | List | A comma separated list of predicted signal-peptide cleavage sites | Each will take the form `<program_name>:<last_base_in_sp>`. So the mature peptide is expected to begin after the number |
| `signalp3_nn` | Boolean [0, 1] | Indicates whether the protein is predicted to have a signal peptide by the neural network model in SignalP 3 |
| `signalp3_hmm` | Boolean [0, 1] | Indicates whether the protein is predicted to have a signal peptide by the HMM model in SignalP 3 |
| `signalp4` | Boolean [0, 1] | Indicates whether the protein is predicted to have a signal peptide by SignalP 4 |
| `signalp5` | Boolean [0, 1] | Indicating whether the protein is predicted to have a signal peptide by SignalP 5 |
| `signalp6` | Boolean [0, 1] | Indicates whether the protein is predicted to have a signal peptide by SignalP 6 |
| `deepsig` | Boolean | Boolean [0, 1] indicating whether the protein is predicted to have a signal peptide by DeepSig |
| `phobius_sp` | Boolean [0, 1] | Indicates whether the protein is predicted to have a signal peptide by Phobius |
| `phobius_tmcount` | Integer | The number of transmembrane domains predicted by Phobius |
| `tmhmm_tmcount` | Integer | The number of transmembrane domains predicted by TMHMM |
| `tmhmm_first_60` | Float | The predicted number of transmembrane AAs in the first 60 residues of the protein by TMHMM |
| `tmhmm_exp_aa` | Float | The predicted number of transmembrane AAs in the protein by TMHMM |
| `tmhmm_first_tm_sp_coverage` | Float | The proportion of the first predicted TM domain that overlaps with the median predicted signal-peptide cut site | Where no signal peptide or no TM domains are predicted, this will always be 0 |
| `targetp_secreted` | Boolean [0, 1] | Indicates whether TargetP 2 predicts the protein to be secreted |
| `targetp_secreted_prob` | Float | The TargetP pseudo-probability of secretion |
| `targetp_mitochondrial_prob` | Float | The TargetP pseudo-probability of mitochondrial localisation |
| `deeploc_membrane` | Float | DeepLoc pseudo-probability of membrane association |
| `deeploc_nucleus` | Float | DeepLoc pseudo-probability of nuclear localisation | Note that all DeepLoc values other than "membrane" are from the same classifier, so the sum of all of the pseudo-probabilities will be 1 |
| `deeploc_cytoplasm` | Float | DeepLoc pseudo-probability of cytoplasmic localisation |
| `deeploc_extracellular` | Float | DeepLoc pseudo-probability of extracellular localisation |
| `deeploc_mitochondrion` | Float | DeepLoc pseudo-probability of mitochondrial localisation |
| `deeploc_cell_membrane` | Float | DeepLoc pseudo-probability of cell membrane localisation |
| `deeploc_endoplasmic_reticulum` | Float | DeepLoc pseudo-probability of ER localisation |
| `deeploc_plastid` | Float | DeepLoc pseudo-probability of plastid localisation |
| `deeploc_golgi` | Float | DeepLoc pseudo-probability of golgi apparatus localisation |
| `deeploc_lysosome` | Float | DeepLoc pseudo-probability of lysosomal localisation |
| `deeploc_peroxisome` | Float | DeepLoc pseudo-probability of peroxisomal localisation |
| `signalp3_nn_d` | Float | The raw D-score for the SignalP 3 neural network |
| `signalp3_hmm_s` | Float | The raw S-score for the SignalP 3 HMM predictor |
| `signalp4_d` | Float | The raw D-score for SignalP 4 | See discussion of choosing multiple thresholds in the [SignalP FAQs](https://services.healthtech.dtu.dk/service.php?SignalP-4.1) |
| `signalp5_prob` | Float | The SignalP 5 signal peptide pseudo-probability |
| `signalp6_prob` | Float | The SignalP 6 signal peptide pseudo-probability |


### `*.gff3`

This file contains gff3 versions of results from analyses that have some positional information (e.g. signal/target peptides or alignments).
The columns are:

1. The protein seqid in your input fasta file.
2. The analysis that gave this result. Note that for database matches, both the software and database are listed, separated by a colon (`:`).
3. The closest [Sequence Ontology](http://www.sequenceontology.org/browser/obob.cgi) term that could be used to describe the region.
4. The start of the region being described (1-based).
5. The end of the region being described (1-based inclusive).
6. The score of the match if available. For MMSeqs2 and HMMER matches, this is the e-value. For SignalP 3-nn and 4 this will be the D-score, for SignalP 3-hmm this is the S-probability, and for SignalP5, DeepSig, TargetP and LOCALIZER mitochondrial or chloroplast predictions this will be the probability score.
7. The strand. This will always be unstranded (`.`), since proteins don't have direction in the same way nucleotides do.
8. The phase, this will always be `.` because it is only valid for CDS features.
9. The GFF attributes. In here the remaining raw results and scores will be present. Of particular interest are the [`Gap` and `Target` attributes](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md#the-gap-attribute), which define what database match an alignment found and the bounds in the matched sequence, and match/mismatch positions.


### Individual results tables

There are a bunch of tables that are just TSV versions of the original outputs.
Most of the tools outputs are not well described and not in convenient formats for parsing so we don't keep them around.
We've done our best to retain all of the information in the original formats as a TSV version.

The original formats are described in:

- https://services.healthtech.dtu.dk/service.php?SignalP-6.0 
- https://services.healthtech.dtu.dk/service.php?SignalP-5.0 
- https://services.healthtech.dtu.dk/service.php?SignalP-4.1
- https://services.healthtech.dtu.dk/service.php?SignalP-3.0
- https://services.healthtech.dtu.dk/service.php?TargetP-2.0
- https://services.healthtech.dtu.dk/service.php?TMHMM-2.0
- http://phobius.sbc.su.se/instructions.html
- https://github.com/BolognaBiocomp/deepsig
- In the Pfamscan source ftp://ftp.ebi.ac.uk/pub/databases/Pfam/Tools/PfamScan.tar.gz
- http://emboss.sourceforge.net/apps/cvs/emboss/apps/pepstats.html
- http://effectorp.csiro.au/output.html
- http://apoplastp.csiro.au/output.html
- http://localizer.csiro.au/output.html
- https://github.com/soedinglab/MMseqs2/wiki#custom-alignment-format-with-convertalis
- http://eddylab.org/software/hmmer/Userguide.pdf under "tabular output formats".

DeepLoc doesn't have any output format documentation that I can find, but hopefully it's pretty self explanatory for you.
Note that all DeepLoc values other than "membrane" are from the same classifier, so the sum of all of the pseudo-probabilities will be 1.
