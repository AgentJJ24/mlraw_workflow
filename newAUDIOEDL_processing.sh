#!/bin/bash

for i in *.edl; do

COUNTER=001
id="nothing"
OCCUR=001
EVENTCOUNT=000
EVENTCOUNT2=000

filename=$(basename "$i")
newEDL="${filename%.*}"

echo "Processing File: $filename"

#PRINT TITLE LINE AT BEGINNING
awk "/TITLE/ {print; exit}" ./"$filename" >> "$newEDL"rev.edl
echo "" >> "$newEDL"rev.edl

while [  $COUNTER -lt 999 ]; do
    eventNo=$(awk "BEGIN { printf(\"%03d\", $COUNTER)}")

    #PROCESS EACH EVENT LINE AND PRINT REVISED EVENT IN NEW EDL
	#CHECK IF LINE IS A "BL" BLANK VIDEO LINE (WHICH DOESN'T COME WITH "FROM CLIP NAME" COMMENT)
	checker=$(awk "/$eventNo  BL/ {print; exit}" ./"$filename")
	check="${checker:5:2}"
	if [ "$check" = "BL" ]; 
		then
		awk "/$eventNo  BL/ {print; exit}" ./"$filename"  >> "$newEDL"rev.edl
		echo "" >> "$newEDL"rev.edl
		EVENTCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT + 1)}")
	else
    		OCCUR=$(awk "BEGIN { printf(\"%03d\", $OCCUR)}")

  		#CREATE NEW REELNAME (#MAKE SURE PREVIOUS REEL NAME DOESN'T HAVE "*" IN THE NAME)
			id=$(awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: //") 
			testA="${id:16:3}"
			testB="${id:0:4}"
			testC="${id:4:3}"

		#FILE IS A MOV FILE (DERIVED FROM MLRAW AND PREVIOUSLY RENAMED) (ex: 002_M04-1334rev.mov)
		if [ "$testA" = "mov" ];
			then	
			reelname="${id:1:2}""${id:5:2}""${id:8:4}"
			awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"rev.edl
			awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" >> "$newEDL"rev.edl
			echo "" >> "$newEDL"rev.edl
			EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")

		#FILE IS A MOV FILE (STRAIGHT FROM CANON DEFAULT) (ex: 007_MVI_3691.mov)
		elif [ "$testC" = "MVI" ];
			then	
			reelname="${id:0:3}""${id:8:4}"" "
			awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"rev.edl
			awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" >> "$newEDL"rev.edl
			echo "" >> "$newEDL"rev.edl
			EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")

		#FILE IS A WAV TAKE FILE
		elif [ "$testB" = "Take" ];
			then	
			test1="${id:5:1}"
			test2="${id:6:1}"
			test3="${id:7:1}"
			test4="${id:8:1}"
            # SPECIAL FIX CASES
			test6="${id:21:1}"
			test7="${id:20:1}"
			test8="${id:19:1}"
	
			#TEST TAKE NAME LENGTH
			if [ "$test1" = "." ];
				then
				reelname="01""A0000""${id:4:1}"
			fi
			if [ "$test2" = "." ];
				then
				reelname="01""A000""${id:4:2}"
			fi
			if [ "$test3" = "." ];
				then
				reelname="01""A00""${id:4:3}"
			fi
			if [ "$test4" = "." ];
				then
				reelname="01""A0""${id:4:4}"
			fi
            if [ "$test4" = "." ];
                then
                reelname="01""A""${id:4:5}"
            fi
			if [ "$test6" = "." ];
				then
				reelname="01""X00""${id:18:3}"
			fi
			if [ "$test7" = "." ];
				then
				reelname="01""X000""${id:18:2}"
			fi
			if [ "$test8" = "." ];
				then
				reelname="01""X0000""${id:18:3}"
			fi

			#REPLACE WITH NEW REEL NAME AND INSERT THE SAME "FROM CLIP" LINE IN REVISED EDL 
			#MAKE SURE PREVIOUS REEL NAME DOESN'T HAVE "*" IN THE NAME
			awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"rev.edl
			awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" >> "$newEDL"rev.edl	
			echo "" >> "$newEDL"rev.edl
			EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")
			
		fi
		OCCUR=$(awk "BEGIN { printf(\"%03d\", $OCCUR + 1)}")
	fi
		reelname=""
		let COUNTER=COUNTER+1 
done
	FINALCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + $EVENTCOUNT)}")
	echo "......Processed $FINALCOUNT Events for $filename"
done

