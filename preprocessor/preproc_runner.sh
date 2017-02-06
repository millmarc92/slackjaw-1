#!/bin/bash

# Intended for direct use by the web app, which passes the archive file as the first argument
# The optional second argument is the customer identifier (whatever it is) used to uniquely
# identify the archive for that customer

scriptname=$0
scriptsdir="`dirname \"$0\"`"
archive_in=$1
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
if [ "$archive_in " == " " ]
then
  echo "ERROR: no archive specified"
  exit 1
elif [ "$invalidchar_in_archive " != " " ]
then
  echo "ERROR: invalid characters in filename:$archive_in"
  exit 2
elif [ ! -f $archive_in ]
then
  echo "ERROR: $archive_in is not a file"
  exit 3
elif [ ! -r $archive_in ]
then
  echo "ERROR: $archive_in is not readable"
  exit 4
fi
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
  cd $cust_id
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
    echo "ERROR: unable to decompress $archive_file to $cust_id"
    exit 10
  fi
}
load_if_valid_archive
#TODO: execute preproc
