#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/3

function findcommon3
{
    typeset r1="{1}([$1])"          # pattern to look for common
    typeset r2="{1}([$2])"          # matches exactly 1 char from string
    typeset r3=$3
    typeset c
    let top=${#r3}-1                # len of string - 1
    for i in {0..$top};do
        c=${r3:i:1}                 # extract next character in string
        if [[ $c = $r1 && $c = $r2 ]]; then     # check for pattern match of other strings
            echo $c
            return
        fi
    done
}

function findcommon2
{
    findcommon3 $r1 $r1 $r2    # wrapper for 2 string common
}

# priority table..  key is letter, data is prio
typeset -A prio
i=1
for p in {a..z} {A..Z};do
    let prio[$p]=i
    let ++i
done

# process each input for answer 1
sum=0
while read sack
do
    len=${#sack}
    r1=${sack:0:len/2}
    r2=${sack:len/2}                            # split in half to 2 sacks

    common=$(findcommon2 $r1 $r2)               # get common item in sack
    let p=${prio[$common]}                      # convert to priority score
    let sum+=p                                  # sum up all scores
done < input.txt

# Answer 1
echo "Answer 1 is $sum"


# process each input for answer 2
sum=0
while true
do
    # read in groups of 3
    read r1
    if (( $? )); then
        break # eof
    fi
    read r2
    read r3

    common=$(findcommon3 $r1 $r2 $r3)           # get common item in sack
    let p=${prio[$common]}                      # convert to priority score
    let sum+=p                                  # sum up all scores
    #echo "$sack com $common prio $p sum $sum"
done < input.txt

echo "Answer 2 is $sum"
