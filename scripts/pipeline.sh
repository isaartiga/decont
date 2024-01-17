#Download all the files specified in data/filenames
for url in $(egrep '^https://*' data/urls) #TODO
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear RNA" #TODO

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

list_sids=$(ls data/*.fastq.gz | cut -d"-" -f1 | sed "s:data/::" | uniq)
# Merge the samples into a single file
for sid in $list_sids #TODO
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# Install cutadapt and create output directories 
mamba install -y cutadapt
mkdir -p out/trimmed
mkdir -p log/cutadapt

# Remove the adapters from the data merged
for sid  in $list_sids
do 
   cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
     -o out/trimmed/"$sid".trimmed.fastq.gz out/merged/"$sid".fastq.gz > log/cutadapt/"$sid".log
done

# TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename $fname .trimmed.fastq.gz)
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
        --outReadsUnmapped Fastx --readFilesIn $fname \
        --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid/
done

# Create a log file (Log.out) containing information from cutadapt and star logs
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci

for sid in $list_sids
do 
   (echo "$sid:" && cat log/cutadapt/$sid.log |\
   egrep 'Reads with adapters|Total basepairs'|\
   sed 's/:[[:space:]]*/: /g' && \
   cat out/star/$sid/Log.final.out |\
   egrep 'Uniquely mapped reads %|Number of reads mapped to (multiple|too many) loci|' |\
   sed 's/^[[:space:]]*//;s/ |[[:space:]]*/: /' && \
   echo " ")\
   >> Log.out
done


