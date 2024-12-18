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
		numarr := make([]int, 0, 100)
		line := lscan.Text()
        for _,numstr := range strings.Fields(line) {
			num, _:=strconv.Atoi(numstr)
			numarr = append(numarr, num)
        }
		// process line
		if !callback(callbackarg, numarr) {
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

func main() {
	nsafe := 0
	b := foreachline(&nsafe, func(nsafep *int, nums []int) bool {
		safe := checkSafe(nums)
		fmt.Println(safe, " ", nums)
		if safe {
			*nsafep++
		}
		return true
	})
	if !b {
		fmt.Println("callback terminated")
		os.Exit(1)
	}
	fmt.Println("answer ", nsafe)
}
