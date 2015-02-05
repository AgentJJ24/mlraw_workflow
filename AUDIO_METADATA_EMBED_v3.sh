#!/bin/bash

pipeline=$1
pullup="pullup"
pulldown="pulldown"
same="same"

mkdir ./embedMetaWAVs

toplevel=$(pwd)


for folder in ./*; do
    [ -d $folder ] && cd "$folder"
    foldername="${folder:2:2}"

    rm *.pek
    rm *.pkf

for i in *.wav; do

id="nothing"
reelname="NULL"

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
            test9="${id:21:1}"
            test10="${id:20:1}"
            test11="${id:19:1}"

			#TEST TAKE NAME LENGTH
            #In the Future, the "01" will be the actual reelfolder that the audio is in.  But for now, this is easier
            if [ "$test6" = "x" ];
                then
                reelname="01""X00""${id:4:3}"
            elif [ "$test7" = "x" ];
                then
                reelname="01""X000""${id:4:2}"
            elif [ "$test8" = "x" ];
                then
                reelname="01""X0000""${id:4:1}"
			elif [ "$test1" = "." ];
				then
				reelname="01""A0000""${id:4:1}"
			elif [ "$test2" = "." ];
				then
				reelname="01""A000""${id:4:2}"
			elif [ "$test3" = "." ];
				then
				reelname="01""A00""${id:4:3}"
			elif [ "$test4" = "." ];
				then
				reelname="01""A0""${id:4:4}"
			elif [ "$test4" = "." ];
                then
                reelname="01""A""${id:4:5}"
            elif [ "$test9" = "." ];
                then
                reelname="01X00""${id:18:3}"
            elif [ "$test10" = "." ];
                then
                reelname="01X000""${id:18:2}"
            elif [ "$test11" = "." ];
                then
                reelname="01X0000""${id:18:1}"
            fi

            #CREATE XMP METADATA
            dd if=../baselineXMP.xml bs=1 skip=0 count=806 seek=0 conv=notrunc of=./"$reelname"_XMP.xml >> quiet.txt 2>&1
            echo "$reelname" >> ./"$reelname"_XMP.xml
            dd if=../baselineXMP.xml bs=1 skip=819 count=161 seek=814 conv=notrunc of=./"$reelname"_XMP.xml >> quiet.txt 2>&1

            #Gather Time Reference Metadata
            ffmpeg -y -i ./"$i" -f ffmetadata ./"$reelname"_METADATA >> quiet.txt 2>&1
            time_reference=$(awk "/time_reference/ {print; exit}" ./"$reelname"_METADATA | sed "s/\time_reference=//")
            rm ./"$reelname"_METADATA >> quiet.txt 2>&1
            echo "Time Reference: $time_reference "

            #Recalculate TimeReference TC stamp on BWAV if necessary (like going from Premiere to Lightworks)

            if [[ -z $1 ]]; then
                echo " WARNING!  Must specify command line argument: 'pulldown' or 'pullup' or 'same' to recalculate BWAV's BWF TC TimeReference stamp "
                exit
            fi
            if [[ $pipeline = $pulldown ]]; then
                old_tr="$time_reference"
                time_reference=$((time_reference*1000/1001))
                echo "...Changing pulled down TimeReference from $old_tr to $time_reference ..."
            elif [[ $pipeline = $pullup ]]; then
                old_tr="$time_reference"
                time_reference=$((time_reference*1001/1000))
                echo "...Changing pulled up TimeReference from $old_tr to $time_reference ..."
            elif [[ $pipeline = $same ]]; then
                echo "same" >> quiet.txt 2>&1
                echo "...No TC stamp change"
            else
                echo " WARNING!  Must specify command line argument: 'pulldown' or 'pullup' or 'same' to recalculate BWAV's BWF TC TimeReference stamp "
                exit
            fi


            #Create Embedded WAV file in new folder
            ffmpeg -y -i ./"$i" -codec copy ../embedMetaWAVs/"$reelname".wav >> quiet.txt 2>&1
            echo "Creating $reelname from $i ..."
            bwfmetaedit --Description="sTAPE=$reelname" ../embedMetaWAVs/"$reelname".wav >> quiet.txt 2>&1
            bwfmetaedit --Timereference="$time_reference" ../embedMetaWAVs/"$reelname".wav >> quiet.txt 2>&1
            ###-For Reel Name ("Tape Name") to be read by Premiere:
            ###-Must be embedded via XMP embedding in WAV File
            bwfmetaedit --in-XMP=./"$reelname"_XMP.xml ../embedMetaWAVs/"$reelname".wav >> quiet.txt 2>&1
            ###*** NOTE THAT THIS MUST CHANGE ACTUAL "TAPE NAME" in THE XMP-XML TO WHAT YOU NEED!

            rm ./"$reelname"_XMP.xml
            rm ./quiet.txt


		
	else
            echo "$filename is not a audio take..."
        fi
done

cd "$toplevel"

done

