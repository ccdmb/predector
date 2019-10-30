DOMAIN="euk"  # can also be bac or arc
INFILE=in.fasta
PREFIX=out
# Outfile will be "${PREFIX}_summary.signalp5"

TMPDIR="tmp$$"

mkdir -p "${TMPDIR}"
signalp -org "${DOMAIN}" -format short -tmp "${TMPDIR}" -fasta "${INFILE}" -prefix "${PREFIX}"

rm -rf -- "${TMPDIR}"
