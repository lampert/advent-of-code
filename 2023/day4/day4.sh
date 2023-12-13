# https://adventofcode.com/2023/day/4

set -u -f # no undeclared vars, no file name expansion

INPUT=input.txt     # problem data
#INPUT=control.txt   # test data

#Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
#Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
#Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
#Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
#Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
#Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

typeset points=0
typeset -a matches=( )
typeset i j

cat $INPUT |
while read ccard card line;do
    card=${card%:}
    # convert to array assignment  my=( 1 2 3 4) win=( 5 6 7 8 9 ... )
    cmd="typeset -a my=( ${line%% \|*} ) win=( ${line##*\| } )"
    eval $cmd
    # terrible algo
    typeset m=0
    for i in ${my[*]};do
        for j in ${win[*]};do
            if (( i == j )); then
                ((m++))
                break
            fi
        done
    done
    ((matches[card-1]=m))       # remember the match score

    if ((m));then
        (( points+=2**(m-1) ))  # tally points
    fi
done
echo "Answer 1: $points"



typeset -a sub=( )  # counts including copies
for ((i=0;i<${#matches[*]};i++));do
    ((sub[i]=-1))
done

function countsub
{
    typeset n=$1         # card number
    nameref out=$2       # return score
    if ((sub[n]==-1)); then
        # not cached yet, so need to count
        typeset i s cnt=0
        for ((i=0; i<matches[n]; i++));do
            countsub $((n+1+i)) s
            ((cnt+=s))
        done
        ((sub[n]=cnt+matches[n]))
    fi
    ((out=sub[n])) # count current, plus subset
    return
}

# calculate all sub-counts
for ((i=${#matches[*]}-1; i>=0; i--));do
    countsub $i sub[i]
done

# now walk each original card and total up
typeset tot=0 s
for ((i=0;i<${#matches[*]};i++));do
    countsub $((i)) s
    ((tot+=1+s))   # count this card plus total of subcounts
done

echo "Answer 2: $tot"
