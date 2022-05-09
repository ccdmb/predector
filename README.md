# Predector

Predict effectors in your proteomes using the Predector!

Predector runs numerous tools for fungal secretome and effector discovery analysis, and outputs a list of ranked candidates.

This includes: SignalP (3, 4, 5, 6), TargetP (v2), DeepLoc, TMHMM, Phobius, DeepSig, CAZyme finding (with dbCAN), Pfamscan, searches against PHI-base, Pepstats, ApoplastP, LOCALIZER, Deepredeff, and EffectorP 1, 2 and 3.
These results are summarised as a table that includes most information that would typically be used for secretome analysis.
Effector candidates are ranked using a [learning-to-rank](https://en.wikipedia.org/wiki/Learning_to_rank) machine learning method, which balances the tradeoff between secretion prediction and effector property prediction, with higher-sensitivity, comparable specificity, and better ordering than naive combinations of these features.

The Predector rank score offers a useful way of sorting your proteomes or subsets of proteomes to separate the bulk of proteins from those with effector-like characteristics (e.g. secreted, small etc).
The rank scores lend themselves well to evaluating candidates in a spreadsheet (i.e by sorting by the score column) and offer a logical place to start looking at your "top" candidates, and guide when to stop evaluating candidates in the list as they become less relevant.
We recommend that users incorporate these ranked effector candidates with experimental evidence or homology matches, and manually evaluate candidates with regard to the targeted host-pathogen interaction to prioritise other more expensive efforts (e.g. cloning or structural modelling).
For example, you might take a set of differentially expressed genes from an RNAseq experiment, and evaluate candidates for experimental follow up from this set in descending order of Predector rank.

We hope that this pipeline can become a platform enabling multiple secretome analyses, with a special focus on eukaryotic (currently only Fungal) effector discovery.


We would welcome any feedback, suggestions, questions, issue reports or even just you letting us know if you're using the pipeline. You can create an [issue](https://github.com/ccdmb/predector/issues) or [discussion](https://github.com/ccdmb/predector/discussions) on GitHub.
Alternatively you can find more contact details at the [bottom of this page](#contact-us).


## Citation and further information
The Predector pipeline and ranking method is described [here](https://doi.org/10.1038/s41598-021-99363-0):

Darcy A. B. Jones, Lina Rozano, Johannes W. Debler, Ricardo L. Mancera, Paula M. Moolhuijzen, James K. Hane (2021). An automated and combinative method for the predictive ranking of candidate effector proteins of fungal plant pathogens. _Scientific Reports_. 11, 19731, DOI: [10.1038/s41598-021-99363-0](https://doi.org/10.1038/s41598-021-99363-0)

If you do use results of Predector in your manuscripts please also cite the dependencies, especially EffectorP and other niche tools.
Predector ranking does not replace these tools, it is designed to combine information from multiple tools in a useful way.
We rely heavily on these tools and they should be supported with citations to enable their continued development.

More details on dependencies are available in [the wiki](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#how-should-i-cite-predector) and we provide a [BibTeX](http://www.bibtex.org/Format/) formatted [file with citations](https://github.com/ccdmb/predector/citations.bib), which can be imported into most citation managers.


## Documentation

Brief instructions are presented on this page, but extended documentation can be found on the project [Wiki page](https://github.com/ccdmb/predector/wiki).

Quick documentation links:

- [Quick install instructions](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#quick-install)
- [Extended install instructions](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#extended-dependency-install-guide)
- [Usage](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#running-the-pipeline)
- [Description of outputs](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#pipeline-output)
- [Common issues](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#common-issues)
- [FAQ](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#faq)


If you have any questions, think that some documentation is missing, or have any other suggestions or issues to report, please feel free to create an [issue](https://github.com/ccdmb/predector/issues) or start a [discussion](https://github.com/ccdmb/predector/discussions).


## Install

This is a quick install guide that unfortunately isn't terribly quick.
For extended documentation and troubleshooting advice, see the [Wiki install documentation](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#quick-install).

**Note that if you have run a previous version of the pipeline, you will need to re-build
the software environment, as the dependencies may have changed.**
Please see the [Wiki install documentation](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#optional---remove-previous-software-environments-for-old-versions-of-the-pipeline) for more details.


### Minimal requirements

- 4 CPUs
- 8 GB RAM
- About 20-30 GB of free disk space (~15 GB for all of the software).
- A bash terminal in a unix-type environment, we primarily test on the current ubuntu LTS.


### 1. Install Conda, Docker, or Singularity

We provide automated ways of installing dependencies using [conda](https://docs.conda.io/en/latest/) environments (linux OS only), or [docker](https://www.docker.com/why-docker) or [singularity](https://sylabs.io/singularity/) containers.

Please follow the instructions at one of the following links to install:

- https://conda.io/projects/conda/en/latest/user-guide/install/linux.html
- https://docs.docker.com/engine/install/
- https://sylabs.io/guides/

If you'd like to speed up building conda environments, we also support [mamba](https://github.com/mamba-org/mamba).

> We cannot support conda (or mamba) environments on Mac or Windows.
> This is because some older software in e.g. SignalP 3 and 4 is not compiled for these operating systems, and being closed source we cannot re-compile them.
> Even windows WSL2 does not seem to play well with SignalP 4.
>
> Please use a full Linux virtual machine (e.g. a cloud server or locally in [VirtualBox](https://www.virtualbox.org/)) or one of the containerised options.

### 2. Download the proprietary software dependencies

Predector runs several tools that we cannot download for you automatically.
Please register for and download each of the following tools, and place them all somewhere that you can access from your terminal.
Where you have a choice between versions for different operating systems, you should always take the **Linux** version (even if using Mac or Windows).

- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-3.0/9-Downloads.php#) version 3.0
- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-4.1/9-Downloads.php#) version 4.1g
- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-5.0/9-Downloads.php#) version 5.0b
- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-6.0/9-Downloads.php#) version 6.0g "fast" **\*currently optional**
- [TargetP](https://services.healthtech.dtu.dk/services/TargetP-2.0/9-Downloads.php#) version 2.0
- [DeepLoc](https://services.healthtech.dtu.dk/services/DeepLoc-1.0/9-Downloads.php#) version 1.0
- [TMHMM](https://services.healthtech.dtu.dk/services/TMHMM-2.0/9-Downloads.php#) version 2.0c
- [Phobius](http://software.sbc.su.se/cgi-bin/request.cgi?project=phobius) version 1.01

Note that DTU (SignalP etc) don't keep older patches and minor versions available.
If the specified version isn't available to download, another version with the same major number _should_ be fine.
But please also let us know that the change has happened, so that we can update documentation and make sure our installers handle them correctly.

I suggest storing these all in a folder and just copying the whole lot around.
If you use Predector often, you'll likely re-build the environment fairly often.

> We've been having some teething problems with SignalP 6. Until this is resolved I've made installing and running it optional.
> You don't have to install SignalP6, though I recommend you try to.

### 3. Build the conda environment or container

We provide an install script that should install the dependencies for the majority of users.

In the following command, substitute the assigned value of `ENVIRONMENT` for `conda`, `mamba`, `docker`, or `singularity` as suitable.
Make sure you're in the same directory as the proprietary source archives.
If the names below don't match the filenames you have exactly, adjust the command accordingly.
For singularity and docker container building you may be prompted for your root password (via `sudo`).

```bash
ENVIRONMENT=docker

curl -s "https://raw.githubusercontent.com/ccdmb/predector/1.2.6-alpha/install.sh" \
| bash -s "${ENVIRONMENT}" \
    -3 signalp-3.0.Linux.tar.Z \
    -4 signalp-4.1g.Linux.tar.gz \
    -5 signalp-5.0b.Linux.tar.gz \
    -6 signalp-6.0g.fast.tar.gz \
    -t targetp-2.0.Linux.tar.gz \
    -d deeploc-1.0.All.tar.gz \
    -m tmhmm-2.0c.Linux.tar.gz \
    -p phobius101_linux.tar.gz
```

This will create the conda environment (named `predector`), or the docker (tagged `predector/predector:1.2.6-alpha`) or singularity (file `./predector.sif`) containers.

**Take note of the message given upon completion**, which will tell you how to use the container or environment with predector.

If you don't want to install SignalP 6 you can exclude the `-6 filename.tar.gz` argument.

If you have issues during installation or want to customise where things are built, please consult the extended documentation.
Or save the install script locally and run `install.sh --help`.


### 4. Install NextFlow

NextFlow requires a bash compatible terminal, and Java version 8+.
We require NextFlow version 21 or above.
Extended install instructions available at: [https://www.nextflow.io/](https://www.nextflow.io).

```bash
curl -s https://get.nextflow.io | bash
```

Or using conda:

```bash
conda install -c bioconda nextflow>=21
```

### 5. Test the pipeline

Use one of the commands below using information given upon completion of dependency install script.

#### Using conda

```bash
nextflow run -profile test -with-conda /home/username/path/to/environment -resume -r 1.2.6-alpha ccdmb/predector
```

#### Using docker

```bash
nextflow run -profile test,docker -resume -r 1.2.6-alpha ccdmb/predector

# if your docker configuration requires sudo use this profile instead
nextflow run -profile test,docker_sudo -resume -r 1.2.6-alpha ccdmb/predector
```

#### Using singularity

```bash
nextflow run -profile test -with-singularity path/to/predector.sif -resume -r 1.2.6-alpha ccdmb/predector

# or if you've build the container using docker and it's in your local docker registry.
nextflow run -profile test,singularity -resume -r 1.2.6-alpha ccdmb/predector
```

## Quickstart

Say you have a set of amino-acid sequences in fasta format in the directory `proteomes`.
The following command will run the complete analysis and the results will be available in a `results` folder.

```bash
nextflow run -resume -r 1.2.6-alpha ccdmb/predector --proteome "proteomes/*"
```

To improve performance I strongly recommend specifying an appropriate profile for the computer you're running the pipeline on.
You can find information on available profiles in the [wiki documentation](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#profiles-and-configuration).


**Please note that if you have previously run a different version of the pipeline on the same computer you will need to ask Nextflow to pull the latest changes.**
See how to do this in the [extended documentation](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#running-different-pipeline-versions) and the [common issues section](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#common-issues).


## Outputs

The main output of Predector is a file with the suffix `-ranked.tsv` which is a tab separated values file that can be opened in excel.
This contains a summarised version of all of the information that you would typically need for evaluating effector protein candidates.

You can find a description of all of the results in [the wiki](https://github.com/ccdmb/predector/wiki/1.2.6-alpha#pipeline-output).

An example set of results is available in the [`test` directory on github](https://github.com/ccdmb/predector/tree/1.2.6-alpha/test/test_set_results).


## Contributing

We're aware that basically every bioinformatician working with pathogens has written some version of this pipeline.
If you're willing, we'd really like for you to help us make this pipeline better.

If you have an analysis that you think should be included, know of better parameters, or think the documentation could be better, please get involved!

If you are a person working on non-fungal plant-pathogens we'd love for you to get in touch.
These methods should apply equally well for Oomycete (etc...) effector discovery, but our expertise is in fungal pathology.
If you can help us understand the needs of your research community, and what proteins you are interested in (perhaps beyond RxLR effectors), we'd really love to collaborate.

We'll make sure that appropriate credit is given, potentially including future authorship for more substantial contributions.
It would be lovely to develop a bit of a community around this thing :)

See the [CONTRIBUTING](CONTRIBUTING.md) page for some details on how we do things, or just send us an email or raise a github issue to introduce yourself.


## Contact us

This pipeline is being developed by several people at the [CCDM](http://ccdm.com.au/).
The primary email contact for now should be Darcy Jones <darcy.ab.jones@gmail.com>.
You can also raise an issue on GitHub to ask a question or introduce yourself.
