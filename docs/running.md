## Running the pipeline

To run predector you just need your input proteomes as uncompressed fasta files.

Assuming that you've installed the dependencies, and know which dependency system you're using (conda, docker, or singularity), you can run like so:


Conda:

```bash
nextflow run \
  -resume \
  -r 1.0.0 \
  -with-conda /path/to/conda/env \
  ccdmb/predector \
  --proteome "my_proteomes/*.faa"
```

Docker:

```bash
nextflow run \
  -resume \
  -r 1.0.0 \
  -profile docker \
  ccdmb/predector \
  --proteome "my_proteomes/*.faa"
```

Singularity:

```bash
nextflow run \
  -resume \
  -r 1.0.0 \
  -with-singularity ./path/to/singularity.sif \
  ccdmb/predector \
  --proteome "my_proteomes/*.faa"
```


### Command line parameters

To get a list of all available parameters, use the `--help` argument.

```bash
nextflow run ccdmb/predector --help
```

Important parameters are:

```
--proteome <path or glob>
  Path to the fasta formatted protein sequences.
  Multiple files can be specified using globbing patterns in quotes.
--phibase <path>
  Path to the PHI-base fasta dataset.

-profile <string>
  Specify a pre-set configuration profile to use.
  Multiple profiles can be specified by separating them with a comma.
  Common choices: test, docker, docker_sudo

-c | -config <path>
  Provide a custom configuration file.
  If you want to customise things like how many CPUs different tasks
  can use, whether to use the SLURM scheduler etc, this is the way
  to do it. See the predector or nextflow documentation for details
  on how to write these.

-with-conda <path>
  The path to a conda environment to use for dependencies.

-with-singularity <path>
  Path to the singularity container file to use for dependencies.

--outdir <path>
  Base directory to store the pipeline results
  default: 'results'

--tracedir <path>
  Directory to store pipeline runtime information
  default: 'results/pipeline_info'

--chunk_size <int>
  The number of proteins to run as a single chunk in the pipeline
  default: 5000

--nostrip
  Don't strip the proteome filename extension when creating the output filenames
  default: false
```


### Profiles and configuration

Nextflow uses configuration files to specify how many cpus or RAM a task can use, or whether to use
a SLURM scheduler on a supercomputing cluster etc.
You can also use these config files to provide parameters.

To select different configurations, you can either use one of the preset "profiles", or you can provide your own
nextflow config files to the `-config` parameter <https://www.nextflow.io/docs/latest/config.html>.
This enables you to tune the number of CPUs used per task etc to your own computing system.


#### Profiles

We have several available profiles that configure where to find software, cpu, memory etc.

| type     | profile     | description                                                                                                                                                                |
|----------|-------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| software | docker      | Run the processes in a docker container.                                                                                                                                   |
| software | docker_sudo | Run the processes in a docker container, using `sudo docker`.                                                                                                              |
| software | podman      | Run the processes in a container using `podman`.                                                                                                                           |
| software | singularity | Run the process using singularity (by pulling it from the local docker registry). To use a singularity image file use the `-with-singularity image.sif` parameter instead. |
| cpu    | c4          | Use up to 4 CPUs/cores per computer/node.                                                                                                                                  |
| cpu    | c8          | Use up to 8 CPUs/cores ...                                                                                                                                                 |
| cpu    | c16         | Use up to 16 CPUs/cores ...                                                                                                                                                |
| memory   | r8          | Use up to 8Gb RAM per computer/node.                                                                                                                                       |
| memory   | r16         | Use up to 16Gb RAM                                                                                                                                                         |
| memory   | r32         | Use up to 32Gb RAM                                                                                                                                                         |
| memory   | r64         | Use up to 64Gb RAM                                                                                                                                                         |
| time     | t1          | Limits process time to 1hr, 5hr, and 12hr for short, medium and long tasks.                                                                                                |
| time     | t2          | Limits process time to 2hr, 10hr, and 24hr for short, medium and long tasks.                                                                                               |
| time     | t3          | Limits process time to 3hr, 15hr, and 24hr for short, medium and long tasks.                                                                                               |
| time     | t4          | Limits process time to 4hr, 20hr, and 48hr for short, medium and long tasks.                                                                                               |
| compute  | pawsey_zeus | A combined profile to use the Pawsey supercomputing centre's Zeus cluster. This sets cpu, memory, and time parameters appropriate for using this cluster. |


You can mix and match these profiles, using the `-profile` parameter.
By default, the pipeline will behave as if you ran the pipeline with `-profile c4,r8` (4 CPUs, and 8 Gb memory) which should be compatible with most modern laptop computers and smaller cloud instances.
But you can increase the number of CPUs available e.g. to make up to 16 CPUs available with `-profile c16` which will have 16 cores available and 8 GB of memory. To make more memory available, specify one of the `r*` profiles e.g. `-profile c16,r32`.

