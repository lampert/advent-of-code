#!/usr/bin/env ksh
# https://adventofcode.com/2023/day/6

set -u -f # no undeclared vars, no file name expansion

function calcScoreQ
{
    typeset t=$1 d=$2
    nameref out=$3 
    # formula is holdTime * (time - holdTime) = distance
    # h(t-h)=d  ->  -h²+th-d=0    that's the quadratic equation
    # ax²+bx+c=0 ... x=(-b ± √(b²-4ac))÷2a
    #                a=-1 b=t c=-d
    #                h=(-t ± √(t²-4(-1)(-d))) ÷ 2(-1)
    #                h=(-t ± √(t²-4d)) ÷ (-2)
    #             this gives the low and high hold times for max distance.  all times between yield better score
    typeset h l nl nh
    (( l=(-t + sqrt(t**2-4*d)) / (-2) ))
    (( h=(-t - sqrt(t**2-4*d)) / (-2) ))
    (( nl=ceil(l) ))
    (( nh=floor(h) ))
    (( l=(l==nl) ? nl+1 : nl ))  # if low bound is an int, don't include in span
    (( h=(h==nh) ? nh-1 : nh ))  # if high bound is an int, don't include in span
    (( out=h-l+1 ))
}

function calcScore
{
    nameref times=$1 dists=$2 score=$3
    ((score=1))
    for ((i=0;i<${#dists[*]};i++));do
        typeset holdspan
        calcScoreQ ${times[i]} ${dists[i]} holdspan
        ((score*=holdspan))   # keep running score
        echo "race $i time ${times[i]} record ${dists[i]}  holdspan $holdspan score $score"
    done
}

score=0

timesarr=( 7 15  30 )
distsarr=( 9 40 200 )
calcScore timesarr distsarr score
echo "Control: $score"

timesarr=(  56     71     79     99 )
distsarr=( 334   1135   1350   2430 )
calcScore timesarr distsarr score
echo "Answer 1: $score"

timesarr=( 71530 )
distsarr=( 940200 )
calcScore timesarr distsarr score
echo "Control 2: $score"

timesarr=(        56717999 )
distsarr=( 334113513502430 )
calcScore timesarr distsarr score
echo "Answer 2: $score"
