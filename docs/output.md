# Output

Predector output several files for each input file that you provide, and some additional ones that can be useful for debugging results.

Results will always be placed under the directory specified by the parameter `--outdir` (`./results` by default).

Downloaded databases (i.e. Pfam and dbCAN) are stored in the `downloads` subdirectory.
Deduplicated sequences and a tab-separated values file mapping the deduplicated sequence ids to their filenames and original ids is in the `deduplicated` subdirectory.

Other directories will be named after the input filenames and each contain several tables.

## `*-ranked.tsv`

This is the main output table that includes the scores and most of the parameters that are important for effector or secretion prediction.
There are a lot of columns, though generally you'll only be interested in a few of them.

1. seqid -- The protein name in the fasta you provided.
2. effector_score -- Float. The predector machine learning effector score for this protein.
3. manual_effector_score -- Float. The manually created effector score, which is the sum of the products of several values in this spreadsheet. Consult the paper for details.
4. manual_secretion_score -- Float. The manually created secretion score, which is the sum of the products of several values in this spreadsheet.
5. phibase_effector -- Boolean \[0, 1\] indicating whether the protein had a significant hit to one of the phibase phenotypes: Effector, Hypervirulence, or loss of pathogenicity.
6. phibase_virulence -- Boolean \[0, 1\] indicating whether the protein had a significant hit with the phenotype "reduced virulence".
7. phibase_lethal -- Boolean \[0, 1\] indicating whether the protein had a significant hit with the phenotype "lethal".
8. phibase_phenotypes -- A comma separated list of the PHI-base phenotypes in the significant hits to PHI-base.
9. phibase_matches -- A comma separated list of the PHI-base entries that were significant hits.
10. effector_match -- Boolean \[0, 1\] indicating whether the protein had a significant hit in the predector curated set of fungal effectors. 
11. effector_matches -- A comma separated list of the matches to the curated set of fungal effectors.
12. pfam_match -- Boolean \[0, 1\] indicating whether the protein had a significant hit to one of the selected Pfam HMMs associated with virulence function.
13. pfam_matches -- A comma separated list of all Pfam HMMs matched.
14. dbcan_match -- Boolean \[0, 1\] indicating whether the protein had a significant hit to one of the dbCAN domains associated with virulence function. 
15. dbcan_matches -- A comma separated lst of all dbCAN matches.
16. effectorp1 -- Float. The raw EffectorP v1 prediction pseudo-probability. Values above 0.5 are considered to be effector predictions.
17. effectorp2 -- Float. The raw EffectorP v2 prediction pseudo-probability. Values above 0.5 are considered to be effector predictions. Values below 0.6 are annotated in the raw EffectorP output as "unlikely effectors".
18. is_secreted -- Boolean \[0, 1\] indicating whether the protein had a signal peptide predicted by any method, and does not have >=2 transmembrane domains predicted by either TMHMM or Phobius.
19. any_signal_peptide -- Boolean \[0, 1\] indicating whether any of the signal peptide prediction methods predict the protein to have a signal peptide.
20. apoplastp -- Float. The raw ApoplastP "apoplast" localised prediction pseudo probability. Values above 0.5 are considered to be apoplastically localised.
21. single_transmembrane -- Boolean \[0, 1\] indicating whether the protein is predicted to have 1 transmembrane domain by TMHMM or Phobius (and not >1 for either), and in the case of TMHMM the predicted number of TM AAs in the first 60 residues is less than 10.
22. multiple_transmembrane -- Boolean \[0, 1\] indicating whether a protein is predicted to have more than 1 transmembrane domain by either Phobius or TMHMM.
23. molecular_weight -- Float. The predicted molecular weight (Daltons) of the protein.
24. residue_number -- Integer. The length of the protein or number of residues/AAs.
25. charge -- Float. The overall predicted charge of the protein.
26. isoelectric_point -- Float. The predicted isoelectric point of the protein.
27. aa_c_number -- Integer. The number of Cysteine residues in the protein.
28. aa_tiny_number -- Integer. The number of tiny residues (A, C, G, S, or T) in the protein.
29. aa_small_number -- Integer. The number of small residues (A, B, C, D, G, N, P, S, T, or V) in the protein.
30. aa_aliphatic_number -- Integer. The number of aliphatic residues (A, I, L, or V) in the protein.
31. aa_aromatic_number -- Integer. The number of aromatic residues (F, H, W, or Y) in the protein.
32. aa_nonpolar_number -- Integer. The number of non-polar residues (A, C, F, G, I, L, M, P, V, W, or Y) in the protein.
33. aa_charged_number -- Integer. The number of charged residues (B, D, E, H, K, R, or Z) in the protein.
34. aa_basic_number -- Integer. The number of basic residues (H, K, or R) in the protein.
35. aa_acidic_number -- Integer. The number of acidic residues (B, D, E or Z) in the protein.
36. fykin_gap -- Float. The number of FYKIN residues + 1 divided by the number of GAP residues + 1. [Testa et al. 2016](https://doi.org/10.1093/gbe/evw121) describe RIP affected regions as being enriched for FYKIN residues, and depleted in GAP residues.
37. localizer_nuclear -- Boolean \[0, 1\] or None '.' indicating whether localiser predicted an internal nuclear localisation peptide. These predictions are run on mature peptides predicted by SignalP 5. Any entry with '.' indicates where the program was not run.
38. localizer_chloro -- Boolean \[0, 1\] or None '.' indicating whether localiser predicted an internal chloroplast localisation peptide. These predictions are run on mature peptides predicted by SignalP 5. Any entry with '.' indicates where the program was not run.
39. localizer_mito -- Boolean \[0, 1\] or None '.' indicating whether localiser predicted an internal mitochondrial localisation peptide. These predictions are run on mature peptides predicted by SignalP 5. Any entry with '.' indicates where the program was not run.
40. signalp3_nn -- Boolean \[0, 1\] indicating whether the protein is predicted to have a signal peptide by the neural network model in SignalP 3.
41. signalp3_hmm -- Boolean \[0, 1\] indicating whether the protein is predicted to have a signal peptide by the HMM model in SignalP 3.
42. signalp4 -- Boolean \[0, 1\] indicating whether the protein is predicted to have a signal peptide by SignalP 4.
43. signalp5 -- Boolean \[0, 1\] indicating whether the protein is predicted to have a signal peptide by SignalP 5.
44. deepsig -- Boolean \[0, 1\] indicating whether the protein is predicted to have a signal peptide by DeepSig.
45. phobius_sp -- Boolean \[0, 1\] indicating whether the protein is predicted to have a signal peptide by Phobius.
46. phobius_tmcount -- Integer. The number of transmembrane domains predicted by Phobius.
47. tmhmm_tmcount -- Integer. The number of transmembrane domains predicted by TMHMM.
48. tmhmm_first_60 -- Float. The predicted number of transmembrane AAs in the first 60 residues of the protein by TMHMM.
49. tmhmm_exp_aa -- Float. The predicted number of transmembrane AAs in the protein by TMHMM.
50. tmhmm_first_tm_sp_coverage -- Float. The proportion of the first predicted TM domain that overlaps with the median predicted signal-peptide cut site. Where no signal peptide or no TM domains are predicted, this will always be 0.
51. targetp_secreted -- Boolean \[0, 1\] indicating whether TargetP 2 predicts the protein to be secreted.
52. targetp_secreted_prob -- Float. The TargetP pseudo-probability of secretion.
53. targetp_mitochondrial_prob -- Float. The TargetP pseudo-probability of mitochondrial localisation.
54. deeploc_membrane -- Float. DeepLoc pseudo-probability of membrane association.
55. deeploc_nucleus -- Float. DeepLoc pseudo-probability of nuclear localisation. Note that all DeepLoc values other than "membrane" are from the same classifier, so the sum of all of the pseudo-probabilities will be 1.
56. deeploc_cytoplasm -- Float. DeepLoc pseudo-probability of cytoplasmic localisation.
57. deeploc_extracellular -- Float. DeepLoc pseudo-probability of extracellular localisation.
58. deeploc_mitochondrion -- Float. DeepLoc pseudo-probability of mitochondrial localisation.
59. deeploc_cell_membrane -- Float. DeepLoc pseudo-probability of cell membrane localisation.
60. deeploc_endoplasmic_reticulum -- Float. DeepLoc pseudo-probability of ER localisation.
61. deeploc_plastid -- Float. DeepLoc pseudo-probability of plastid localisation.
62. deeploc_golgi -- Float. DeepLoc pseudo-probability of golgi apparatus localisation.
63. deeploc_lysosome -- Float. DeepLoc pseudo-probability of lysosomal localisation.
64. deeploc_peroxisome -- Float. DeepLoc pseudo-probability of peroxisomal localisation.
65. signalp3_nn_d -- Float. The raw D-score for the SignalP 3 neural network.
66. signalp3_hmm_s -- Float. The raw S-score for the SignalP 3 HMM predictor.
67. signalp4_d -- Float. The raw D-score for SignalP 4. See discussion of choosing multiple thresholds in the [SignalP FAQs](https://services.healthtech.dtu.dk/service.php?SignalP-5.0).
68. signalp5_prob -- Float. The SignalP 5 signal peptide pseudo-probability.


## `*.gff3`

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


## Individual results tables

There are a bunch of tables that are just TSV versions of the original outputs.
Most of the tools outputs are not well described and not in convenient formats for parsing so we don't keep them around.
We've done our best to retain all of the information in the original formats as a TSV version.

The original formats are described in:

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
