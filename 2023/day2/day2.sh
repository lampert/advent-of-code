#!/usr/bin/env ksh
# https://adventofcode.com/2023/day/2

set -u -f # no undeclared vars, no file name expansion

INPUT=input.txt
#INPUT=control.txt

# Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
# Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
# Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
# Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
# Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green


typeset tot1=0 tot2=0
cat $INPUT | while read game id line;do
    id=${id%:}
    set - $line
    typeset maxr=0 maxg=0 maxb=0
    typeset nr=0 ng=0 nb=0 
#   echo "id $id: $line"
    
#   track max of each color from all groups
    while [[ -n ${1:-} ]]; do
        case $2 in
        red*)   ((nr=$1)) ;;
        green*) ((ng=$1)) ;;
        blue*)  ((nb=$1)) ;;
        esac
        if [[ $2 = *";" || -z ${3:-} ]]; then
            # reached end of set
            (( maxr=fmax(nr,maxr) ))
            (( maxg=fmax(ng,maxg) ))
            (( maxb=fmax(nb,maxb) ))
            nr=0 ng=0 nb=0
        fi
        shift 2
    done
    if (( maxr<=12 && maxg<=13 && maxb<=14 )); then
        # all colors within limits, so add it
        ((tot1+=id))
    fi
    ((tot2+=(maxr*maxg*maxb))) # different formula for answer 2
done
echo "Answer 1: $tot1"
echo "Answer 2: $tot2"



