#!/bin/bash



scriptname=$0
usage="Usage:\n$scriptname customer_id date_range search_string[...]\n\
customer_id, date_range and at least one search_string is required.\n\
date_range takes the format YYYY-MM-DD:YYYY-MM-DD. Any other format will\n\
result in searching the entire history(NOTE:not implemented)\n\
After the first search term, subsequent search_string values may be\n\
led with a minus character to indicate exclusion of the string that follows.\n\
Example: $scriptname cust-1234 * [Ss]lack -slackjaw\n\
This would find all instances of \"Slack\" or \"slack\" in cust-1234's entire\n\
history, except when the word \"slackjaw\" is also mentioned."

cust_id=$1
shift
date_range=$1 #not currently implemented
shift
query_string_num='0' # the rest of the arguments are search strings
query_array=()
while [ "$1 " != " " ]
do
  query_string_num=`expr $query_string_num + 1`
  query_array[$query_string_num]=$1
  shift
done
parsed="parsed" # MVP preproc output directory

# check if we can actually have a customer directory by the name. Uses the same
# error codes as preproc_runner.sh when appropriate. Some of these checks may
# not be strictly necessary after MVP preproc is replaced, but they should
# always succeed as a side effect of archive unpacking
invalidchar_in_custid=`echo "$cust_id" | grep "[^a-zA-Z0-9_.-]"`
if [ "$cust_id " == " " ]
then
  echo "ERROR: no customer specified"
  echo -e "$usage"
  exit 5
elif [ "$invalidchar_in_custid " != " " ]
then
  echo "ERROR: invalid characters in customer id:$cust_id"
  exit 6
elif [ ! -d $cust_id ]
then
  echo "ERROR: no customer archive found for $cust_id"
  exit 13
elif [ ! -w $cust_id ]
then
  echo "ERROR: $cust_id customer directory not writable"
  exit 8
fi

cd $cust_id
if [ $? -ne 0 ]
then
  echo "ERROR: unable to enter $cust_id customer directory"
  exit 14
fi

if [ "$date_range " == " " ]
then
  echo "ERROR: no date range specified"
  echo -e "$usage"
  exit 15
elif [ "$query_string_num" == "0" ]
then
  echo "ERROR: no query strings specified"
  echo -e "$usage"
  exit 16
fi

timestamper(){
  echo `date +%Y%m%d%H%M%S`
}

outdir="" # For storing query output
#-----------------------------------------------------------------------------#
# MVP query ------------------------------------------------------------------#
#-----------------------------------------------------------------------------#
mvp_parser_setup(){
  outdir="query-`timestamper`"
  if [ ! -d $outdir ]
  then
    mkdir $outdir
    if [ $? -ne 0 ]
    then
      echo "ERROR: unable to create query directory $outdir"
      exit 15
    fi
  else
    echo "ERROR: Query for $outdir already created"
    exit 16
  fi
}
search_all_terms(){
  search_cmd="grep \"${query_array[1]}\" ${parsed}/*"
  if [ $query_string_num -gt 1 ]
  then
    for i in `seq 2 $query_string_num`
    do
      query_string=${query_array[${i}]}
      if [ "${query_string:0:1}" == "-" ]
      then
        search_cmd+=" | grep -v \"${query_string:1}\""
      else
        search_cmd+=" | grep \"${query_string}\""
      fi
    done
  fi
  #TODO: add an inline reformatter to package the results for the frontend
  eval "$search_cmd" > $outdir/grepresult
  echo "$outdir/grepresult" #sending the result location via STDOUT
  exit 0
}
mvp_parser_setup
search_all_terms
