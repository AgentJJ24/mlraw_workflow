#!/bin/bash
echo "Specify first argument as EDL to process and second argument as task."
echo "Tasks:"
echo "'scan': Rename's REELNAME with first 8 characters of filename (in comments like from Premiere) and sorts EDL into C-Mode (ReelName) for 'Scanning' Online "
echo "'special': Special fix for First Five Years EDLs"
fileinput=$1
taskselect=$2



####################################################################################################################################################################################################
################################################################################   SCAN EDL  #######################################################################################################
####################################################################################################################################################################################################
if [ "$taskselect" = "scan" ]; then

for i in "$fileinput"; do

COUNTER=001
id="nothing"
OCCUR=001
EVENTCOUNT=000
EVENTCOUNT2=000

filename=$(basename "$i")
newEDL="${filename%.*}"

echo "Processing to create Scan EDL from File: $filename"

#PRINT TITLE LINE AT BEGINNING
rm -rf ./"$newEDL"_SCAN.edl
rm -rf ./"$newEDL"_FILELIST.txt
awk "/TITLE/ {print; exit}" ./"$filename" >> "$newEDL"_SCAN.edl
echo "" >> "$newEDL"_SCAN.edl

while [  $COUNTER -lt 999 ]; do
    eventNo=$(awk "BEGIN { printf(\"%03d\", $COUNTER)}")

    #PROCESS EACH EVENT LINE AND PRINT REVISED EVENT IN NEW EDL
	#CHECK IF LINE IS A "BL" BLANK VIDEO LINE (WHICH DOESN'T COME WITH "FROM CLIP NAME" COMMENT)
	checker=$(awk "/$eventNo  BL/ {print; exit}" ./"$filename")
	check="${checker:5:2}"
	if [ "$check" = "BL" ]; 
		then
		awk "/$eventNo  BL/ {print; exit}" ./"$filename"  >> "$newEDL"temp.edl
        #echo "" >> "$newEDL"temp.edl
		EVENTCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT + 1)}")
	else
    		OCCUR=$(awk "BEGIN { printf(\"%03d\", $OCCUR)}")

  		#CREATE NEW REELNAME (#MAKE SURE PREVIOUS REEL NAME DOESN'T HAVE "*" IN THE NAME)
			id=$(awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: //") 
			testA="${id:18:3}"
			testB="${id:0:4}"
			testC="${id:4:3}"

		#FILE IS A MOV FILE (DERIVED FROM MLRAW AND PREVIOUSLY RENAMED) (ex: 002_M04-1334rev.mov)
		if [ "$testA" = "mov" ];
			then	
			reelname="${id:0:8}"
			awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"temp.edl
			awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" >> "$newEDL"_FILELIST.txt
            #echo "" >> "$newEDL"temp.edl
			EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")			
		fi
		OCCUR=$(awk "BEGIN { printf(\"%03d\", $OCCUR + 1)}")
	fi
		reelname=""
		COUNTER=$(awk "BEGIN { printf(\"%03d\", $COUNTER + 1)}")
done
	FINALCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + $EVENTCOUNT)}")
	echo "......Processed $FINALCOUNT Events for $filename"
done

echo ""
echo "Sorting by ReelName"
sort -k 2 "$newEDL"temp.edl >> "$newEDL"_INTER.edl
rm -rf ./"$newEDL"temp.edl


COUNTER=001

echo "Renumbering events..."
while [  $COUNTER -lt 1000 ]; do
    eventNo=$(awk "BEGIN { printf(\"%03d\", $COUNTER)}")

    awk "/V     C/{i++}i==$eventNo{print; exit}" ./"$newEDL"_INTER.edl | sed "s/[^*][^*][^*]\(  [^*][^*][^*][^*][^*][^*][^*][^*] V     C        [^*][^*][^*][^*][^*][^*][^*][^*][^*][^*][^*] [^*][^*][^*][^*][^*][^*][^*][^*][^*][^*][^*] [^*][^*][^*][^*][^*][^*][^*][^*][^*][^*][^*] [^*][^*][^*][^*][^*][^*][^*][^*][^*][^*][^*]\).*/$eventNo\1/" >> "$newEDL"_SCAN.edl

    echo -ne "...event $eventNo\r"
    
    COUNTER=$(awk "BEGIN { printf(\"%03d\", $COUNTER + 1)}")

done

echo ""

rm -rf ./"$newEDL"_INTER.edl


####################################################################################################################################################################################################
################################################################################   SPECIAL   #######################################################################################################
####################################################################################################################################################################################################

