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

	n := 0
    // walk each coordinate
	for y := 0; y < len(puz); y++ {
		for x := 0; x < len(puz[y]); x++ {

            // search each direction
            for _,dir:=range [][]int { {-1,-1},{0,-1},{1,-1}, {-1,0},{1,0}, {-1,1},{0,1},{1,1} } {
                n+=findit(x, y, dir[0], dir[1], "XMAS")
            }
		}
	}
	fmt.Println("answer ", n)
}
