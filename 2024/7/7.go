package main

import (
	"bufio"
	. "fmt"
	. "math"
	"os"
	"strings"
)

// tries all combinations of +/* and returns true any match target
func tryall(target int, nums []int) (bool, bool) {
	var a string
	var found1, found2 bool
	permutations := Pow(3, float64(len(nums)-1)) // n^3 -> # of permutations of + and * and || given # of terms
	// walk through all possible permutations of operations for this target.
	// operation "2" (which is combine ||) does not apply to part1
	for ops := range int(permutations) {
		check := nums[0]
		a = Sprintf("%v", check)
		o := ops
		appliesToPart1 := true
		for j := 1; j < len(nums); j++ {
			switch o % 3 { // operation
			case 0: // multiply
				check = check * nums[j]
				a += Sprintf("*%v", nums[j])
			case 1: // add
				check = check + nums[j]
				a += Sprintf("+%v", nums[j])
			case 2: // combine
				mult := Pow10(int(Log10(float64(nums[j])) + 1.0)) // how much to move over left digits
				check = check*int(mult) + nums[j]
				a += Sprintf("||%v", nums[j])
				appliesToPart1 = false // don't count this for part 1 answer
			}
			o /= 3
		}
		if check == target {
			if appliesToPart1 {
				found1 = true
			}
			found2 = true
			if found1 && found2 {
				break // no need to continue, since both are found
			}
		}
	}
	return found1, found2
}

func main() {

	// 190: 10 19
	// 3267: 81 40 27
	// ...
	var totalpart1, totalpart2 int
	lscan := bufio.NewScanner(os.Stdin)
	for lscan.Scan() {
		snums := strings.Fields(lscan.Text())
		inums := make([]int, len(snums))
		for i, snum := range snums {
			Sscanf(snum, "%d", &inums[i])
		}
		// inums is integer slice
		target := inums[0]
		matchpart1, matchpart2 := tryall(target, inums[1:])
		if matchpart1 || matchpart2 {
			Println("match ", matchpart1, matchpart2, " target", target, " check ", inums)
			if matchpart1 {
				totalpart1 += target
			}
			if matchpart2 {
				totalpart2 += target
			}
		}
	}
	Println("part 1 answer ", totalpart1)
	Println("part 2 answer ", totalpart2)

}
