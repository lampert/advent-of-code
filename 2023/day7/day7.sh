#!/usr/bin/env ksh
# https://adventofcode.com/2023/day/7

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
    [1-9]) outValue=$card ;;
        T) outValue=10 ;;
        J) outValue=11 ;;
        Q) outValue=12 ;;
        K) outValue=13 ;;
        A) outValue=14 ;;
    *) echo >&2 "error! unknown card $card"; exit 1;;
    esac
}

function calcHandType
{
    nameref hand=$1
    if (( hand.byCount[5] )); then
        hand.type="7" # five of a kind.
    elif (( hand.byCount[4] )); then
        hand.type="6" # four of a kind.
    elif (( hand.byCount[3] && hand.byCount[2] )); then
        hand.type="5"    # full house
    elif (( hand.byCount[3] )); then
        hand.type="4" # three of a kind
    elif (( hand.byCount[2]==2 )); then
        hand.type="3" # two pair
    elif (( hand.byCount[2]==1 )); then
        hand.type="2" # one pair
    else
        hand.type="1" # high card.
    fi
}

# this converts a card in to a sortable key, with A first, 1 last.
typeset -A cardSortTbl=([A]=n [K]=m [Q]=l [J]=k [T]=j [9]=i [8]=h [7]=g [6]=f [5]=e [4]=d [3]=c [2]=b [1]=a)

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
    typeset -A hand.byCard=( )
    typeset -A hand.byCount=( )
    # index by card
    for ((i=0;i<${#hand.cards};i++));do
        typeset v
        getCardValue ${hand.cards:i:1} v
        ((hand.byCard[$v]++))
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
    #printf "rank %4d hand ${hands[$handNum].cards} bid %3d sort %-10s score %10d\n" $rank ${hands[$handNum].bid} ${hands[$handNum].sortkey} ${score}
    ((++rank))
done
echo "Answer 1: $score"

