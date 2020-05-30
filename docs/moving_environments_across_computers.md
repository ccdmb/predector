

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
docker save predector/predector:0.0.1-dev.2 > predector.tar
```

And the on the other end

```bash
docker load -i predector.tar
```

Singularity container `.sif` files can be copied in the same way and is also suitable for HPC environments.


Hopefully, one of these options will work for you.

