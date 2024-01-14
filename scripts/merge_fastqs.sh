# This script merges all files from a given sample (the sample id(sid) is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

# Capture input parameters from command arguments
origen_directory=$1
output_directory=$2
sid=$3

# Create output directory in case it doesn´t exist
mkdir -p out/merged

# Merge the fastqs from the same sample into a single file 
cat ${origen_directory}/${sid}* > ${output_directory}/${sid}.fastq.gz
