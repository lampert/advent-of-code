#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/9
set -u -f    # no undeclared vars, no file name expansion (causes dir lookup for array [])

INPUT=input.txt


function mapDirection
{
    typeset dir=$1        # input is R,L,U,D
    nameref dx=$2 dy=$3   # output is dx,dy
    case $dir in
        R) dx=1; dy=0;;
        L) dx=-1; dy=0;;
        U) dx=0; dy=-1;;
        D) dx=0; dy=1;;
        *) echo >&2 "bad input $dir";;
    esac
}


function countOnce
{
    nameref once=$1        # state
    nameref atLeastOnce=$2 # input/output count
    typeset -i x=$3 y=$4   # input x,y coordinates to count
    typeset key=$(printf "tx=%d,ty=%d" $x $y)
    if (( !once[$key] )); then
        (( once[$key]=1 ))
        (( atLeastOnce++ ))
    fi
}


function moveKnot
{
    nameref knots=$1
    typeset knotNum=$2
    typeset newx=$3 newy=$4
    typeset -n hx=knots[knotNum].x   hy=knots[knotNum].y  # hx,hy aliased to head
    if (( knotNum == ${#knots[*]}-1 ));then
        # this is tail, so end recursion
        let hx=newx hy=newy
        return
    fi
    let hx=newx hy=newy   # move head

    # now adjust tail, if necessary
    typeset -n tx=knots[knotNum+1].x ty=knots[knotNum+1].y # tx,ty aliased to tail
    typeset -i dx=newx-tx dy=newy-ty # distance from new head to tail
    if (( abs(dx)<=1 && abs(dy)<=1 ));then
        # no need to move tail
        return
    fi

    (( dx=dx ? copysign(1,dx) : 0 ))  # convert dx to -1,0,1
    (( dy=dy ? copysign(1,dy) : 0 ))  # convert dy to -1,0,1
    moveKnot knots $((knotNum+1)) $((tx+dx)) $((ty+dy))   # move tail
}




function main
{
    for answerNum in 1 2;do

        typeset -A once=( )                  # track if tail already touched this spot.
        typeset -i atLeastOnce=0             # start at 0 for answer.

        typeset -i numKnots
        case $answerNum in
            1)  numKnots=2 ;;  # answer one has 2 knots (head and tail)
            2)  numKnots=10 ;; # answer two has 10 knots
        esac
        knots=()
        for ((i=0; i<numKnots; i++)); do
            knots[i]=(x=500 y=500)
        done 

        # count initial tail spot
        countOnce once atLeastOnce ${knots[numKnots-1].x} ${knots[numKnots-1].y}

        while read dir num
        do
            mapDirection $dir dx dy
            for ((i=num-1; i>=0; i--));do # move for this many paces
                let newx=dx+knots[0].x newy=dy+knots[0].y
                moveKnot knots 0 $newx $newy
                countOnce once atLeastOnce ${knots[numKnots-1].x} ${knots[numKnots-1].y}
            done
        done < $INPUT

        echo "Answer $answerNum is $atLeastOnce."
    done
}


main
