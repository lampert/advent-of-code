#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/7

#INPUT=control.txt
INPUT=input.txt

set -u           # no undeclared vars

typeset -A dirs  # track size of dirs

while read l
do
    set - $l
    case $l in
    '$ cd ..') cur=${cur%/*/}/ ;;
    '$ cd /')  cur=/ ;;
    '$ cd '*)  cur=$cur$3/ ;;
    '$ ls') ;;
    'dir '*)   dir=$cur$2/ ;;

    [0-9]*)  # file and size listed
        size=$1
        # add size to all parent dirs.
        tmp=$cur
        while [[ -n $tmp ]];do
            let dirs[$tmp]+=size
            tmp=${tmp%%*([^/])/} # back one dir at a time
        done
        ;;

    *) echo >&2 "ERROR PARSE"; exit 1 ;;
    esac
done < $INPUT


# Answer 1. Find all dirs with size <= 1e5


let sum=0
for i in ${!dirs[@]};do
    let size=${dirs[$i]}
    if (( size <= 1e5 )); then   # as per answer 1, limit size for summing
        let sum+=size
    fi
done
echo "Answer 1 is $sum."


# Answer 2. Find least sized > required size dir.


let freespace=70e6-dirs["/"]    # as per question 2, total disk space minus used disk space
let required=30e6-freespace     # required is 30e6, so find

let answer=70e6  # prime the state with max possible
for i in ${!dirs[@]};do
    let size=${dirs[$i]}
    if (( size>=required && size<=answer )); then
        let answer=size         # scan for valid dir
    fi
done
echo "Answer 2 is $answer."
