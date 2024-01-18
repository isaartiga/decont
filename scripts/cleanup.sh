
if [ $# == 0 ]; then
   rm -r res/* out/* log/* data/*.gz
else
   if [ "$@" == "data" ]; then
	rm -r data/*gz
   elif [ "$@" == "resources" ]; then
	rm -r res/*
   elif [ "$@" == "outputs" ]; then
        rm -r out/*
   elif [ "$@" == "logs" ]; then
        rm -r log/*
   fi
fi
