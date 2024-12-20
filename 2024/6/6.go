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
		return -1     //off the board
	}
	if puz[y][x] == '#' || puz[y][x]=='O' {
		return -2     //blocked
	}
	if puz[y][x]=='.' && !visited[vis_t{x,y,-1}] {
		*count++                      //count this one
		visited[vis_t{x,y,-1}]=true   //mark as counted, with d==-1
	}

	for {
		// walk in direction and check
		if visited[vis_t{x,y,d}] {
			return -3              //looped! already visited and went this direction
		}
		visited[vis_t{x,y,d}]=true // mark this coord and direction
		rc:=walk(count,x+dir[d][0],y+dir[d][1],d)
		switch rc {
		case -3:  //loop detected, return
			return -3
		case -2:  //blocked, so turn directions
			d=(d+1)%4
		case -1:  //off the edge
			return -1
		}
	}
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
	fmt.Println("start ",startx,starty)
	puz[starty][startx]='.' // initialize first step to empty

	// PART I

	var cnt int
	visited=make(map[vis_t]bool)
	walk(&cnt, startx,starty,0)
	fmt.Println("part 1 answer ",cnt)

	// PART II

	countLoops:=0
	for bly:=range len(puz) {
		for blx:=range len(puz[0]) {
			visited=make(map[vis_t]bool)
			if puz[bly][blx] == '.' {
				puz[bly][blx]='O'
				cnt=0
				rc:=walk(&cnt,startx,starty,0)
				if rc==-3 {       // -3 indicates loop
					countLoops++
				}
				puz[bly][blx]='.' // restore puzzle
			}
		}
	}
	fmt.Println("part 2 answer ",countLoops)
}
