package main

import (
	"bufio"
	"fmt"
	"os"
)

var puz [][]rune

func findit(x, y, dx, dy int, s string) int {
	if len(s) == 0 {
		return 1 //found - no more string to search
	}
	if x < 0 || y < 0 || x >= len(puz[0]) || y >= len(puz) {
		return 0 //out of bounds
	}
	if puz[y][x] != rune(s[0]) {
		return 0 //mismatch
	}
	// look in each direction
	if findit(x+dx, y+dy, dx, dy, s[1:]) == 1 {
		return 1
	}
	// not found
	return 0
}

func main() {

	// read in puzzle
	lscan := bufio.NewScanner(os.Stdin)
	for lscan.Scan() {
		puz = append(puz, []rune(lscan.Text()))
	}

	// PART I
	n := 0
	// walk each coordinate
	for y := 0; y < len(puz); y++ {
		for x := 0; x < len(puz[y]); x++ {
			// search each direction
			for _, dir := range [][]int{{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}} {
				n += findit(x, y, dir[0], dir[1], "XMAS")
			}
		}
	}
	fmt.Println("part 1 answer ", n)

	// PART II
	n = 0
	// walk each coordinate
	for y := 0; y < len(puz); y++ {
		for x := 0; x < len(puz[y]); x++ {

			// need 2 diagonals to make an X
			need2 := 0
			for _, dir := range [][]int{{-1, -1}, {-1, 1}, {1, -1}, {1, 1}} {
				// from center, start at each diagonal and search opposite direction
				need2 += findit(x+dir[0], y+dir[1], -dir[0], -dir[1], "MAS")
			}
			if need2 == 2 { // found 2 diagonals
				n++
			}
		}
	}
	fmt.Println("part 2 answer ", n)

}
