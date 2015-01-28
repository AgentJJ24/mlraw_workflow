#!/bin/bash

mkdir ./embedMetaWAVs

toplevel=$(pwd)


for folder in ./*; do
    [ -d $folder ] && cd "$folder"
    foldername="${folder:2:2}"

for i in *.wav; do

id="nothing"

filename=$(basename "$i")
bakename="${filename%.*}"

echo "Processing File: $filename in $folder with $foldername"

  		#CREATE NEW REELNAME (#MAKE SURE PREVIOUS REEL NAME DOESN'T HAVE "*" IN THE NAME)
			id="$i"
			testA="${id:0:4}"

		#FILE IS A WAV TAKE FILE
		if [ "$testA" = "Take" ];
			then	
			test1="${id:5:1}"
			test2="${id:6:1}"
			test3="${id:7:1}"
			test4="${id:8:1}"
            # SPECIAL FIX CASES
			test6="${id:7:1}"
			test7="${id:6:1}"
			test8="${id:5:1}"
	
			#TEST TAKE NAME LENGTH
            if [ "$test6" = "x" ];
                then
                reelname="$foldername""X00""${id:4:3}"
            elif [ "$test7" = "x" ];
                then
                reelname="$foldername""X000""${id:4:2}"
            elif [ "$test8" = "x" ];
                then
                reelname="$foldername""X0000""${id:4:1}"
			elif [ "$test1" = "." ];
				then
				reelname="$foldername""A0000""${id:4:1}"
			elif [ "$test2" = "." ];
				then
				reelname="$foldername""A000""${id:4:2}"
			elif [ "$test3" = "." ];
				then
				reelname="$foldername""A00""${id:4:3}"
			elif [ "$test4" = "." ];
				then
				reelname="$foldername""A0""${id:4:4}"
			elif [ "$test4" = "." ];
                then
                reelname="$foldername""A""${id:4:5}"
            fi

            #CREATE XMP METADATA

            dd if=../baselineXMP.xml bs=1 skip=0 count=806 seek=0 conv=notrunc of=./"$reelname"_XMP.xml
            echo "$reelname" >> ./"$reelname"_XMP.xml
            dd if=../baselineXMP.xml bs=1 skip=819 count=161 seek=814 conv=notrunc of=./"$reelname"_XMP.xml


            cp ./"$i" ../embedMetaWAVs/"$reelname".wav
            bwfmetaedit --Description="sTAPE=$reelname" ../embedMetaWAVs/"$reelname".wav
            ###-For Reel Name ("Tape Name") to be read by Premiere:
            ###-Must be embedded via XMP embedding in WAV File
            bwfmetaedit --in-XMP=./"$reelname"_XMP.xml ../embedMetaWAVs/"$reelname".wav
            ###*** NOTE THAT THIS MUST CHANGE ACTUAL "TAPE NAME" in THE XMP-XML TO WHAT YOU NEED!

            rm ./"$reelname"_XMP.xml

	else
            echo "$filename is not a audio take..."
        fi
done

cd "$toplevel"

done

