#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/12

set -u -f # no undeclared vars, no file name expansion

#INPUT=control.txt
INPUT=input.txt

# convert a->z  to integers
typeset -A cToH
typeset -i i=0
for c in {a..z};do
    (( cToH[$c]=++i ))   # map [a-z]->1-26
done

# read map and convert to array of heights
typeset -a map
typeset -g -i xSize ySize=0
typeset -g -i startX=-1 startY=-1 endX=-1 endY=-1
while read line;do
    if [[ $line = *S* ]]; then
        l2=${line%S*}
        (( startX=${#l2} ))
        (( startY=ySize ))
        line=${line/S/a}
    fi
    if [[ $line = *E* ]]; then
        l2=${line%E*}
        (( endX=${#l2} ))
        (( endY=ySize ))
        line=${line/E/z}
    fi
    for ((x=0; x<${#line}; ++x));do
        c=${line:x:1}
        (( height=cToH[$c] ))
        (( map[$ySize][$x]=height ))  # convert to height integers
    done
    (( ySize++ ))
done < $INPUT

xSize=${#map[0][*]}
printf "xSize  %4d  ySize  %4d\n" $xSize $ySize
printf "startX %4d  startY %4d\n" $startX $startY
printf "endX   %4d  endY   %4d\n" $endX $endY

directions=( (dx=0 dy=1) (dx=1 dy=0) (dx=-1 dy=0) (dx=0 dy=-1) )

# queue implementation
typeset -T queueT=(
    typeset lo=0
    typeset hi=0
    typeset -A data=()

    function push
    # arg 1 is data to push on queue
    {
        typeset in=$1
        _.data[${_.hi}]="$in"
        ((_.hi++))
    }

    function pop
    # arg 1 is variable name to accept data from queue
    #  $? = 0 for success
    {
        nameref out=$1
        if ((_.lo==_.hi));then
            out=
            return 1
        fi
        eval out=${_.data[${_.lo}]}
        unset _.data[${_.lo}]
        ((_.lo++))
        return 0
    }
)

typeset -g iters=0

# breadth first search
function findWay
{
    nameref map=$1
    nameref bestNSteps=$2
    typeset startX=$3 startY=$4

    # initialize with starting location in queue.
    queueT q
    q.push "(x=$startX y=$startY depth=0)"
    typeset -A lookedat=([$startX,$startY]=1)

    typeset s # hold current step

    # drain queue.
    while true;do

        ((++iters))
        q.pop s
        (($?)) && break # break if rcode !=0

        if ((s.depth>=bestNSteps)); then
            # already past best, so don't bother looking
            continue
        fi

        if ((s.x==endX && s.y==endY)); then
            echo "FOUND END nSteps ${s.depth} nq ${#q[*]} ${s.x},${s.y} best $bestNSteps iters $iters"
            if (( s.depth<bestNSteps )); then
                echo "New best: ${s.depth}"
                (( bestNSteps = s.depth ))
                continue
            fi
        fi

        for dir in {0..3};do
            let newx=s.x+directions[dir].dx newy=s.y+directions[dir].dy
            if (( newx<0 || newx>=xSize || newy<0 || newy>=ySize )); then
                continue # don't go out of bounds
            fi
            if (( map[newy][newx]-map[s.y][s.x]>1 ));then
                continue # too big a height difference
            fi
            if (( lookedat[$newx,$newy]==1 ));then
                continue # looked at already
            fi
            (( lookedat[$newx,$newy]=1 )) # mark as looked at

            q.push "(x=$newx y=$newy depth=$((s.depth+1)))"
        done
    done
}

#Answer 1. Start at S, find shortest path to E.

(( bestNSteps=xSize*ySize))
findWay map bestNSteps $startX $startY
echo "Answer 1 is $bestNSteps."

#Answer 2. Start at all a's
# don't reset bestNSteps - work was already done
for ((y=0;y<ySize;y++));do
    echo "scanning row $y of $ySize...current best $bestNSteps"
    for ((x=0;x<xSize;x++));do
        if ((map[y][x]==1));then
            findWay map bestNSteps $x $y
        fi
    done
done
echo "Answer 2 is $bestNSteps."
