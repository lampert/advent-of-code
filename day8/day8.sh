#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/8

#INPUT=control.txt
INPUT=input.txt

set -u           # no undeclared vars


typeset -a grid
while read g;do
    grid[${#grid[*]}]=$g
done < $INPUT


let xsiz=${#grid[0]}
let ysiz=${#grid[*]}

#echo "xsiz $xsiz ysiz $ysiz"


# Answer 1. Count visible trees from each direction.

typeset -a counted  # track if tree counted already
let num=0

function countTree
{
    nameref grid=$1
    nameref treeSize=$2
    nameref counted=$3
    nameref num=$4
    nameref x=$5
    nameref y=$6
    typeset name=$7

    typeset check=${grid[y]:x:1}
#   echo "$name x,y $x,$y check $check treeSize $treeSize"
    if (( check > treeSize )); then
        let treeSize=check
        if (( !counted[y][x] )); then
            counted[y][x]=1 # remember that it was already counted.
            let num++
            #echo "$name counted x,y $x,$y num $num"
        fi
    fi
}

# check view from each direction

for (( x=1; x<xsiz-1; x++ )); do
    let treeSize=${grid[0]:x:1}
    for (( y=1; y<ysiz-1; y++ )); do
        countTree grid treeSize counted num x y "n-s"
    done
done
for (( x=1; x<xsiz-1; x++ )); do
    treeSize=${grid[ysiz-1]:x:1}
    for (( y=ysiz-2; y>=1; y-- )); do
        countTree grid treeSize counted num x y "s-n"
    done
done
for (( y=1; y<ysiz-1; y++ )); do
    let treeSize=${grid[y]:0:1}
    for (( x=1; x<xsiz-1; x++ )); do
        countTree grid treeSize counted num x y "e-w"
    done
done
for (( y=1; y<ysiz-1; y++ )); do
    treeSize=${grid[y]:xsiz-1:1}
    for (( x=xsiz-2; x>=1; x-- )); do
        countTree grid treeSize counted num x y "w-e"
    done
done

# add outer bounds
let edge=2*xsiz+2*ysiz-4
let num+=edge
echo "Answer 1 is $num trees visible."
