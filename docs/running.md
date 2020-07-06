## Running the pipeline

To run predector you need your input proteomes as uncompressed fasta files, and a downloaded copy of the [PHI-base](http://www.phi-base.org/) fasta file.

Assuming that you've installed the dependencies, and know which dependency system you're using (conda, docker, or singularity), you can run like so:

```bash
nextflow run -profile docker ccdmb/predector --phibase phibase-latest.fas --proteome "my_proteomes/*.faa"
```

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
  default: '${params.outdir}'

--tracedir <path>
  Directory to store pipeline runtime information
  default: '${params.outdir}/pipeline_info'

--chunk_size <int>
  The number of proteins to run as a single chunk in the pipeline
  default: '${params.chunk_size}'

--nostrip
  Don't strip the proteome filename extension when creating the output filenames
  default: false
```

### Configuration

You can provide your own nextflow config files to the `-config` parameter <https://www.nextflow.io/docs/latest/config.html>.
This enables you to tune the number of CPUs used per task etc to your own computing system.

We'll try to add some details on how to do this soon.
For now I suggest you copy one of the files in <https://github.com/ccdmb/predector/tree/master/conf>, and modify as needed.


### Providing pre-downloaded Pfam and dbCAN datasets.

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

This will skip the download step at the beginning and just use those files, which saves a few minutes.