The time profiles (`t*`) are useful for limiting running times of tasks. By default the times are not limited, but these can be useful to use if you are running on a supercomputing cluster (specifying the times can get you through the queue faster) or on commercial cloud computing services (so you don't rack up an unexpected bill if something stalls somehow).

So to use combine all of these things; to use docker containers, extra ram and CPUs etc you can provide the profile `-profile c16,r32,t2,docker`.


#### Custom configuration

If the preset profiles don't meet your needs you can provide a custom config file. Extended documentation can be found here: <https://www.nextflow.io/docs/latest/config.html>.

I'll detail some pipeline specific configuration below but I suggest you start by copying the file <https://github.com/ccdmb/predector/tree/master/conf/template_single_node.config> and modify as necessary.

Each nextflow task is labelled with the software name, cpu, ram, and time requirements for each task.
In the config files, you can select these tasks by label.


| kind     | label          | description                                                                                                          |
|----------|----------------|----------------------------------------------------------------------------------------------------------------------|
| cpu      | `cpu_low`        | Used for single threaded tasks. Generally doesn't need to be touched.                                                |
| cpu      | `cpu_medium`     | Used for parallelised tasks that are IO bound. E.G. signalp 3 & 4, deeploc etc.                                      |
| cpu      | `cpu_high`       | Used for parallelised tasks that use lots of CPUs efficiently. Usually this should be all available CPUs.            |
| memory   | `ram_low`        | Used for processes with low RAM requirements, e.g. downloads.                                                        |
| memory   | `ram_medium`     | Used for tasks with moderate RAM requirements, and many of the parallelised tasks (e.g. with `cpu_medium`).          |
| memory   | `ram_high`       | Used for tasks with high RAM requirements. Usually this should be all available RAM.                                 |
| time     | `time_short`     | Used with tasks that should be super quick like `sed` or splitting files etc (1 or 2 hours at the very most).        |
| time     | `time_medium`    | Used for more expensive tasks, most parallelised tasks should be able to complete within this time (e.g 5-10 hours). |
| time     | `time_long`      | Used for potentially long running tasks or tasks with times that depends on external factors e.g. downloads.         |
| software | `download`       | Software environment for downloading things. (i.e. contains wget)                                                    |
| software | `posix`          | " for using general posix/GNU tools                                                                                  |
| software | `predectorutils` | " Tasks that use the predector-utils scripts.                                                                        |
| software | `signalp3`       |                                                                                                                      |
| software | `signalp4`       |                                                                                                                      |
| software | `signalp5`       |                                                                                                                      |
| software | `signalp6`       |                                                                                                                      |
| software | `deepsig`        |                                                                                                                      |
| software | `phobius`        |                                                                                                                      |
| software | `tmhmm`          |                                                                                                                      |
| software | `deeploc`        |                                                                                                                      |
| software | `apoplastp`      |                                                                                                                      |
| software | `localizer`      |                                                                                                                      |
| software | `effectorp1`     |                                                                                                                      |
| software | `effectorp2`     |                                                                                                                      |
| software | `effectorp3`     |                                                                                                                      |
| software | `emboss`         |                                                                                                                      |
| software | `hmmer3`         |                                                                                                                      |
| software | `pfamscan`       |                                                                                                                      |
| software | `mmseqs`         |                                                                                                                      |



### Running different pipeline versions.

We pin the version of the pipeline to run in all of our example commands with the `-r 1.0.0` parameter.
These flags are optional, but recommended so that you know which version you ran. Different versions of the pipelines may output different scores, use different parameters look etc. It also re-enforces the link between the pipeline version and the docker container tags.

If you have previously run predector and want to update it to use a new version, you can either provide a new version to the `-r` parameter, and add the `-latest` flag to tell nextflow to pull new changes from the github repository.
Likewise, you can run old versions of the pipeline by simply changing `-r`.
You can also pull new changes without running the pipeline using `nextflow pull ccdmb/predector`.

Note that the software environments (conda, docker, singularity) often will not be entirely compatible between versions. You should probably rebuild the container or conda environment from scratch when changing versions.
I suggest keeping copies of the proprietary dependencies handy in a folder or archive, and just building and removing the container/environment as you need it.


### Providing pre-downloaded Pfam, PHI-base, and dbCAN datasets.

Sometimes the Pfam or dbCAN servers can be a bit slow for downloads, and are occasionally unavailable which will cause the pipeline to fail.
You may want to keep the downloaded databases to reuse them (or pre-download them).

If you've already run the pipeline once, they'll be in the `results` folder (unless you specified `--outdir`) so you can do:

```bash
cp -rL results/downloads ./downloads
nextflow run \
  -profile test \
  -resume ccdmb/predector \
  --phibase phi-base_current.fas \
  --pfam_hmm downloads/Pfam-A.hmm.gz \
  --pfam_dat downloads/Pfam-A.hmm.dat.gz \
  --pfam_active_site downloads/active_site.dat.gz \
  --dbcan downloads/dbCAN.txt
```

This will skip the download step at the beginning and just use those files, which saves a few minutes.

