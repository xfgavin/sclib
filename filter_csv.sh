#!/bin/bash
SCRIPTROOT=$( cd $(dirname $0) ; pwd)
Usage(){
cat <<USAGE
++++++++++++++++++++++++++++++++++++++++++++++++++++
Part of sclib (https://github.com/xfgavin/sclib)
Remove matched rows in a given list from a csv
by xfgavin@gmail.com 01/24/2018 @UCSD
+++++++++++++++++++++++++++++++++++++++++++++++++++++

`basename $0` <-i csv to work on>  <-l list to remove> [-c target column in csv -ih rows of input file header -lh rows of list header ]
-i </path/to/csv>
  The csv we are going to work on,
  Or CSVs, in this case, please use double quotes, esp, when you are using wildcards.

-l </path/to/list>
  The list to remove from csv.

Optional:
-c <column number in target csv>
  Define which column in the csv has the data that in the list file.
-ih <rows of input file header>
  How many rows of the input file header, by default it equals 1
-lh <rows of list header>
  How many rows of the list header, by default it equals 1

-h, --help
	Show me.

Examples:
`basename $0` -i target.csv -l list
`basename $0` -i target.csv -l list -c 3
`basename $0` -i "*.csv" -l list -c 3

USAGE
rm -f $lck
[ ${#ERROR} ] && echo -e '\E[7;31;40m'"\033[1mError: $ERROR\033[0m" && exit -1
exit 0
}

filtercsv(){
  ((index_list=csv_list_header_len+1))
  tail -n +$index_list $csv_list|sed -e 's/"//g' > dup_list

  for csv in $csv_input
  do
    column_count=`head -1 $csv | sed 's/[^,]//g' | wc -c`
    filename=`echo $csv|rev|cut -d. -f 2-|rev`
    head -n$csv_input_header_len $csv > ${filename}_header.csv
    ((index_data=csv_input_header_len+1))
    tail -n +$index_data $csv|sort -k$csv_input_column -t, > ${filename}_data.csv
    cut -d, -f$csv_input_column ${filename}_data.csv >data_list
    sort dup_list data_list |uniq -u > uniq_list
    case $csv_input_column in
      1)
        join -t, ${filename}_data.csv uniq_list >${filename}_data_new.csv
        ;;
      $column_count)
        ((index_data_1=csv_input_column-1))
        #cut -d, -f1-$index_data_1 ${filename}_data.csv >data_list_1
        #paste data_list data_list_1 -d, > ${filename}_data.csv
        join -t, -1 $csv_input_column ${filename}_data.csv uniq_list >${filename}_data_new.csv
        cut -d, -f1 ${filename}_data_new.csv >data_list
        cut -d, -f2- ${filename}_data_new.csv >data_list_1
        paste data_list_1 data_list -d, > ${filename}_data_new.csv
        ;;
      *)
        [ $csv_input_column -gt $column_count ] && echo -e '\E[7;31;40m'"\033[1mError: column number in input csv cannot be greater than total column count\033[0m" && exit -1
        ((index_data_1=csv_input_column-1))
        ((index_data_2=csv_input_column+1))
        #cut -d, -f1-$index_data_1 ${filename}_data.csv >data_list_1
        #cut -d, -f${index_data_2}- ${filename}_data.csv >data_list_2
        #paste data_list data_list_1 data_list_2 -d, > ${filename}_data.csv
        join -t, -1 $csv_input_column ${filename}_data.csv uniq_list >${filename}_data_new.csv
        cut -d, -f1 ${filename}_data_new.csv >data_list
        cut -d, -f2-$csv_input_column ${filename}_data_new.csv >data_list_1
        cut -d, -f${index_data_2}- ${filename}_data_new.csv >data_list_2
        paste data_list_1 data_list data_list_2 -d, > ${filename}_data_new.csv
        ;;
    esac
    mv ${filename}_header.csv $csv
    cat ${filename}_data_new.csv >> $csv
    rm -f ${filename}_data*.csv data_list* uniq_list
  done
  rm -f dup_list
}

lck=.filter_csv.lck
[ -f $lck ] && echo "filter_csv process is running, check lock file: `pwd`/$lck" && echo -1
touch $lck

re_number='^[0-9]+$'
if [ $# -eq 1 ]
then
  [ $1 = "-f" -o $1 = "--help" ] && Usage
else
  while [ x$1 != x ] ; do
    case $1 in
      -i)
        #input file
        #[ -f $2 ] && csv_input=$2 || (ERROR="Input file: $2 doesn't exist" ; Usage)
        csv_input="$2"
        shift 2
        ;;
      -l)
        #list
        [ -f $2 ] && csv_list=$2 || (ERROR="list: $2 doesn't exist" ; Usage)
        shift 2
        ;;
      -v)
        #Debugging
        DEBUG=1
        shift 1
        ;;
      -c)
        #column number in input csv that has info of the list
        [[ $2 =~ $re_number ]] && csv_input_column=$2 || (ERROR="column number should be non-negative integer" ; Usage)
        shift 2
        ;;
      -ih)
        #row count of input csv header
        [[ $2 =~ $re_number ]] && csv_input_header_len=$2 || (ERROR="row count of input header should be non-negative integer" ; Usage)
        shift 2
        ;;
      -lh)
        #row count of list csv header
        [[ $2 =~ $re_number ]] && csv_list_header_len=$2 || (ERROR="row count of input header should be non-negative integer" ; Usage)
        shift 2
        ;;
      *)
        shift 1
        ;;
    esac
  done
fi
if [ ${#csv_input} -eq 0 ]
then
  ERROR="Please supply Input file"
  Usage
elif [ ${#csv_list} -eq 0 ]
then
  ERROR="Please supply list file"
  Usage
else
  [ ${#csv_input_column} -eq 0 ] && csv_input_column=1
  [ ${#csv_input_header_len} -eq 0 ] && csv_input_header_len=1
  [ ${#csv_list_header_len} -eq 0 ] && csv_list_header_len=1
  filtercsv
fi
rm -f $lck
