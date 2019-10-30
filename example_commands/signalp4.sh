DOMAIN="euk"  # can also be bac or arc
INFILE=in.fasta
OUTFILE=out.txt

signalp -t "${DOMAIN}" -f short "${INFILE}" > "${OUTFILE}"
