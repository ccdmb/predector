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

...

I'll add this when we're sure that the format we have is ok.


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
