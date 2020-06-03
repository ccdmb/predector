# predector

Predict effectors in your proteomes using the Predector!

**WARNING: This pipeline is currently still in fairly early development. Some documentation may be incomplete, and software may not perform as expected. Get in contact if you're really keen to continue.**


# What's the plan?

The pipeline will run several common tools (and some less common ones) for effector candidate prediction based on protein properties.

We plan to include.

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
 - [ ] Integration of existing experimental custom scores (e.g. RNAseq, Proteomics, Dn/Ds) to inform candidate weighting.
 - [ ] A classifier and clustering scheme for prioritising effector candidates

Possible add-on pipelines in the future.
 - [ ] Protein structural prediction tools from the RaptorX toolkit, and comparison with structural features of known effectors.



Also we intend to inject as many [Predator](https://en.wikipedia.org/wiki/Predator_(film)) references as possible because predector kind of sounds like predator.

~~Stay tuned!~~
Stick around!
![](https://images.amcnetworks.com/ifc.com/wp-content/uploads/2016/03/stickaround.gif)


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
curl -s "https://raw.githubusercontent.com/ccdmb/predector/master/install.sh" \
| bash -s <environment> \
    -3 signalp-3.0.Linux.tar.Z \
    -4 signalp-4.1g.Linux.tar.gz \
    -5 signalp-5.0b.Linux.tar.gz \
    -t targetp-2.0.Linux.tar.gz \
    -d deeploc-1.0.All.tar.gz \
    -m tmhmm-2.0c.Linux.tar.gz \
    -p phobius101_linux.tar.gz
```

This will create the conda environment (named `predector`), or the docker (tagged `predector/predector:0.0.1-dev.2`) or singularity (file `./predector.sif`) containers.

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


## Contributing

We're aware that basically every bioinformatician working with pathogens has written some version of this pipeline.
If you're willing, we'd really like for you to help us make this pipeline better.

If you have an analysis that you think should be included, know of better parameters, or think the documentation could be better, please get involved!

We'll make sure that appropriate credit is given, potentially including future authorship for more substantial contributions.
It would be lovely to develop a bit of a community around this thing :)

See the [CONTRIBUTING](CONTRIBUTING.md) page for some details on how we do things, or just send us an email or raise a github issue to introduce yourself.


## Contact us

This pipeline is being developed by several people at the [CCDM](http://ccdm.com.au/).
The primary email contact for now should be Darcy Jones <darcy.ab.jones@gmail.com>.
You can also raise an issue on GitHub to ask a question or introduce yourself.
