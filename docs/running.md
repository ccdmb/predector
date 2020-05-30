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


