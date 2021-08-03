## Quick install

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
- [SignalP](https://services.healthtech.dtu.dk/services/SignalP-6.0/9-Downloads.php#) version 6 "fast"
- [TargetP](https://services.healthtech.dtu.dk/services/TargetP-2.0/9-Downloads.php#) version 2.0
- [DeepLoc](https://services.healthtech.dtu.dk/services/DeepLoc-1.0/9-Downloads.php#) version 1.0
- [TMHMM](https://services.healthtech.dtu.dk/services/TMHMM-2.0/9-Downloads.php#) version 2.0c
- [Phobius](http://software.sbc.su.se/cgi-bin/request.cgi?project=phobius) version 1.01

Note that DTU (SignalP etc) don't keep older patches and minor versions available.
If the specified version isn't available to download, another version with the same major number _should_ be fine.


### 3. Build the conda environment or container

We provide an install script that should install the dependencies for the majority of users.

In the following command, substitute the assigned value of `ENVIRONMENT` for `conda`, `docker`, or `singularity` as suitable.
Make sure you're in the same directory as the proprietary source archives.
If the names below don't match the filenames you have exactly, adjust the command accordingly.
For singularity and docker container building you may be prompted for your root password (via `sudo`).

```bash
ENVIRONMENT=docker

curl -s "https://raw.githubusercontent.com/ccdmb/predector/1.1.0-alpha/install.sh" \
| bash -s "${ENVIRONMENT}" \
    -3 signalp-3.0.Linux.tar.Z \
    -4 signalp-4.1g.Linux.tar.gz \
    -5 signalp-5.0b.Linux.tar.gz \
    -6 signalp-6.0.fast.tar.gz \
    -t targetp-2.0.Linux.tar.gz \
    -d deeploc-1.0.All.tar.gz \
    -m tmhmm-2.0c.Linux.tar.gz \
    -p phobius101_linux.tar.gz
```

This will create the conda environment (named `predector`), or the docker (tagged `predector/predector:1.1.0-alpha`) or singularity (file `./predector.sif`) containers.

**Take note of the message given upon completion**, which will tell you how to use the container or environment with predector.

If you have issues during installation or want to customise where things are built, please consult the extended documentation.
Or save the install script locally and run `install.sh --help`.


### 4. Install NextFlow

NextFlow requires a bash compatible terminal, and Java version 8+.
We require NextFlow version 21 or above.
Extended install instructions are available at: [https://www.nextflow.io/](https://www.nextflow.io).

```bash
curl -s https://get.nextflow.io | bash
```

Or using conda:

```bash
conda install -c bioconda nextflow>=21
```

### 5. Test the pipeline

Use one of the commands below using information given upon completion of dependency install script.
**Make sure you use the environment that you specified in [Step 3](#3--Build-the-conda-environment-or-container).**

Using conda:

```bash
nextflow run -profile test -with-conda /home/username/path/to/environment -resume -r 1.1.0-alpha ccdmb/predector
```

Using docker:

```bash
nextflow run -profile test,docker -resume -r 1.1.0-alpha ccdmb/predector

# if your docker configuration requires sudo use this profile instead
nextflow run -profile test,docker_sudo -resume -r 1.1.0-alpha ccdmb/predector
```

Using singularity:

```bash
nextflow run -profile test -with-singularity path/to/predector.sif -resume -r 1.1.0-alpha ccdmb/predector

# or if you've build the container using docker and it's in your local docker registry.
nextflow run -profile test,singularity -resume -r 1.1.0-alpha ccdmb/predector
```

## Extended dependency install guide

If the quick install method doesn't work for you, you might need to run the environment build steps manually.
It would be great if you could also contact us to report the issue, so that we can get the quick install instructions working for more people.

The following guides assume that you have successfully followed the steps 1, 2, and 4, and aim to teplace step 3.

### Building the conda environment the long way

We provide a conda environment file that can be downloaded and installed.
This environment contains several "placeholder" packages to deal with the proprietary software.
Essentially, these placeholder packages contain scripts to take the source files of the
proprietary software, and install them into the conda environment for you.

**It is necessary to run both of the code blocks below to properly install the environment.**

First we create the conda environment, which includes the non-proprietary dependencies and the "placeholder" packages.

```bash
# Download the environment config file.
curl -o environment.yml https://raw.githubusercontent.com/ccdmb/predector/1.1.0-alpha/environment.yml

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
&& signalp6-register signalp-6.0.fast.tar.gz \
&& targetp2-register targetp-2.0.Linux.tar.gz \
&& deeploc-register deeploc-1.0.All.tar.gz \
&& phobius-register phobius101_linux.tar.gz \
&& tmhmm2-register tmhmm-2.0c.Linux.tar.gz
```

If any of the `*-register` scripts fail, please contact the authors or raise an issue on github (we'll try to have an FAQ setup soon).


### Building the Docker container the long way

For docker and anything that supports docker images we have a [prebuilt container on DockerHub](https://hub.docker.com/repository/docker/predector/predector-base) containing all of the open-source components.
To install the proprietary software we use this image as a base to build on with a new dockerfile.
To build the new image with the proprietary dependencies, you need to run the command below which can all be copy-pasted directly into your terminal.
Modify the source `.tar` archive filenames in the command if necessary.
Depending on how you installed docker you may need to use `sudo docker` in place of `docker`.

```bash
curl -s https://raw.githubusercontent.com/ccdmb/predector/1.1.0-alpha/Dockerfile \
| docker build \
  --build-arg SIGNALP3=signalp-3.0.Linux.tar.Z \
  --build-arg SIGNALP4=signalp-4.1g.Linux.tar.gz \
  --build-arg SIGNALP5=signalp-5.0b.Linux.tar.gz \
  --build-arg SIGNALP6=signalp-6.0.fast.tar.gz \
  --build-arg TARGETP2=targetp-2.0.Linux.tar.gz \
  --build-arg PHOBIUS=phobius101_linux.tar.gz \
  --build-arg TMHMM=tmhmm-2.0c.Linux.tar.gz \
  --build-arg DEEPLOC=deeploc-1.0.All.tar.gz \
  -t predector/predector:1.1.0-alpha \
  -f - \
  .
```

Your container should now be available as `predector/predector:1.1.0-alpha` in your docker registry `docker images`.


### Building the Singularity container the long way

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
export SIGNALP6=signalp-6.0.fast.tar.gz
export TARGETP2=targetp-2.0.Linux.tar.gz
export PHOBIUS=phobius101_linux.tar.gz
export TMHMM=tmhmm-2.0c.Linux.tar.gz
export DEEPLOC=deeploc-1.0.All.tar.gz

# Download the .def file
curl -o ./singularity.def https://raw.githubusercontent.com/ccdmb/predector/1.1.0-alpha/singularity.def

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
singularity build predector.sif docker-daemon://predector/predector:1.1.0-alpha
```


Because the container images are quite large, `singularity build` will sometimes fail if your `/tmp` partition isn't big enough.
In that case, set the following environment variables and remove the cache directory (`rm -rf -- "${PWD}/cache"`) when `singularity build` is finished.

```bash
export SINGULARITY_CACHEDIR="${PWD}/cache"
export SINGULARITY_TMPDIR="${PWD}/cache"
export SINGULARITY_LOCALCACHEDIR="${PWD}/cache"
```


## Copying environments to places where you don't have root user permission

We can't really just put the final container images up on dockerhub or singularity hub,
since that would violate the proprietary license agreements.
So if you don't have root user permission on the computer (e.g. a supercomputing cluster) you're going to run the analysis on you can either use the conda environments or build a container on a different computer and copy the image up.


If the option is available to you, I would recommend using the singularity containers for HPC.
Singularity container `.sif` files can be simply copied to whereever you're running the analysis.


Some supercomputing centres will have [`shifter`](https://docs.nersc.gov/programming/shifter/overview/) installed, which allows you to run jobs with docker containers. Note that there are two versions of `shifter` and nextflow only supports one of them (the nersc one).
Docker containers can be saved as a tarball and copied wherever you like.

```bash
# You could pipe this through gzip if you wanted.
docker save predector/predector:1.1.0-alpha > predector.tar
```

And the on the other end

```bash
docker load -i predector.tar
```


Conda environment should be able to be built anywhere, since they don't require root user permission.
You should just be able to follow the instructions described earlier.
Just make sure that you install the environment on a shared filesystem (i.e. one that all nodes in your cluster can access).

There are also options for "packing" a conda environment into something that you can copy around (e.g. [conda-pack](https://conda.github.io/conda-pack/)), though we haven't tried this yet.



Hopefully, one of these options will work for you.


## Common install issues

### Running with docker `Unable to find image 'predector/predector:1.1.0-alpha' locally`

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
