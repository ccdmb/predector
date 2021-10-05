## Common issues

### `` Cannot find revision `X.X.X` -- Make sure that it exists in the remote repository `https://github.com/ccdmb/predector` ``

All of our code examples specify the pipeline version number, which is to ensure that the correct dependencies are used and it's always clear what is actually being run.

Unfortunately this can cause a few issues if you have previously run the pipeline using the same computer.
You can read about this in more detail in the section "[Running different pipeline versions](#running-different-pipeline-versions)".

Try the following steps to resolve the issue.

1. Double check that the specified version number is actually a tagged version of the pipeline (https://github.com/ccdmb/predector/tags).
2. Try re-running the pipeline with the `-latest` flag included. i.e. `nextflow run -r X.X.X -latest ccdmb/predector --proteome "proteomes/*"`.
3. Try pulling the updates down from GitHub with nextflow directly with the following command: `nextflow pull ccdmb/predector`. Then try re-running the pipeline.
4. Try asking nextflow to delete it's local copy of Predector from its cache with the following command: `nextflow drop ccdmb/predector`. Then try re-running the pipeline.

If you're still having problems after this, please either email us or raise an issue on GitHub.

### Running with docker `Unable to find image 'predector/predector:1.1.0-beta.1' locally`

This usually means that you haven't built the docker image locally.
Remember that we cannot distribute some of the dependencies, so you need to build the container image and move it to where you'll be running.

Please check that you have the docker container in your local registry:

```bash
docker images
```

It's also possible that you built a different environment (e.g. conda or singularity).
Check `conda info -e` or for any `.sif` files where your source archives are.

Another possibility is that you are trying to run the pipeline using a container built for a different version of the pipeline.
Please check that the version tag in `docker images` is the same as the pipeline that you're trying to run.
Update the pipeline if necessary using `nextflow pull ccdmb/predector`.


### Running with singularity `ERROR : Failed to set loop flags on loop device: Resource temporarily unavailable`.

This is caused by nextflow trying to launch lots of tasks with the same singularity image at the same time.
Updating singularity to version >= 3.5 _should_ resolve the issue.


## FAQ

We'll update these as we find new issues and get feedback.
Please raise an issue on GitHub or email us if you have an issue not covered here.

### What do predector "effector scores" actually mean?

It's best to think of the learning to rank scores (and the manually designed ranking scores) as arbitrary numbers that attempt to make effectors appear near the top of a sorted list.
The scores will not be consistent between different versions of the model, so please be careful if you're trying to compare scores.
Similarly, like with EffectorP the scores should not be treated as a 'likelihood'.
Although the you can generally say that proteins with higher scores will be more like known effectors, the difference in "effector-ness" between 0 and 1 is not necessarily the same as it is between 1 and 2 (and so on).

In the upcoming paper for version 1 we present some comparisons with EffectorP classification using a score threshold of 0, but this is not how we suggest you use these scores and the threshold may not be applicable in the future if we change how the model is trained.
In general, it's best to look at some additional evidence (e.g. homologues or presence-absence) and manually evaluate candidates in descending order of score (i.e. using predector as a decision support system) until you have enough to work with.

In the first version of the model, the predictions between 0 and 1 can contain some odd effector predictions (e.g. NRPS genes).
This is because the model has tried to accomodate some unusual effectors, but the decision tree rules (with discontinuous boundaries) can let some things through that obviously aren't effectors.
If you delve into the proteins with lower scores we recommended that you manually evaluate the protein properties in the ranking sheet yourself to select candidates.

With predector we really wanted to encourage you to look at your data.
Ranking separates the bulk of good proteins from bad ones, so a it's easier to decide when to stop manually evaluating candidates and settle on a list.
Think of it like searching for papers on the web.
The first page usually contains something relevant to what you're interested in, but sometimes there are some gems in the 2nd and 3rd pages.

### How should I cite predector?

Predector isn't published yet though the manuscript is near submission.
In the mean time, the url to the main GitHub repository will be fine <https://github.com/ccdmb/predector>.

Please also cite the dependencies that we use whenever possible.
I understand that citation limits can be an issue, but the continued maintenance development of tools relies on these citations.
There is a [BibTeX](http://www.bibtex.org/Format/) formatted [file with citations in the main github repository](https://github.com/ccdmb/predector/citations.bib), which can be imported into most citation managers.
The dependency citations are also listed below.

- Almagro Armenteros, J. J., Sønderby, C. K., Sønderby, S. K., Nielsen, H., & Winther, O. (2017). DeepLoc: Prediction of protein subcellular localization using deep learning. Bioinformatics, 33(21), 3387–3395. https://doi.org/10.1093/bioinformatics/btx431
- Armenteros, Jose Juan Almagro, Salvatore, M., Emanuelsson, O., Winther, O., Heijne, G. von, Elofsson, A., & Nielsen, H. (2019). Detecting sequence signals in targeting peptides using deep learning. Life Science Alliance, 2(5). https://doi.org/10.26508/lsa.201900429
- Armenteros, José Juan Almagro, Tsirigos, K. D., Sønderby, C. K., Petersen, T. N., Winther, O., Brunak, S., Heijne, G. von, & Nielsen, H. (2019). SignalP 5.0 improves signal peptide predictions using deep neural networks. Nature Biotechnology, 37(4), 420–423. https://doi.org/10.1038/s41587-019-0036-z
- Di Tommaso, P., Chatzou, M., Floden, E. W., Barja, P. P., Palumbo, E., & Notredame, C. (2017). Nextflow enables reproducible computational workflows. Nature Biotechnology, 35(4), 316–319. https://doi.org/10.1038/nbt.3820
- Dyrløv Bendtsen, J., Nielsen, H., von Heijne, G., & Brunak, S. (2004). Improved Prediction of Signal Peptides: SignalP 3.0. Journal of Molecular Biology, 340(4), 783–795. https://doi.org/10.1016/j.jmb.2004.05.028
- Eddy, S. R. (2011). Accelerated Profile HMM Searches. PLOS Computational Biology, 7(10), e1002195. https://doi.org/10.1371/journal.pcbi.1002195
- Finn, R. D., Bateman, A., Clements, J., Coggill, P., Eberhardt, R. Y., Eddy, S. R., Heger, A., Hetherington, K., Holm, L., Mistry, J., Sonnhammer, E. L. L., Tate, J., & Punta, M. (2014). Pfam: The protein families database. Nucleic Acids Research, 42(Database issue), D222–D230. https://doi.org/10.1093/nar/gkt1223
- Teufel, F., Armenteros, J. A. A., Johansen, A. R., Gíslason, M. H., Pihl, S. I., Tsirigos, K. D., Winther, O., Brunak, S., von Heijne, G., & Nielsen, H. (2021). SignalP 6.0 achieves signal peptide prediction across all types using protein language models. bioRxiv. https://doi.org/10.1101/2021.06.09.447770
- Käll, L., Krogh, A., & Sonnhammer, E. L. L. (2004). A Combined Transmembrane Topology and Signal Peptide Prediction Method. Journal of Molecular Biology, 338(5), 1027–1036. https://doi.org/10.1016/j.jmb.2004.03.016
- Krogh, A., Larsson, B., von Heijne, G., & Sonnhammer, E. L. (2001). Predicting transmembrane protein topology with a hidden Markov model: Application to complete genomes. Journal of Molecular Biology, 305(3), 567–580. https://doi.org/10.1006/jmbi.2000.4315
- Petersen, T. N., Brunak, S., Heijne, G. von, & Nielsen, H. (2011). SignalP 4.0: Discriminating signal peptides from transmembrane regions. Nature Methods, 8(10), 785–786. https://doi.org/10.1038/nmeth.1701
- Rice, P., Longden, I., & Bleasby, A. (2000). EMBOSS: The European Molecular Biology Open Software Suite. Trends in Genetics, 16(6), 276–277. https://doi.org/10.1016/S0168-9525(00)02024-2
- Savojardo, C., Martelli, P. L., Fariselli, P., & Casadio, R. (2018). DeepSig: Deep learning improves signal peptide detection in proteins. Bioinformatics, 34(10), 1690–1696. https://doi.org/10.1093/bioinformatics/btx818
- Sperschneider, J., Catanzariti, A.-M., DeBoer, K., Petre, B., Gardiner, D. M., Singh, K. B., Dodds, P. N., & Taylor, J. M. (2017). LOCALIZER: Subcellular localization prediction of both plant and effector proteins in the plant cell. Scientific Reports, 7(1), 1–14. https://doi.org/10.1038/srep44598
- Sperschneider, J., Dodds, P. N., Gardiner, D. M., Singh, K. B., & Taylor, J. M. (2018). Improved prediction of fungal effector proteins from secretomes with EffectorP 2.0. Molecular Plant Pathology, 19(9), 2094–2110. https://doi.org/10.1111/mpp.12682
- Sperschneider, J., Dodds, P. N., Singh, K. B., & Taylor, J. M. (2018). ApoplastP: Prediction of effectors and plant proteins in the apoplast using machine learning. New Phytologist, 217(4), 1764–1778. https://doi.org/10.1111/nph.14946
- Sperschneider, J., Gardiner, D. M., Dodds, P. N., Tini, F., Covarelli, L., Singh, K. B., Manners, J. M., & Taylor, J. M. (2016). EffectorP: Predicting fungal effector proteins from secretomes using machine learning. New Phytologist, 210(2), 743–761. https://doi.org/10.1111/nph.13794
- Sperschneider, J., & Dodds, P. N. (2021). EffectorP 3.0: prediction of apoplastic and cytoplasmic effectors in fungi and oomycetes. bioRxiv. https://doi.org/10.1101/2021.07.28.454080
- Steinegger, M., & Söding, J. (2017). MMseqs2 enables sensitive protein sequence searching for the analysis of massive data sets. Nature Biotechnology, 35(11), 1026–1028. https://doi.org/10.1038/nbt.3988
- Tange, O. (2020). GNU Parallel 20200522 ('Kraftwerk'). Zenodo. https://doi.org/10.5281/zenodo.3841377
- Urban, M., Cuzick, A., Seager, J., Wood, V., Rutherford, K., Venkatesh, S. Y., De Silva, N., Martinez, M. C., Pedro, H., Yates, A. D., Hassani-Pak, K., & Hammond-Kosack, K. E. (2020). PHI-base: The pathogen–host interactions database. Nucleic Acids Research, 48(D1), D613–D620. https://doi.org/10.1093/nar/gkz904
- Zhang, H., Yohe, T., Huang, L., Entwistle, S., Wu, P., Yang, Z., Busk, P. K., Xu, Y., & Yin, Y. (2018). dbCAN2: A meta server for automated carbohydrate-active enzyme annotation. Nucleic Acids Research, 46(W1), W95–W101. https://doi.org/10.1093/nar/gky418

