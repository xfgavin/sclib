#!/bin/bash
SCRIPTROOT=$( cd $(dirname $0) ; pwd)
Usage(){
cat <<USAGE
++++++++++++++++++++++++++++++++++++++++++++++++++++
Part of sclib (https://github.com/xfgavin/sclib)
View csv in terminal window
Adapted from Chris Jean https://chrisjean.com/view-csv-data-from-the-command-line/
by xfgavin@gmail.com 01/26/2018 @UCSD
+++++++++++++++++++++++++++++++++++++++++++++++++++++

`basename $0` </path/to/csv> [-h/--help]
Required:
  /path/to/csv
Optional:
-h, --help
        Show me.

Examples:
`basename $0` csv

USAGE
[ ${#ERROR} -gt 0 ] && echo -e "\e[1;101;93mError: $ERROR\e[0m" && exit -1
exit 0
}
termviewer(){
  cat $1 | sed -e 's/,,/, ,/g' | column -s, -t | less -#5 -N -S
}
if [ $# -eq 1 ]
then
  [ $1 = -h -o $1 = --help ] && Usage
  [ ! -f $1 ] && ERROR="File $1 is not readable" && Usage
  termviewer
fi
