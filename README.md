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

We provide a conda environment file that can be downloaded and installed.
This environment contains several "placeholder" packages to deal with the proprietary software.
Essentially, these placeholder packages contain scripts to take the source files of the
proprietary software, and install them into the conda environment for you.

```bash
# Download the environment config file.
curl -o environment.yml https://raw.githubusercontent.com/ccdmb/predector/0.0.1-dev.1/environment.yml

# Create the environment
conda env create -f environment.yml
conda activate predector

# These commands make fixes to the source code when necessary
# and copy the source into your conda environment so that it all works together.
signalp3-register signalp-3.0.Linux.tar.Z
signalp4-register signalp-4.1g.Linux.tar.gz
signalp5-register signalp-5.0b.Linux.tar.gz
targetp2-register targetp-2.0.Linux.tar.gz
deeploc-register deeploc-1.0.All.tar.gz
phobius-register phobius101_linux.tar.gz
tmhmm2-register tmhmm-2.0c.Linux.tar.gz
```


#### Docker and Podman

For docker and anything that supports docker images we have a [prebuilt container](https://hub.docker.com/repository/docker/predector/predector-base) on dockerhub containing all of the open-source components.
To install the proprietary software we use this image as a base to build on with a new dockerfile.
Essentially it does the same thing that the conda `*-register` commands do.

The interface to podman is exactly the same as for docker, so
for all following commands you can just substitute podman for docker.

If you're using docker, you may need to use `sudo docker`.

```bash
curl -s https://raw.githubusercontent.com/ccdmb/predector/0.0.1-dev.1/Dockerfile \
| docker build \
  --build-arg SIGNALP3=signalp-3.0.Linux.tar.Z \
  --build-arg SIGNALP4=signalp-4.1g.Linux.tar.gz \
  --build-arg SIGNALP5=signalp-5.0b.Linux.tar.gz \
  --build-arg TARGETP2=targetp-2.0.Linux.tar.gz \
  --build-arg PHOBIUS=phobius101_linux.tar.gz \
  --build-arg TMHMM=tmhmm-2.0c.Linux.tar.gz \
  --build-arg DEEPLOC=deeploc-1.0.All.tar.gz \
  -t predector/predector:0.0.1-dev.1 \
  -f - \
  .
```

Podman is nice because it uses cgroups v2, so can do pretty much everything docker can do but without requiring root permission.
That includes building images, which i think you still need permission for with singularity.
However, I have had some intermittent issues with volume mounting and permissions that I haven't been able to solve.
**Docker original and Singularity are probably the better runtime options for now for stability.**
Podman seems to be fine for building the containers though.


#### Singularity

There are a few ways to build the singularity image (the filename `predector.sif` in the sections below).

If you only have singularity installed, you can build the container directly
by downloading the `.def` file and setting some environment variables with the
paths to the sources:

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
curl -o ./singularity.def https://raw.githubusercontent.com/ccdmb/predector/0.0.1-dev.1/singularity.def

# Build the .sif singularity image.
# Note that `sudo -E` is important, it tells sudo to keep the environment variables
# that we just set.
sudo -E singularity build \
  predector.sif \
  ./singularity.def
```

If you've already built the container using docker or podman, you can convert them to
singularity format. You don't have to be a root user.

for docker:

```bash
singularity build predector.sif docker://predector/predector:0.0.1-dev.1
```

for podman:

```bash
podman save --format oci-archive --output predector.tar localhost/predector/predector:0.0.1-dev.1
singularity build predector.sif oci-archive://predector.tar
```

Because the container images are quite large, `singularity build` will sometimes fail if your `/tmp` partition isn't big enough.
In that case, set the following environment variables and remove the cache directory (`rm -rf -- "${PWD}/cache"`) when `singularity build` is finished.

```bash
export SINGULARITY_CACHEDIR="${PWD}/cache"
export SINGULARITY_TMPDIR="${PWD}/cache"
export SINGULARITY_LOCALCACHEDIR="${PWD}/cache"
```

## Run the test datasets

To use a conda environment you'll need to find the path where it is installed.

```bash
conda info -e | grep "predector"
```

Copy the path of the environment.
On linux this will usually be `${HOME}/miniconda3/envs/predector`.

Now provide that path to the `-with-conda` parameter.

```bash
nextflow run \
  -profile test \
  -with-conda "${HOME}/miniconda3/envs/predector" \
  -resume \
  ccdmb/predector
```


Using containers is a similar process.

```bash
nextflow run -profile test,docker -resume ccdmb/predector

# if your docker condiguration requires sudo use this profile instead
nextflow run -profile test,docker_sudo -resume ccdmb/predector

# or if you want to use singularity
nextflow run \
  -profile test \
  -with-singularity path/to/predector.sif \
  -resume \
  ccdmb/predector

# or if you've build the container using docker and it's in your local docker registry.
nextflow run -profile test,singularity -resume ccdmb/predector
```


If you're running the tests with a few different environments e.g. docker and conda you may want to keep the downloaded databases and reuse them because they can take some time to download.

If you've already run the pipeline once, they'll be in the `results` folder (unless you specified `--outdir`) so you can do:

```bash
cp -rL results/downloads ./downloads
nextflow run \
  -profile test \
  -resume ccdmb/predector \
  --pfam_hmm downloads/Pfam-A.hmm.gz \
  --pfam_dat downloads/Pfam-A.hmm.dat.gz \
  --pfam_active_site downloads/active_site.dat.gz \
  --dbcan downloads/dbCAN.txt
```

This will skip the download step at the beginning and just use those files, which saves about 10 mins.


## Copying environments to places where you don't have root user permission

We can't really just put the final container images up on dockerhub or singularity hub,
since that would violate the proprietary license agreements.
So if you don't have root user permission on the computer (e.g. a supercomputing cluster) you're going to run the analysis on you can either use the conda environments or build a container on a different computer and copy the image up.


For conda, you can just follow the instructions described earlier.
Just make sure that you install the environment on a shared filesystem (i.e. one that all nodes in your cluster can access).


Some supercomputing centres will have [`shifter`](https://docs.nersc.gov/programming/shifter/overview/) installed, which allows you to run jobs with docker containers. Note that there are two versions of `shifter` and nextflow only supports one of them (the nersc one).
Docker containers can be saved as a tarball and copied wherever you like.

```bash
# You could pipe this through gzip if you wanted.
docker save predector/predector:0.0.1-dev.1 > predector.tar
```

And the on the other end

```bash
docker load -i predector.tar
```

Singularity container `.sif` files can be copied in the same way and is also suitable for HPC environments.


Hopefully, one of these options will work for you.
