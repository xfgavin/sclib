#!/bin/bash
SCRIPTROOT=$( cd $(dirname $0) ; pwd)
Usage(){
cat <<USAGE
++++++++++++++++++++++++++++++++++++++++++++++++++++
Part of sclib (https://github.com/xfgavin/sclib)
Merge two csvs by common column
by xfgavin@gmail.com 08/18/2017 @UCSD
+++++++++++++++++++++++++++++++++++++++++++++++++++++

`basename $0` <-1 input csv1> <-2 input csv2> <-c1 common column in csv1> <-c2 common column in csv2> <-o output> <-k output format> <-e columns to exclude> [-u Whether to keep unmatched data ] [ -nhd no header]
-1/-2 </path/to/csv>
  The csvs to merge

-c1/-c2 <number>
  The common column numbers in csv1 or csv2.

-o </path/to/csv>
  Output file name

-k <output format>
  Output format, which columns in csv1/csv2 to keep. e.g. 1.2,1.3,2.4,2.5 will keep columns 2 & 3 from csv1 and columns 4 & 5 from csv2, the common column will always be kept.
  Please refer to man page of join

-e <columns to exclude>
  Output format, which columns in csv1/csv2 to discard. e.g. 1.2,1.3,2.4,2.5 will discard columns 2 & 3 from csv1 and columns 4 & 5 from csv2, the common column will always be kept.
  Please refer to man page of join

Optional:
-u <1/0>
  Whether to keep unmatched data.
-nhd
  csvs don't have header
  by default, the first rows of those csvs will be considered as headers.

-h, --help
        Show me.

Examples:
`basename $0` -1 csv1 -2 csv2 -c1 1.1 -c2 2.3 -k 1.2,1.3,2.2,2.4 -o newcsv -e 2.5

USAGE
[ ${#ERROR} ] && echo -e '\E[7;31;40m'"\033[1mError: $ERROR\033[0m" && exit -1
exit 0
}

mergecsv(){
  column_to_exclude_1=`echo $column_to_exclude| grep -oE "1\.[0-9]*,|1\.[0-9]*$"`
  column_to_exclude_2=`echo $column_to_exclude| grep -oE "2\.[0-9]*,|2\.[0-9]*$"`
  [ ${#column_to_exclude_1} -eq 0 ] && column_to_exclude_1="1.$common_column_1" || column_to_exclude_1="$column_to_exclude_1,1.$common_column_1"
  [ ${#column_to_exclude_2} -eq 0 ] && column_to_exclude_2="2.$common_column_2" || column_to_exclude_2="$column_to_exclude_2,2.$common_column_2"
  
#  file_ext=`basename $mergedfile|rev|cut -d. -f 1|rev`
#  mergedfile_tmp1=`echo $mergedfile|sed -e "s/\.$file_ext$/_tmp1.$file_ext/g"`
#  mergedfile_tmp2=`echo $mergedfile|sed -e "s/\.$file_ext$/_tmp2.$file_ext/g"`
  mergedfile_tmp1=`echo $mergedfile|sed -e "s/\(\.[^.]*\)$/_tmp1\1/g"`
  mergedfile_tmp2=`echo $mergedfile|sed -e "s/\(\.[^.]*\)$/_tmp2\1/g"`
  header_1=`head -n 1 $file_1`
  header_2=`head -n 1 $file_2`
  
  output_format_1=`echo $output_format| grep -oE "1\.[0-9]*,|1\.[0-9]*$"`
  output_format_2=`echo $output_format| grep -oE "2\.[0-9]*,|2\.[0-9]*$"`
  [ ${#output_format_1} -gt 0 ] && has_1=1 || has_1=0
  [ ${#output_format_2} -gt 0 ] && has_2=1 || has_2=0
  
  if [ $has_1 -eq 0 ]
  then
    column_count_1=`echo $header_1| grep -o "," | wc -l`
    ((column_count_1=column_count_1+1))
    for ((i=1;i<=$column_count_1;i++))
    do
      tmp=`echo $column_to_exclude_1 | grep -E "1\.$i,|1\.$i$"`
      if [ ${#tmp} -eq 0 ]
      then
        if [ $i -lt $column_count_1 ]
        then
          output_format_1="${output_format_1}1.$i,"
        else
          output_format_1="${output_format_1}1.$i"
        fi
      fi
    done
    output_format_1=`echo $output_format_1|sed -e "s/,$//g"`
    output_format="$output_format_1,$output_format"
  fi
  if [ $has_2 -eq 0 ]
  then
    column_count_2=`echo $header_2 | grep -o "," | wc -l`
    ((column_count_2=column_count_2+1))
    for ((i=1;i<=$column_count_2;i++))
    do
      tmp=`echo $column_to_exclude_2 | grep -E "2\.$i,|2\.$i$"`
      if [ ${#tmp} -eq 0 ]
      then
        if [ $i -lt $column_count_2 ]
        then
          output_format_2="${output_format_2}2.$i,"
        else
          output_format_2="${output_format_2}2.$i"
        fi
      fi
    done
    output_format_2=`echo $output_format_2|sed -e "s/,$//g"`
    output_format="$output_format,$output_format_2"
  fi
  output_format=`echo $output_format|sed -e "s/,,/,/g" -e "s/ //g" -e "s/,$//g"`
  if [ $noheader -eq 0 ]
  then
    join --header -t',' -1 $common_column_1 -2 $common_column_2 -a1 -o 0,$output_format <( echo $header_1 && tail -n +2 $file_1 |sort -t, -k$common_column_1) <(echo $header_2 && tail -n +2 $file_2 | sort -t, -k$common_column_2) > $mergedfile_tmp1
  else
    join -t',' -1 $common_column_1 -2 $common_column_2 -a1 -o 0,$output_format <( sort -t, -k$common_column_1 $file_1 ) <( sort -t, -k$common_column_2 $file_2 ) > $mergedfile_tmp1
  fi
  
  output_format=`echo $output_format|sed -e "s/1\./3./g" -e "s/2\./1./g"`
  output_format=`echo $output_format|sed -e "s/3\./2./g"`
  if [ $noheader -eq 0 ]
  then
    join --header -t',' -1 $common_column_2 -2 $common_column_1 -a1 -o 0,$output_format <( echo $header_2 && tail -n +2 $file_2 |sort -t, -k$common_column_2) <(echo $header_1 && tail -n +2 $file_1 | sort -t, -k$common_column_1) > $mergedfile_tmp2
  else
    join -t',' -1 $common_column_2 -2 $common_column_1 -a1 -o 0,$output_format <( sort -t, -k$common_column_2 $file_2 ) <( sort -t, -k$common_column_1 $file_1 ) > $mergedfile_tmp2
  fi
  
  grep -axFf $mergedfile_tmp1 $mergedfile_tmp2 >$mergedfile
  
  if [ $nodiff -eq 0 ]
  then
    grep -avxFf $mergedfile_tmp1 $mergedfile_tmp2 >>$mergedfile
    grep -avxFf $mergedfile_tmp2 $mergedfile_tmp1 >>$mergedfile
  fi
  rm -f $mergedfile_tmp1 $mergedfile_tmp2
}

re_number='^[0-9]+$'
common_column_1=1
common_column_2=1
nodiff=1
noheader=0
if [ $# -eq 1 ]
then
  [ $1 = "-f" -o $1 = "--help" ] && Usage
else
  while [ x$1 != x ] ; do
    case $1 in
      -1)
        #csv1
        [ -f $2 ] && file_1=$2 || (ERROR="Input file: $2 doesn't exist" ; Usage)
        shift 2
        ;;
      -2)
        #csv2
        [ -f $2 ] && file_2=$2 || (ERROR="Input file: $2 doesn't exist" ; Usage)
        shift 2
        ;;
      -o)
        #output filename
        [ ${#2} -gt 0 ] && mergedfile=$2 || (ERROR="output filename is empty" ; Usage)
        shift 2
        ;;
      -v)
        #Debugging
        DEBUG=1
        shift 1
        ;;
      -c1)
        #common column in csv1
        [[ $2 =~ $re_number ]] && common_column_1=$2 || (ERROR="column number of csv1 should be positive integer" ; Usage)
        shift 2
        ;;
      -c2)
        #common column in csv2
        [[ $2 =~ $re_number ]] && common_column_2=$2 || (ERROR="column number of csv2 should be positive integer" ; Usage)
        shift 2
        ;;
      -k)
        #columns to keep from both csvs
        [ ${#2} -gt 0 ] && output_format=$2 || (ERROR="Please specify columns to keep from both csvs or remove the -k parameter" ; Usage)
        shift 2
        ;;
      -e)
        #columns to exclude from both csvs
        [ ${#2} -gt 0 ] && column_to_exclude=$2 || (ERROR="Please specify columns to remove from both csvs or remove the -e parameter" ; Usage)
        shift 2
        ;;
      -u)
        #Whether to keep unmatched columns
        [[ $2 =~ '^[0-1]$' ]] && nodiff=$2
        shift 2
        ;;
      -nhd)
        #no header
        noheader=1
        shift 1
        ;;
      *)
        shift 1
        ;;
    esac
  done
fi

[ ${#file_1} -eq 0 ] && ERROR="1st file is empty" && Usage
[ ${#file_2} -eq 0 ] && ERROR="2nd file is empty" && Usage
[ ! -f $file_1 ] && ERROR="1st file is not readable" && Usage
[ ! -f $file_2 ] && ERROR="2nd file is not readable" && Usage
[ $file_1 = $file_2 ] && ERROR="input files should be uniq" && Usage
mergecsv
