#! /bin/bash

traverse() {
	for item in $1/*; do
		if [ -d $item ]; then
			#echo $item "is dir"
			traverse $item
		elif [ -f $item ]; then
			#echo $item "is file"
			md5 -r $item >> $md5file
		fi
	done
}

#check args
if [ $# != 1 ]; then
	echo "Usage: $0 version"
	exit
fi

#check md5 file
md5file="publish/$1.md5"
if [ -f $md5file ]; then
	echo "version" $1 "exists"
	read -p "clear it? [Y/n]" ch
	if [ "$(echo $ch | tr '[a-z]' '[A-Z]' | cut -c 1)" == "Y" ]; then
		rm -rf publish/$1*
	else
		exit
	fi
fi

#log version
echo $1 > project/version

traverse project

cat $md5file | while read line; do
	md5=${line:0:32}
	name=${line:33}

	#diff version
	for (( i=0; i<$1; i++ )); do
		path=${name/#project/publish\/${1}\/${i}_to_${1}}
		path=${path%/*}

		if [ ! -d $path ]; then
			mkdir -p $path
		fi

		if [ "$(cat publish/$i.md5 | grep $name | awk '{ print $1 }')" != "$md5" ]; then
			cp $name $path
		fi
	done
done

#zip
for (( i=0; i<$1; i++ )); do
	zip -jqr publish/${1}/${i}_to_${1} publish/${1}/${i}_to_${1}/*
done
