#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/15

set -u -f # no undeclared vars, no file name expansion

#Sensor at x=2, y=18: closest beacon is at x=-2, y=15
#Sensor at x=9, y=16: closest beacon is at x=10, y=16
#Sensor at x=12, y=14: closest beacon is at x=10, y=16
#Sensor at x=10, y=20: closest beacon is at x=10, y=16
#...
#INPUT=control.txt; LIM=20
INPUT=input.txt; LIM=4000000


function signalCoverage
{
    # update coverage in signal map
    # each line is array of ranges of horizontal coverage, ie 1-2 4-5 7-10
    nameref g=$1
    (( sx=$2 )); (( sy=$3 ))
    (( bx=$4 )); (( by=$5 ))

    (( difx=abs(sx-bx) ))
    (( dify=abs(sy-by) ))
    (( manh = difx+dify )) # "manhattan" distance. total signal strength

    (( lo=sy-manh ))
    (( hi=sy+manh ))
    (( hi<0 || lo>LIM )) && return #out of limits, skip

    (( lo= lo<0 ? 0 : lo ))        #clamp to limits
    (( hi= hi>LIM ? LIM : hi ))

    # collect all ranges of signal per line
    for (( l=lo; l<=hi; l++ ))
    do
        (( difl = abs(l-sy) )) # how far is vertical distance
        (( left = manh-difl )) # how much horizontal length is left
        addRangeToLine g[$l] $((sx-left)) $((sx+left))
    done
}

function addRangeToLine
{
    nameref r=$1
    typeset lo=$2 hi=$3
    typeset -A r
    key=$( printf "10#%08d" $lo )
    (( r[$key] < hi )) && (( r[$key]=hi ))
}

function compressRanges
{
    nameref or=$1
    typeset reset=1
    typeset lo hi
    typeset -A newr
    for newlo in ${!or[*]};do
        typeset newhi=$((or[$newlo]))
        if ((reset)); then
            reset=0
            (( lo=newlo ))
            (( hi=newhi ))
            #echo "reset lo=$lo hi=$hi"
            continue
        fi
        #echo "  check $((lo)),$((hi)) vs $((newlo)),$((newhi))"
        if (( (newlo>=lo-1 && newlo<=hi+1) 
           || (newhi>=lo-1 && newhi<=hi+1) 
           || (newlo<=lo-1 && newhi>=hi+1) ))
        then
            if (( newlo<lo )); then
                (( lo=newlo ))
            fi
            if (( newhi>hi ));then
                (( hi=newhi ))
            fi
            #echo "      compressed $((lo)),$((hi))"
        else
            addRangeToLine newr $lo $hi
            (( lo=newlo ))
            (( hi=newhi ))
            #echo "  reset lo=$lo hi=$hi"
        fi
    done
    addRangeToLine newr $lo $hi
    # copy new array to old.
    for i in ${!or[*]};do
        unset or[$i]
    done
    for i in ${!newr[*]};do
        or[$i]=${newr[$i]}
    done
}

typeset numSensor=0
while read line;do
    ((++numSensor))
done < $INPUT

typeset n=0
typeset -A signal
while read csensor cat x y cclosest cbeacon cis cat bx by
do
    x=${x#x=}; x=${x%,}
    y=${y#y=}; y=${y%:}
    bx=${bx#x=}; bx=${bx%,}
    by=${by#y=}
    typeset dist=$((abs(x-bx)+abs(y-by)))
    echo "$((++n)) of $((numSensor)) sensor $x $y beacon $bx $by dist $dist"
    signalCoverage signal $x $y $bx $by
done < $INPUT

# consolidate lines

for l in ${!signal[*]};do
    #echo "line $l: $( for i in ${!signal[$l][*]};do printf " $i,${signal[$l][$i]}"; done; echo )"
    compressRanges signal[$l]
    typeset n=${#signal[$l][*]}
    if (( n>1 )); then
        echo "line $l nitems $n: $( for i in ${!signal[$l][*]};do printf " $i,${signal[$l][$i]}"; done; echo )"
        set - ${!signal[$l][@]}
        if (( $signal[$l][$1]+2 == $2 )); then
            echo " ** gap $(( $2 - 1 ))"
            echo " Answer 2 is $(( ($2-1)*4000000+l ))"
        fi
    fi
done

