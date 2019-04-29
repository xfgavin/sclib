#!/usr/bin/env bash
SCRIPTROOT=$( cd $(dirname $0) ; pwd)
usage()
{
[ ${#Error} -gt 0 ] && echo -e "\nError: $Error\n"
cat <<EOF
++++++++++++++++++++++++++++++++++++++++++++++++++++
Part of sclib (https://github.com/xfgavin/sclib)
Print dimentional information for a given csv file
by xfgavin@gmail.com 09/25/2018 @UCSD
+++++++++++++++++++++++++++++++++++++++++++++++++++++
usage: `basename $0` options

OPTIONS:
   -i      csv file

Example:
  `basename $0` -i /path/to/csv

EOF
[ ${#Error} -gt 0 ] && exit -1
exit 0
}

csv=
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

row_count=`wc -l $1|awk '{print $1}'`
((row_count=row_count-1))
column_count=`head -n1 $1|sed -e "s/,\+/,/g" -e "s/,/\n/g"|wc -l`
echo "Name: `basename $1`"
echo "Path: `dirname $1`"
echo "Rows: $row_count"
echo "Columns: $column_count"
