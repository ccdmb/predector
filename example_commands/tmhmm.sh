INFILE="in.fasta"
OUTFILE="out.txt"

tmhmm -short -d < "${INFILE}" > "${OUTFILE}"

# This creates a *lot* of temporary files that it doesn't clean up.
rm -rf -- TMHMM_*
