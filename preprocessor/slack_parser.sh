#!/bin/bash

scriptname=$0
indirs=$@
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

interleave_day(){
  ye=${1}
  shift
  mo=${1}
  shift
  da=${1}
  shift
  fs=$@
  cat ${fs} | sort > ${outdir}/${ye}-${mo}-${da}.csv
}

# saving some time to prevent finding in years without data
minyear="2009"
minfound=`ls $outdir |cut -d- -f 1 |sort -u |grep "[0-9]\{4\}" |head -1`
if [ "${minfound} " != " " ]; then
  minyear="$minfound"
fi
interleave_days(){
  lyear=2017
  # No slack archives before its creation in 2009
  for year in $(seq ${minyear} $lyear)
  do
    for month in $(seq -w 01 12)
    do
      for day in $(seq -w 01 1 31)
      do
        files=`find $outdir -name "${year}-${month}-${day}:*.csv"`
        if [ "$files " != " " ]; then
          interleave_day ${year} ${month} ${day} ${files} &
          #cat $files | sort > ${outdir}/${year}-${month}-${day}.csv
        fi
      done
    done
  done
}
timestamper
user_translation=""
for indir in $indirs
do
  if [ -d $indir ] && [ -r $indir ]
  then
    # this only works because find returns shallower directories first
    # if retained, the username translation logic should move to its own loop
    if [ -f "$indir/users.json" ]
    then # setting user ID to username translations
      seds=`awk -F\" '/\"id\":/{uid=$4} /\"name\":/{seds=seds"; s/"uid"/"$4"/g"} END{print substr(seds,3)}' $indir/users.json`
    fi
    for dayfile in `ls $indir/*.json`
    do
      dayfile=`basename $dayfile`
      channel_name=`echo $indir | awk '{dirdepth=split($0,a,"/"); print a[dirdepth-1]":"a[dirdepth]}'`
      echo "" > $outdir/${dayfile%.json}:$channel_name.csv #clear out anything that's there w/o needing to delete
      grep -A 4 "\"type\": \"message\"," $indir/$dayfile |sed "${seds}" | awk -v src_chan=$channel_name '$1=="\"user\":" {split($2,a,"\""); user=a[2]}$1=="\"text\":" {split($0,a,": "); text=a[2]; sub(/,$/,"",text)}$1=="\"ts\":" {split($2,a,"\""); timestamp=a[2]; print timestamp","user","src_chan","text}' >> $outdir/${dayfile%.json}:$channel_name.csv
    done
  else
    echo "$indir is not a readable directory;skipping"
  fi #[ -d $indir ] && [ -r $indir ]
done
timestamper
interleave_days
timestamper
