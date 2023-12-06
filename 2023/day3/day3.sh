#!/usr/bin/env ksh
# https://adventofcode.com/2023/day/3

set -u -f # no undeclared vars, no file name expansion

INPUT=input.txt
#INPUT=control.txt

# 467..114..
# ...*......
# ..35..633.
# ......#...
# 617*......
# .....+.58.
# ..592.....
# ......755.
# ...$.*....
# .664.598..

# read input, pad with . all around the outside
ysize=0
cat $INPUT | while read line;do
    if ((ysize==0));then
        grid[$ysize]=".${line//?/.}."  # tack on empty line above
        ((++ysize))
    fi
    grid[$ysize]=".$line."             # tack empty spaces to left & right
    ((++ysize))
done
grid[$ysize]="${grid[0]}"              # tack on empty line below
((++ysize))
((xsize=${#grid[0]}-1))

# scan for numbers

((tot=0))
for ((y=1; y<ysize; y++));do
    for ((x=1; x<xsize; x++));do
        [[ ${grid[y]:x} != +([0-9])* ]] && continue  # match a number

        num=${.sh.match[1]} # get the matching number from the regex result
        ((nlen=${#num}+2))

        # now check for any symbols in substring above, around, and below
        if [[ ${grid[y-1]:x-1:nlen} != +([0-9.])
        ||    ${grid[y]:x-1:nlen}   != +([0-9.])
        ||    ${grid[y+1]:x-1:nlen} != +([0-9.]) ]]; then
            # found an adjacent symbol
            ((tot+=num))
        fi

        ((x+=${#num}-1))
   done
done
echo "Answer 1: $tot"




# scan for '*', find 2 adjacent numbers

# turn grid in to arrays
for ((y=0;y<ysize;y++));do
    g[y]=( ${grid[y]//?/\0 } )
done

function collectNum
{
    # search for number @ x,y.  returns in out if found
    nameref grid=$1
    typeset x=$2 y=$3
    nameref out=$4
    if [[ ${grid[y][x]} != [0-9] ]]; then
        out=""
        return #not a num
    fi
    
    # find beginning of number
    while [[ ${grid[y][x-1]} == [0-9] ]]; do
        ((--x))
    done
    #echo "beginning of number = $x,$y: ${grid[y][x]}"

    # collect number
    out=""
    while [[ ${grid[y][x]} == [0-9] ]]; do
        out="$out${grid[y][x]}"
        #echo " collect number = $x,$y: ${grid[y][x]} -> $out"
        grid[y][x]='x'
        ((++x))
    done
}


((tot=0))
for ((y=1; y<ysize; y++));do
    for ((x=1; x<xsize; x++));do
        [[ ${g[y][x]} != '*' ]] && continue  # find symbol

        #echo "found a * at $x,$y"

        typeset -a nums=( )

        # collect surrounding numbers
        for ((yy=-1; yy<=1; yy++));do
            for ((xx=-1; xx<=1; xx++)); do
                out=""
                collectNum g $((x+xx)) $((y+yy)) out
                if [[ -n $out ]]; then
                    nums[${#nums[*]}]=$out  # collect adjacent number
                fi
            done
        done

        if ((${#nums[*]} == 2));then
            # only if there are 2, then they count
            (( tot+=(${nums[0]} * ${nums[1]}) ))
        fi

   done
done
echo "Answer 2: $tot"

