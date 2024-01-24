
if [ $# == 0 ]; then
   rm -r res/* out/* log/* data/*.fastq*
else
   if [ "$@" == "data" ]; then
	rm -r data/*.fastq*
   elif [ "$@" == "resources" ]; then
	rm -r res/*
   elif [ "$@" == "outputs" ]; then
        rm -r out/*
   elif [ "$@" == "logs" ]; then
        rm -r log/*
   fi
fi
