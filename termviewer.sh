#!/usr/bin/env bash
SCRIPTROOT=$( cd $(dirname $0) ; pwd)
Usage(){
cat <<USAGE
++++++++++++++++++++++++++++++++++++++++++++++++++++
Part of sclib (https://github.com/xfgavin/sclib)
View csv in terminal window
Adapted from Chris Jean https://chrisjean.com/view-csv-data-from-the-command-line/
by xfgavin@gmail.com 01/26/2018 @UCSD
+++++++++++++++++++++++++++++++++++++++++++++++++++++

`basename $0` -i </path/to/csv>
Required:
  /path/to/csv
Options:
    -i      csv file

Examples:
`basename $0` -i csv

USAGE
[ ${#ERROR} -gt 0 ] && echo -e "\e[1;101;93mError: $ERROR\e[0m" && exit -1
exit 0
}

termviewer(){
  cat $csv | sed -e 's/,,/, ,/g' | column -s, -t | less -#5 -N -S
}

csv=
column=
if [ "${1:0:1}" = "-" ]
then
  while getopts "i:" OPTION
  do
       case $OPTION in
           i)
               csv=$OPTARG
               ;;
           ?)
               usage
               exit
               ;;
       esac
  done
else
  csv=$1
fi

[ -z "$csv" ] && Error="No csv file is provided" && usage
[ ! -f $csv ] && Error="csv file does not exist" && usage

termviewer
