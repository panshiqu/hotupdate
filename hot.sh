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
		rm -rf publish/3*
	else
		exit
	fi
fi

traverse project

#mkdir
for (( i=0; i<$1; i++ )); do
	mkdir -p "publish/${1}/${i}_to_${1}"
done

cat $md5file | while read line; do
	md5=${line:0:32}
	name=${line:33}

	#diff version
	for (( i=0; i<$1; i++ )); do
		if [ "$(cat publish/$i.md5 | grep $name | awk '{ print $1 }')" != "$md5" ]; then
			cp $name ${name/#project/publish\/${1}\/${i}_to_${1}}
		fi
	done
done
