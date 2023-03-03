#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/16

set -u -f # no undeclared vars, no file name expansion

INPUT=control.txt   # test data
#INPUT=input.txt    # problem data

function shortestDistances
{
    # Output dists calculated distance to each cave
    nameref map=$1
    nameref dists=$2
    typeset cave=$3
    typeset currentDistance=$4

    if (( currentDistance==0 )); then
        #initialize
        typeset -A dists=( )
    fi

    typeset oldDist
    oldDist=${dists[$cave]:-inf}    # if unset, then set to infinity
    if (( currentDistance < oldDist )); then
        # this is a shorter path.
        dists[$cave]=$currentDistance
        # now calculate all tunnels from here
        typeset newCave
        for newCave in ${map[$cave].tunnels[*]}; do
            shortestDistances map dists $newCave $((currentDistance+1))
        done
    fi
}

typeset globalIterations=0
typeset globalStart=$SECONDS

function tryPaths
{
    nameref map=$1
    typeset cave=$2
    typeset timeLeft=$3

    if (( (++globalIterations % 10000) == 0));then
        echo "Iterations $globalIterations seconds $((SECONDS-globalStart))"
    fi

    # calculate score for turning on this valve.
    typeset myScore=$((map[$cave].rate * timeLeft))

    # mark as used (rate=0), but remember so I can restore on return.
    typeset oldRate=$((map[$cave].rate))
    map[$cave].rate=0

    # look for valves with rate>0 and try them.
    typeset maxScore=0
    typeset c
    for c in ${!map[*]};do
        (( map[$c].rate==0 )) && continue       # skip no valve
        typeset -i dist=${map[$cave].dists[$c]}
        (( dist+1 > timeLeft )) && continue     # skip if out of time
        tryPaths map $c $((timeLeft-dist-1))    # get the score for this path
        (( maxScore=fmax($?,maxScore) ))        # $? has returned score. track maximum
    done
    (( map[$cave].rate=oldRate ))               # restore rate score before returning.
    return $((myScore + maxScore))              # return my score
}

# Read in map of tunnels & rates
# "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE"

typeset -A map
while read cv v ch cf r ct cl ct ct2 ts;do
    typeset r=${r#rate=} r=${r%\;}     # extract rate, remove rate= and ;
    typeset t=( $ts ) t=${t[*]%,}      # make array, clean up ,'s
    map[$v]=(valve=$v rate=$r dists=( ) tunnels=$t )
done < $INPUT

# Calculate all distances for all caves

typeset c
for c in ${!map[*]};do
    shortestDistances map map[$c].dists $c 0
    echo "Cave $c:"
    typeset -p map[$c].dists
done

echo "Trying paths..."

tryPaths map AA 30
typeset score=$?

echo "Answer 1: maxScore $score"
