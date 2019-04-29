#!/usr/bin/env bash
SCRIPTROOT=$( cd $(dirname $0) ; pwd)
usage()
{
[ ${#Error} -gt 0 ] && echo -e "\nError: $Error\n"
cat <<EOF
++++++++++++++++++++++++++++++++++++++++++++++++++++
Part of sclib (https://github.com/xfgavin/sclib)
Remove a given column from a given csv file
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
  while getopts "i:c:o:" OPTION
  do
       case $OPTION in
           i)
               csv=$OPTARG
               ;;
           c)
               column=$OPTARG
               ;;
           o)
               outfile=$OPTARG
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
  outfile=$3
fi

[ -z "$csv" ] && Error="No csv file is provided" && usage
[ -z "$column" ] && Error="No column is provided" && usage
[ ! -f $csv ] && Error="csv file does not exist" && usage

colid=(`head -n1 $csv|sed -e "s/,\+/,/g" -e "s/,/\n/g"|grep -n $column|cut -d: -f1`)
colcount=`head -n1 $csv|sed -e "s/,\+/,/g" -e "s/,/\n/g"|wc -l`
[ ${#colid} -eq 0 ] && "Error: column $column does not exist" && exit -1
sourcepath=`dirname $csv`
sourcename=`basename $csv`
cd $sourcepath
cp $sourcename .$sourcename

colid_len=${#colid[@]}
for ((id=0;id<$colid_len;id++))
do
  [ $((id+1)) -eq ${colid[$id]} -a $((colid_len-id)) -gt 1 ] && continue
  col_curr=${colid[$id]}
  if [ $id -eq 0 ]
  then
    case $col_curr in
      1)
        ;;
      2)
        colstring="1"
        ;;
      *)
        colstring="1-`echo $((col_curr-1))`"
        ;;
    esac
  else
    col_pre=${colid[((id-1))]}
    case $((col_curr-col_pre)) in
      1)
        [ $((colid_len-id)) -gt 1 ] && continue
        ;;
      2)
        colstring="$colstring,`echo $((col_pre+1))`"
        ;;
      *)
        colstring="$colstring,`echo $((col_pre+1))`-`echo $((col_curr-1))`"
        ;;
    esac
  fi
  if [ $((colid_len-id)) -eq 1 ]
  then
    case $((colcount-colid[$id])) in
      0)
        break
        ;;
      1)
        colstring="$colstring,$colcount"
        ;;
      *)
        colstring="$colstring,`echo $((col_curr+1))`-"
        ;;
    esac
  fi
done
colstring=`echo $colstring|sed -e "s/^,//g"`
echo $colstring
if [ ${#outfile} -gt 0 ]
then
  cut -d, -f`echo $colstring` .$sourcename >$outfile
else
  cut -d, -f $colstring .$sourcename >`echo $sourcename|sed -e "s/\.csv$//g"`_cut.csv
fi
rm -f .$sourcename

#for col in `echo $colid`
#do
#  case $col in
#    1)
#      if [ ${#3} -gt 0 ]
#      then
#        cut -d, -f2- .$1 >.${1}_new
#        mv .${1}_new .$1
#      else
#        cut -d, -f2- .$1 >.${1}_new
#        mv .${1}_new .$1
#      fi
#      ;;
#    $colcount)
#      ;;
#    *)
#  esac
#done
#
#
#for col in `echo $colid`
#do
#  case $col in
#    1)
#      if [ ${#3} -gt 0 ]
#      then
#        cut -d, -f2- .$1 >.${1}_new
#        mv .${1}_new .$1
#      else
#        cut -d, -f2- .$1 >.${1}_new
#        mv .${1}_new .$1
#      fi
#      ;;
#    $colcount)
#      ;;
#    *)
#  esac
#done
