#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/8

#INPUT=control.txt
INPUT=input.txt

set -u           # no undeclared vars


typeset -a grid
while read g;do
    # convert string of digits "1234..." to array initialization (1 2 3 4 ...)
    grid[${#grid[*]}]=(${g//[0-9]/ \0}) 
done < $INPUT

(( xsiz=${#grid[0][*]} ))  # number of elements across 0th row.
(( ysiz=${#grid[*]} ))     # number of rows.

#echo "xsiz $xsiz ysiz $ysiz"


# Answer 1. Count visible trees from each direction.


typeset -a isCounted  # track if tree counted already.
(( num=0 ))           # count of trees

function countTree
{
    typeset name=$1
    typeset -i check
    (( check=grid[y][x] ))
    if (( check > treeSize )); then
        (( treeSize=check ))
        if (( !isCounted[y][x] )); then
            (( isCounted[y][x]=1 )) # remember that it was already counted.
            (( num++ ))
        fi
    fi
}

# check view from each direction

for (( x=1; x<xsiz-1; x++ )); do
    (( treeSize=grid[0][x] ))
    for (( y=1; y<ysiz-1; y++ )); do
        countTree "n-s"
    done
done
for (( x=1; x<xsiz-1; x++ )); do
    (( treeSize=grid[ysiz-1][x] ))
    for (( y=ysiz-2; y>=1; y-- )); do
        countTree "s-n"
    done
done
for (( y=1; y<ysiz-1; y++ )); do
    (( treeSize=grid[y][0] ))
    for (( x=1; x<xsiz-1; x++ )); do
        countTree "e-w"
    done
done
for (( y=1; y<ysiz-1; y++ )); do
    (( treeSize=grid[y][xsiz-1] ))
    for (( x=xsiz-2; x>=1; x-- )); do
        countTree "w-e"
    done
done

(( edge=2*xsiz+2*ysiz-4 )) # add outer bounds
(( num+=edge ))
echo "Answer 1 is $num trees visible."



# Answer 2. Find best "view"


typeset -i maxScore=0
typeset -i check
for (( y=0; y<ysiz; y++ )); do
    for (( x=0; x<xsiz; x++ )); do
        (( treeSize=grid[y][x] ))           # current tree size
        nTrees=(0 0 0 0)                    # count of trees in each direction
        for (( yy=y-1; yy>=0; yy-- ));do    # to north
            (( check=grid[yy][x] ))
            (( nTrees[0]++ ))
            (( check>=treeSize )) && break
        done
        for (( yy=y+1; yy<ysiz; yy++ ));do  # to south
            (( check=grid[yy][x] ))
            (( nTrees[1]++ ))
            (( check>=treeSize )) && break
        done
        for (( xx=x-1; xx>=0; xx-- ));do    # to west
            (( check=grid[y][xx] ))
            (( nTrees[2]++ ))
            (( check>=treeSize )) && break
        done
        for (( xx=x+1; xx<xsiz; xx++ ));do  # to east
            (( check=grid[y][xx] ))
            (( nTrees[3]++ ))
            (( check>=treeSize )) && break
        done
        (( score=nTrees[0]*nTrees[1]*nTrees[2]*nTrees[3] )) # score calculation
        if (( score > maxScore )); then
            (( maxScore=score ))
            #echo "New max score: $score @ $x,$y (${nTrees[*]})"
        fi
    done
done

echo "Answer 2 is $maxScore maximum tree score."
