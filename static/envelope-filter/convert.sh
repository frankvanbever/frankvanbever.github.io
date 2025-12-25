#!/usr/bin/env zsh


for wavfile in $(ls *.wav);
do
    filename=$(basename $wavfile ".wav")
    ffmpeg -i $wavfile -vn -ar 44100 -ac 2 -b:a 192k "${filename}.mp3"
done
