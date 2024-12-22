package main

import (
	"bufio"
	"fmt"
	"os"
_	"slices"
    "strings"
)

// tries all combinations of +/* and returns true any match target
func tryall(target int, nums []int) (bool,string) {
    var a string
    permutations:=1<<(len(nums)-1) // # of permutations of + and * given # of terms
    //fmt.Println(target,nums," perm",permutations)
    for ops:=range permutations {
        check:=nums[0]
        a=fmt.Sprintf("%v",check)
        for obit,j:=1,1; j<len(nums); obit,j=obit<<1,j+1 {
            if (ops & obit)==0 {
                // bit set then multiply, else add
                check=check*nums[j]
                a+=fmt.Sprintf("*%v",nums[j])
            } else {
                check=check+nums[j]
                a+=fmt.Sprintf("+%v",nums[j])
            }
        }
        //fmt.Println(target,"==",check,"? ",(target==check),"  ",a)
        if (check==target) {
            return true,a
        }
    }
    return false,"none"
}

func main() {

// 190: 10 19
// 3267: 81 40 27
// ...
    total := 0
	lscan := bufio.NewScanner(os.Stdin)
	for lscan.Scan() {
        snums:=strings.Fields(lscan.Text())
        inums:=make([]int,len(snums))
        for i,snum:=range snums {
            fmt.Sscanf(snum,"%d",&inums[i])
        }
        // inums is integer slice
        match,_:=tryall(inums[0],inums[1:])
        if match {
            //fmt.Println("match ",snums," ops ",sops)
            total+=inums[0]
        }
	}
    fmt.Println("part 1 answer ",total)

}
