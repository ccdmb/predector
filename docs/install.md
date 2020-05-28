# Installing dependencies

To run the pipeline itself you'll need to install [Nextflow](https://www.nextflow.io/).
We provide a conda environment and containers to handle software dependencies.
However, because we rely on several tools with proprietary licenses there are a few extra steps necessary to get things running.

Because some of the software only works with linux, we cannot support MacOS or Windows.
Mac and Windows users are recommended to use a virtual environment or one of the containerised options (rather than conda).

1) Install [Docker](https://docs.docker.com/engine/install/), [Singularity](https://sylabs.io/guides/3.5/user-guide/), or [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html)
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


## Conda

We provide a conda environment file that can be downloaded and installed.
This environment contains several "placeholder" packages to deal with the proprietary software.
Essentially, these placeholder packages contain scripts to take the source files of the
proprietary software, and install them into the conda environment for you.

**It is necessary to run both of the code blocks below to properly install the environment.**

First we create the conda environment, which includes the non-proprietary dependencies and the "placeholder" packages.

```bash
# Download the environment config file.
curl -o environment.yml https://raw.githubusercontent.com/ccdmb/predector/0.0.1-dev.2/environment.yml

# Create the environment
conda env create -f environment.yml
conda activate predector
```

To complete the installation we need to run the `*-register` scripts, which install the proprietary source archives you downloaded yourself.
You can copy-paste the entire command below directly into your terminal.
Modify the source tar archive filenames in the commands if necessary.

```bash
signalp3-register signalp-3.0.Linux.tar.Z \
&& signalp4-register signalp-4.1g.Linux.tar.gz \
&& signalp5-register signalp-5.0b.Linux.tar.gz \
&& targetp2-register targetp-2.0.Linux.tar.gz \
&& deeploc-register deeploc-1.0.All.tar.gz \
&& phobius-register phobius101_linux.tar.gz \
&& tmhmm2-register tmhmm-2.0c.Linux.tar.gz
```

If any of the `*-register` scripts fail, please contact the authors or raise an issue on github (we'll try to have an FAQ setup soon).


## Docker

For docker and anything that supports docker images we have a [prebuilt container on DockerHub](https://hub.docker.com/repository/docker/predector/predector-base) containing all of the open-source components.
To install the proprietary software we use this image as a base to build on with a new dockerfile.
To build the new image with the proprietary dependencies, you need to run the command below which can all be copy-pasted directly into your terminal.
Modify the source `.tar` archive filenames in the command if necessary.
Depending on how you installed docker you may need to use `sudo docker` in place of `docker`.

```bash
curl -s https://raw.githubusercontent.com/ccdmb/predector/0.0.1-dev.2/Dockerfile \
| docker build \
  --build-arg SIGNALP3=signalp-3.0.Linux.tar.Z \
  --build-arg SIGNALP4=signalp-4.1g.Linux.tar.gz \
  --build-arg SIGNALP5=signalp-5.0b.Linux.tar.gz \
  --build-arg TARGETP2=targetp-2.0.Linux.tar.gz \
  --build-arg PHOBIUS=phobius101_linux.tar.gz \
  --build-arg TMHMM=tmhmm-2.0c.Linux.tar.gz \
  --build-arg DEEPLOC=deeploc-1.0.All.tar.gz \
  -t predector/predector:0.0.1-dev.2 \
  -f - \
  .
```

Your container should now be available as `predector/predector:0.0.1-dev.2` in your docker registry `docker images`.


## Singularity

There are a few ways to build the singularity image with the proprietary software installed (the filename `predector.sif` in the sections below).

If you only have singularity installed, you can build the container directly
by downloading the `.def` file and setting some environment variables with the
paths to the proprietary source archives.
The following commands will build this image for you, and can be copy-pasted directly into your terminal.
Modify the source tar archive filenames if necessary.

```bash
# This is used to emulate the --build-args functionality of docker.
# Singularity lacks this feature. You can unset the variables after you're done.
export SIGNALP3=signalp-3.0.Linux.tar.Z
export SIGNALP4=signalp-4.1g.Linux.tar.gz
export SIGNALP5=signalp-5.0b.Linux.tar.gz
export TARGETP2=targetp-2.0.Linux.tar.gz
export PHOBIUS=phobius101_linux.tar.gz
export TMHMM=tmhmm-2.0c.Linux.tar.gz
export DEEPLOC=deeploc-1.0.All.tar.gz

# Download the .def file
curl -o ./singularity.def https://raw.githubusercontent.com/ccdmb/predector/0.0.1-dev.2/singularity.def

# Build the .sif singularity image.
# Note that `sudo -E` is important, it tells sudo to keep the environment variables
# that we just set.
sudo -E singularity build \
  predector.sif \
  ./singularity.def
```

If you've already built the container using docker, you can convert them to singularity format.
You don't need to use `sudo` even if your docker installation usually requires it.

```bash
singularity build predector.sif docker://predector/predector:0.0.1-dev.2
```


Because the container images are quite large, `singularity build` will sometimes fail if your `/tmp` partition isn't big enough.
In that case, set the following environment variables and remove the cache directory (`rm -rf -- "${PWD}/cache"`) when `singularity build` is finished.

```bash
export SINGULARITY_CACHEDIR="${PWD}/cache"
export SINGULARITY_TMPDIR="${PWD}/cache"
export SINGULARITY_LOCALCACHEDIR="${PWD}/cache"
```

