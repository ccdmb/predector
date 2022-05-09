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

### Running with docker `Unable to find image 'predector/predector:X.X.X' locally`

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


### `Connecting to XXX... failed: Connection timed out.`

We automatically download Pfam, dbCAN, and PHI-base by default while running the pipeline.
Sometimes these sources will be unavailable (e.g. for maintenance or they've just crashed),
and sometimes the URLs to these data will change.

It is possible for you to download these data separately, and provide the files to the pipeline as described [here](https://github.com/ccdmb/predector/wiki#providing-pre-downloaded-pfam-phi-base-and-dbcan-datasets).
If you find yourself running the pipeline often it might be a good thing to keep a downloaded copy handy.

In the case that the servers are down, unfortunately we can't do much.
But if the URL appears to have changed, we would appreciate it if you could please let us know so that we can resolve the issue.


### `ERROR ~ unable to resolve class XXX`

You may encounter this error if you are using an old version of Nextflow (pre v21).
We use the updated DSL2 syntax, which will cause older versions of Nextflow to raise errors looking like this...

```
ERROR ~ unable to resolve class download_phibase
@ line 7, column 5.
       download as download_phibase;
       ^

_nf_script_9f2a833e: 8: unable to resolve class download_pfam_hmm
@ line 8, column 5.
       download as download_pfam_hmm;
       ^

_nf_script_9f2a833e: 9: unable to resolve class download_pfam_dat
@ line 9, column 5.
       download as download_pfam_dat;
       ^
```

Please update Nextflow to a more recent version (>21) to resolve this issue.


### Running/setting up conda environment: `loadable library and perl binaries are mismatched (got handshake key 0xdb80080, needed 0xde00080)`

This will usually happen if the operating system you're running on has some perl libraries in the search path for a different version of perl.
Unfortunately because conda environments are not isolated from the host operating system like containers are, there isn't much we can do to avoid this.
The good news is that it's usually an easy fix.

Search your bash environment for `PERL5LIB` or `PERLLIB`. e.g.

```
env | grep -i "perl"
```

If either of these are set, it's likely that this is how perl is finding these incompatible options.
Try `unset`-ing these paths and try running again. e.g.

```
unset PERL5LIB
unset PERLLIB
```


If you are on a computer that uses `module`s to import software (e.g. many HPC clusters), check for any loaded perl modules
as these will usually set the above variables.

```
# Check for and loaded perl modules
module list

# unload any relevant perl modules e.g.
module unload perl
```

**Note** you will need to unset these environment variables anytime you restart
a new terminal session and want to use the conda environment.
Alternatively you can remove the default imports and environment variable settings e.g. in your `~/.bashrc` file to make changes permanent.

If unsetting the variables/unloading modules doesn't work, please let us know and we'll try to resolve the issue.
We'll need info about any set environment variables before and after loading the conda environment, and the specific conda packages installed.

e.g.
```
env > env_before_load.txt
conda activate predector
env > env_after_load.txt

conda list > conda_environment.txt
```


### Error while running signalp 6 `ValueError: zero-size array to reduction operation maximum which has no identity`

This is a known issue with some sequences and certain versions of SignalP 6.
Unfortunately we can't do much about this other than report the troublesome sequence(s) to the developers.

If you contact us or raise an issue we can do that for you.
Please include the sequences that are causing the issue and the exact version of SignalP 6 that you downloaded so that we can be most helpful.
Otherwise if you use GitHub you can raise an issue yourself in [their repository](https://github.com/fteufel/signalp-6.0) (note though that the code that's up there isn't actually what it distributed).
They also list contact emails in their [installation instructions](https://github.com/fteufel/signalp-6.0/blob/main/installation_instructions.md#bugs-and-questions).


As a temporary fix you can either re-run the pipeline using the `--no_signalp6` parameter, which will not run SignalP 6 on any sequences.
Alternatively, you can manually mark this chunk (internally we chunk the input into sets of `--chunk_size` unique sequences (default 5000)) as completed. This will only skip signalp6 for an individual chunk.

1) Find the working directory of the task from the error message.
It will look like this:
```
Work dir:
  /home/ubuntu/predector_analysis/work/7e/954be70138c4c29467945fade280ab
```

2) Set the exit code to 0 and create an empty output file:

```
DIR_CONTAINING_ERROR=/home/ubuntu/predector_analysis/work/7e/954be70138c4c29467945fade280ab

echo "0" > "${DIR_CONTAINING_ERROR}/.exitcode"
touch "${DIR_CONTAINING_ERROR}/out.ldjson"
```

3) Re-run the pipeline as you did before with the `-resume` option.

This should restart the pipeline and continue as if SignalP 6 hadn't failed (though it may still fail on a different chunk).
Note however that if you skip the analysis for one chunk, the manual ranking scores (and probably the learned ranking scores in the near future) won't be reliable (because the other chunks will have more information).


### Error while running a process with `Command exit status: 137`

The error-code usually means that you have run out of memory in a task.
At the time of writing this seems to happen when running SignalP 6 on relatively small computers (e.g. with <6GB RAM available).

General strategies for reducing memory usage are to reduce the `--chunk_size` to below 1000 (say 500).
Specifically for SignalP 6 you can also try reducing the `--signalp6_bsize` to 10.
You can read more about these parameters in the [Command line parameters section](#command-line-parameters).

If you encounter this issue in the final steps when producing the output and ranking tables, it may be the case that one of your input fasta files is very large.
As noted in the [running the pipeline section](#running-the-pipeline), Predector was designed to handle typical proteomes.
The number of proteomes doesn't really matter because internally we deduplicate and divide the inputs into chunks, but if one single input fasta has say >10e5 proteins, this can cause an issue if you don't have lots of RAM (I find that about 30GB is needed for a few million proteins).
If your proteins aren't split into proteomes (e.g you're running on a set downloaded from UniProt), it's best to split them yourself to batches of about 20000, and then concatenate the final tables yourself. We can guide you through dealing with this to make use of what you have already computed, so please get in touch.

If you encounter this issue with other processes please let us know.
We've done our best to keep peak memory use low for most tasks, but there may be cases that we hadn't considered.


### Installing with Mamba, `Problem: nothing provides __glibc >=2.17,<3.0.a0 needed by...`

This appears to happen with very old versions of Mamba, and was reported to us [here](https://github.com/ccdmb/predector/issues/77).
It appears that simply updating mamba will fix the problem.

```
conda update -n base -c conda-forge mamba
```

If this does not resolve the problem, please raise another [issue](https://github.com/ccdmb/predector/issues) or [contact us](https://github.com/ccdmb/predector#contact-us).


## FAQ

We'll update these as we find new issues and get feedback.
Please raise an issue on GitHub or email us if you have an issue not covered here.

### What do Predector "effector scores" actually mean?

It's best to think of the learning to rank scores (and the manually designed ranking scores) as arbitrary numbers that attempt to make effectors appear near the top of a sorted list.
The scores will not be consistent between different versions of the model, so please be careful if you're trying to compare scores.
Similarly, like with EffectorP the scores should not be treated as a 'likelihood'.
Although you can generally say that proteins with higher scores will be more like known effectors, the difference in "effector-ness" between 0 and 1 is not necessarily the same as it is between 1 and 2 (and so on).

In the paper for version 1 we present some comparisons with EffectorP classification using a score threshold of 0, but this is not how we suggest you use these scores and the threshold may not be applicable in the future if we change how the model is trained.
In general, it's best to look at some additional evidence (e.g. homologues, expression, or presence-absence) and manually evaluate candidates in descending order of score (i.e. using Predector as a decision support system) until you have enough to work with.

In the first version of the model, the predictions between 0 and 1 can contain some odd effector predictions.
This is because the model has tried to accomodate some unusual effectors, but the decision tree rules (with discontinuous boundaries) can let some things through that obviously aren't effectors.
If you delve into the proteins with lower scores we recommended that you manually evaluate the protein properties in the ranking sheet yourself to select candidates.

With Predector we really wanted to encourage you to look at your data.
Ranking separates the bulk of good proteins from bad ones, so it's easier to decide when to stop manually evaluating candidates and settle on a list.
Think of it like searching for papers on the web.
The first page usually contains something relevant to what you're interested in, but sometimes there are some gems in the 2nd and 3rd pages.


### How should I cite Predector?

The Predector pipeline and ranking method is published in [scientific reports](https://doi.org/10.1038/s41598-021-99363-0):

Darcy A. B. Jones, Lina Rozano, Johannes W. Debler, Ricardo L. Mancera, Paula M. Moolhuijzen, James K. Hane (2021). An automated and combinative method for the predictive ranking of candidate effector proteins of fungal plant-pathogens. _Scientific Reports_. 11, 19731, DOI: [10.1038/s41598-021-99363-0](https://doi.org/10.1038/s41598-021-99363-0)

Please also cite the dependencies that we use whenever possible.
I understand that citation limits can be an issue, but the continued maintenance development of tools relies on these citations.
If you absolutely must prioritise, I'd suggest keeping EffectorP, ApoplastP, Deepredeff, TargetP, TMHMM, and one of the SignalP papers, as these do most of the heavy lifting in the pipeline.
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
- Kristianingsih, R., MacLean, D. (2021). Accurate plant pathogen effector protein classification ab initio with deepredeff: an ensemble of convolutional neural networks. BMC Bioinformatics 22, 372. https://doi.org/10.1186/s12859-021-04293-3
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

