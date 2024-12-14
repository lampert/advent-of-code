package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

// read each line from a file, parse in to slice of ints, then callback to process
func foreachline[A any](callbackarg A, callback func(A, []int) bool) bool {

	// Line scanner...
	lscan := bufio.NewScanner(os.Stdin)
	for n := 0; lscan.Scan(); n++ {
		w := make([]int, 0, 100)
		line := lscan.Text()

		// Word scanner, collect all ints
		wscan := bufio.NewScanner(strings.NewReader(line))
		wscan.Split(bufio.ScanWords)
		for wscan.Scan() {
			val, _ := strconv.Atoi(wscan.Text())
			w = append(w, val)
		}

		// process line
		if !callback(callbackarg, w) {
			return false
		}
	}
	if err := lscan.Err(); err != nil {
		log.Fatal(err)
		return false
	}
	return true
}

func abs(value int) int {
	if value < 0 {
		return -value
	}
	return value
}

func checkSafe(nums []int) bool {
    // apply rules: all moving in same direction, movement limited from 1-3
    // returns: true if pass
	safe := true
	dir := 0
	last := nums[0]
	for _, n := range nums[1:] {
		if n > last {
			if dir < 0 {
				safe = false
				break
			}
			dir = 1
		} else if n < last {
			if dir > 0 {
				safe = false
				break
			}
			dir = -1
		}
		dif := abs(last - n)
		if dif < 1 || dif > 3 {
			safe = false
			break
		}
		last = n
	}
	return safe
}

func checkSafeOneRemoved(nums []int) bool {
    // try checksafe by removing entries upon failure
    if (checkSafe(nums)) {
        return true
    }
    for i:=0; i<len(nums); i++ {
        newnums := append([]int{}, nums[0:i]...)
        newnums = append(newnums, nums[i+1:]...)
        if (checkSafe(newnums)) {
            return true
        }
    }
    return false;
}

func main() {
	nsafe := 0
	b := foreachline(&nsafe, func(nsafep *int, nums []int) bool {
		safe := checkSafeOneRemoved(nums)
		fmt.Println(safe, " ", nums)
        if (safe) { *nsafep++ }
		return true
	})
	if !b {
		fmt.Println("callback terminated")
		os.Exit(1)
	}
	fmt.Println("answer ", nsafe)
}
