#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/14

set -u -f # no undeclared vars, no file name expansion

#INPUT=control.txt
# 498,4 -> 498,6 -> 496,6
# 503,4 -> 502,4 -> 502,9 -> 494,9

INPUT=input.txt

function addLine
{
    #plot line in grid
    nameref g=$1
    typeset p1=$2
    typeset p2=$3
#
    typeset x1=${p1%%,*} y1=${p1##*,} # break up points
    typeset x2=${p2%%,*} y2=${p2##*,}

#   echo "addLine $x1,$y1 to $x2,$y2"
    if (( x1==x2 )); then
        for y in {$y1..$y2};do        # vertical line
            g[$x1,$y]='#'
        done
    else
        for x in {$x1..$x2};do        # horizontal line
            g[$x,$y1]='#'
        done
    fi

# track bottom coordinate for simulation
    for x in $x1 $x2;do
        (( x>${g["xMax"]:=$x} )) && (( g["xMax"]=x ))
        (( x<${g["xMin"]:=$x} )) && (( g["xMin"]=x ))
    done
    for y in $y1 $y2;do
        (( y>${g["yMax"]:=$y} )) && (( g["yMax"]=y ))
        (( y<${g["yMin"]:=$y} )) && (( g["yMin"]=y ))
    done
}

function readGrid
{
    # read each edge definition from input and plot in to grid associative array
    nameref g=$1
    g["xMax"]=500  # initial point at which sand pours in
    g["xMin"]=500
    g["yMax"]=0
    g["yMin"]=0
    while read edge; do
        # break up edge in to pairs of points
        while [[ $edge = *"->"* ]]; do
            typeset p1=${edge%%->*}   # isolate first point
            edge="${edge#$p1->}"      # shift to second point
            typeset p2=${edge%%->*}   # isolate second point
            addLine g $p1 $p2      # plot each point in the line
        done
    done < $INPUT
}

function drawGrid
{
    nameref g=$1
    typeset x y
    for (( y=g["yMin"]; y<=g["yMax"]+3; ++y ));do
        printf "%4d: " $y
        for (( x=g["xMin"]-3; x<=g["xMax"]+3; ++x ));do
            typeset c=${g[$x,$y]:-'.'}
            printf "$c"
        done
        printf "\n"
    done
}

typeset -ri SIMEND=1 SIMBLOCK=2 SIMNEXT=3

function simulate
{
    nameref g=$1

    typeset -i i=0
    while true;do
        (( (i%100)==0 )) && printf "iteration $i...\n"
        pourSand g 500 0
        typeset rc=$?
        ((rc!=SIMNEXT)) && break
        ((++i))
    done
    drawGrid g
    printf "total iterations $i, rc $rc\n"
    return $rc
}

function pourSand
{
    nameref g=$1
    typeset x=$2 y=$3
    (( y>g[yMax] )) && return $SIMEND  # beyond bottom

    typeset space=${g[$x,$y]:-'.'}
    if [[ $space != '.' ]]; then
        # occupied space
        return $SIMBLOCK  # blocked
    fi

    # empty space
    pourSand g $x $((y+1))  #try directly below
    typeset rc=$?
    ((rc==$SIMEND || rc==$SIMNEXT)) && return $rc    # beyond bottom (END) or need next one (NEXT)
    pourSand g $((x-1)) $((y+1))  # try diagonally left
    rc=$?
    ((rc==$SIMEND || rc==$SIMNEXT)) && return $rc    # beyond bottom (END) or need next one (NEXT)
    pourSand g $((x+1)) $((y+1))  # try diagonally right
    rc=$?
    ((rc==$SIMEND || rc==$SIMNEXT)) && return $rc    # beyond bottom (END) or need next one (NEXT)
    # place here and request next.
    g[$x,$y]='o'
    return $SIMNEXT
}

printf "\n\nAnswer 1\n\n"

typeset -A grid=( )
readGrid grid
simulate grid

printf "\n\nAnswer 2\n\n"

typeset -A grid2=( )
readGrid grid2
addLine grid2 $((grid["xMin"]-1000)),$((grid["yMax"]+2)) $((grid["xMin"]+1000)),$((grid["yMax"]+2)) # add the floor
grid2["xMin"]=${grid["xMin"]} #restore old max for drawGrid
grid2["xMax"]=${grid["xMax"]}
simulate grid2
