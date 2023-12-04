#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/1

set -u           # no undeclared vars
typeset -A elf   # key= total + elfnum (elfnum in key to allow dupes), data is unused
typeset -i calories=0

# collect info for each elf, and store in sorted map
while true;do
    read n
    rc=$?  # remember rcode in case EOF

    # if theres data, add to sum and read next
    if [[ -n $n ]]; then
        (( calories+=n ))
        continue
    fi

    # no more data for this elf
    nelf=${#elf[@]}
    key=$(printf "(calories=%010d elfnum=%04d)" calories nelf)
    (( elf[$key]=1 ))
    calories=0
    (( rc )) && break  # break if EOF
done < input.txt

typeset -a elf_sorted=( "${!elf[@]}" )       # copy keys to array sorted by key

# Answer 1

nelf=${#elf[@]}
eval e=${elf_sorted[$((nelf-1))]}            # array entry converts directly to struct
(( calories=10#${e.calories} ))              # make sure ksh decodes leading 0 as base 10
echo "answer 1: top calories are $calories"

# Answer 2

calories=0
# last 3 entries in array are 3 highest calories
for i in {$((nelf-1))..$((nelf-3))};do
    unset e
    eval e=${elf_sorted[i]}
    (( calories+=10#${e.calories} ))
done
echo "answer 2: sum of top 3 is  $calories"
