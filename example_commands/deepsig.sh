INFILE="in.fasta"
OUTFILE="out.txt"
DOMAIN="euk"

deepsig.py -f "${INFILE}" -o "${OUTFILE}" -k "${DOMAIN}"
