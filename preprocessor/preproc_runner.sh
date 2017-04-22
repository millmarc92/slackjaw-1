#!/bin/bash

# Intended for direct use by the web app, which passes the archive file as the first argument
# The optional second argument is the customer identifier (whatever it is) used to uniquely
# identify the archive for that customer


function abspath() {
    if [ -d "$1" ]; then
        (cd "$1"; pwd)
    elif [ -f "$1" ]; then
        if [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}

scriptname=$0
relscriptsdir="`dirname \"$0\"`"
scriptsdir=`abspath $relscriptsdir`
preproc="slack_parser.sh"
archive_in=`echo "$1" | tr " " "_"`
cust_id=$2
mode=$3
if [ "$mode " != "debug " ]; then
  exec 2>/dev/null # stops stderr output from shell commands
fi
if [ "$mode " == "silent " ]; then
  exec 1>/dev/null # stops error messages
fi

# check if we have an actual readable file from the customer
invalidchar_in_archive=`echo "$archive_in" | grep "[^a-zA-Z0-9_.-]"`
if [ "$1 " == " " ]
then
  echo "ERROR: no archive specified"
  exit 1
elif [ "$invalidchar_in_archive " != " " ]
then
  echo "ERROR: invalid characters in filename:$archive_in"
  exit 2
elif [ ! -f "$1" ]
then
  echo "ERROR: $1 is not a file"
  exit 3
elif [ ! -r "$1" ]
then
  echo "ERROR: $1 is not readable"
  exit 4
else
  echo $archive_in
  mv "$1" $archive_in
  if [ $? -ne 0 ]
  then
    echo "ERROR: cannot rename $1 to $archive_in"
    exit 11
  fi
fi

archive_file=$(abspath ${archive_in})

# check if we can actually have a customer directory to receive decompressed
# customer archives
invalidchar_in_custid=`echo "$cust_id" | grep "[^a-zA-Z0-9_.-]"`
if [ "$cust_id " == " " ]
then
  echo "ERROR: no customer specified"
  exit 5
elif [ "$invalidchar_in_custid " != " " ]
then
  echo "ERROR: invalid characters in customer id:$cust_id"
  exit 6
elif [ ! -d $cust_id ]
then
  mkdir $cust_id
  if [ $? -ne 0 ]
  then
    echo "ERROR: unable to create a directory for $cust_id"
    exit 7
  fi
fi
cust_dir="`pwd`/$cust_id"

if [ ! -w $cust_id ]
then
  echo "ERROR: $cust_id customer directory not writable"
  exit 8
fi

# This section looks at the magic numbers in the archive header to see what
# type of compression archive it is. Big-endian/little-endian issues are
# automatically handled by the decompression utility, so we don't care about
# byte order
archive_header_bytes=( `hexdump -e '1/1 "%02x" "\n"' $archive_file | head -2` )
bytematch(){
  for element in "${archive_header_bytes[@]}"
  do
    if [ "$1 " == "$element " ]; then
      return 0
    fi
  done
  return 1
}
bytematches(){
  if bytematch $1 && bytematch $2; then
    return 0
  fi
  return 1
}
iszip(){
  if bytematches "50" "4b"; then
    return 0
  fi
  return 1
}
isgzip(){
  if bytematches "1f" "8b"; then
    return 0
  fi
  return 1
}
isbzip(){
  if bytematches "42" "5a"; then
    return 0
  fi
  return 1
}

load_if_valid_archive(){
  if iszip || isgzip || isbzip
  then
    load_customer
  else
    echo "ERROR: $archive_file does not look like a valid archive. Only compressed tarballs and zips supported"
    exit 9
  fi
}

# decompress to the customer directory; throw an error if this fails.
# could take a while to fail for, say, a truncated archive, or running out of
# disk space.
load_customer(){
  cd $cust_dir
  if iszip
  then
    unzip $archive_file
  elif isgzip
  then
    tar zxvf $archive_file
  elif isbzip
  then
    tar jxvf $archive_file
  fi
  if [ $? -ne 0 ]
  then
    echo "ERROR: unable to decompress $archive_file to $cust_id"
    exit 10
  fi
}

# finds and cleans all the source dirs. By default, zip uploads will only
# contain one slack archive, but this function means that they can upload
# archive files containing multiple slack archives and we can handle them all.
# The archives can't be nested, however; they should be siblings
arch_paths=() # creating as global variable for set_source_dirs() to set
set_source_dirs(){
  OIFS=$IFS
  IFS=$'\n'
  # arch_paths[0] holds the holds the final array index
  arch_paths=( `find $(pwd) -name "users.json" |awk '{ent= ent "\n" substr($0,1,(length($0) - 10))} END {print NR "\n" ent}'` )
  IFS=$OIFS
  # cycle through and clean up any directories with spaces, which can cause
  # problems for other tools/utilities/whatever.
  for i in `seq 1 ${arch_paths[0]}`
  do
    startpath=${arch_paths[${i}]}
    cleanpath=`echo "$startpath" | tr " " "_"`
    if [ "$startpath " != "$cleanpath " ]
    then # need to clean up spaces
      mv "$startpath" $cleanpath
      if [ $? -ne 0 ]
      then
        echo "ERROR: unable to mv customer archive from \"$startpath\" to \"$cleanpath\""
        exit 12
      fi
      arch_paths[${i}]="$cleanpath"
    fi #if [ "$startpath " != "$cleanpath " ]
  done #for (i=1; i<=${arch_paths[0]}; i++)
}
#MVP script=based parser, to be replaced w/batabase or whatever
channel_list=""
run_script_parser(){
  for i in `seq 1 ${arch_paths[0]}`
  do
    find_channels `echo ${arch_paths[${i}]} | awk '{print substr($0,1,(length($0) - 1))}'`
  done
  cd $cust_dir # make sure we're in the customer dir, so the 'parsed' dirs ends up where expected.
  ${scriptsdir}/${preproc} $channel_list
}
find_channels(){
  channel_list="$channel_list `find $1 -type d`"
}


#TODO: check for space handling with alternate formats
load_if_valid_archive # always do
set_source_dirs #always do
run_script_parser #will change w/backend
