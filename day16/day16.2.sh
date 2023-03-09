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
typeset globalStart=$SECONDS globalNext=$((globalStart+1.0))

typeset -A globalScoreCache
typeset globalCacheMiss=0 globalCacheHit=0

function tryMultiPaths
{
    nameref map=$1
    nameref caves=$2
    nameref timesLeft=$3
    typeset depth=${4:-0}

    (( ++globalIterations ))
    if (( SECONDS > globalNext )); then
        echo "Iterations: $globalIterations time: $((int(SECONDS-globalStart))) per sec: $(( int(globalIterations/(SECONDS-globalStart)))) Hits $globalCacheHit Miss $globalCacheMiss"
        (( globalNext+=1.0 ))
    fi

typeset myIt=$globalIterations

    typeset c
    typeset candidates=(${ for c in ${!map[*]};do ((map[$c].rate>0)) && echo $c; done;})
#echo "depth $depth its $myIt  ENTER caves ${caves[*]} nCaves ${#caves[*]} timesLeft ${timesLeft[*]} candidates ${candidates[*]}"
    typeset cacheKey="${caves[*]},${timesLeft[*]},${candidates[*]}"
    typeset maxScore=${globalScoreCache[$cacheKey]:--1}    # lookup in cache
    if ((maxScore>=0)); then
#echo "cache:  $maxScore '$cacheKey' (hit)"
        ((globalCacheHit++))
    else
        ((globalCacheMiss++))
        typeset -a maxScores
        typeset i
        for i in ${!caves[*]};do
            typeset timeLeft=$((timesLeft[$i]))
            typeset cave=${caves[$i]}
#echo "depth $depth its $myIt cnum $i  ?timeLeft $timeLeft thisCave $cave TimeLeft ${timesLeft[$i]}"
            maxScores[$i]=0
            typeset newCaves=(${caves[*]})
            typeset newTimesLeft=(${timesLeft[*]})
            for c in ${candidates[*]};do
                typeset dist=${map[$cave].dists[$c]}
                (( dist+1>=timeLeft )) && continue       # skip if out of time
#echo "depth $depth its $myIt cnum $i caves ${caves[*]} timesLeft ${timesLeft[*]} try $c from ${candidates[*]}"
                newCaves[$i]=$c
                newTimesLeft[$i]=$((timeLeft-dist-1))
                typeset score=$((map[$c].rate*newTimesLeft[$i]))
                typeset oldRate=${map[$c].rate}
                map[$c].rate=0
                tryMultiPaths map newCaves newTimesLeft $((depth+1))
                (( score+=$? ))                          # $? has returned score. track maximum
                if (( score>maxScores[$i] ));then
                    (( maxScores[$i]=score ))
                fi
                map[$c].rate=$oldRate                    # restore rate score 
#echo "depth $depth its $myIt cnum $i caves ${caves[*]} timesLeft ${timesLeft[*]} tried $c, score $score, maxScore $maxScore"
            done
        done
        typeset maxScore=0
        for i in ${maxScores[*]};do
            ((i>maxScore)) && ((maxScore=i))
        done
#echo "cache:  $maxScore '$cacheKey' (miss)"
        globalScoreCache[$cacheKey]=$maxScore
    fi
#echo "depth $depth its $myIt RETURN caves ${caves[*]} timesLeft ${timesLeft[*]} maxScore $maxScore"
    return $((maxScore))              # return my score
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

# trim map to only start and valves
for c in ${!map[*]};do
    [[ $c = AA ]] && continue
    ((map[$c].rate==0)) && unset map[$c]
done

echo "Trying paths..."

#typeset caves=(AA) timesLeft=(30)
typeset caves=(AA AA) timesLeft=(26 26)
tryMultiPaths map caves timesLeft
typeset score=$?

echo "Answer 2: maxScore $score iterations $globalIterations cacheHits $globalCacheHit misses $globalCacheMiss"
