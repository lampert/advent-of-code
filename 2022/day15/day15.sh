#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/15

set -u -f # no undeclared vars, no file name expansion

#Sensor at x=2, y=18: closest beacon is at x=-2, y=15
#Sensor at x=9, y=16: closest beacon is at x=10, y=16
#Sensor at x=12, y=14: closest beacon is at x=10, y=16
#Sensor at x=10, y=20: closest beacon is at x=10, y=16
#...
#INPUT=control.txt; LINE=10
INPUT=input.txt; LINE=2000000

function lineCoverage
{
    nameref g=$1
    (( l=$2 ))
    (( sx=$3 )); (( sy=$4 ))
    (( bx=$5 )); (( by=$6 ))

    (( difx=abs(sx-bx) ))
    (( dify=abs(sy-by) ))
    (( manh = difx+dify )) # "manhattan" distance. total signal strength

    (( sy<=l && (sy+manh) < l )) && return # sensor is out of range of line
    (( sy>=l && (sy-manh) > l )) && return

    (( difl = abs(l-sy) )) # how far is vertical distance
    (( left = manh-difl )) # how much horizontal length is left
    echo "sensor $sx,$sy beacon $bx,$by line $l manh $manh difl $difl left $left fill {$((-left))..$((left))}"
    for i in {0..$left};do       # fill in horizontal spaces to the left & right
        typeset c=${g[$((sx+i)),$l]:='#'} # only overwrite if empty
        typeset c=${g[$((sx-i)),$l]:='#'}
    done
}

typeset -A grid
while read csensor cat x y cclosest cbeacon cis cat bx by
do
    x=${x#x=}; x=${x%,}
    y=${y#y=}; y=${y%:}
    bx=${bx#x=}; bx=${bx%,}
    by=${by#y=}
    grid[$x,$y]=S
    grid[$bx,$by]=B
    typeset dist=$((abs(x-bx)+abs(y-by)))
    echo "sensor $x $y beacon $bx $by dist $dist"
    lineCoverage grid $LINE $x $y $bx $by
done < $INPUT

echo "Answer 1.  Counting # on line $LINE"
typeset count=0

# find all data in line $LINE
for i in ${!grid[*]}  # each key in map
do
    typeset c=${grid["$i"]}
    [[ $i != *,$LINE ]] && continue   # filter to *,LINE
    [[ $c != B ]] && (( ++count ))    # count anything not a beacon
done

echo "count $count"

