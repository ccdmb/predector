# Conda recipes

These are the recipes and simple build system that we're using to distribute packages.
Eventually I hope to get most of these packages into bioconda and/or conda-forge, but that will take extra time that I don't have right now.

USERS DO NOT NEED TO BUILD THESE PACKAGES.

This is for developers and the especially curious.
Note that all of our recipes and the commands below assume you're running Linux
on an x86 computer. Things should be ok on MacOS or a windows bash emulator (especially if you're running things in containers),
but I can't really test it. Most bioinformatics servers/clusters etc will be running linux.


### build all of the conda packages using containers

Building inside containers with podman is the default mode, but you can also use docker.

```
make all
# or equivalently
make CONTAINER=1 DOCKER=podman all

# To use docker
make CONTAINER=1 DOCKER=docker all
```

The built packages will be in `./builds`.


### build everything on your own operating system

I'd recommend against building on your own computer in general.
The `conda build` command puts packages all over the place and things get messy.
But it can be useful if you've got something causing an error and you need to get at the tarball.

Assuming you're in a dedicated conda environment with `conda-build` and `conda-verify` installed:

```
make CONTAINER=0 all
```

The built packages will be in `./builds` and also in you conda base directory somewhere under `pkg`.



### Dealing with closed-source software

We rely on a lot of software that we can't redistribute.
In most cases there aren't good open-source alternatives, so we're forced to find ways to make
the installation process easier, without being able to just handle everything.

Our solution is to create a placeholder package, which contains a script that users can run to add the downloaded licensed software to their conda environment (or to a Docker image containing the environment).

This pattern is based on the [Bioconda gatk 3 recipe](https://github.com/bioconda/bioconda-recipes/tree/master/recipes/gatk).

The signalp, targetp, tmhmm, phobius, and deeploc recipes all have:

1) Bash script that raises an error message in place of the actual program (e.g. signalp)
2) A `-register` script which takes the downloaded software archive, extracts it, modifies it if necessary, and then installs it as necessary in the conda environment.
3) A `post-link.sh` script which just prints a warning that you need to run `-register` to finish installing the package.
4) A `pre-unlink.sh` script which acts to uninstall the things installed by `-register`. Conda doesn't know how to track them, so without this script `conda uninstall` would just leave the licensed source files hanging around.


A mocked up example of the install process:

```
$ conda install signalp3

It looks signalp3 hasn't been installed yet.

Usage: signalp3-register /path/to/SignalP-3.0.tar.Z

Due to license restrictions, this recipe cannot distribute and 
install SignalP directly. To complete the installation you must 
download a licensed copy from DTU: 
    https://services.healthtech.dtu.dk/services/SignalP-3.0/9-Downloads.php# 
and run (after installing this package):
    signalp3-register /path/to/SignalP-3.0.tar.Z
This will copy signalp3 into your conda environment.


$ signalp3 -version
SignalP has not been installed yet.

Please download the signalp program and run signalp3-register to complete the installation.


$ signalp3-register path/to/SignalP-3.0.tar.Z

$ signalp3 -version
3.0b, Dec 2005
```

I think this is a good compromise solution, and it should play nicely with a docker ONBUILD style containerisation strategy.
