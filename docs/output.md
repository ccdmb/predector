## Pipeline output

Predector outputs several files for each input file that you provide, and some additional ones that can be useful for debugging results.

Results will always be placed under the directory specified by the parameter `--outdir` (`./results` by default).

Downloaded databases (i.e. Pfam and dbCAN) are stored in the `downloads` subdirectory.
Predector internally removes duplicate sequences at the start to avoid redundant computation and reduplicates them at the end.
The `deduplicated` folder contains the deduplicated sequences, results, and a mapping file of the old ids to new ones.

Other directories will be named after the input filenames and each contains several tables.
An example set of these results is available in the [`test` directory on github](https://github.com/ccdmb/predector/tree/1.2.7/test/test_set_results).

### `deduplicated/`

The deduplicated folder contains deduplicated sequences and a tab-separated values file mapping the deduplicated sequence ids to their filenames and original ids in the `deduplicated` subdirectory.
Deduplicated sequences may not be the same as the input sequences, as we do some "cleaning" before running the pipeline to avoid some common issues causing software crashes.
Basically sequences are all uppercased, `*` characters are removed from the ends, `-` characters are removed, and any remaining `*JBZUO` characters are replaced with `X`.

The `deduplicated.tsv` file has four columns:

| Column | Type | Description |
|:-------|:-----|:------------|
| deduplicated_id | str | The ID of the unique sequence in the deduplicated results |
| input_file | str | The input filename that the sequence came from |
| original_id | str | The ID of the protein in the input file |
| checksum | str | This is a hashed verison of the input amino-acid sequence that we use to detect duplicate sequences. The checksums are created with the [`seguid` function in BioPython](https://biopython.org/docs/1.75/api/Bio.SeqUtils.CheckSum.html#Bio.SeqUtils.CheckSum.seguid) |


This folder also contains two `.ldjson` files.
`deduplicated.ldjson` contains all results of analyses on the deduplicated sequences.
`new_results.ldjson` contains a subset of the results in `deduplicated.ldjson` suitable for input as pre-computed input to the pipeline.


### `analysis_software_versions.tsv`

This is a table containing the software and database (where relevant) versions
of the analyses that Predector has run.

It has a simple 3 column structure. `analysis`, `software_version`, `database_version`.
If the analysis doesn't use a database or we cannot determine which version of the database you're using
(because you provided it yourself rather than letting the pipeline download it), then the `database_version` column will be an empty string.


### `*-ranked.tsv`

This is the main output table that includes the scores and most of the parameters that are important for effector or secretion prediction.
There are a lot of columns, though generally you'll only be interested in a few of them.

| Column | Data type | Description | Notes |
|:--------- |:-----------|:------------------------|:-----------|
| `seqid` | String | The protein name in the fasta input you provided |
| `effector_score` | Float | The Predector machine learning effector score for this protein |
| `manual_effector_score` | Float | The manually created effector score, which is the sum of the products of several values in this spreadsheet | See [manual ranking scores](#manual-ranking-scores) for details |
| `manual_secretion_score` | Float | The manually created secretion score, which is the sum of the products of several values in this spreadsheet |
| `effector_matches` | String | A comma separated list of the significant matches to the curated set of fungal effector HMMs | If you are interested in knowing more about matches, see https://doi.org/10.6084/m9.figshare.16973665 under `effectordb.tsv` for details and links to papers describing functions. Matches are sorted by evalue, so the first hit is the best. |
| `phibase_genes` | String | A comma separated list of PHI-base gene names that were significant hits to this sequence | Matches are sorted by evalue, so the first hit is the best. |
| `phibase_phenotypes` | String | A comma separated list of the distinct PHI-base phenotypes in the significant hits to PHI-base | Phenotypes are sorted by minimum evalue for matches with that phenotype. |
| `phibase_ids` | String | A comma separated list of the PHI-base entries that were significant hits | You can find out more details about PHI-base matches here http://www.phi-base.org/, which will include links to literature describing experimental results. If you do publish relevant experiments on virulence factors or effectors or know of entries not in PHI-base, please do consider helping them curate https://canto.phi-base.org/. Matches are sorted by evalue, so the first hit is the best. |
| `has_phibase_effector_match` | Boolean [0, 1] | Indicates whether the protein had a significant hit to one of the phibase phenotypes: Effector, Hypervirulence, or loss of pathogenicity |
| `has_phibase_virulence_match` | Boolean [0, 1] | Indicating whether the protein had a significant hit with the phenotype "reduced virulence" |
| `has_phibase_lethal_match` | Boolean [0, 1] | Indicating whether the protein had a significant hit with the phenotype "lethal" |
| `pfam_ids` | List | A comma separated list of all Pfam HMM ids matched | You can find details on Pfam match entries at http://pfam.xfam.org (use the "Jump to" search boxes with this ID). Matches are sorted by evalue, so the first hit is the best.|
| `pfam_names` | List | A comma separated list of all Pfam HMM names matched | Matches are sorted by evalue, so the first hit is the best. |
| `has_pfam_virulence_match` | Boolean [0, 1] | Indicating whether the protein had a significant hit to one of the selected Pfam HMMs associated with virulence function | A list of virulence associated Pfam entries is here: https://github.com/ccdmb/predector/blob/master/data/pfam_targets.txt |
| `dbcan_matches` | List | A comma separated list of all dbCAN matches | You can find details on CAZYme families at http://www.cazy.org/. For more on dbCAN specifically see here https://bcb.unl.edu/dbCAN2/. Matches are sorted by evalue, so the first hit is the best. |
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
| `kex2_cutsites` | List | A comma separated list of potential matches to Kex2 motifs | These each take the form of `<match>:<pattern>[&<pattern>[...]]:<start>-<end>`. Where match is the actual motif in your protein, and pattern is one of `[LIJVAP]X[KRTPEI]R`, `LXXR`, `[KR]R`. If multiple patterns match at the same position, they will be listed separated by `&`, e.g the motif `LAKR` might output `LAKR:[LIJVAP]X[KRTPEI]R&LXXR:10-13` since both pattens match that motif at that position. Positions are start and end inclusive (like GFF3). See [Outram et al. 2021](https://doi.org/10.1371/journal.ppat.1010000) for a recent brief review. Note that these are simple regular expression matches and there has been no processing. Use with some caution |
| `rxlr_like_motifs` | List | A comma separated list of potential RxLR-like motifs `[RKH][A-Z][LMIFYW][A-Z]` as described by [Kale et al. 2010](https://doi.org/10.1016/j.cell.2010.06.008) | Each take the form of `<match>:<start>-<end>`. Positions are start and end inclusive (like GFF3). Note that this is a simple regular expression match, it tends to be quite non-specific, and the function of these motifs remains controversial. Use with some caution |
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
| `phobius_tm_domains` | List | A comma separated list of transmembrane domain predictions from Phobius. Each will have the format `<start>-<end>` | Positions are start and end inclusive (like GFF3). We also add the prefix `tm:` to this column. This is to prevent Excel from interpreting these entries as dates.  |
| `tmhmm_tmcount` | Integer | The number of transmembrane domains predicted by TMHMM |
| `tmhmm_first_60` | Float | The predicted number of transmembrane AAs in the first 60 residues of the protein by TMHMM |
| `tmhmm_exp_aa` | Float | The predicted number of transmembrane AAs in the protein by TMHMM |
| `tmhmm_first_tm_sp_coverage` | Float | The proportion of the first predicted TM domain that overlaps with the median predicted signal-peptide cut site | Where no signal peptide or no TM domains are predicted, this will always be 0 |
| `tmhmm_domains` | List | A comma separated list of transmembrane domains predicted by TMHMM. Each will have the format `<start>-<end>` | Positions are start and end inclusive (like GFF3). We also add the prefix `tm:` to this column. This is to prevent Excel from interpreting these entries as dates. |
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
| `deepsig_signal_prob` | Float or None `.` | The DeepSig signal peptide pseudo-probability. Note that DeepSig only outputs the probability of the main prediction, so any proteins with a Transmembrane or Other prediction will be None (`.`) here. |
| `deepsig_transmembrane_prob` | Float or None `.` | The DeepSig transmembrane pseudo-probability. |
| `deepsig_other_prob` | Float or None `.` | The DeepSig "other" (i.e. not signal peptide or transmembrane) pseudo-probability.


### `*.gff3`

This file contains gff3 versions of results from analyses that have some positional information (e.g. signal/target peptides or alignments).
The columns are:

| Column | Type | Description |
|:-------|:-----|:------------|
| `seqid` | str | The protein seqid in your input fasta file. |
| `source` | str | The analysis that gave this result. Note that for database matches, both the software and database are listed, separated by a colon (`:`). |
| `type` | str | The closest [Sequence Ontology](http://www.sequenceontology.org/browser/obob.cgi) term that could be used to describe the region. |
| `start` | int | The start of the region being described (1-based). |
| `end` | int | The end of the region being described (1-based inclusive). |
| `score` | float | The score of the match if available. For MMSeqs2 and HMMER matches, this is the e-value. For SignalP 3-nn and 4 this will be the D-score, for SignalP 3-hmm this is the S-probability, and for SignalP5, DeepSig, TargetP and LOCALIZER mitochondrial or chloroplast predictions this will be the probability score. |
| `strand` | `+`, `-`, or `.` | This will always be unstranded (`.`), since proteins don't have direction in the same way nucleotides do. |
| `phase` | `0`, `1`, `2`, or `.` | This will always be `.` because it is only valid for CDS features. |
| `attributes` | A semi-colon delimited list of `key=value` pairs | In here the remaining raw results and scores will be present. Of particular interest are the [`Gap` and `Target` attributes](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md#the-gap-attribute), which define what database match an alignment found and the bounds in the matched sequence, and match/mismatch positions. Some punctuation characters will be escaped using [URL escape rules](https://en.wikipedia.org/wiki/Percent-encoding#Reserved_characters). For example, commas `,` will be escaped as `%2C`. |


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


### `*.ldjson`

[LDJSON](https://jsonlines.org/) (aka. JSONL or [NDJSON](http://ndjson.org/)) is the common format file type that we use to store results.
It is a plain text file, where each line is a valid [JSON](https://www.json.org/) format.

The basic structure of each line is as follows (indentation and newlines added for clarity).

```
{
    "analysis": str,
    "checksum": str,
    "software": str,
    "software_version": str,
    "database": Optional[str],
    "database_version": Optional[str],
    "pipeline_version": str,
    "data": analysis specific object,
}
```

The `data` field contains the actual results from the analysis, which will be specific to each analysis type.
The fields in `data` will represent parsed elements from the original software output.

Line delimited JSON can be parsed in most programming languages fairly easily.
E.g. in python3

```
import json
results = []
with open("results.ldjson", "r") as handle:
    for line in handle:
        sline = line.strip()
        if sline == "":
            continue
        result = json.loads(sline)
        results.append(result)
```


### `pipeline_info/`

Contains details of how the pipeline ran.
Each file shows run-times, memory and CPU usage etc.



### Linking vs copying results.

By default in Predector the results of the pipeline are copied from the `work` folder to the `results` folder. 
Note that this is **not** the default behaviour for Nextflow pipelines, which instead [symbolically links](https://en.wikipedia.org/wiki/Symbolic_link) results files from the `work` directory, to the specified output directory.
**If you want to recover the default Nextflow behaviour (i.e. symlinking rather than copying results), you can use the `--symlink` parameter.**

Symlinking saves some space and time, but requires a bit of extra care when copying and deleting files.
If you delete the `work` folder you will also be deleting the actual contents of the results, and you'll be left with a pointer to a non-existent file.
**Make sure you copy any files that you want to keep before deleting anything**.

If you use the linux [`cp`](https://linux.die.net/man/1/cp) command to copy results, please **make sure to use the `-L` flag**.
This ensures that you copy the contents of the file rather than just copying another link to the file.
[`rsync`](https://linux.die.net/man/1/rsync) also requires using an `-L` flag to copy the contents rather than a link.
[`scp`](https://linux.die.net/man/1/scp) will always follow links to copy the contents, so no special care is necessary.

If you use a different tool, please make sure that it copies the contents.
