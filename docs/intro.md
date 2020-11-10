Predector is a pipeline to run numerous secretome and fungal effector prediction tools, and to combine them in usable
and informative ways.

The pipeline currently includes: SignalP (3, 4, 5), TargetP (v2), DeepLoc, TMHMM, Phobius, DeepSig, CAZyme finding (with dbCAN), Pfamscan, searches against PHI-base, Pepstats, ApoplastP, LOCALIZER and EffectorP 1 and 2.
These results are summarised as a table that includes most information that would typically be used for secretome analysis.
Effector candidates are ranked using a [learning-to-rank](https://en.wikipedia.org/wiki/Learning_to_rank) machine learning method, which balances the tradeoff between secretion prediction and effector property prediction, with higher-sensitivity, comparable specificity, and better ordering than naive combinations of these features.
We recommend that users incorporate these ranked effector scores with experimental evidence or homology matches to prioritise other more expensive efforts (e.g. cloning or structural modelling).

We hope that predector can become a platform enabling multiple secretome analyses, with a special focus on eukaryotic (currently only Fungal) effector discovery.
We also seek to establish data informed best practises for secretome analysis tasks, where previously there was only a loose consensus, and to make it easy to follow them.

Predector is designed to be run on complete predicted proteomes, as you would get after gene prediction or from databases like uniprot.
Although the pipeline will happily run with processed mature proteins or peptide fragments, the analyses that are run as part of the pipeline are not
intended for this purpose and any results from such input should be considered with **extreme caution**.

