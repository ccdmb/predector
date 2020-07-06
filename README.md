# predector

Predict effectors in your proteomes using the Predector!

Predector runs numerous tools for fungal secretome and effector discovery analysis, and outputs a list of ranked candidates.

This includes: SignalP (3, 4, 5), TargetP (v2), DeepLoc, TMHMM, Phobius, DeepSig, CAZyme finding (with dbCAN), Pfamscan, searches against PHI-base, Pepstats, ApoplastP, LOCALIZER and EffectorP 1 and 2.
These results are summarised as a table that includes most information that would typically be used for secretome analysis.
Effector candidates are ranked using a novel [learning-to-rank](https://en.wikipedia.org/wiki/Learning_to_rank) machine learning method, which balances the tradeoff between secretion prediction and effector property prediction, with higher-sensitivity, comparable specificity, and better ordering than naive combinations of these features.
We recommend that incorporate these ranked effector scores with experimental evidence or homology matches to prioritise other more expensive efforts (e.g. cloning or structural modelling).

We hope that this pipeline can become a platform enabling multiple secretome analyses, with a special focus on eukaryotic (currently only Fungal) effector discovery.


**WARNING: This pipeline is currently still in fairly early development. Some documentation may be incomplete, and software may not perform as expected. Get in contact if you're really keen to continue.**


## Install

This is a quick install guide that unfortunately isn't terribly quick.
For extended documentation and troubleshooting advice, see the [install documentation](https://github.com/ccdmb/predector/blob/master/docs/install.md).


### 1. Install Conda, Docker, or Singularity

We provide automated ways of installing dependencies using [conda](https://docs.conda.io/en/latest/) environments (linux OS only), or [docker](https://www.docker.com/why-docker) or [singularity](https://sylabs.io/singularity/) containers.

Please follow the instructions at one of the following links to install:

- https://conda.io/projects/conda/en/latest/user-guide/install/linux.html
- https://docs.docker.com/engine/install/
- https://sylabs.io/guides/


NB. We cannot support conda environments on Mac or Windows.
Please use a Linux virtual machine or one of the containerised options.


### 2. Download the proprietary software dependencies

Predector runs several tools that we cannot download for you automatically.
Please register for and download each of the following tools, and place them all somewhere that you can access from your terminal.
Where you have a choice between versions for different operating systems, you should always take the **Linux** version (even if using Mac or Windows).

- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-3.0/9-Downloads.php#) version 3.0
- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-4.1/9-Downloads.php#) version 4.1g
- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-5.0/9-Downloads.php#) version 5.0b
- [TargetP](https://services.healthtech.dtu.dk/services/TargetP-2.0/9-Downloads.php#) version 2.0
- [DeepLoc](https://services.healthtech.dtu.dk/services/DeepLoc-1.0/9-Downloads.php#) version 1.0
- [TMHMM](https://services.healthtech.dtu.dk/services/TMHMM-2.0/9-Downloads.php#) version 2.0c
- [Phobius](http://software.sbc.su.se/cgi-bin/request.cgi?project=phobius) version 1.01

Note that DTU (SignalP etc) don't keep older patches and minor versions available.
If the specified version isn't available to download, another version with the same major number _should_ be fine.


### 3. Build the conda environment or container

We provide an install script that should install the dependencies for the majority of users.

In the following command, substitute `<environment>` for `conda`, `docker`, or `singularity`.
Make sure you're in the same directory as the proprietary source archives.
If the names below don't match the filenames you have exactly, adjust the command accordingly.
For singularity and docker container building you may be prompted for your root password (via `sudo`).

```bash
curl -s "https://raw.githubusercontent.com/ccdmb/predector/0.1.0-dev/install.sh" \
| bash -s <environment> \
    -3 signalp-3.0.Linux.tar.Z \
    -4 signalp-4.1g.Linux.tar.gz \
    -5 signalp-5.0b.Linux.tar.gz \
    -t targetp-2.0.Linux.tar.gz \
    -d deeploc-1.0.All.tar.gz \
    -m tmhmm-2.0c.Linux.tar.gz \
    -p phobius101_linux.tar.gz
```

This will create the conda environment (named `predector`), or the docker (tagged `predector/predector:0.1.0-dev`) or singularity (file `./predector.sif`) containers.

**Take note of the message given upon completion**, which will tell you how to use the container or environment with predector.

If you have issues during installation or want to customise where things are built, please consult the extended documentation.
Or save the install script locally and run `install.sh --help`.


### 4. Install NextFlow

NextFlow requires a bash compatible terminal, and Java version 8+.
We require NextFlow version 20 or above.
Extended install instructions available at: [https://www.nextflow.io/](https://www.nextflow.io).

```bash
curl -s https://get.nextflow.io | bash
```

Or using conda:

```bash
conda install -c bioconda nextflow
```

### 5. Test the pipeline

Use one of the commands below using information given upon completion of dependency install script.

#### Using conda

```bash
nextflow run -profile test -with-conda /home/username/path/to/environment -resume ccdmb/predector
```

#### Using docker

```bash
nextflow run -profile test,docker -resume ccdmb/predector

# if your docker configuration requires sudo use this profile instead
nextflow run -profile test,docker_sudo -resume ccdmb/predector
```

#### Using singularity

```bash
nextflow run -profile test -with-singularity path/to/predector.sif -resume ccdmb/predector

# or if you've build the container using docker and it's in your local docker registry.
nextflow run -profile test,singularity -resume ccdmb/predector
```


## Quickstart

Say you have a set of amino-acid sequences in fasta format in the directory `proteomes`.
The following command will run the complete analysis and the results will be available in a `results` folder.

```bash
nextflow run ccdmb/predector --proteome "proteomes/*" --phibase "phibase.fasta"
```

## Future plans

The pipeline will run several common tools (and some less common ones) for effector candidate prediction based on protein properties.

We currently intend to include.

 - [x] SignalP 3, 4, and 5
 - [x] TMHMM
 - [x] Phobius
 - [x] Deepsig
 - [x] DeepLoc
 - [x] TargetP
 - [x] EffectorP 1 and 2
 - [x] ApoplastP
 - [x] LOCALIZER
 - [x] Protein similarity searches against PHIbase using MMSeqs2
 - [x] CAZyme annotations using HMMER and dbCAN
 - [x] Protein domain annotation using Pfam-scan
 - [x] A classifier and ranking scheme for prioritising effector candidates
 - [ ] A meta-secretion prediction model for better secretome prediction.
 - [ ] Integration of existing experimental custom scores (e.g. RNAseq, Proteomics, Dn/Ds) to inform candidate weighting.
 - [ ] Protein structural prediction tools from the RaptorX toolkit, and comparison with structural features of known effectors.


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
