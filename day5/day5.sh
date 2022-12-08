#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/5

INPUT=input.txt

set -u # ksh don't allow unset variables


# sample input:
###### bucket contents:
#     [D]    
# [N] [C]    
# [Z] [M] [P]
###### bucket defintion:
#  1   2   3 
#
###### move directives:
# move 1 from 2 to 1
# move 3 from 1 to 3
# move 2 from 2 to 1
# move 1 from 1 to 2


# first step, determine number of buckets.

nbuckets=0
while read line;do
    if [[ $line = +(*(\s)+(\d))*(\s) ]]; then
        # (look for array of spaces, then digits)
        buckets=($line)         # create array from buckets to count #
        nbuckets=${#buckets[*]}
        break
    fi
done < $INPUT
if (( nbuckets == 0 ));then
    echo >&2 "error: bucket definition not found"
    exit 1
fi


# send step, gather starting state of buckets


# initialize all buckets to empty
for ((i=0;i<nbuckets;i++));do
    buckets[i]=""
done

# read fixed size fields. "IFS=" prevents stripping of spaces (no field splitting)
while IFS= read line;do
    if [[ $line = +(*(\s)+(\d))*(\s) ]]; then
        # reached definition line in input. so stop.
        break
    fi
    # walk each line extracting values for each bucket
    for (( j=0; j<nbuckets; j++ )); do
        c=${line:j*4+1:1} # extract bucket contents for each bucket at this height
        if [[ $c != " " ]]; then
            buckets[$j]=$c${buckets[$j]}      # append to bucket, if not empty
        fi
    done
done < $INPUT

# make a copy of starting state for each answer
eval bucket1=$(printf "%B" buckets)  # this copies an assoc array
eval bucket2=$(printf "%B" buckets)  # %B exports in a format that can be assigned







# final step - process move directives for each answer



function popb
{
    # pop elements off stack
    nameref buckets=$1
    typeset -i bucketnum=$2
    typeset -i npop=$3
    nameref output=$4
    output=${buckets[bucketnum-1]: -npop:npop}           # pull npop chars off end
    buckets[bucketnum-1]=${buckets[bucketnum-1]%$output} # remove from bucket
}

function pushb
{
    # push elements on to stack
    nameref buckets=$1
    typeset -i bucketnum=$2
    typeset c=$3
    buckets[bucketnum-1]=${buckets[bucketnum-1]}$c
}

exec 4<$INPUT     # open input file as fd 4
while read -u 4 line;do
    if [[ -z $line ]]; then
        break # empty line preceeds move directives
    fi
done 

# move 1 from 2 to 1
while read -u 4 move num from a to b
do
#   echo "move $num from $a to $b"

    # Answer1, one at a time
    for i in {1..$num};do
        popb bucket1 $a 1 c
        pushb bucket1 $b $c
    done

    # Answer2, all at once
    popb bucket2 $a $num c
    pushb bucket2 $b $c

done

function emitanswer
{
    nameref buckets=$1
    print -n "$2"
    for ((i=0;i<nbuckets;i++));do
        print -n ${buckets[i]: -1:1}
    done
    print "."
}

emitanswer bucket1 "Answer 1 is "
emitanswer bucket2 "Answer 2 is "
