## Running the pipeline

To run predector you just need your input proteomes as uncompressed fasta files.

Assuming that you've installed the dependencies, and know which dependency system you're using (conda, docker, or singularity), you can run like so:


Conda:

```bash
nextflow run \
  -resume \
  -r 1.2.6-alpha \
  -with-conda /path/to/conda/env \
  ccdmb/predector \
  --proteome "my_proteomes/*.faa"
```

Docker:

```bash
nextflow run \
  -resume \
  -r 1.2.6-alpha \
  -profile docker \
  ccdmb/predector \
  --proteome "my_proteomes/*.faa"
```

Singularity:

```bash
nextflow run \
  -resume \
  -r 1.2.6-alpha \
  -with-singularity ./path/to/singularity.sif \
  ccdmb/predector \
  --proteome "my_proteomes/*.faa"
```


Note that a peculiarity of nextflow is that any globbing patterns (e.g. `*`) need to be in quotes (single or double is fine), and you can't directly provide multiple filenames as you might expect.
See below for some ways you can typically provide files to the `--proteome` parameter.

| Use case | Correct | Incorrect |
|----------|---------|-----------|
| Single protein file | `--proteome my.fasta` | |
| All fasta files in a folder | `--proteome "folder/*.fasta"` | `--proteome folder/*.fasta` |
| Directly specify two files | `--proteome "{folder/file1.fasta,other/file2.fasta}"` (Ensure no spaces at the separating comma)| `--proteome "folder/file1.fasta other/file2.fasta"` |

