package main

// puzzle: https://adventofcode.com/2024/day/8

import (
	"bufio"
	. "fmt"
	"os"
)

var layout []string

type coord struct{ x, y int }
var m_antenna = map[rune][]coord{}

func generateAntinodes(cs []coord, part2 bool) []coord {
	var m_anti []coord
	// for each pair of coordinates, generate antinodes
	for _, c := range cs {
		for _, d := range cs {
			if c == d {
				continue
			}
			dx, dy := (c.x - d.x), (c.y - d.y)
			var i int
			if !part2 {
				// part2 counts antenna location, so start at 0*dx,dy. 
				// part1 does not, start at 1*dx,dy
				i=1  
			}
			for ;; i++ {
				an := coord{c.x + i*dx, c.y + i*dy}
				if an.x < 0 || an.x >= len(layout[0]) || an.y < 0 || an.y >= len(layout) {
					break // out of bounds
				} 
				m_anti = append(m_anti, an)
				//Println(c, d, "->", an," i,dx,dy ",i,i*dx,i*dy)
				if !part2 {
					// part1 only plots one antinode.
					// part2 repeats until off the board
					break
				}
			}
		}
	}
	return m_anti
}

func main() {
	// ............
	// ........0...
	// ....0.......
	// ......A.....
	// …
	lscan := bufio.NewScanner(os.Stdin)
	y := 0
	for lscan.Scan() {
		l := lscan.Text()
		layout = append(layout, l)
		for x, v := range l {
			if v != '.' {
				c := coord{x, y}
				m_antenna[v] = append(m_antenna[v], c)
			}
		}
		y++
	}

	// generate antinodes for each frequency and store unique coordinate
	// PART I - only do first node
	m_antinodes:=map[coord]bool{}
	for _, cs := range m_antenna {
		for _, a := range generateAntinodes(cs, false) {
			m_antinodes[a] = true
		}
	}
	Println("answer part 1",len(m_antinodes))

	// PART II - all antinodes
	m_antinodes=map[coord]bool{}
	for _, cs := range m_antenna {
		for _, a := range generateAntinodes(cs, true) {
			m_antinodes[a] = true
		}
	}
	Println("answer part 2",len(m_antinodes))
}
