#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/16

set -u -f # no undeclared vars, no file name expansion

#INPUT=control.txt   # test data
INPUT=input.txt    # problem data

function shortestDistances
{
    nameref map=$1 dists=$2
    typeset cave=$3 currentDistance=$4
    typeset oldDist=${dists[$cave]:-inf}    # if unset, then set to infinity
    if (( currentDistance<oldDist )); then
        dists[$cave]=$currentDistance
        typeset newCave
        for newCave in ${map.tunnels[$cave][*]}; do
            shortestDistances map dists $newCave $((currentDistance+1))
        done
    fi
}

function calculateScores
{
    # calculate score to all caves and store maximum for each combination of open valves
    nameref map=$1
    typeset cave=$2 timeLeft=$3 score=${4:-0} openValves=${5:-0}
    ((map.scores[$openValves]=fmax(${map.scores[$openValves]:-0},score))) # max score for this set of open valves
    typeset c
    for c in ${!map.valveBit[*]};do                 # calculate from all tunnels
        typeset bit=${map.valveBit[$c]}             # each valve assigned its own bit
        (( openValves & bit )) && continue          # skip already open valves
        typeset distance=${map.dists[$cave][$c]}
        typeset newTimeLeft=$((timeLeft-distance-1))
        ((newTimeLeft<=0)) && continue              # can't reach in time
        calculateScores map $c $newTimeLeft $((score+(map.rate[$c]*newTimeLeft))) $((openValves|bit))
    done
}

function readMap
{
    nameref map=$1
    # Read in map of tunnels & rates
    # "Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE"
    typeset -C map=(typeset -A rate tunnels dists valveBit maxScore scores)
    while read cv v ch cf r ct cl ct ct2 ts;do
        typeset r=${r#rate=} r=${r%\;}     # extract rate, remove rate= and ;
        typeset t=( $ts ) t=${t[*]%,}      # make array, clean up ,'s
        map.rate[$v]=$r
        map.tunnels[$v]=$t
        typeset -A map.dists[$v]
    done < $INPUT
    typeset c bit=1
    for c in ${!map.rate[*]};do            # get distances for every cave to every other cave
        shortestDistances map map.dists[$c] $c 0
        if ((map.rate[$c]>0));then         # assign a bit to each valve
            map.valveBit[$c]=$bit
            ((bit*=2))
        fi
    done
}

typeset map
readMap map

# find the max score for all combinations of open valves and 30 minutes overall
calculateScores map AA 30
typeset m=0 i
for i in ${map.scores[*]};do
    ((m=fmax(m,i)))
done
echo "Answer 1: maxScore $m"

# find the max score for 2 disjoint open valve sets, with less time overall
typeset -A map.scores=()
calculateScores map AA 26   # recalculate for 26 minutes left.
typeset bmp1 bmp2 m=0
for bmp1 in ${!map.scores[*]};do
    for bmp2 in ${!map.scores[*]};do
        (( bmp1&bmp2 )) && continue # skip overlapping valves
        (( m=fmax(m, ${map.scores[$bmp1]}+${map.scores[$bmp2]}) ))  # get max of separate scores
    done
done
echo "Answer 2: maxScore $m"

