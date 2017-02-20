#!/bin/bash

scriptname=$0
indirs=$@
msg_to_csv='$1=="\"user\":" {split($2,a,"\""); user=a[2]}$1=="\"text\":" {split($0,a,": "); text=a[2]; sub(/,$/,"",text)}$1=="\"ts\":" {split($2,a,"\""); timestamp=a[2]; print timestamp","user","text}'
if [ "$indirs " == " " ]
then
  echo "Usage: $scriptname directory_list"
  echo "output goes to ./parsed/"
  exit 0
fi

timestamper(){
  echo `date +%H%M%S`
}

outdir="parsed"
if [ ! -d $outdir ]
then
  mkdir $outdir
  if [ $? -ne 0 ]
  then
    echo "unable to create output directory $outdir"
    exit 1
  fi
elif [ ! -w $outdir ]
then
  echo "$outdir is not writable"
  exit 2
fi

interleave_days(){
  lyear=2017
  for year in $(seq 2009 $lyear)
  do
    for month in $(seq -w 01 12)
    do
      for day in $(seq -w 01 31)
      do
        files=`find $outdir -name "${year}-${month}-${day}:*.csv"`
        if [ "$files " != " " ]; then
          cat $files |sort > ${outdir}/${year}-${month}-${day}.csv
        fi
      done
    done
  done
}
timestamper
for indir in $indirs
do
  if [ -d $indir ] && [ -r $indir ]
  then
    for dayfile in `ls $indir/*.json`
    do
      dayfile=`basename $dayfile`
      channel_name=`echo $indir | awk '{dirdepth=split($0,a,"/"); print a[dirdepth-1]":"a[dirdepth]}'`
      echo "" > $outdir/${dayfile%.json}:$channel_name.csv #clear out anything that's there w/o needing to delete
      grep -A 4 "\"type\": \"message\"," $indir/$dayfile | awk -v src_chan=$channel_name '$1=="\"user\":" {split($2,a,"\""); user=a[2]}$1=="\"text\":" {split($0,a,": "); text=a[2]; sub(/,$/,"",text)}$1=="\"ts\":" {split($2,a,"\""); timestamp=a[2]; print timestamp","user","src_chan","text}' >> $outdir/${dayfile%.json}:$channel_name.csv
    done
  else
    echo "$indir is not a readable directory;skipping"
  fi #[ -d $indir ] && [ -r $indir ]
done
timestamper
interleave_days
timestamper
