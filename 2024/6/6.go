package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
)

type vis_t struct { x,y,d int }  // keep track of visited cells
var visited map[vis_t]bool

var puz [][]rune      // puzzle map
var startx,starty int // starting location in puz

var dir=[4][2]int{ {0,-1}, {1,0}, {0,1}, {-1,0} }  // direction table: dx,dy  N,E,S,W

func walk(count *int, x,y,d int) int {
// walk in direction 'd' counting empty spots and turning or stopping

	if x<0 || y<0 || x>=len(puz[0]) || y>=len(puz) {
		//fmt.Println(x,y,"off the board")
		return -1     //off the board
	}
	if visited[vis_t{x,y,d}] {
		return -3     //looped! already visited
	}
	visited[vis_t{x,y,d}]=true
	if puz[y][x] == '#' || puz[y][x]=='O' {
		//fmt.Println(x,y,"blocked ",string(puz[y][x]))
		return -2     //blocked
	}
	if puz[y][x]=='.' {
		//fmt.Println(x,y,"count ",string(puz[y][x]))
		*count++      //count this one
		puz[y][x]='X' //mark as been here
	}

	for {
		// walk in direction and check
		rc:=walk(count,x+dir[d][0],y+dir[d][1],d)
		switch rc {
		case -3:  //loop, get out
			return -3
		case -2:  //blocked, so turn
			d=(d+1)%4
			//fmt.Println(x,y,"turn right to ",d)
			if puz[y][x]=='^' && d==0 { // at start position pointing north - loop
				fmt.Println(x,y,"loop from turn")
				return -3
			}
		case -1:  //off the edge
			return -1
		}
	}
}

func copypuz(orig [][]rune) [][]rune {
//  make deep copy of puzzle
	cpy:=make([][]rune,0,len(orig))
	for _,row:=range orig {
		cpyr:=make([]rune,len(row))
		copy(cpyr,row)
		cpy=append(cpy,cpyr)
	}
	return cpy
}

func main() {

	startx,starty=-1,-1 // starting location
	lscan := bufio.NewScanner(os.Stdin)
	for lscan.Scan() {
		l:=[]rune(lscan.Text())
		if (startx<0) {
			startx=slices.Index(l,'^') // find starting location, or -1 if not found[]rune
			starty=len(puz)
		}
		puz = append(puz, l)
	}
	savepuz:=copypuz(puz) // save copy of original puzzle
	fmt.Println("start ",startx,starty)
	puz[starty][startx]='.' // initialize first step to empty

	// PART I
//
	var cnt int
//	walk(&cnt, startx,starty,0)
//	fmt.Println("part 1 answer ",cnt)

	// PART II

	countLoops:=0
	for bly:=range len(puz) {
		for blx:=range len(puz[0]) {
			puz=copypuz(savepuz)
			visited=make(map[vis_t]bool)
			if puz[bly][blx] == '.' {
				puz[bly][blx]='O'
				cnt=0
				rc:=walk(&cnt,startx,starty,0)
				if rc==-3 {
					// -3 indicates loop
					fmt.Println(blx,bly,"found a looper")
					countLoops++
				}
			}
		}
	}
	fmt.Println("part 2 answer ",countLoops)
}
