#!/usr/bin/env ksh
# https://adventofcode.com/2022/day/13

set -u -f # no undeclared vars, no file name expansion

#INPUT=control1.txt
#INPUT=control.txt
INPUT=input.txt

function fixTypeset
{
    # fix up typeset -p quirks
    nameref typ=$1
    typ=${typ//\(/ \( } # (( convert to ( (.  ksh can't parse ((
    typ=${typ//\)/ \) } # convert )) to ) ), to match above
    typ=${typ//;/\(}    # ksh bug? typeset -p shows ;) instead of ()    :(
    typ=${typ//+( )/ }  # fix spaces
    if [[ $typ = typeset* && $typ != *=* ]]; then
        # empty list case - typeset -p leaves out empty ( ). have to add it back
        #     $ typeset -a empty=( )
        #     $ typeset -p empty
        #     typeset -a empty
        typ+="=( )"
    fi
}

function compare
{
    typeset lin="$1"
    typeset rin="$2"

# echo "compare"; echo " l=$lin"; echo " r=$rin"

    eval typeset -a ls="$lin"  # convert from string to data structs
    eval typeset -a rs="$rin"

    ltyp=$(typeset -p ls)      # get type
    fixTypeset ltyp
    rtyp=$(typeset -p rs)
    fixTypeset rtyp

# echo "  type: l=$ltyp"; echo "  type: r=$rtyp"

    # convert both to lists if only one is a list
    if [[ $ltyp = typeset* && $rtyp != typeset* ]]; then
        #echo left is list, right is not. convert right to list
        rs=( $rs )
        rtyp=$(typeset -p rs)
        fixTypeset rtyp
    elif [[ $ltyp != typeset* && $rtyp = typeset* ]]; then
        #echo right is list, left is not. convert left to list
        ls=( $ls )
        ltyp=$(typeset -p ls)
        fixTypeset ltyp
    fi

# echo "  fix : l=$ltyp"; echo "  fix : r=$rtyp"

    # if they are both integers, then compare and return
    if [[ $ltyp != typeset* ]]; then
        #echo "compare integers $ls, $rs"
        if ((ls<rs)); then
            return -1 # left side less
        elif ((ls>rs)); then
            return 1 # right side greater
        else
            return 0 # equal, keep comparing
        fi
    fi

    # list type. compare each element
    typeset i
    typeset rc
# echo "compare lists."
    for (( i=0; i<${#ls[*]}; i++ )); do

#        typeset lev="list. $i of ${#ls[*]},${#rs[*]}"
#        echo "   $lev"

        if (( i>=${#rs[*]} )); then
            #echo out of items to compare on right side, right side greater
            return 1
        fi

        # in some cases, ksh shows empty typeset -p. (ksh bug?) so fix this by putting in expected value.
        typeset descl=$(typeset -p ls[$i])
        fixTypeset descl
        if [[ -z $descl ]]; then
            descl="${ls[$i]}"
        else
            descl=${descl#*=} # get rid of var= prefix
        fi

        typeset descr=$(typeset -p rs[$i])
        fixTypeset descr
        if [[ -z $descr ]]; then
            descr="${rs[$i]}"
        else
            descr=${descr#*=} # get rid of var= prefix
        fi

#        echo "   compare l=$descl"; echo "   compare r=$descr"

        # descend down with each element
        compare "$descl" "$descr"
        rc=$?
#        echo "   $lev result=$rc"
        if ((rc!=0)); then
            return $rc  # found a result
        fi
    done
    if (( i<${#rs[*]} )); then
        #echo theres more on right side, so left side less
        return -1
    fi
    #echo "returning above, this level equal"
    return 0 # more to do.. these were equal
}



# read input file

integer nlines=0
unset lines
typeset -A lines

while true;do
    typeset lin=
    read lin
    (($?)) && break # EOF
    [[ -z $lin ]] && continue

    # convert to ksh format
    typeset l=${lin//\[/\(}    # [ -> (
    l=${l//\]/\)}              # ] -> )
    l=${l//,/ }                # 3,4,5 -> 3 4 5
    fixTypeset l

    lines[$nlines]="$l"
    ((nlines++))
done < $INPUT

# Answer 1

typeset sum i index

sum=0
for (( i=0,index=1; i<nlines; i+=2,index++ )); do

# echo "index $index"
    typeset l="${lines[$i]}"
    typeset r="${lines[$((i+1))]}"
# echo "l=$l"
# echo "r=$r"
    compare "$l" "$r"
    rc=$?
    if ((rc<=0)); then
        # right order
        (( sum+=index ))
    fi
# echo "result $rc sum $sum"
done 

echo "Answer 1 is $sum."


# Answer 2


# add the two special lines for answer 2
lines[$nlines]="( ( 2 ) ) # decoder"
((nlines++))
lines[$nlines]="( ( 6 ) ) # decoder"
((nlines++))

typeset i j rc

echo "answer 2 sorting..."

for (( i=0; i<nlines; ++i )); do
    (( i%10==0 )) && echo " sorting $i of $nlines"
    for (( j=0; j<nlines; ++j )); do
        (( i==j )) && continue
        typeset l="${lines[$i]}"
        typeset r="${lines[$j]}"
        compare "$l" "$r"
        rc=$?
        if (( rc<0 )); then
            typeset tmp="${lines[$i]}"
            lines[$i]="${lines[$j]}"
            lines[$j]="$tmp"
        fi
    done
done

echo "scanning..."

tmp=1
for (( i=0; i<nlines; i++ ));do
    if [[ "${lines[$i]}" = *decoder ]]; then
        (( tmp*=(i+1) ))
        echo " found decoder at index $((i+1)) tmp $tmp"
    fi
done
echo "Answer 2 is $tmp."
