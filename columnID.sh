#!/usr/bin/env bash
SCRIPTROOT=$( cd $(dirname $0) ; pwd)
usage()
{
[ ${#Error} -gt 0 ] && echo -e "\nError: $Error\n"
cat <<EOF
++++++++++++++++++++++++++++++++++++++++++++++++++++
Part of sclib (https://github.com/xfgavin/sclib)
Find column id in a given csv file and for a given column
by xfgavin@gmail.com 09/25/2018 @UCSD
+++++++++++++++++++++++++++++++++++++++++++++++++++++

usage: `basename $0` options

OPTIONS:
   -i      csv file
   -c      column

Example:
  `basename $0` -i /path/to/csv -c column1

EOF
[ ${#Error} -gt 0 ] && exit -1
exit 0
}

csv=
column=
if [ "${1:0:1}" = "-" ]
then
  while getopts "i:c:" OPTION
  do
       case $OPTION in
           i)
               csv=$OPTARG
               ;;
           c)
               column=$OPTARG
               ;;
           ?)
               usage
               exit
               ;;
       esac
  done
else
  csv=$1
  column=$2
fi

[ -z "$csv" ] && Error="No csv file is provided" && usage
[ -z "$column" ] && Error="No column is provided" && usage
[ ! -f $csv ] && Error="csv file does not exist" && usage

head -n1 $csv|sed -e "s/,\+/,/g" -e "s/,/\n/g" -e 's/"//g'|grep -n '^'$column'$'|cut -d: -f1