You can find more info on the Globbing operations that are supported by Nextflow in the [Java documentation](https://docs.oracle.com/javase/tutorial/essential/io/fileOps.html#glob).


Predector is designed to run with typical proteomes, e.g. with an average of ~15000 proteins.
Internally we de-duplicate sequences and split the fasta files into smaller chunks to reduce redundant computation, enhance parallelism, and control peak memory usage.
You do not need to concatenate your proteomes together, instead you should keep them separate and use the globbing patterns above.
Inputting a single very large fasta file will potentially cause the pipeline to fail in the final steps producing the final ranking and analysis tables, as the "re-duplicated" results can be extremely large.
If you are running a task that doesn't naturally separate (e.g. a multi-species dataset downloaded from a UniProtKB query), it's best to chunk the fasta into sets of roughly 20000 (e.g. using [seqkit](https://bioinf.shenwei.me/seqkit/usage/#split)) and use the globbing pattern on those split fastas.


### Accessing and copying the results

By default the results of the pipeline are stored in the `results` folder. You can change this directory using the `--outdir` parameter to the pipeline.
You can find more details on the outputs in the [pipeline output](#pipeline-output) section.

It's important to note that nextflow [symbolically links](https://en.wikipedia.org/wiki/Symbolic_link) results files from the `work` directory, to the specified output directory.
This saves some space, but requires a bit of extra care when copying and deleting files.
If you delete the `work` folder you will also be deleting the actual contents of the results, and you'll be left with a pointer to a non-existent file.
**Make sure you copy any files that you want to keep before deleting anything**.

If you use the linux [`cp`](https://linux.die.net/man/1/cp) command to copy results, please **make sure to use the `-L` flag**.
This ensures that you copy the contents of the file rather than just copying another link to the file.
[`rsync`](https://linux.die.net/man/1/rsync) also requires using an `-L` flag to copy the contents rather than a link.
[`scp`](https://linux.die.net/man/1/scp) will always follow links to copy the contents, so no special care is necessary.

If you use a different tool, please make sure that it copies the contents.


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

--pfam_hmm <path>
  Path to already downloaded gzipped pfam HMM database
  default: download the hmms

--pfam_dat <path>
  Path to already downloaded gzipped pfam DAT database
  default: download the DAT file

--dbcan <path>
  Path to already downloaded gzipped dbCAN HMM database
  default: download the hmms

--effectordb <path>
  Path to already downloaded gzipped HMMs of effectors.
  default: download from <https://doi.org/10.6084/m9.figshare.16973665>

--precomputed_ldjson <path>
  Path to an ldjson formatted file from previous Predector runs.
  These records will be skipped when re-running the pipeline
  where the sequence is identical and the versions of software
  and databases (where applicable) are the same.
  default: don't use any precomputed results.

--chunk_size <int>
  The number of proteins to run as a single chunk in the pipeline.
  The input fasta files are split into chunks for checkpointing
  and parallelism. Reduce this if you are running into RAM errors,
  but note that nextflow can create a lot of files so this may slow
  your filesystem down. Increase this to produce fewer files,
  but note that the runtime of each task will be longer so increase
  resources accordingly. For a typical fungal proteome (~15k proteins), setting
  to 1000 is suitable. If running >100k proteins, increasing
  chunk size to ~10000 may be appropriate.
  default: 5000

--signalp6_bsize <int>
  This sets the batch size used by the SignalP6 neural network.
  SP6 can use a lot of RAM, and reducing the batch size reduces the memory use
  at the cost of slower speeds. For computers with lots of RAM (e.g. >16GB),
  increasing this to 64 or higher will speed up.
  For smaller computers try reducing to 10.
  default: 32

--no_localizer
  Don't run LOCALIZER, which can take a long time and isn't strictly needed
  for prediction of effectors (it's more useful for evaluation).

--no_signalp6
  Don't run SignalP v6. We've had several issues running SignalP6. 
  This option is primarily here to give users experiencing issues
  to finish the pipeline without it.
  If you didn't install SignalP6 in the Predector environment,
  the pipeline will automatically detect this and skip running SignalP6.
  In that case this flag isn't strictly necessary, but potentially useful
  for documenting what was run.
  THIS OPTION WILL BE REMOVED IN A FUTURE RELEASE.

--no_pfam
  Don't download and/or run Pfam and Pfamscan. Downloading Pfam is quite slow,
  even though it isn't particularly big. Sometimes the servers are down too.
  You might also run your proteomes through something like interproscan, in which
  case you might not need these results. This means you can keep going without it.

--no_dbcan
  Don't download and/or run searches against the dbCAN CAZyme dataset.
  If you're doing this analysis elsewhere, the dbCAN2 servers are down,
  or just don't need it, this lets to go without it.

--no_phibase
  Don't download and/or run searches against PHI-base.

--no_effectordb
  Don't download and/or run searches against Effector HMMs.

-r <version>
  Use a specific version of the pipeline. This version must match one of the
  tags on github <https://github.com/ccdmb/predector/tags>.
  In general it is best to specify a version, and all example commands
  in the documentation include this flag.

-latest
  Pull the pipeline again from github. If you have previously run
  Predector, and are specifying a new version to -r, you will need to use
  this parameter.
  See <https://github.com/ccdmb/predector/wiki#running-different-pipeline-versions>

-params-file <path>
  Load command line parameters from this JSON or YAML file rather.

-profile <string>
  Specify a pre-set configuration profile to use.
  Multiple profiles can be specified by separating them with a comma.
  Common choices: test, docker, docker_sudo

-c | -config <path>
  Provide a custom configuration file.
  If you want to customise things like how many CPUs different tasks
  can use, whether to use the SLURM scheduler etc, this is the way
  to do it. See the Predector or Nextflow documentation for details
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

--nostrip
  Don't strip the proteome filename extension when creating the output filenames
  default: false

-ansi-log=<true|false>
  The default Nextflow feedback prints and deletes the screen so that it appears as an updating block of text.
  Predector runs a lot of steps so this view usually takes up more than the full screen.
  Additionally this default mode doesn't play well if you re-direct the output to a file (e.g. using nohup or on a slurm cluster).
  Nextflow is supposed to switch when in a non-interactive shell, but I find that it often doesn't.
  If you would like to explicitly disable this Nextflow single screen colourful output, please specify `-ansi-log=false`.
```

*Note*. The difference in parameters starting with `-` and `--` are deliberate and shouldn't be mixed up.
Those starting with a single hyphen `-` are Nextflow runtime parameters, which are described here <https://www.nextflow.io/docs/latest/cli.html#run>.
Those starting with two hyphens `--` are Predector defined parameters.


### Manual ranking scores

In the pipeline ranking output tables we also provide a manual (i.e. not machine learning) ranking score for both effectors `manual_effector_score` and secretion `manual_secretion_score`.
This was provided so that you could customise the ranking if the ML ranker isn't what you want.

> NOTE: If you decide not to run specific analyses (e.g. signalp6 or Pfam), this may affect comparability between different runs of the pipeline.

These scores are computed by a relatively simple linear function weighting features in the ranking table.
You can customise the weights applied to the features from the command line.

In the following tables, the sum of all `feature` * `weight` pairs will compute the overall score.
The `feature` names match those in the [`*-ranked.tsv`](#-rankedtsv) file.
The effector score includes all of the secretion scores. It is built on-top of it with additional effector-relevant features.

Note that for some tools we subtract 0.5 and multiply by 2.
This is done for some classifiers so that the value is between 1 and -1. So it can both penalise and increase scores.

I've added a special column in here "has_effector_match" which is not in the ranking table.
It is composed of four other columns like this:

```
has_effector_match = has_phibase_effector_match
                  or (effector_matches != '.')
                  or has_dbcan_virulence_match
                  or has_pfam_virulence_match
```


| score | feature | default weight | command line option |
|-------|---------|----------------|---------------------|
| secretion | `is_secreted` | 2.0 | `--secreted_weight` |
| secretion | `signalp3_hmm` | 0.0001 | `--sigpep_ok_weight` |
| secretion | `signalp3_nn` | 0.0001 | `--sigpep_ok_weight` |
| secretion | `phobius` | 0.0001 | `--sigpep_ok_weight` |
| secretion | `deepsig` | 0.0001 | `--sigpep_ok_weight` |
| secretion | `signalp4` | 0.003 | `--sigpep_good_weight` |
| secretion | `signalp5` | 0.003 | `--sigpep_good_weight` |
| secretion | `signalp6` | 0.003 | `--sigpep_good_weight` |
| secretion | `targetp_secreted` | 0.003 | `--sigpep_good_weight` |
| secretion | `multiple_transmembrane` | -1 | `--multiple_transmembrane_weight` |
| secretion | `single_transmembrane` | -0.7 | `--single_transmembrane_weight` |
| secretion | `deeploc_extracellular` | 1.3 | `--deeploc_extracellular_weight` |
| secretion | `deeploc_nucleus` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_cytoplasm` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_mitochondrion` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_cell_membrane` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_endoplasmic_reticulum` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_plastid` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_golgi` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_lysosome` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_peroxisome` | -1.3 | `--deeploc_intracellular_weight` |
| secretion | `deeploc_membrane` | -1.3 | `--deeploc_membrane_weight` |
| secretion | `targetp_mitochondrial_prob` | -0.5 | `--targetp_mitochondrial_weight` |
| effector | `2 * (effectorp1 - 0.5)` | 0.5 | `--effectorp1_weight` |
| effector | `2 * (effectorp2 - 0.5)` | 2.5 | `--effectorp2_weight` |
| effector | `effectorp3_apoplastic` | 0.5 | `--effectorp3_apoplastic_weight` |
| effector | `effectorp3_cytoplasmic` | 0.5 | `--effectorp3_cytoplastmic_weight` |
| effector | `effectorp3_noneffector` | -2.5 | `--effectorp3_noneffector_weight` |
| effector | `2 * (deepredeff_fungi - 0.5)` | 0.1 | `--deepredeff_fungi_weight` |
| effector | `2 * (deepredeff_oomycete - 0.5)` | 0.0 | `--deepredeff_oomycete_weight` |
| effector | `has_effector_match` | 2.0 | `--effector_homology_weight` |
| effector | `(!has_effector_match) and has_phibase_virulence_match` | 0.5 | `--virulence_homology_weight` |
| effector | `has_phibase_lethal_match` | -2 | `--lethal_homology_weight` |


Note that all DeepLoc probability values except `deeploc_membrane` will sum to 1 because they result from
a single multi-class classifier (see the common [Softmax function](https://en.wikipedia.org/wiki/Softmax_function) for details on how this happens). So the total penalty for DeepLoc "intracellular" localisation can
only ever be a maximum of `--deeploc_intracellular_weight` which requires that `deeploc_extracellular` is 0.
And the increase from extracellular localisation can only ever be a maximum of `--deeploc_extracellular_weight`, which will happen if `deeploc_extracellular` is 1 (so all others must be 0).

The high weight assigned to `is_secreted` and relatively low weights assigned to individual classifiers is
intended to give a general bump to things that have signal peptides and no TM domains etc, but then a slight boost for proteins
that are positively predicted by multiple tools.


### Profiles and configuration

Nextflow uses configuration files to specify how many CPUs or RAM a task can use, or whether to use
a SLURM scheduler on a supercomputing cluster etc.
You can also use these config files to provide parameters.

To select different configurations, you can either use one of the preset "profiles", or you can provide your own
Nextflow config files to the `-config` parameter <https://www.nextflow.io/docs/latest/config.html>.
This enables you to tune the number of CPUs used per task etc to your own computing system.


#### Profiles

We have several available profiles that configure where to find software, CPU, memory etc.

| type     | profile     | description                                                                                                                                                                |
|----------|-------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| software | docker      | Run the processes in a docker container.                                                                                                                                   |
| software | docker_sudo | Run the processes in a docker container, using `sudo docker`.                                                                                                              |
| software | podman      | Run the processes in a container using `podman`.                                                                                                                           |
| software | singularity | Run the process using singularity (by pulling it from the local docker registry). To use a singularity image file use the `-with-singularity image.sif` parameter instead. |
| cpu    | c4          | Use up to 4 CPUs/cores per computer/node.                                                                                                                                  |
| cpu    | c8          | Use up to 8 CPUs/cores ...                                                                                                                                                 |
| cpu    | c16         | Use up to 16 CPUs/cores ...                                                                                                                                                |
| memory   | r4          | Use up to 4Gb RAM per computer/node.                                                                                                                                       |
| memory   | r6          | Use up to 6Gb RAM per computer/node.                                                                                                                                       |
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

**In general for best performance I suggest specifying the profiles with the largest number of CPUs that you have available on the computer you're running on.**
For example if you are running on a computer with 8 CPUs and 32 GB of RAM specify `-profile c8,r32`.
This will allow the pipeline to make the best use of your available resources.


The time profiles (`t*`) are useful for limiting running times of tasks. By default the times are not limited, but these can be useful to use if you are running on a supercomputing cluster (specifying the times can get you through the queue faster) or on commercial cloud computing services (so you don't rack up an unexpected bill if something stalls somehow).

So to combine all of these things; to use docker containers, extra ram and CPUs etc you can provide the profile `-profile c16,r32,t2,docker`.


#### Custom configuration

If the preset profiles don't meet your needs you can provide a custom config file. Extended documentation can be found here: <https://www.nextflow.io/docs/latest/config.html>.

I'll detail some pipeline specific configuration below but I suggest you start by copying the file <https://github.com/ccdmb/predector/tree/master/conf/template_single_node.config> and modify as necessary.

If you have questions about this, or want to suggest a configuration for us to officially distribute with the pipeline please file an [issue](https://github.com/ccdmb/predector/issues) or start a [discussion](https://github.com/ccdmb/predector/discussions).

Each Nextflow task is labelled with the software name, CPU, RAM, and time requirements for each task.
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
| software | `predectorutils` | " Tasks that use the Predector-utils scripts.                                                                        |
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
| software | `deepredeff`     |                                                                                                                      |
| software | `emboss`         |                                                                                                                      |
| software | `hmmer3`         |                                                                                                                      |
| software | `pfamscan`       |                                                                                                                      |
| software | `mmseqs`         |                                                                                                                      |


### Running different pipeline versions.

We pin the version of the pipeline to run in all of our example commands with the `-r 1.2.6-alpha` parameter.
These flags are optional, but recommended so that you know which version you ran.
Different versions of the pipelines may output different scores, use different parameters, different output formats etc.
It also re-enforces the link between the pipeline version and the docker container tags.

If you specify the pipeline to run as `ccdmb/predector`, Nextflow will pull the git repository from GitHub and put it in a local cache.
Unfortunately, if you change the version number provided to `-r` and that version is not in the local copy of the repository you will get an error (See [Common issues](#common-issues).
If you have previously run Predector and want to update it to use a new version, you can do one of the following:

1. Provide the new version to the `-r` parameter, and add the `-latest` flag to tell Nextflow to pull new changes from the GitHub repository.
   Likewise, you can run old versions of the pipeline by simply changing `-r`.

  ```
  nextflow run -r 1.2.6-alpha -latest ccdmb/predector --proteomes "my_proteins.fasta"
  ```

2. You can ask Nextflow to pull new changes without running the pipeline using `nextflow pull ccdmb/predector`.

3. You can ask Nextflow to delete the local copy of the repository entirely using `nextflow drop ccdmb/predector`. Nextflow will then pull a fresh copy the next time you run the pipeline.

If you get an error about missing git tags when running either of the first two options, try the third option (`drop`). This might happen if we delete old development tags of the pipeline to clean up the pipeline.


**Note that the software environments (conda, docker, singularity) often will not be entirely compatible between versions.** You should generally rebuild the container or conda environment from scratch when changing versions.
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
  --dbcan downloads/dbCAN.txt \
  --effectordb downloads/effectordb.hmm.gz
```

This will skip the download step at the beginning and just use those files, which saves a few minutes.

You can also download the files from:
- http://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/ `Pfam-A.hmm.gz` and `Pfam-A.hmm.dat.gz`
- https://bcb.unl.edu/dbCAN2/download/ `dbCAN-HMMdb-V10.txt`
- http://www.phi-base.org/downloadLink.htm OR https://github.com/PHI-base/data/tree/master/releases (only need the `.fas` fasta file).
- https://doi.org/10.6084/m9.figshare.16973665 `effectordb.hmm.gz`


### Providing pre-computed results to skip already processed proteins

Predector can now take results of previous Predector runs to skip re-running individual analyses of identical proteins.
This is decided based on a checksum of the processed sequence, the version of the software, and the version of the database (when applicable).
If all three match, we will skip that analysis for that protein.

In the `deduplicated` folder is a file called `new_results.ldjson`.
This contains all of the results from the current run of Predector.
Just hold on to this file, and provide it to the `--precomputed_ldjson` argument the next time you run the pipeline.
You can concatenate multiple of these files together without issue (e.g. `cat dedup1.ldjson dedup2.ldjson > my_precomputed.ldjson`) to continue a set of precomputed results in the long term.

Note that the results file `new_results.ldjson` will not contain any of the results that you provide to the `--precomputed_ldjson` argument. This is to avoid adding too many duplicate entries when you concatenate the files. It isn't a problem if there are duplicate entries in there, we internally deal with it, but it does slow things down and make the files bigger.

Here's a basic workflow using precomputed results.


```
nextflow run -profile docker -resume -r 1.2.6-alpha ccdmb/predector \
  --proteome my_old_proteome.fasta

cp -L results/deduplicated/new_results.ldjson ./precomputed.ldjson

nextflow run -profile docker -resume -r 1.2.6-alpha ccdmb/predector \
  --proteome my_new_proteome.fasta --precomputed_ldjson ./precomputed.ldjson

cat results/deduplicated/new_results.ldjson >> ./precomputed.ldjson
```

Any proteins in the first proteome will be skipped when you run the new one.
I imagine this should speed up running new proteomes or re-running a newer version of the pipeline, as the actual versions of the software behind it don't change often.

Note that database searches are only assigned versions if the pipeline downloads the actual files.
If you provide pre-downloaded copies, the pipeline won't skip these searches.
This is just because we can't figure out what version a database is from the filename, and it ensures consistency.
The database searches are not a particularly time-consuming part of the pipeline anyway, so I don't expect this to be a big issue.
Please let us know if you feel otherwise.


Future versions may be able to download precomputed results from a server.
It's something we're working on.


### Cleaning up

Nextflow will dump a bunch of things in the directory that you run it in, and if you've run a lot of
datasets it might be taking up a lot of space or the many files might slow down your filesystem.
Note that the results will only be [symbolically linked](https://en.wikipedia.org/wiki/Symbolic_link) from the `work` directory.
If you need to copy files from the results folder, make sure you use the `-L` flag to `cp`.

Once you've got what you need from the `results` folder:

```
rm -rf -- work results .nextflow*
```

Will clean up what's in your working directory.
