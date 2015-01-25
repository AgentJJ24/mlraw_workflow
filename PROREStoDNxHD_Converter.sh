for i in *.mov; do
   filename=$(basename "$i")
   newFILE="$i"
   reelname="${filename:0:8}"

  echo "Processing $i into $reelname "
  # ffmpeg -i "$i" -y -vcodec dnxhd -b:v 60M -vf "scale=iw*sar*min(1280/(iw*sar)\,720/ih):ih*min(1280/(iw*sar)\,720/ih),pad=1280:720:(ow-iw)/2:(oh-ih)/2" -r 24000/1001 -pix_fmt yuv422p -timecode 00:00:00:00 -metadata:s:v:0 reel_name="$filename" -metadata:s:v:1 reel_name="$filename" -metadata:s:0 reel_name="$filename" -metadata:s:1 reel_name="$filename" ../"$newFILE"

   ffmpeg -i "$i" -y -vcodec prores -timecode 00:00:00:00 -metadata:s:v:0 reel_name="$reelname" ../PRORES_OFFLINE/"$newFILE"

done
