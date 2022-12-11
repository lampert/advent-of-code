#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/10
set -u -f # no undeclared vars, no file name expansion 


#INPUT=control.txt
INPUT=input.txt

log=(0)     # log value of X per cycle

let cycle=1 # current cycle 
let regx=1  # current value of x

while read instruction value; do
    case $instruction in
        noop)
            (( log[cycle++]=regx ))
            ;;

        addx)
            (( log[cycle++]=regx ))
            (( log[cycle++]=regx ))
            (( regx+=value ))
            ;;
        *)
            echo >&2 "error parsing input"
            exit 1
            ;;
    esac
done < $INPUT 

let sum=0
for i in 20 60 100 140 180 220;do
    (( sum+=i*log[i] ))
done
echo "Answer 1 is $sum."

echo "Answer 2"
cycle=1
for (( y=0; y<6; y++ ));do
    for (( x=0; x<40; x++ ));do
        (( crt=log[cycle++] ))
        if (( x>=crt-1 && x<=crt+1 )); then
            print -n "█"
        else
            print -n " "
        fi
    done
    print
done

