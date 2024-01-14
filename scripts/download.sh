# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
#19
url=$1
destination_directory=$2
unzip_yes_no=$3
filtered=$4

wget -P ${destination_directory} -N ${url}

if [ ${unzip_yes_no} = "yes" ]; then
        gunzip -k ${destination_directory}/$(basename ${url})
fi

if [ -n "$filtered" ]; then
	echo ${filtered}
	awk -v filtered="$filtered" '$0 ~ filtered {flag=1; next} />/{flag=0} !flag' ${destination_directory}/$(basename ${url} .gz ) >  ${destination_directory}/$(basename ${url} .gz ).filtered 
fi

