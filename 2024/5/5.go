package main

import (
	"bufio"
	"fmt"
	"os"
    "strconv"
    "strings"
    "slices"
)

var rules [2]int
var pages [][]int

func main() {

	// read in rules
    // 22|33
    // ...
    //
    // 1,2,3,4,5
    // ...
    var rules [][2]int
	lscan := bufio.NewScanner(os.Stdin)
	for lscan.Scan() {
        l:=lscan.Text()
        var r [2]int
        n,_:=fmt.Sscanf(l, "%d|%d",&r[0],&r[1])
        if n==0 {
            break // empty line means next section
        }
		rules = append(rules, r)
	}
	fmt.Println("rules",rules)

    // and page numbers
    for lscan.Scan() {
        var p []int
        // convert csv to slice of ints
        for _,v:=range strings.Split(lscan.Text(), ",") {
            n,_:=strconv.Atoi(v)
            p=append(p,n)
        }
        pages = append(pages, p)
    }
    fmt.Println("pages",pages)

    // process each page for PART 1
    score:=0
    for _,p:=range pages {
        // check rules
        good:=true
        for _,r:=range rules {
            i1:=slices.Index(p, r[0])
            i2:=slices.Index(p, r[1])
            if i1!=-1 && i2!=-1 && i1>i2 { // no good
                //fmt.Println(p," rule ",r)
                good=false
                break
            }
        }
        if good {
            middle:=p[(len(p)-1)/2]
            score+=middle
        }
    }
    fmt.Println("answer part 1",score)

    // process each page for PART 2
    score=0
    for _,p:=range pages {
        // check rules
        good:=true
        for i:=0; i<len(rules); i++ {
			r:=rules[i]
            i1:=slices.Index(p, r[0])
            i2:=slices.Index(p, r[1])
            if i1!=-1 && i2!=-1 && i1>i2 { // no good
                good=false
				// swap elements and rerun rules
				p[i1],p[i2]=p[i2],p[i1]
				i=-1 // reset rules index
            }
        }
        if !good { // only count adjusted ones
            middle:=p[(len(p)-1)/2]
            score+=middle
        }
    }
    fmt.Println("answer part 2",score)

}
