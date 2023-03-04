#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/16

set -u -f # no undeclared vars, no file name expansion

#INPUT=control.txt   # test data
INPUT=input.txt    # problem data

function shortestDistances
{
    # Output dists calculated distance to each cave
    nameref map=$1
    nameref dists=$2
    typeset cave=$3
    typeset currentDistance=$4

    typeset oldDist
    oldDist=${dists[$cave]:-inf}    # if unset, then set to infinity
    if (( currentDistance < oldDist )); then
        # this is a shorter path.
        dists[$cave]=$currentDistance
        # now calculate all tunnels from here
        typeset newCave
        for newCave in ${map.caves[$cave].tunnels[*]}; do
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
        echo "Iterations $globalIterations persec $((int(globalIterations/(SECONDS-globalStart))))"
    fi

    nameref caveP=map.caves[$cave]              # pointer to current cave info.

    typeset myScore=$((caveP.rate * timeLeft))  # calculate score for turning on this valve.

    # mark as used (rate=0), but remember so I can restore on return.
    if ((caveP.rate>0)); then
        unset map.valves[$cave]                 # remove from valve list
    fi

    # look for valves with rate>0 and try them.
    typeset c maxScore=0
    for c in ${!map.valves[*]};do
        (( map.caves[$c].rate==0 )) && continue # skip no valve
        typeset -i dist=${caveP.dists[$c]}
        (( dist+1 > timeLeft )) && continue     # skip if out of time
        tryPaths map $c $((timeLeft-dist-1))    # get the score for this path
        (( maxScore=fmax($?,maxScore) ))        # $? has returned score. track maximum
    done

    # restore to valve list
    if ((caveP.rate>0));then
        map.valves[$cave]=1                     # add back to valve list
    fi
    return $((myScore + maxScore))              # return my score
}

# Read in map of tunnels & rates
# "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE"

typeset -C map=(typeset -A caves; typeset -A valves)
while read cv v ch cf r ct cl ct ct2 ts;do
    typeset r=${r#rate=} r=${r%\;}     # extract rate, remove rate= and ;
    typeset t=( $ts ) t=${t[*]%,}      # make array, clean up ,'s
    map.caves[$v]=(rate=$r; typeset -A dists; tunnels=$t )
    (( r>0 )) && map.valves[$v]=1      # cache list of valves
done < $INPUT

# Calculate all distances for all caves

typeset c
for c in ${!map.caves[*]};do
    shortestDistances map map.caves[$c].dists $c 0
    echo "Cave $c:"
    typeset -p map.caves[$c].dists
done

echo "Trying paths..."

tryPaths map AA 30
typeset score=$?

echo "Answer 1: maxScore $score"
