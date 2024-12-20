package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
)

var puz [][]rune
var dir=[4][2]int{ {0,-1}, {1,0}, {0,1}, {-1,0} }  // dx,dy  N,E,S,W

func walk(count *int, x,y,d int) int {
// walk in direction 'd' counting empty spots and turning or stopping

	if x<0 || y<0 || x>=len(puz[0]) || y>=len(puz) {
		return -1     //off the board
	}
	if puz[y][x] == '#' {
		return -2     //blocked
	}
	if puz[y][x]=='.' {
		*count++      //count this one
		puz[y][x]='X' //mark as been here
	}

	for {
		// walk in direction and check
		rc:=walk(count,x+dir[d][0],y+dir[d][1],d)
		switch rc {
		case -2:  //blocked, so turn
			d=(d+1)%4
		case -1:  //off the edge
			return -1
		}
	}
}

func main() {

	x,y:=-1,-1 // starting location
	lscan := bufio.NewScanner(os.Stdin)
	for lscan.Scan() {
		l:=[]rune(lscan.Text())
		if (x<0) {
			x=slices.Index(l,'^') // find starting location, or -1 if not found[]rune
			y=len(puz)
		}
		puz = append(puz, l)
	}
	fmt.Println("start ",x,y)
	puz[y][x]='.' // initialize first step to empty

	var cnt int
	walk(&cnt, x,y,0)
	fmt.Println("answer ",cnt)
}
