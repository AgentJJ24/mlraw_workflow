for i in *.mov; do
   filename=$(basename "$i")
   newFILE="$i"
   reelname="${filename:0:8}"
   $testA = "${filename:0:3}"

if [ "$testA" = "007" ];
   newName="${filename:1:2}""05""${filename:3:4}"".mov"
   mv ./"$i" ./"$newName"
   echo "Moved $i to $newName "
fi

done
