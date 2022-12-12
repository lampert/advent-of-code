#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/11

set -u -f # no undeclared vars, no file name expansion

# verbose mode
let verbose=0
if [[ $# -gt 0 && $1 = -v ]]; then
    verbose=1
fi

#INPUT=control.txt
INPUT=input.txt

function Error
{
    #emit error message and exit
    echo >&2 "ERROR: $@"
    exit 1
}


function parseMonkeys
{
    nameref monkeys=$1

    typeset -C newMonkey=(inspectionCount=0)   # initialized monkey.
    typeset -C m=newMonkey

    while true;do

        read line
        let rc=$?                 # save for eof loop break
        if [[ -z $line ]]; then   # empty line denotes end of monkey definition
            eval monkeys+=$m      # add last monkey to array, if any data in there

            m=newMonkey           # initialize monkey.

            (( $rc )) && break    # if rcode from read, this means EOF, so break.
            continue
        fi

        set - $line    # split words in to $1,$2,... 
        case $1 in
            Monkey)    # Monkey #

                # verify monkey number matches array.
                (( ${2%:} != ${#monkeys[*]} )) && Error "mismatched monkey num $2 != ${#monkeys[*]}"
                ;;

            Starting)       # Starting items: 1, 2, 3

                [[ $2 != "items:" ]] && Error "parse $line"  # sanity checks
                shift 2
                m.items=( ${*//,/} )   # strip "," out and create array, ie (1 2 3)
                ;;

            Operation:)     # Operation: new = old + 3

                shift
            m.operation="$@"
            ;;

            Test:)          # Test: divisible by 17

                [[ $2 != "divisible" || $3 != "by" ]] && Error "parse $line"  # sanity checks
                m.testDivisibleBy=$4
                ;;

            If)             # If true: throw to monkey 0
                            # If false: throw to monkey 1'

                [[ $3 != throw || $4 != to || $5 != monkey ]] && Error "parse $line"
                if [[ $2 = true: ]]; then
                    m.ifTrueThrowTo=$6
                elif [[ $2 = false: ]]; then
                    m.ifFalseThrowTo=$6
                else
                    Error "parse $line"
                fi
                ;;
        esac
    done < $INPUT

    if ((verbose)); then
        echo "-- Monkey defintions"
        for ((i=0; i<${#monkeys[*]}; i++));do
            print -n "$i "
            typeset -p monkeys[$i]
            echo
        done
        echo "-- end Monkey defintions"
    fi
}


function runSimulation
{
    nameref m=$1
    typeset numRounds=$2
    typeset worryDiv=$3

if ((verbose)); then
    echo "-- simulation Monkey defintions"
    for ((i=0; i<${#m[*]}; i++));do
        print -n "$i "
        typeset -p m[$i]
        echo
    done
    echo "-- end Monkey defintions"
fi

    for round in {1..20}; do

        for ((i=0; i<${#m[*]}; i++));do

            # move items to temp variable
            unset items
            typeset -m items=m[i].items

            (( m[i].inspectionCount += ${#items[*]} ))   # count inspections per monkey

            typeset -f new                     # new set to float because integers overflow
            for old in ${items[*]};do
                (( ${m[i].operation} ))  # execute formula new=old*...
                (( new/=3 ))                   # worry decay
                if (( new%${m[i].testDivisibleBy}==0)); then
                    (( throwTo=${m[i].ifTrueThrowTo} ))
                else
                    (( throwTo=${m[i].ifFalseThrowTo} ))
                fi
                m[$throwTo].items+=($new)  # move item to monkey list
            done

        done
        if ((verbose)); then
            echo "----after round $round"
            for ((i=0; i<${#m[*]}; i++));do
                echo "   monkey $i items ${m[i].items[*]}"
            done
        fi
    done

    if ((verbose));then
        echo "--- counts after all rounds"
        for ((i=0; i<${#m[*]}; i++));do
            echo "   monkey $i counts ${m[i].inspectionCount}"
        done
    fi
}


typeset -a initialState
parseMonkeys initialState



# Answer 1.  find 2 highest counts and multiply.



eval typeset -a run1=$(printf %B initialState)
runSimulation run1 20 3  # numRounds 20, worry divider 3

# index counts
typeset -A indexCounts
for ((i=0; i<${#run1[*]}; i++));do
    (( c=${run1[i].inspectionCount} ))
    key=${ printf "count=%010d,monkey=%03d" $c $i;}
    indexCounts[$key]=$c
done
sortedByIndex=(${!indexCounts[*]})    # export sorted keys to new array
(( mult=${indexCounts[$sortedByIndex[-1]]}*${indexCounts[$sortedByIndex[-2]]} ))  # multiply highest 2

echo "Answer 1 is $mult."

