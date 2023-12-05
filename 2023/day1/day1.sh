#!/usr/bin/env ksh
# https://adventofcode.com/2023/day/1

set -u -f # no undeclared vars, no file name expansion

INPUT=input.txt
#INPUT=control.txt

typeset tot=0
cat $INPUT | while read line;do
    line="${line//[^0-9]/}"        # eliminate non numbers
    num=${line:0:1}${line: -1:1}   # grab first and last number (may be the same)
    (( tot+=num ))
done
echo Answer 1: $tot

[[ $INPUT = control.txt ]] && INPUT=control2.txt # switch to second control

typeset tot=0
cat $INPUT | while read line;do

    # walk each character scanning for spelled out digits or actual digits
    nums=""
    for (( i=0; i<${#line}; i++ ));do
        case ${line:i} in
        one*)   nums+="1" ;;
        two*)   nums+="2" ;;
        three*) nums+="3" ;;
        four*)  nums+="4" ;;
        five*)  nums+="5" ;;
        six*)   nums+="6" ;;
        seven*) nums+="7" ;;
        eight*) nums+="8" ;;
        nine*)  nums+="9" ;;
        [0-9]*) nums+=${line:i:1} ;;
        esac
    done
    (( num=${nums:0:1}${nums: -1:1} ))   # form target number from first and last (may be the same)
    (( tot+=num ))
    #echo "read  $line   numsonly $nums   num $num   tot=$tot"
done
echo Answer 2: $tot
    

