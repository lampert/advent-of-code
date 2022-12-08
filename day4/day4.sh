#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/4

fullyEncap=0
overlap=0

while IFS=" -," read a1 a2 b1 b2   # extract ranges a1-a2,b1-b2
do

    # collect fully encapsulated ranges
    if (( (a1<=b1 && a2>=b2) || (b1<=a1 && b2>=a2) )); then
        let fullyEncap++
    fi

    # collect overlapping ranges
    if (( (a1<=b1 && a2>=b1) || (a1<=b2 && a2>=b2) 
    ||    (b1<=a1 && b2>=a1) || (b1<=a2 && b2>=a2) )); then
        let overlap++
    fi

done < input.txt

echo "number of fully encapsulated $fullyEncap"
echo "number of overlaps           $overlap"
