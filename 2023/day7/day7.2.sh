#!/usr/bin/env ksh
# https://adventofcode.com/2023/day/7
# part 2

set -u -f # no undeclared vars, no file name expansion

INPUT=input.txt     # problem data
#INPUT=control.txt   # test data

# 32T3K 765
# T55J5 684
# KK677 28
# KTJJT 220
# QQQJA 483

function getCardValue
{
    typeset card=$1
    nameref outValue=$2
    case $card in
        J) outValue=1 ;;
    [2-9]) outValue=$card ;;
        T) outValue=10 ;;
        Q) outValue=12 ;;
        K) outValue=13 ;;
        A) outValue=14 ;;
    *) echo >&2 "error! unknown card $card"; exit 1;;
    esac
}

#rank  257 hand 3J8A6 jokers 1 bid 958 sort 3,daing    score   16400237


function calcHandType
{
    nameref hand=$1
    if (( hand.byCount[5]
    || (hand.byCount[4] && hand.jokers==1)
    || (hand.byCount[3] && hand.jokers==2)
    || (hand.byCount[2] && hand.jokers==3)
    || (hand.byCount[1] && hand.jokers==4)
    || (hand.jokers==5)
    )); then
        hand.type="7" # five of a kind.

    elif (( hand.byCount[4] 
    || (hand.byCount[3] && hand.jokers==1)
    || (hand.byCount[2] && hand.jokers==2)
    || (hand.byCount[1] && hand.jokers==3)
    )); then
        hand.type="6" # four of a kind.

    elif (( hand.byCount[3] && hand.byCount[2]
    || (hand.byCount[3] && hand.byCount[1] && hand.jokers==1)
    || (hand.byCount[2]==2 && hand.jokers==1)
    || (hand.byCount[1] && hand.byCount[2] && hand.jokers==2)
    )); then
        hand.type="5"    # full house

    elif (( hand.byCount[3] 
    || (hand.byCount[2] && hand.jokers==1)
    || (hand.byCount[1] && hand.jokers==2)
    )); then
        hand.type="4" # three of a kind

    elif (( hand.byCount[2]==2 )); then
        hand.type="3" # two pair.  no need to test jokers.  will always be a better hand above

    elif (( hand.byCount[2]==1 
    || (hand.byCount[1]>=1 && hand.jokers==1)
    )); then
        hand.type="2" # one pair

    else
        hand.type="1" # high card.
    fi
}

# this converts a card in to a sortable key, with A first, 1 last.
typeset -A cardSortTbl=([A]=n [K]=m [Q]=l [T]=k [9]=j [8]=i [7]=h [6]=g [5]=f [4]=e [3]=d [2]=c [1]=b [J]=a)

function makeSortKey
{
    # converts hand in to a sort key by hand strength.
    nameref hand=$1
    typeset hand.sortkey="${hand.type},"
    for ((i=0;i<${#hand.cards};i++));do
        typeset c=${hand.cards:i:1}
        hand.sortkey+=${cardSortTbl[$c]}
    done
}


typeset -a hands=( )
typeset -A sortedHands=( )

cat $INPUT | 
while read cards bid;do
    # count like cards
    typeset -C hand=( )
    hand.cards=$cards
    hand.bid=$bid
    hand.jokers=0
    typeset -A hand.byCard=( )
    typeset -A hand.byCount=( )
    # index by card
    for ((i=0;i<${#hand.cards};i++));do
        typeset v
        getCardValue ${hand.cards:i:1} v
        if (( v==1 )); then
            ((hand.jokers++))    # count jokers separately
        else
            ((hand.byCard[$v]++))
        fi
    done
    # index by counts also
    for i in ${!hand.byCard[*]};do
        ((hand.byCount[${hand.byCard[$i]}]++))
    done
    calcHandType hand
    makeSortKey hand
    sortedHands+=([${hand.sortkey}]=${#hands[*]})
    eval hands+="$hand"
done

# now, calculate result:  in sorted hand strength, sum of rank * bid for each
typeset score=0 rank=1 i
for i in ${!sortedHands[*]};do
    typeset handNum=${sortedHands[$i]}
    ((score+=rank*hands[$handNum].bid))
    #printf "rank %4d hand ${hands[$handNum].cards} jokers ${hands[$handNum].jokers} bid %3d sort %-10s score %10d\n" $rank ${hands[$handNum].bid} ${hands[$handNum].sortkey} ${score}
    ((++rank))
done
echo "Answer 2: $score"

