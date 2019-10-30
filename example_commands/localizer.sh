INFILE="in.fasta" # These should be mature sequences from signalp
OUTDIR="out"  # Results will go in "${OUTDIR}/Results.txt"

LOCALIZER.py -e -M -i "${INFILE}" -o "${OUTDIR}"
