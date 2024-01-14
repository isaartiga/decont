# This script should merge all files from a given sample (the sample id(sid) is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

origen_directory=$1
output_directory=$2
sid=$3

mkdir -p out/merged

cat ${origen_directory}/${sid}* > ${output_directory}/${sid}.fastq.gz
