#! /bin/bash

#Colors
SOMECOLOR='\033[0;34m'
BROWN='\033[0;31m'
NC='\033[0m'

#Echo message prefix
M="${BROWN}"
O="${SOMECOLOR}"
S="${NC}"

[ "$1" == "--files-only" ]
files_only=$?
if [ $files_only -eq 0 ]; then shift 1; fi

dir="$1"
pat_files_grep="$2"
pat_egrep="$3"
egrep="grep -E --color=auto"
#egrep="egrep --color=auto"
#egrep="grep --color=auto"

if [ $files_only -ne 0 ]; then
	echo
	find "$dir" -iname "$pat_files_grep" \
		-execdir $egrep "$pat_egrep" '{}' \; \
	    -execdir echo -ne "$M<<  from file: ${NC}" \; \
		-execdir readlink -f '{}' \; \
	    -execdir echo \;
	#    -execdir echo -e "$O-------------------------------------------------------------------${NC}" \;
else
	egrep="$egrep -q"
	find "$dir" -iname "$pat_files_grep" \
		-execdir $egrep "$pat_egrep" '{}' \; \
		-execdir readlink -f '{}' \;
fi


#<readlink shows full path of file and follows any symlinks
