#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/6

set -u           # no undeclared vars

function scanDupe
#  arg 1:  scanLen - length to scan for dupes
#  arg 2:  message contents
#  arg 3:  output - beginning of non-dupe range
{
    typeset -i scanLen=$1
    typeset msg="$2"
    nameref output=$3
    let dupe=0

    # scan message
    for (( i=0; i<${#msg}-scanLen; i++)); do

        # scan for dupes in window
        for (( j=0; j<scanLen; j++ ));do

            pattern=${msg:i+j+1:scanLen-j-1}          # generate pattern to look for dupes.
            if [[ ${msg:i+j:1} = [$pattern] ]]; then  # look for this char in dupe range
                    dupe=1
                    break
            fi

        done
        if (( dupe )); then
            dupe=0
            continue # found dupe, continue scanning message
        fi
        output=$((i+scanLen)) # return offset after non-dupe range
        return 0
    done
    echo "ERROR - nothing found"
    exit 1
}

typeset -i offset

msg=$(cat input.txt)
scanDupe 4 $msg offset
echo "Answer 1 is $((offset))."
scanDupe 14 $msg offset
echo "Answer 2 is $((offset))."
