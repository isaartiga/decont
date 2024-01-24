# This script indexs the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# Capture input parameters from command arguments
target=$1
output_directory=$2

# Create the output directory if it doesn´t exist
mkdir -p res/$(basename ${target} .fasta)_idx

# Index genome/contaminants
STAR --runThreadN 4 --runMode genomeGenerate --genomeDir res/$(basename ${target} .fasta)_idx \
--genomeFastaFiles ${target} --genomeSAindexNbases 9