elif [ "$taskselect" = "special" ]; then

for i in "$fileinput"; do

COUNTER=001
id="nothing"
OCCUR=001
EVENTCOUNT=000
EVENTCOUNT2=000

filename=$(basename "$i")
newEDL="${filename%.*}"

rm -rf ./"$newEDL"_FIX.edl

echo "Processing Special Fix for File: $filename"

awk "/TITLE/ {print; exit}" ./"$filename" >> "$newEDL"_FIX.edl
echo "" >> "$newEDL"_FIX.edl

    while [  $COUNTER -lt 999 ]; do
        eventNo=$(awk "BEGIN { printf(\"%03d\", $COUNTER)}")

        #PROCESS EACH EVENT LINE AND PRINT REVISED EVENT IN NEW EDL
        #CHECK IF LINE IS A "BL" BLANK VIDEO LINE (WHICH DOESN'T COME WITH "FROM CLIP NAME" COMMENT)
        checker=$(awk "/$eventNo  BL/ {print; exit}" ./"$filename")
        check="${checker:5:2}"
        if [ "$check" = "BL" ]; then
            awk "/$eventNo  BL/ {print; exit}" ./"$filename"  >> "$newEDL"_FIX.edl
            echo "" >> "$newEDL"_FIX.edl
            EVENTCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT + 1)}")
        else
            OCCUR=$(awk "BEGIN { printf(\"%03d\", $OCCUR)}")

            #CREATE NEW REELNAME (#MAKE SURE PREVIOUS REEL NAME DOESN'T HAVE "*" IN THE NAME)
            id=$(awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: //")
            testA="${id:18:3}" # Correctly Labelled
            testB="${id:12:3}" # Original "rev" or "cat" file
            testC="${id:4:3}" # MVI MOV test
            testD="${id:0:1}" # Messed up April 11 files

#echo "id: $id"
#echo "TESTS.  A: $testA B: $testB C: $testC D: $testD"

            #FILE IS A CORRECTLY NAMED MOV FILE 
            if [ "$testA" = "mov" ]; then
                reelname="${id:0:8}"
                awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"_FIX.edl
                reelnameext="$reelname""_00000000.mov"
                awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: $id/\* FROM CLIP NAME: $reelnameext/" >> "$newEDL"_FIX.edl
                echo "" >> "$newEDL"_FIX.edl
                EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")

            #FILE IS A MOV FILE THAT WAS ORIGINALLY SHOT AS SUCH
            elif [ "$testC" = "MVI" ]; then
                if [ "${id:1:2}" = "04" ] || [ "${id:1:2}" = "05" ] || [ "${id:1:2}" = "06" ] || [ "${id:1:2}" = "07" ] || [ "${id:1:2}" = "08" ]; then
                    reelname="${id:1:2}""05""${id:8:4}"
                elif [ "${id:1:2}" = "01" ] || [ "${id:1:2}" = "02" ] || [ "${id:1:2}" = "03" ]; then
                    reelname="${id:1:2}""04""${id:8:4}"
                elif [ "${id:1:2}" = "09" ] || [ "${id:1:2}" = "10" ] || [ "${id:1:2}" = "11" ]; then
                    reelname="${id:1:2}""06""${id:8:4}"
                elif [ "${id:1:2}" = "12" ] || [ "${id:1:2}" = "13" ] || [ "${id:1:2}" = "14" ] || [ "${id:1:2}" = "15" ] || [ "${id:1:2}" = "16" ]; then
                    reelname="${id:1:2}""11""${id:8:4}"
                elif [ "${id:1:2}" = "17" ] || [ "${id:1:2}" = "18" ] || [ "${id:1:2}" = "19" ] || [ "${id:1:2}" = "20" ]; then
                    reelname="${id:1:2}""12""${id:8:4}"
                elif [ "${id:1:2}" = "21" ] || [ "${id:1:2}" = "22" ] || [ "${id:1:2}" = "23" ] || [ "${id:1:2}" = "24" ] || [ "${id:1:2}" = "25" ] || [ "${id:1:2}" = "26" ] || [ "${id:1:2}" = "27" ] || [ "${id:1:2}" = "28" ] || [ "${id:1:2}" = "29" ] || [ "${id:1:2}" = "30" ] || [ "${id:1:2}" = "31" ] || [ "${id:1:2}" = "32" ]; then
                    reelname="${id:1:2}""13""${id:8:4}"
                elif [ "${id:1:2}" = "33" ] || [ "${id:1:2}" = "34" ] || [ "${id:1:2}" = "35" ] || [ "${id:1:2}" = "36" ] || [ "${id:1:2}" = "37" ] || [ "${id:1:2}" = "38" ]; then
                    reelname="${id:1:2}""18""${id:8:4}"
                elif [ "${id:1:2}" = "42" ] || [ "${id:1:2}" = "45" ]; then
                    reelname="${id:1:2}""19""${id:8:4}"
                elif [ "${id:1:2}" = "52" ] || [ "${id:1:2}" = "53" ] || [ "${id:1:2}" = "54" ] || [ "${id:1:2}" = "55" ] || [ "${id:1:2}" = "56" ] || [ "${id:1:2}" = "57" ] || [ "${id:1:2}" = "58" ]; then
                    reelname="${id:1:2}""21""${id:8:4}"
                else
                    echo "WARNING..."
                    echo "Cannot find proper reel match of ${id:1:2} for $id"
                fi

                awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"_FIX.edl
reelnameext="$reelname""_00000000.mov"
awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: $id/\* FROM CLIP NAME: $reelnameext/" >> "$newEDL"_FIX.edl
                echo "" >> "$newEDL"_FIX.edl
                EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")


            # MOV (DERIVED FROM MLRAW AND PREVIOUSLY RENAMED) (ex: 002_M04-1334rev.mov)
            elif [ "$testB" = "rev" ]; then
                reelname="${id:1:2}""${id:5:2}""${id:8:4}"
                awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"_FIX.edl
reelnameext="$reelname""_00000000.mov"
awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: $id/\* FROM CLIP NAME: $reelnameext/" >> "$newEDL"_FIX.edl
                echo "" >> "$newEDL"_FIX.edl
                EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")

            # MOV (DERIVED FROM MLRAW AND PREVIOUSLY RENAMED) (ex: 002_M04-1334catrev.mov)
            elif [ "$testB" = "cat" ]; then
                reelname="${id:1:2}""${id:5:2}""${id:8:4}"
                awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"_FIX.edl
reelnameext="$reelname""_00000000.mov"
awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: $id/\* FROM CLIP NAME: $reelnameext/" >> "$newEDL"_FIX.edl
                echo "" >> "$newEDL"_FIX.edl
                EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")

            # April 11 mess ups
            elif [ "$testD" = "M" ]; then
                findTime="10#${id:4:4}"
                var1=916
                var2=0
                var3=1320
                var4=900
                var5=1605
                var6=1319
                var7=1724
                var8=1604
                var9=1723

                if [[ $findTime -lt $var1 ]] && [[ $findTime -gt $var2 ]]; then
                    reelname="12""${id:1:2}""${id:4:4}"
                elif [[ $findTime -lt $var3 ]] && [[ $findTime -gt $var4 ]]; then
                    reelname="13""${id:1:2}""${id:4:4}"
                elif [[ $findTime -lt $var5 ]] && [[ $findTime -gt $var6 ]]; then
                    reelname="14""${id:1:2}""${id:4:4}"
                elif [[ $findTime -lt $var7 ]] && [[ $findTime -gt $var8 ]]; then
                    reelname="15""${id:1:2}""${id:4:4}"
                elif [[ $findTime -gt $var9 ]]; then
                    reelname="16""${id:1:2}""${id:4:4}"
                else
                    echo "WARNING..."
                    echo "Cannot find proper reel match for time $findTime of $id"
                fi


                awk "/$eventNo  / {print; exit}" ./"$filename" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] /$eventNo  $reelname /" >> "$newEDL"_FIX.edl
reelnameext="$reelname""_00000000.mov"
awk "/FROM CLIP NAME/{i++}i==$OCCUR{print; exit}" ./"$filename" | sed "s/\* FROM CLIP NAME: $id/\* FROM CLIP NAME: $reelnameext/" >> "$newEDL"_FIX.edl
                echo "" >> "$newEDL"_FIX.edl
                EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")

            elif [ "$id" != "" ]; then
                echo "WARNING..."
                echo "Cannot find any suitable matches for $id"
            fi

            OCCUR=$(awk "BEGIN { printf(\"%03d\", $OCCUR + 1)}")

        fi
        reelname=""
        COUNTER=$(awk "BEGIN { printf(\"%03d\", $COUNTER + 1)}")

    done
    FINALCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + $EVENTCOUNT)}")
    echo "......Processed $FINALCOUNT Events for $filename"
done

else
    echo "Please specify either 'scan' or 'special'"
fi


echo ""

rm -rf ./"$newEDL"_INTER.edl
