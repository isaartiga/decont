# This script downloads the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) is the word "yes"
# - filter the sequences based on a word contained in their header lines ($4):
#   sequences containing the specified word in their header are **excluded**

# Capture input parameters from command arguments
url=$1
destination_directory=$2
unzip_yes_no=$3
filter=$4

# Download the file from the specified URL ($url) in the specified directory ($destination_directory).
wget -P ${destination_directory} -N ${url}

#   Check if the unzip flag ($unzip_yes_no) is set to "yes", if True, unzip the downloaded file keeping the original zip file.
if [ ${unzip_yes_no} = "yes" ]; then
        gunzip -k ${destination_directory}/$(basename ${url})
fi

#   Check if a filter is provided ($filtered), then use AWK to filter the contents of the file, excluding sequences that contain the filter words in their description.
if [ -n "$filter" ]; then
	awk -v filter="$filter" '$0 ~ filter {flag=1; next} />/{flag=0} !flag' ${destination_directory}/$(basename ${url} .gz ) >  ${destination_directory}/$(basename ${url} .gz ).filtered 
fi

#  Copy the filtered content to the original unzip file and remove the original filtered file
cp -f ${destination_directory}/$(basename ${url} .gz).filtered ${destination_directory}/$(basename ${url} .gz)
rm ${destination_directory}/$(basename ${url} .gz).filtered
