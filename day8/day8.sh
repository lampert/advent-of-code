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
    typeset name=$1
    typeset check=${grid[y]:x:1}
    if (( check > treeSize )); then
        let treeSize=check
        if (( !counted[y][x] )); then
            counted[y][x]=1 # remember that it was already counted.
            let num++
        fi
    fi
}

# check view from each direction

for (( x=1; x<xsiz-1; x++ )); do
    let treeSize=${grid[0]:x:1}
    for (( y=1; y<ysiz-1; y++ )); do
        countTree "n-s"
    done
done
for (( x=1; x<xsiz-1; x++ )); do
    treeSize=${grid[ysiz-1]:x:1}
    for (( y=ysiz-2; y>=1; y-- )); do
        countTree "s-n"
    done
done
for (( y=1; y<ysiz-1; y++ )); do
    let treeSize=${grid[y]:0:1}
    for (( x=1; x<xsiz-1; x++ )); do
        countTree "e-w"
    done
done
for (( y=1; y<ysiz-1; y++ )); do
    treeSize=${grid[y]:xsiz-1:1}
    for (( x=xsiz-2; x>=1; x-- )); do
        countTree "w-e"
    done
done

let edge=2*xsiz+2*ysiz-4  # add outer bounds
let num+=edge
echo "Answer 1 is $num trees visible."



# Answer 2. Find best "view"


typeset maxScore=0
for (( y=0; y<ysiz; y++ )); do
    for (( x=0; x<xsiz; x++ )); do
        treeSize=${grid[y]:x:1}
        # to north
        nTrees=(0 0 0 0) # number of trees in each direction
        for (( yy=y-1; yy>=0; --yy ));do
            typeset check=${grid[yy]:x:1}
            let nTrees[0]++
            ((check>=treeSize)) && break
        done
        for (( yy=y+1; yy<ysiz; ++yy ));do
            typeset check=${grid[yy]:x:1}
            let nTrees[1]++
            ((check>=treeSize)) && break
        done
        for (( xx=x-1; xx>=0; --xx ));do
            typeset check=${grid[y]:xx:1}
            let nTrees[2]++
            ((check>=treeSize)) && break
        done
        for (( xx=x+1; xx<xsiz; ++xx ));do
            typeset check=${grid[y]:xx:1}
            let nTrees[3]++
            ((check>=treeSize)) && break
        done
        let score=nTrees[0]*nTrees[1]*nTrees[2]*nTrees[3]
        if (( score > maxScore )); then
            let maxScore=score
            # echo "New max score: $score @ $x,$y (${nTrees[*]})"
        fi
    done
done

echo "Answer 2 is $maxScore."
