# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

target=$1
output_directory=$2

mamba install -y star

mkdir -p res/$(basename ${target} .fasta)_idx

STAR --runThreadN 4 --runMode genomeGenerate --genomeDir res/$(basename ${target} .fasta)_idx \
--genomeFastaFiles ${target} --genomeSAindexNbases 9
