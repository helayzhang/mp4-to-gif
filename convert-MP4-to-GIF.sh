#!/bin/bash
echo "+------------------------------------------------------+"
echo "|           MP4 to GIF Convert tools v1.0              |"
echo "+------------------------------------------------------+"
echo "| Author:         helay                                |"
echo "| Email:          helayzhang@126.com                   |"
echo "| Dependents:     ffmpeg      - www.ffmpeg.org         |"
echo "|                 ImageMagick - www.imagemagick.org    |"
echo "+------------------------------------------------------+"

# Get MP4 File Path
printf "Please Enter the MP4 File Name(include path):"
read mp4_file
if [ ! $mp4_file ]; then 
    echo "Fatal!!! Input MP4 should not be Empty."
    exit 1
fi

# Check MP4 Resolution
pixel_width=$(ffmpeg -i $mp4_file 2>&1 | grep 'Video:' | awk -F' ' '{print $11}' | awk -F'x' '{print $1}')
pixel_height=$(ffmpeg -i $mp4_file 2>&1 | grep 'Video:' | awk -F' ' '{print $11}' | awk -F'x' '{print $2}' | awk -F',' '{print $1}')
if [ ! $pixel_width ] || [ ! $pixel_height ]; then
    echo "Fatal!!! Cannot Analyse MP4's Resolution, Please Check File Format."
    exit 1
else
    echo "Input MP4's Resolution is: $pixel_width*$pixel_height"
fi

# Get Convert Start Timestamp
printf "Please Enter Convert Start Timestamp(Use 00:00:00.0 Format, default: From the Very Beginning):"
read start_time
if [ ! $start_time ]; then
    echo "Will Use default Start Timestamp: 00:00::00.0"
    start_time=00:00:00.0
fi

# Get Convert Frame Rate
printf "Please Enter Convert Frame Rate(default: 10, suggestion: 10):"
read rate
if [ ! $rate ]; then
    echo "Will Use default Frame Rate: 10"
    rate=10
fi

# Input Convert Seconds
printf "Please Enter Convert Seconds Need to Convert(Use 0.0 Format, dafault 1.0):"
read seconds
if [ ! $seconds ]; then
    echo "Will Use default Convert Seconds: 1.0"
    seconds=1.0
fi

total_frames=$(echo "scale=2; $rate * $seconds" | bc)
total_frames=$(printf "%1.f" $total_frames)
echo "Summary: Will Generate $total_frames Frames, start from $start_time of the Video, during $seconds seconds"

if [ ! -d convert_temp ]; then
  mkdir -p convert_temp
fi
rm -rf convert_temp/*

echo "Convert Video Frames into JPGs..."
ffmpeg -i $mp4_file -y -f image2 -ss $start_time -r $rate -vframes $total_frames convert_temp/temp_%03d.jpg >/dev/null 2>&1

name=$(date +"%s")
echo "Convert JPGs into GIF..."
convert -compress jpeg convert_temp/*.jpg $name.gif
echo ">>>>> $name.gif"
