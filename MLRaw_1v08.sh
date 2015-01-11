#!/bin/bash
# Goes from top directory full of Reel Directories and processes MLVs to have embedded timecode (either in metadata or filename) and delivers OpenEXR ACES files and Proxies
echo "MLRaw Bash Script version 1.08"
echo "Process 'setup' & 'online' & 'offline' from master directory (full of reel folders)"
echo "ALWAYS run this script from 2nd Level (in the Day's Reels folder that contains all the numbered reel directories."

# Break out the tools
cp -r ./TOOLS/* ./ 2> quiet.txt



num=0
curdir=$(pwd)
pipeline=$1
setupvar1=$2
offlinevar1=$2
offlinevar2=$3
offline="offline"
online="online"
setup="setup"
gather="gather"
gathervar1=$2
scanedl=$2
framehandles=$3
starteventNo=$4
endeventNo=$5
starissue="\*"
twodigits="11"

if [[ -z $1 ]]; then
    echo " WARNING!  Must specify command line argument: 'setup' or 'online' or 'offline' "

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt

exit
fi

#Get timestamp
timestamp() {
date +"%T"
}

startTimeStamp=$(timestamp)
startTimeStamp="${startTimeStamp:0:2}""${startTimeStamp:3:2}""${startTimeStamp:6:2}""${startTimeStamp:9:2}"
echo "Time Start:  $startTimeStamp"
echo ""
###############################################################################################################################################################
###############################################################################################################################################################
##############################################################    SETUP   PROCESS     #########################################################################
###############################################################################################################################################################
###############################################################################################################################################################
if [[ $pipeline = $setup ]]; then

if [[ -z $2 ]]; then
echo "ATTENTION: Specify second argument as REEL Folder(s) to setup. './*' for all Reel Folders "

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
exit
fi


for folder in "$setupvar1"; do
    [ -d $folder ] && cd "$folder"
    if [[ $folder = $starissue ]]; then  # helps us not to process anything beside a numeric reel folder
        echo "Skipping folder" $folder "...."
        cd "$curdir"
    elif [ "$folder" = "TOOLS" ]; then
        echo "Skipping folder" $folder "...."
        cd "$curdir"
    elif [ "${folder:2:1}" = "0" ] || [ "${folder:2:1}" = "1" ] || [ "${folder:2:1}" = "2" ] || [ "${folder:2:1}" = "3" ] || [ "${folder:2:1}" = "4" ] || [ "${folder:2:1}" = "5" ] || [ "${folder:2:1}" = "6" ] || [ "${folder:2:1}" = "7" ] || [ "${folder:2:1}" = "8" ] || [ "${folder:2:1}" = "9" ] ; then
        echo "Entering folder " $folder
        mkdir ./ARCHIVE >> quiet.txt 2>&1
        mkdir ./REPORTS >> quiet.txt 2>&1
        mkdir ./PROXIES >> quiet.txt 2>&1
        mkdir ./ONLINES >> quiet.txt 2>&1

#######  RENAME MLV/RAW to have proper REEL NAME ##############################################################################################################
###############################################################################################################################################################
    echo ""
    echo "Renaming MLV/RAW with REEL NAME..."

    for i in *.MLV; do
        filename=$(basename "$i")
        bakefile="${filename%.*}"

        # Check name (basically make sure not to process file with actual name "*.MLV");  Checks to make sure name starts with an "M"
        if [ "${bakefile:0:1}" = "M" ] ; then

        newfile="${bakefile:1:2}""${bakefile:4:4}"
        mv "$filename" "$folder""$newfile".MLV >> quiet.txt 2>&1
        for ii in "$bakefile".M*; do
            filename2=$(basename "$ii")
            bakefile2="${filename2%.*}"
            newfile2="${bakefile:1:2}""${bakefile:4:4}"
            mv "$filename2" "$folder""$newfile2"."${filename2:9:3}" >> quiet.txt 2>&1
        done

        fi
    done

    for i in *.RAW; do
        filename=$(basename "$i")
        bakefile="${filename%.*}"

        # Check name (basically make sure not to process file with actual name "*.RAW");  Checks to make sure name starts with an "M"
        if [ "${bakefile:0:1}" = "M" ] ; then

        newfile="${bakefile:1:2}""${bakefile:4:4}"
        mv "$filename" "$folder""$newfile".RAW >> quiet.txt 2>&1
        for ii in "$bakefile".R*; do
            filename2=$(basename "$ii")
            bakefile2="${filename2%.*}"
            newfile2="${bakefile:1:2}""${bakefile:4:4}"
            mv "$filename2" "$folder""$newfile2"."${filename2:9:3}" >> quiet.txt 2>&1
        done

        fi
    done

####### Process each MLV/RAW into DNG Sequence and WAV file in MLV ############################################################################################
###############################################################################################################################################################
    echo ""
    echo "Processing MLVs into DNG Sequences and WAV files..."
    for i in *.MLV; do
        filename=$(basename "$i")
        bakefile="${filename%.*}"

        # Check name (basically make sure not to process file with actual name "*.MLV");  Checks to make sure name starts with a number
        if [ "${bakefile:0:1}" = "0" ] || [ "${bakefile:0:1}" = "1" ] || [ "${bakefile:0:1}" = "2" ] || [ "${bakefile:0:1}" = "3" ] || [ "${bakefile:0:1}" = "4" ] || [ "${bakefile:0:1}" = "5" ] || [ "${bakefile:0:1}" = "6" ] || [ "${bakefile:0:1}" = "7" ] || [ "${bakefile:0:1}" = "8" ] || [ "${bakefile:0:1}" = "9" ] ; then

        mkdir "$bakefile"
            ../mlv_dump -x "$bakefile".MLV >> quiet.txt 2>&1
            # mv ./"$bakefile".IDX ./"$bakefile"/"$bakefile".IDX
            #../mlv_dump -m -o ./"$bakefile"/"$bakefile"_tmpmeta.mlv "$bakefile".MLV  #Metadata extraction
            #../mlv_dump -v ./"$bakefile"/"$bakefile"_tmpmeta.mlv > ./"$bakefile"/"$bakefile"_meta.txt  #Metadata extraction
            #rm ./"$bakefile"/"$bakefile"_tmpmeta.mlv  #Metadata extraction
            #rm ./"$bakefile"/"$bakefile"_tmpmeta.mlv.wav  #Metadata extraction
            ../mlv_dump --dng --cs2x2 "$bakefile".MLV -o ./"$bakefile"/"$bakefile"_ >> quiet.txt 2>&1
            echo -ne "....Processing MLV into DNG & WAV:" $bakefile
            echo ""
            # rm ./"$bakefile"/"$bakefile".IDX
        mv ./"$bakefile"/"$bakefile"_.wav ./"$bakefile"/"$bakefile"_TIMECODE.WAV >> quiet.txt 2>&1
        #cp ../MLRaw*.sh ./"$bakefile"/

        fi
    done

    echo ""
    echo "Processing RAWs into DNG Sequences..."
    for i in *.RAW; do
        filename=$(basename "$i")
        bakefile="${filename%.*}"

        # Check name (basically make sure not to process file with actual name "*.RAW");  Checks to make sure name starts with a number
        if [ "${bakefile:0:1}" = "0" ] || [ "${bakefile:0:1}" = "1" ] || [ "${bakefile:0:1}" = "2" ] || [ "${bakefile:0:1}" = "3" ] || [ "${bakefile:0:1}" = "4" ] || [ "${bakefile:0:1}" = "5" ] || [ "${bakefile:0:1}" = "6" ] || [ "${bakefile:0:1}" = "7" ] || [ "${bakefile:0:1}" = "8" ] || [ "${bakefile:0:1}" = "9" ] ; then

        # Concatenate R## files into RAW
        for ii in "$bakefile".R0*; do
            filename2=$(basename "$ii")
            bakefile2="${filename2%.*}"
            if [ "${filename2:11:1}" = "0" ] || [ "${filename2:11:1}" = "1" ] || [ "${filename2:11:1}" = "2" ] || [ "${filename2:11:1}" = "3" ] || [ "${filename2:11:1}" = "4" ] || [ "${filename2:11:1}" = "5" ] || [ "${filename2:11:1}" = "6" ] || [ "${filename2:11:1}" = "7" ] || [ "${filename2:11:1}" = "8" ] || [ "${filename2:11:1}" = "9" ] ; then
                echo "Folding $filename2 into $filename"
                dd if=./"$filename2" bs=2048 >> ./"$filename" 
                rm -f ./"$filename2"
            fi
        done
        for ii in "$bakefile".R1*; do
            filename2=$(basename "$ii")
            bakefile2="${filename2%.*}"
            if [ "${filename2:11:1}" = "0" ] || [ "${filename2:11:1}" = "1" ] || [ "${filename2:11:1}" = "2" ] || [ "${filename2:11:1}" = "3" ] || [ "${filename2:11:1}" = "4" ] || [ "${filename2:11:1}" = "5" ] || [ "${filename2:11:1}" = "6" ] || [ "${filename2:11:1}" = "7" ] || [ "${filename2:11:1}" = "8" ] || [ "${filename2:11:1}" = "9" ] ; then
                echo "Folding $filename2 into $filename"
                dd if=./"$filename2" bs=2048 >> ./"$filename" 
                rm -f ./"$filename2"
            fi
        done

        mkdir "$bakefile"
        echo -ne "....Processing RAW into DNG:" $bakefile
        echo ""
            ../raw2dng_chroma2x2 ./"$bakefile".RAW ./"$bakefile"/"$bakefile"_ >> quiet.txt 2>&1
        #cp ../MLRaw*.sh ./"$bakefile"/

        fi

    done


##### Stamp each MLV/RAW and respective DNG Sequence with Timecode Stamp in File name #########################################################################
###############################################################################################################################################################

    echo ""
    echo "Retrieving Timecode from Timecode Track for .MLV files (if they have accompanying WAV file).  Updating Files..."
    echo "  Make sure Timecode Track is 24 NDF running at 23.976fps..."
    for i in *.MLV; do
        filename=$(basename "$i")
        bakefile="${filename%.*}"

        # Check name (basically make sure not to process file with actual name "*.MLV");  Checks to make sure name starts with a number
        if [ "${bakefile:0:1}" = "0" ] || [ "${bakefile:0:1}" = "1" ] || [ "${bakefile:0:1}" = "2" ] || [ "${bakefile:0:1}" = "3" ] || [ "${bakefile:0:1}" = "4" ] || [ "${bakefile:0:1}" = "5" ] || [ "${bakefile:0:1}" = "6" ] || [ "${bakefile:0:1}" = "7" ] || [ "${bakefile:0:1}" = "8" ] || [ "${bakefile:0:1}" = "9" ] ; then

            ../ltcdump -F -c 1 ./"$bakefile"/"$bakefile"_TIMECODE.WAV > ./"$bakefile"/"$bakefile"_TIMECODE.txt
        timecode=$(awk '$1 ~ /[0-9][0-9]$/' ./"$bakefile"/"$bakefile"_TIMECODE.txt | awk "/[0-9][0-9]/{i++}i=1{print; exit}" | sed -e 's/^\(.\{11\}\).*$/\1/')
        timecodeNAME="${timecode:0:2}""${timecode:3:2}""${timecode:6:2}""${timecode:9:2}"

        if [[ $timecodeNAME ]]; then
            mv "$bakefile".MLV "$bakefile"_"$timecodeNAME".MLV
            echo ""
            echo "Start Timcode: " $timecode "for" $bakefile
            numhold1="10#${timecodeNAME:0:2}"  # The #10 makes sure leading zeros are interpreted as decimal and not hex/octal/etc...
            numhold2="10#${timecodeNAME:2:2}"
            numhold3="10#${timecodeNAME:4:2}"
            numhold4="10#${timecodeNAME:6:2}"
            var60=60
            var24=24
            newnum=$((((((($var60*$numhold1)+$numhold2)*$var60)+$numhold3)*$var24)+$numhold4))
            newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 0)}") #expand out to 7 digits
            for ii in ./"$bakefile"/*.dng; do
                filename2=$(basename "$ii")
                bakefile2="${filename2%.*}"
                newname="${bakefile2:0:8}"_"$timecodeNAME"_"$newnum"
                mv ./"$bakefile"/"$bakefile2".dng ./"$bakefile"/"$newname".DNG
                newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 1)}")
                echo -ne "....Stamping Timecode for "$bakefile". Frame: "$bakefile2 "\r"
            done
            mv ./"$bakefile" ./"${bakefile2:0:8}"_"$timecodeNAME"

        elif [[ -z $timecodeNAME ]]; then
            timecodeNAME="00000000"  # No TC track, so start at 0
            echo ""
            echo "Start Timcode: " $timecodeNAME "for" $bakefile
            mv "$bakefile".MLV "$bakefile"_"$timecodeNAME".MLV
            newnum=0
            newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 0)}") #expand out to 7 digits
            for ii in ./"$bakefile"/*.dng; do
                filename2=$(basename "$ii")
                bakefile2="${filename2%.*}"
                newname="${bakefile2:0:8}"_"$timecodeNAME"_"$newnum"
                mv ./"$bakefile"/"$bakefile2".dng ./"$bakefile"/"$newname".DNG
                newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 1)}")
                echo -ne "....Stamping Timecode for " $bakefile ". Frame: " $bakefile2 "\r"
            done
            mv ./"$bakefile" ./"${bakefile2:0:8}"_"$timecodeNAME"
        fi

        fi
    done

    echo ""
    echo "Retrieving Timecode from Timecode Track for .RAW files (if they have accompanying WAV file).  Updating Files..."
    echo "...Make sure Timecode Track is 24 NDF running at 23.976fps..."
    for i in *.RAW; do
        filename=$(basename "$i")
        bakefile="${filename%.*}"

        # Check name (basically make sure not to process file with actual name "*.RAW")
        if [ "${bakefile:0:1}" = "0" ] || [ "${bakefile:0:1}" = "1" ] || [ "${bakefile:0:1}" = "2" ] || [ "${bakefile:0:1}" = "3" ] || [ "${bakefile:0:1}" = "4" ] || [ "${bakefile:0:1}" = "5" ] || [ "${bakefile:0:1}" = "6" ] || [ "${bakefile:0:1}" = "7" ] || [ "${bakefile:0:1}" = "8" ] || [ "${bakefile:0:1}" = "9" ] ; then

            ../ltcdump -F -c 1 ./"$bakefile"/"$bakefile"_TIMECODE.WAV > ./"$bakefile"/"$bakefile"_TIMECODE.txt >> quiet.txt 2>&1
        timecode=$(awk '$1 ~ /[0-9][0-9]$/' ./"$bakefile"/"$bakefile"_TIMECODE.txt | awk "/[0-9][0-9]/{i++}i=1{print; exit}" | sed -e 's/^\(.\{11\}\).*$/\1/')
        timecodeNAME="${timecode:0:2}""${timecode:3:2}""${timecode:6:2}""${timecode:9:2}"

        if [[ $timecodeNAME ]]; then
            mv "$bakefile".RAW "$bakefile"_"$timecodeNAME".RAW
            echo ""
            echo "Start Timcode: " $timecode "for" $bakefile
            numhold1="10#${timecodeNAME:0:2}"  # The #10 makes sure leading zeros are interpreted as decimal and not hex/octal/etc...
            numhold2="10#${timecodeNAME:2:2}"
            numhold3="10#${timecodeNAME:4:2}"
            numhold4="10#${timecodeNAME:6:2}"
            var60=60
            var24=24
            newnum=$((((((($var60*$numhold1)+$numhold2)*$var60)+$numhold3)*$var24)+$numhold4))
            newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 0)}") #expand out to 7 digits
            for ii in ./"$bakefile"/*.dng; do
                filename2=$(basename "$ii")
                bakefile2="${filename2%.*}"
                newname="${bakefile2:0:8}"_"$timecodeNAME"_"$newnum"
                mv ./"$bakefile"/"$bakefile2".dng ./"$bakefile"/"$newname".DNG
                newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 1)}")
                echo -ne "....Stamping Timecode for "$bakefile". Frame: "$bakefile2 "\r"
            done
            mv ./"$bakefile" ./"${bakefile2:0:8}"_"$timecodeNAME"

        elif [[ -z $timecodeNAME ]]; then
            timecodeNAME="00000000"  # No TC track, so start at 0
            echo ""
            echo "Start Timcode: " $timecodeNAME "for" $bakefile
            mv "$bakefile".RAW "$bakefile"_"$timecodeNAME".RAW
            newnum=0
            newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 0)}") #expand out to 7 digits
            for ii in ./"$bakefile"/*.dng; do
                filename2=$(basename "$ii")
                bakefile2="${filename2%.*}"
                newname="${bakefile2:0:8}"_"$timecodeNAME"_"$newnum"
                mv ./"$bakefile"/"$bakefile2".dng ./"$bakefile"/"$newname".DNG
                newnum=$(awk "BEGIN { printf(\"%07d\", $newnum + 1)}")
                echo -ne "....Stamping Timecode for " $bakefile ". Frame: " $bakefile2 "\r"
            done
            mv ./"$bakefile" ./"${bakefile2:0:8}"_"$timecodeNAME"
        fi

        fi

    done


######## Archive MLVs (and their IDX) & RAW Files; FINAL CLEAN UP #############################################################################################
###############################################################################################################################################################
    echo ""


    for i in *.M*; do
        filename=$(basename "$i")
        mv ./"$filename" ./ARCHIVE/"$filename" >> quiet.txt 2>&1
    done

    for i in *.IDX; do
        filename=$(basename "$i")
        mv ./"$filename" ./ARCHIVE/"$filename" >> quiet.txt 2>&1
    done

    for i in *.RAW; do
        filename=$(basename "$i")
        mv ./"$filename" ./ARCHIVE/"$filename" >> quiet.txt 2>&1
    done
    echo ""
    echo "Archiving Master RAW/MLV files..."
    echo ""
    mkdir ./ARCHIVE/MASTERS >> quiet.txt 2>&1
    tar -cvf ./ARCHIVE/"${folder:2:2}"_"$startTimeStamp".tar ./ARCHIVE/*.* >> ./REPORTS/xz_RAWcompression_report.txt 2>&1
    #xz -z -f -v -4 ./ARCHIVE/"${folder:2:2}".tar >> ./REPORTS/xz_RAWcompression_report.txt 2>&1
    mv ./ARCHIVE/"${folder:2:2}"_"$startTimeStamp".tar ./ARCHIVE/MASTERS/"${folder:2:2}"_"$startTimeStamp".tar >> quiet.txt 2>&1

    for i in ./ARCHIVE/*.M*; do
        filename=$(basename "$i")
        rm -rf ./ARCHIVE/"$filename" >> quiet.txt 2>&1
    done
    for i in ./ARCHIVE/*.IDX; do
        filename=$(basename "$i")
        rm -rf ./ARCHIVE/"$filename" >> quiet.txt 2>&1
    done
    for i in ./ARCHIVE/*.RAW; do
        filename=$(basename "$i")
        rm -rf ./ARCHIVE/"$filename" >> quiet.txt 2>&1
    done

    mv ./quiet.txt ./REPORTS/setup_report.txt
    rm -rf ./"*_00000000"

    cd "$curdir"
    fi

    rm -rf ./"\*"
    rm -rf ./"\*_00000000"

done



fi
###############################################################################################################################################################
############################################################### END SETUP PROCESS #############################################################################
###############################################################################################################################################################






###############################################################################################################################################################
###############################################################################################################################################################
##############################################################    OFFLINE PROCESS     #########################################################################
###############################################################################################################################################################
###############################################################################################################################################################
if [[ $pipeline = $offline ]]; then

if [[ -z $2 ]]; then
echo "ATTENTION: Specify second argument as REEL Folder(s) to offline. './#/*' for all Reel Folders (# is the Reel Number Folder "

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
exit
fi

if [[ -z $3 ]]; then
echo "ATTENTION: Specify third argument as 'y' or 'n' to tar/xz compression. "

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
exit
fi

toplevel=$(pwd)

for folder2 in "$offlinevar1"; do
[ -d $folder ] && cd "$folder2"


##### Process DNGs into Offline Proxy Files ###################################################################################################################
###############################################################################################################################################################
echo ""
echo "Process DNGs into Offline Proxy Files..."
echo "...dcraw & ctlrender have hushed outputs (no -v)..."

#Process DNGs into 8-bit TIFF with Rec709 curve
for ii in *.DNG; do
    filename2=$(basename "$ii")
    bakefile2="${filename2%.*}"
        # No WB Compensation (-r 1.0 1.0 1.0 1.0)      # ISO Median Stacked Dark Frame (-K)
        # Black Level Offset 2048 (-k) INTRISICALLY ALREADY INSIDE DARK FRAME HERE thus set to  # Saturation Level 16384 (-S) # RAW Color Space (-o)
        # ADH Interpolation Debayer (-q)  # Median Filter (-m)  # Wavelet Noise Reduction (-n)  # 16-bit Linear Tiff (-4 -T)
            ../../dcraw -v -r 1.0 1.0 1.0 1.0 -k 2050 -S 14332 -n 90 -o 0 -q 3 -4 -T ./"$bakefile2".DNG >> ../REPORTS/dcraw_report.txt 2>&1
            ../../ctlrender -format tiff8 -verbose -force -ctl ../../MLrawRGBtoPROXY.ctl ./"$bakefile2".tiff ./temp"$bakefile2".TIFF >> ../REPORTS/ctlrender_report.txt 2>&1
            rm -f ./"$bakefile2".tiff
            echo -ne "Processing Offline Proxies: "$bakefile ". Frame: "$bakefile2 "\r"
done

echo ""

#Gather Timecode Stamp
bakefile="${filename2%.*}"
numhold1="10#${bakefile:9:2}"  # The #10 makes sure leading zeros are interpreted as decimal and not hex/octal/etc...
numhold2="10#${bakefile:11:2}"
numhold3="10#${bakefile:13:2}"
numhold4="10#${bakefile:15:2}"
var60=60
var24=24
startnum=$((((((($var60*$numhold1)+$numhold2)*$var60)+$numhold3)*$var24)+$numhold4))
startnum=$(awk "BEGIN { printf(\"%07d\", $startnum + 0)}") #expand out to 7 digits

#Create PRORES(proxy level) Proxies
echo -ne "Creating Prores(PROXY) Proxy for" "${bakefile:0:17}"
ffmpeg -start_number "$startnum" -f image2 -r 24/1.001 -i ./temp"${bakefile:0:17}"_%07d.TIFF -codec:v prores -profile:v 0 -timecode "${bakefile:9:2}":"${bakefile:11:2}":"${bakefile:13:2}":"${bakefile:15:2}" -metadata:s:1 reel_name="${bakefile:0:8}" -y ../PROXIES/"${bakefile:0:17}".mov >> ../REPORTS/ffmpeg_report.txt 2>&1

# Remove 8-bit TIFFs used for PROXIES
for ii in temp*.TIFF; do
    filename2=$(basename "$ii")
    bakefile2="${filename2%.*}"
    rm -f ./"$bakefile2".TIFF
done

find . -iname '*.DNG' -print > ./FILELIST.txt # Necessary workflow for a HEAVY number of files

# Compress DNGs for later use in Online Process
if [ "$offlinevar2" = "y" ]; then
    echo ""
    echo -ne "Compressing ${bakefile:0:17} into tarball"
    tar -cvf ./"${bakefile:0:17}".tar --files-from ./FILELIST.txt >> ../REPORTS/xz_compression_report.txt 2>&1
    xz -z -f -v -4 ./"${bakefile:0:17}".tar >> ../REPORTS/xz_compression_report.txt 2>&1

    # Remove leftover DNGs
    for ii in *.DNG; do
        filename2=$(basename "$ii")
        bakefile2="${filename2%.*}"
        rm -f ./"$bakefile2".DNG
    done
else
    echo ""
    echo "No compression or archiving selected for DNGs..."
fi

echo ""

done

cd "$toplevel"
fi
###############################################################################################################################################################
############################################################### END OFFLINE PROCESS ###########################################################################
###############################################################################################################################################################






###############################################################################################################################################################
###############################################################################################################################################################
##############################################################    ONLINE  PROCESS     #########################################################################
###############################################################################################################################################################
###############################################################################################################################################################
if [[ $pipeline = $online ]]; then

    if [[ -z $2 ]]; then
    echo " Must specify second command line argument:  .edl file \'SCAN EDL\' "

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
    exit
    fi

    if [[ -z $3 ]]; then
    echo " Must specify frame handles:  #### "

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
    exit
    fi

    if [[ -z $4 ]]; then
    echo " Must specify start event:  #### "
# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
    exit
    fi

    if [[ -z $5 ]]; then
    echo " Must specify end event:  #### "
# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
    exit
    fi

    edlbasename=$(basename "$scanedl")
    cp "$scanedl" ./"$edlbasename" 2> quiet.txt
    scanedl="$edlbasename"

    prevREEL="EMPTYREEL"
    nextREEL="EMPTYREEL"
    starteventNo=$(awk "BEGIN { printf(\"%03d\", $starteventNo + 0)}") #expand out to 3 digits 
    endeventNo=$(awk "BEGIN { printf(\"%03d\", $endeventNo + 0)}") #expand out to 3 digits 

    # Setup Variables
    EDLNAME=$(awk "/TITLE/ {print; exit}" ./"$scanedl" 2> quiet.txt | sed "s/TITLE: //" 2> quiet.txt)
    EDLNAME="${EDLNAME:0:8}"
    COUNTER=$starteventNo
    id="nothing"
    EVENTCOUNT=000
    checkahead=000
    EVENTCOUNT2=000
    curdir=$(pwd)


    if [[ $EDLNAME != "" ]]; then
        echo ""
        echo "Expecting a 24NDF EDL"
        echo "Ingesting Pull List Scan EDL: " $scanedl
        echo "Frame Handles: " $framehandles
        echo "EDL Title: " $EDLNAME
        echo "Starting on event $starteventNo and ending on event $endeventNo"
        echo ""

        endeventNo=$(awk "BEGIN { printf(\"%03d\", $endeventNo + 1)}") # Add 1 for the while loop

        while [  $COUNTER -lt $endeventNo ]; do
            eventNo=$(awk "BEGIN { printf(\"%03d\", $COUNTER)}")
            checkahead=$(awk "BEGIN { printf(\"%03d\", $COUNTER + 1)}")
            nextREEL=$(awk "/$checkahead  / {print; exit}" ./"$scanedl" | sed "s/$checkahead  \([^*][^*][^*][^*][^*][^*][^*][^*]\).*/\1/")

            # CHECK IF EVENT IS BL (Black Leader or "black video"). If so, increase EventCount by 1
            checker=$(awk "/$eventNo  BL/ {print; exit}" ./"$scanedl")
            check="${checker:5:2}"
            if [ "$check" = "BL" ]; then
                EVENTCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT + 1)}")
                echo  "Event Processed:" $eventNo "was a 'BL' event..."

            else
                REELNAME=$(awk "/$eventNo  / {print; exit}" ./"$scanedl" | sed "s/$eventNo  \([^*][^*][^*][^*][^*][^*][^*][^*]\).*/\1/")

                # Check to see if this Reel exists in this folder
                reelFolderCheck=$(find . -name "${REELNAME:0:2}" -print)

                if [[ $REELNAME != "" ]]; then
                    STARTTC=$(awk "/$eventNo  [0-9]/ {print; exit}" ./"$scanedl" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] V     C        \([^*][^*][^*][^*][^*][^*][^*][^*][^*][^*][^*]\).*/\1/")
                    ENDTC=$(awk "/$eventNo  [0-9]/ {print; exit}" ./"$scanedl" | sed "s/$eventNo  [^*][^*][^*][^*][^*][^*][^*][^*] V     C        [^*][^*][^*][^*][^*][^*][^*][^*][^*][^*][^*] \([^*][^*][^*][^*][^*][^*][^*][^*][^*][^*][^*]\).*/\1/")

                    # Calculate Start Timecode Frame Number
                    timecodeNAME="${STARTTC:0:2}""${STARTTC:3:2}""${STARTTC:6:2}""${STARTTC:9:2}"
                    numhold1="10#${timecodeNAME:0:2}"  # The #10 makes sure leading zeros are interpreted as decimal and not hex/octal/etc...
                    numhold2="10#${timecodeNAME:2:2}"
                    numhold3="10#${timecodeNAME:4:2}"
                    numhold4="10#${timecodeNAME:6:2}"
                    var60=60
                    var24=24
                    startframe=$((((((($var60*$numhold1)+$numhold2)*$var60)+$numhold3)*$var24)+$numhold4))
                    startframe=$(awk "BEGIN { printf(\"%07d\", $startframe + 0)}") #expand out to 7 digits

                    # Calculate Start Timecode Frame Number
                    timecodeNAME="${ENDTC:0:2}""${ENDTC:3:2}""${ENDTC:6:2}""${ENDTC:9:2}"
                    numhold1="10#${timecodeNAME:0:2}"  # The #10 makes sure leading zeros are interpreted as decimal and not hex/octal/etc...
                    numhold2="10#${timecodeNAME:2:2}"
                    numhold3="10#${timecodeNAME:4:2}"
                    numhold4="10#${timecodeNAME:6:2}"
                    var60=60
                    var24=24
                    endframe=$((((((($var60*$numhold1)+$numhold2)*$var60)+$numhold3)*$var24)+$numhold4))
                    endframe=$(awk "BEGIN { printf(\"%07d\", $endframe + 0)}") #expand out to 7 digits

                    # Move into REEL folder; uncompress DNG seq;  IF the folder exists here
                    if [[ $reelFolderCheck != "" ]]; then
                        cd "${REELNAME:0:2}"
                        cd "$REELNAME"*
                            REELTCNAME=$(basename $(pwd))
                            mkdir ../ONLINES/"$EDLNAME" >> quiet.txt 2>&1
                            mkdir ../ONLINES/"$EDLNAME"/"$REELTCNAME" >> quiet.txt 2>&1

                            # Check for existence of following file types (case insensitive with -iname)
                            archiveCheck=$(find . -iname "*.xz" -print)
                            tiffCheck=$(find . -iname "*.tiff" -print)
                            movCheck=$(find . -iname "*.MOV" -print)
                            dngCheck=$(find . -iname "*.DNG" -print)

                            # Uncompress and Unarchive DNGs if not previously done and there is an archive present
                            if [ "$REELNAME" != "$prevREEL" ] && [ "$archiveCheck" != "" ]; then
                                echo "Uncompressing $REELNAME..."
                                xz -d -k *.xz 
                                tar -xvkf *.tar 
                                rm -rf ./*.tar 
                            else
                                echo "No need to uncompress $REELNAME.  Already done..."
                            fi

                            framecounter=0
                            var2=2
                            zero=0
                            xx="10#${endframe:0:7}"
                            yy="10#${startframe:0:7}"
                            zz="10#${framehandles:0:7}"
                            totalframes=$((($xx-$yy)+($zz*$var2)))
                            startcount=$(($yy-$zz))

                            if [ "$startcount" -lt "$zero" ]; then
                                totalframes=$(($startcount+$totalframes))
                                startcount=0
                            fi
                            echo -ne "Event $eventNo .  Processing $totalframes frames for $REELTCNAME.  Starting on frame $startcount and ending on frame $endframe....\n"

                            framecounter=$(awk "BEGIN { printf(\"%07d\", $framecounter + 0)}")
                            startcount=$(awk "BEGIN { printf(\"%07d\", $startcount + 0)}")


                            if [ "$movCheck" != "" ]; then

                                # MOV file online: Creates TIFFs in MLRaw Colorspace that will then be picked up by the ctlrender below to carry on to online EXR files as usual
                                # NOTE: MOVs are currently scaled to 1280x720!!!

                                echo -ne "Processing MOV file "$REELTCNAME".MOV into online EXRs..."

                                ffmpeg -i ./"$REELTCNAME".MOV -vf scale=1280:-1 -an -r 24/1.001 -pix_fmt rgb48le -vcodec tiff -start_number 0000000 -y ./"$REELTCNAME"_%07d.tiff >> ../REPORTS/ffmpeg_mov_report.txt 2>&1

                                while [ $framecounter -lt $totalframes ]; do

                                    ff="10#${framecounter:0:7}"
                                    ss="10#${startcount:0:7}"
                                    currFrame=$(($ff+$ss))
                                    currFrame=$(awk "BEGIN { printf(\"%07d\", $currFrame + 0)}") #expand out to 7 digits

                                    # MOV into linear 16-bit TIFFs (MLRaw colorspace)
                                    ../../ctlrender -format tiff16 -verbose -ctl ../../MOVtoTIFFrawspace.ctl ./"$REELTCNAME"_"$currFrame".tiff ./temp"$REELTCNAME"_"$currFrame".tiff >> ../REPORTS/online_report.txt 2>&1
                                    rm -rf ./"$REELTCNAME"_"$currFrame".tiff >> ../REPORTS/online_report.txt 2>&1

                                    # Linear 16-bit TIFFS (MLRaw Colorspace) into ACES EXR
                                    ../../ctlrender -format aces -compression PIZ -verbose -ctl ../../MLrawRGBtoACES*.ctl ./temp"$REELTCNAME"_"$currFrame".tiff ./"$REELTCNAME"_"$currFrame".exr >> ../REPORTS/online_report.txt 2>&1
                                    rm -rf ./temp"$REELTCNAME"_"$currFrame".tiff >> ../REPORTS/online_report.txt 2>&1

                                    mv ./"$REELTCNAME"_"$currFrame".exr ../ONLINES/"$EDLNAME"/"$REELTCNAME"/"$REELTCNAME"_"$currFrame".exr >> quiet.txt 2>&1
                                    echo -ne "....Processing Frame " $REELTCNAME"_"$currFrame" \r"
                                    framecounter=$(awk "BEGIN { printf(\"%07d\", $framecounter + 1)}")

                                    # NOTE: Seems as if any math performed on variables requires declaring as decimal (#10) first (after being expanded out the number of digits if needed)

                                done

                            elif [ "$dngCheck" != "" ]; then

                                # DNG file online: dcraw debayer into linear 16-bit TIFFs (in MLRaw Colorspace) then
                                while [ $framecounter -lt $totalframes ]; do

                                    ff="10#${framecounter:0:7}"
                                    ss="10#${startcount:0:7}"
                                    currFrame=$(($ff+$ss))
                                    currFrame=$(awk "BEGIN { printf(\"%07d\", $currFrame + 0)}") #expand out to 7 digits
                                    ../../dcraw -v -r 1.0 1.0 1.0 1.0 -k 2050 -S 14332 -n 90 -o 0 -q 3 -4 -T ./"$REELTCNAME"_"$currFrame".DNG >> ../REPORTS/online_report.txt 2>&1
                                    ../../ctlrender -format aces -compression PIZ -verbose -ctl ../../MLrawRGBtoACES*.ctl ./"$REELTCNAME"_"$currFrame".tiff ./ >> ../REPORTS/online_report.txt 2>&1
                                    mv ./"$REELTCNAME"_"$currFrame".exr ../ONLINES/"$EDLNAME"/"$REELTCNAME"/"$REELTCNAME"_"$currFrame".exr >> quiet.txt 2>&1
                                    echo -ne "....Processing Frame " $REELTCNAME"_"$currFrame".DNG \r"
                                    framecounter=$(awk "BEGIN { printf(\"%07d\", $framecounter + 1)}")

                                    # NOTE: Seems as if any math performed on variables requires declaring as decimal (#10) first (after being expanded out the number of digits if needed)

                                done

                            fi

                            # Remove leftovers
                            # Remove leftover TIFFS is they weren't already there
                            if [ "$tiffCheck" = "" ]; then
                                echo -ne "Removing TIFFS..."
                                for iii in *.tiff; do
                                    filename3=$(basename "$iii")
                                    bakefile3="${filename3%.*}"
                                    rm -f ./"$bakefile3".tiff
                                done
                            fi

                            # Remove DNGs if not needed for next REEL AND there is an archive present
                            if [ "$REELNAME" != "$nextREEL" ] && [ "$archiveCheck" != "" ]; then
                                echo -ne "Removing DNGs and leaving Archive..."
                                echo ""
                                for iii in *.DNG; do
                                    filename3=$(basename "$iii")
                                    bakefile3="${filename3%.*}"
                                    rm -f ./"$bakefile3".DNG
                                done
                            fi

                            rm -rf ./quiet.txt

                            EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")
                            echo -ne "Event Processed for $REELTCNAME: $eventNo Start TC: $STARTTC ($startframe) End TC: $ENDTC ($endframe) with handles of $framehandles frames  \n"
                            echo ""
                        cd ../
                        rm -rf ./quiet.txt

                    else    
                        EVENTCOUNT2=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + 1)}")
                        echo "Event $eventNo: $REELNAME not in this list of directories... "
                    fi
                    prevREEL="$REELNAME"
                    cd "$curdir"
                fi

            fi

            COUNTER=$(awk "BEGIN { printf(\"%03d\", $COUNTER + 1)}")

        done

        echo ""
        FINALCOUNT=$(awk "BEGIN { printf(\"%03d\", $EVENTCOUNT2 + $EVENTCOUNT)}")
        echo "......Processed $FINALCOUNT Events for $filename"


    else
        echo ""
        echo "No EDL with that name. "
        echo ""
    fi

    rm -rf ./"$scanedl"

fi
###############################################################################################################################################################
############################################################### END ONLINE  PROCESS ###########################################################################
###############################################################################################################################################################


###############################################################################################################################################################
###############################################################################################################################################################
##############################################################    GATHER  PROCESS     #########################################################################
###############################################################################################################################################################
###############################################################################################################################################################
# Used to gather all Online files from
if [[ $pipeline = $gather ]]; then
echo ""
echo "Gather has been selected.  We will now gather all of your online files from "
echo "   a specified EDL name and bring them into Master Section"


if [[ -z $2 ]]; then
echo ""
echo "ATTENTION: Specify second argument as EDL name (in the edl file!) to gather. "
echo ""

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt
exit
fi

startfromdir=$(pwd)

cd ../

mkdir ./ONLINE_DI
mkdir ./ONLINE_DI/"$gathervar1"

returnback=$(pwd)
homedir=$(basename $(pwd))

for folder in ./*; do
    [ -d $folder ] && cd "$folder"

    if [[ $folder = $starissue ]]; then  # helps us not to process anything beside a numeric reel folder
        echo "Skipping folder" $folder "...."

    elif [ "${folder:2:1}" != "0" ] && [ "${folder:2:1}" != "1" ]; then  # Checks to make sure first number is a month and the directory is a day directory
        echo "Skipping folder" $folder "since it doesn't begin with month number..."

    else
        returnback2=$(pwd)

        for folder2 in ./*; do
            [ -d $folder2 ] && cd "$folder2"

            if [[ $folder2 = $starissue ]]; then  # helps us not to process anything beside a numeric reel folder
                echo "Skipping folder" $folder2 "...."

            elif [ "${folder2:2:1}" != "0" ] && [ "${folder2:2:1}" != "1" ] && [ "${folder2:2:1}" != "2" ] && [ "${folder2:2:1}" != "3" ] && [ "${folder2:2:1}" != "4" ] && [ "${folder2:2:1}" != "5" ] && [ "${folder2:2:1}" != "6" ] && [ "${folder2:2:1}" != "7" ] && [ "${folder2:2:1}" != "8" ] && [ "${folder2:2:1}" != "9" ]; then  # Checks to make sure that it is a reel directory
                echo "Skipping folder" $folder2 "...."

            else
                cd ./ONLINES
                echo "Moving $gathervar1 files in $folder2 to ONLINE_DI..."
                mv ./"$gathervar1"*/* ../../../ONLINE_DI/"$gathervar1"/ >> ../../../quiet.txt 2>&1
                cd ../
            fi

            cd "$returnback2"

        done

    fi

    cd "$returnback"

done

rm -rf ./quiet.txt

cd "$startfromdir"

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt


fi
###############################################################################################################################################################
############################################################### END GATHER  PROCESS ###########################################################################
###############################################################################################################################################################

# Pack away tools
rm -rf ./ctlrender
rm -rf ./dcraw
rm -rf ./ltcdump
rm -rf ./mlv_dump
rm -rf ./*.ctl
rm -rf ./quiet.txt

endTimeStamp=$(timestamp)
endTimeStamp="${endTimeStamp:0:2}""${endTimeStamp:3:2}""${endTimeStamp:6:2}""${endTimeStamp:9:2}"
echo "Time Start: $startTimeStamp   Time End:  $endTimeStamp"