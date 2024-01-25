# This script must be used from the decont repository

# Download all the files specified in data/urls
# for url in $(egrep '^https://*' data/urls)
# do
#    bash scripts/download.sh $url data
# done

# Identify fastq files already downloaded and urls to download
fastq_files=$(ls data | egrep '*.fastq.gz$')
urls_list=$(egrep '^https://*' data/urls)

# Check if files in data/urls are downloaded
# if not, dowload them
echo "Downloading data files:"
if [ -z "$fastq_files" ]; then
   wget -i data/urls -P data
else
   for url in $urls_list
   do
      download_file=$(basename $url)
      if [ -e data/$download_file ]; then
         echo "$download_file already downloaded"
      else
         wget -P data -N $url
      fi
   done
fi

# Check MD5
echo "Cheking MD5 for downloaded files: "
for url in $urls_list
do
   download_file=$(basename $url)
   if [ -e data/$download_file ]; then
        md5_url=${url}.md5
        md5_expected=$(wget -qO- $md5_url | cat | cut -d " " -f 1)
        md5_obteined=$(md5sum data/$download_file  | cut -d " " -f 1)
        if [ $md5_expected == $md5_obteined ]; then
           echo "MD5 of '$download_file' successfully verified"
        else
           echo "Error! MD5 verification failed for '$download_file'."
        fi
   fi
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
echo "Downloading contaminants file: "
if [ -e res/contaminants.fasta ]; then
   echo "Contaminants.fasta file already exists"
else
   bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes "small nuclear RNA" 
fi

# Index the contaminants file
echo "Indexing contaminants: "
if [[ ! -d res/contaminants_idx ]] || [[ ! "$(ls res/contaminants_idx)" ]]; then
   bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
else
   echo "Contaminants already indexed"
fi

# Identify a list of sample IDs (sid)
list_sids=$(ls data/*.fastq.gz | cut -d"-" -f1 | sed "s:data/::" | uniq)

# Merge the samples into a single file for each sid
echo "Merging samples "
for sid in $list_sids
do
   if [ ! -e out/merged/$sid* ]; then
      bash scripts/merge_fastqs.sh data out/merged $sid
   else
      echo "$sid already merged"
   fi
done

# Create output directories
mkdir -p out/trimmed
mkdir -p log/cutadapt

# Remove the adapters from the data merged
echo "Removing adapters: "
for sid  in $list_sids
do
   if [[ ! -e log/cutadapt/$sid.log ]] || [[ ! -e out/trimmed/$sid.trimmed.fastq.gz ]]; then
      cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        -o out/trimmed/"$sid".trimmed.fastq.gz out/merged/"$sid".fastq.gz > log/cutadapt/"$sid".log
   else
      echo "Adaptamers already removed for $sid"
   fi
done

# Run STAR alignment for all trimmed files and keep the non-aligned reads
echo "Running alignment: "
for fname in out/trimmed/*.fastq.gz
do
    # Obtain the sample ID from the filename
    sid=$(basename $fname .trimmed.fastq.gz)
    mkdir -p out/star/$sid
    if [ ! "$(ls out/star/$sid)" ]; then
	STAR --runThreadN 4 --genomeDir res/contaminants_idx \
         --outReadsUnmapped Fastx --readFilesIn $fname \
         --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid/
   else
      echo "Alignment keeping the non-aligned reads already done for $sid"
   fi
done


# Create a log file (pipeline.log) containing information from cutadapt and star logs
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
if [ -e "log/pipeline.log" ]; then
   echo "The log file containing info from cutadapt and star logs already exists"
else
   for sid in $list_sids
   do
      echo "$sid:" && (cat log/cutadapt/$sid.log | egrep 'Reads with adapters|Total basepairs'| sed 's/:[[:space:]]*/: /g') && (cat out/star/$sid/Log.final.out | egrep 'Uniquely mapped reads %|Number of reads mapped to (multiple|too many) loci' | sed 's/^[[:space:]]*//;s/ |[[:space:]]*/: /') && echo " "
   done >> log/pipeline.log
fi
