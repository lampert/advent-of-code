#!/usr/bin/env ksh
# https://adventofcode.com/2023/day/5

set -u -f # no undeclared vars, no file name expansion

INPUT=input.txt     # problem data
#INPUT=control.txt   # test data

function error
{
    echo >&2 "$@"
    exit 1
}

((ans1=inf))

read cseed line <$INPUT
[[ $cseed != seeds: ]] && error "failed read seeds:"  # sanity check
typeset -a seeds=( $line )

for seed in ${seeds[*]};do

    #echo "process seed $seed"
    ((trx=seed))
    exec 9<$INPUT  # open input on fd 9

    while true;do

        # scan till next transform
        while read -u9 transform cmap;do
            [[ $cmap != map: ]] && continue
            break
        done
        [[ -z $transform ]] && break # out of transforms
        #echo "found transform $transform"

        while true;do
            read -u9 d s t
            [[ -z $d ]] && break
            #printf "%32s  %8d-%8d -> %8d-%8d\n" "$transform" $((s)) $((s+t-1)) $((d)) $((d+t-1))
            ((trx<s || trx>s+t-1)) && continue   # not in range
            ((dif=trx-s))
            #echo "transform $transform from $trx to $((d+dif))"
            ((trx=d+dif))
            break
        done

    done
    #echo "*seed $seed -> location $trx"
    ((ans1=fmin(ans1,trx)))

done

echo "Answer 1: $ans1"







################ Answer 2:


# find all the transform definitions in the input file.
typeset -a transformPositions=( )
exec 9<$INPUT                        # open input on fd 9
while true;do
    9<#"*map:"                       # scan file for next map
    read -u9 transform cmap
    [[ -z $transform ]] && break
    transformPositions+=( $(9<#) )   # store current file position
done


# helper function to add range with optional transformation to array.
function addtx
{ 
    nameref out=$1
    typeset trx=$2 s=$3 e=$4
    out+=( s=$((s+trx));e=$((e+trx)) )
}


((ans2=inf))   # set answer to max value to start.  will scan for minimum 

# now process each seed range.

for ((i=0; i<${#seeds[*]}; i+=2));do

    # Start with seed range from seed list above.
    typeset -a ss=( (s=$((seeds[i]));e=$((seeds[i]+seeds[i+1]-1))) )   # ss.s is start, ss.e is end of range

    # process each transform for this seed.
    for tpos in ${transformPositions[*]};do
        typeset -a newss=()            # collect transformed seed ranges (may be multiple)
        nchanges=-1                    # set up conditions to hit reset case
        exec 9<$INPUT                  # open input file.
        9<#((EOF))                     # position at eof so it reads empty - it'll get empty read and hit my reset case
        while true;do
            read -u9 td ts tsrng       # next transform criteria: destination, source, range
            if [[ -z $td ]];then
                # at end of transform criteria.  but I might need to reset back, if there were changes.
                (( nchanges==0 )) && break # no more work for this transform.

                # since there were changes, we should reset file position to top of transform criteria and run again.
                nchanges=0
                exec 9<$INPUT   # I need to re-open the file or else I get unexpected results from read. I *think* it needs to clear read buffer.
                9<#((tpos))     # position file pointer at $tpos
                continue
            fi
            te=$((ts+tsrng-1))  # end of transform range.  (start is $ts)
            trx=$((td-ts))      # transform to apply if in range.

            # split up all ranges so they are either in or out of a range.
            for j in ${!ss[*]};do  # for each seed range.
                if (( ss[j].e<ts || ss[j].s>te )); then
                    # outside of range, no transform yet
                    #     ts.....te
                    #s..e           s..e
                    continue
                elif (( ss[j].s>=ts && ss[j].e<=te )); then
                    # completely contained in range, transform and add
                    #    ts.......te      (transform range)
                    #      s.....e        (seed range)
                    #      [ttttt]        (splits)
                    addtx newss $trx $((ss[j].s)) $((ss[j].e))
                    unset ss[j]
                    ((nchanges++))
                elif (( ss[j].s<ts && ss[j].e>te )); then
                    # larger than range , split 3 ways
                    #     ts.....te       (transform range)
                    #  s..|.......|..e    (seed range)
                    #  [1][ttttttt][3]    (splits)
                    addtx ss    0     $((ss[j].s)) $((ts-1))
                    addtx newss $trx  $ts $te
                    addtx ss    0     $((te+1)) $((ss[j].e))
                    unset ss[j]
                    ((nchanges++))
                elif (( ss[j].s>=ts && ss[j].s<=te )); then
                    # split 2 ways
                    #     ts.....te       (transform range)
                    #        s....|...e   (seed range)
                    #        [tttt][11]
                    addtx newss $trx  $((ss[j].s)) $((te))
                    addtx ss    0     $((te+1)) $((ss[j].e))
                    unset ss[j]
                    ((nchanges++))
                elif (( ss[j].s<ts && ss[j].e<=te )); then
                    # split 2 ways
                    #     ts.....te       (transform range)
                    # s...|....e          (seed range)
                    # [11][tttt]
                    addtx ss    0     $((ss[j].s)) $((ts-1))
                    addtx newss $trx  $((ts)) $((ss[j].e))
                    unset ss[j]
                    ((nchanges++))
                else
                    error "logic error? ${ss[j]},$td,$ts,$trx"
                    exit 1
                fi
            done #for all seed ranges
        done #while current transform

        # if a seed was not in transform criteria, it progresses unmodified
        for j in ${!ss[*]};do
            addtx newss 0 $((ss[j].s)) $((ss[j].e))
        done

        # copy over transformed set to base set for next transform.
        eval ss=$( printf %B newss ) #(not sure why typeset -m ss=newss doesn't work)
        unset newss

    done #while any transforms left

    # done with all transforms.  now check for minimum.
    for j in ${!ss[*]};do
        ((ans2=fmin(ans2,ss[j].s)))
    done
done

echo "Answer 2: $ans2"
