# predector

Predict effectors in your proteomes using the Predector!


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

To run the pipeline itself you'll need to install [Nextflow](https://www.nextflow.io/).
We provide a conda environment and containers to handle software dependencies.
However, because we rely on several tools with proprietary licenses there are a few extra steps necessary to get things running.

Because some of the software only works with linux, we cannot support MacOS or Windows.
Mac and Windows users are recommended to use a virtual environment or one of the containerised options (rather than conda).

1) Install [Docker](https://docs.docker.com/engine/install/), [Podman](https://podman.io/), [Singularity](https://sylabs.io/guides/3.5/user-guide/), or [Conda](https://docs.conda.io/en/latest/miniconda.html)
2) Download the linux source files for proprietary dependencies.
   Move them all into the same folder.
   - [SignalP v3](https://services.healthtech.dtu.dk/services/SignalP-3.0/9-Downloads.php#)
   - [SignalP v4](https://services.healthtech.dtu.dk/services/SignalP-4.1/9-Downloads.php#)
   - [SignalP v5](https://services.healthtech.dtu.dk/services/SignalP-5.0/9-Downloads.php#)
   - [TargetP v2](https://services.healthtech.dtu.dk/services/TargetP-2.0/9-Downloads.php#)
   - [DeepLoc v1](https://services.healthtech.dtu.dk/services/DeepLoc-1.0/9-Downloads.php#)
   - [TMHMM v2](https://services.healthtech.dtu.dk/services/TMHMM-2.0/9-Downloads.php#)
   - [Phobius](http://software.sbc.su.se/cgi-bin/request.cgi?project=phobius)
3) Open a terminal, move into the directory where you saved the source files, and create the conda environment or container by following the relevant steps below.


#### Conda

```bash
# This pulls a version from anaconda.org
conda env create predector/predector/0.0.1-alpha
conda activate predector

signalp3-register signalp-3.0.Linux.tar.Z
signalp4-register signalp-4.1g.Linux.tar.gz
signalp5-register signalp-5.0b.Linux.tar.gz
targetp2-register targetp-2.0.Linux.tar.gz
deeploc-register deeploc-1.0.All.tar.gz
phobius-register phobius101_linux.tar.gz
tmhmm2-register tmhmm-2.0c.Linux.tar.gz
```


#### Docker and Podman

The interface to podman is exactly the same as for docker, so
for all following commands you can just substitute podman for docker.

If you're using docker, you may need to use `sudo` before commands.

```bash
docker build \
  --build-arg SIGNALP3=signalp-3.0.Linux.tar.Z \
  --build-arg SIGNALP4=signalp-4.1g.Linux.tar.gz \
  --build-arg SIGNALP5=signalp-5.0b.Linux.tar.gz \
  --build-arg TARGETP2=targetp-2.0.Linux.tar.gz \
  --build-arg PHOBIUS=phobius101_linux.tar.gz \
  --build-arg TMHMM=tmhmm-2.0c.Linux.tar.gz \
  --build-arg DEEPLOC=deeploc-1.0.All.tar.gz \
  -t predector/predector:0.0.1 \
  -f https://raw.githubusercontent.com/ccdmb/predector/master/Dockerfile \
  .
```


#### Singularity

Soon we'll have a way to build the final image directly with singularity.
For now you'll need to build the image with docker, and use singularity to convert it to their format.
