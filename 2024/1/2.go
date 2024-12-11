package main

import (
	"fmt"
	"io"
	"log"
)

func main() {
	var la []int
	var mb = make(map[int]int)
	for {
		var a, b int
		_, err := fmt.Scanf("%d %d", &a, &b)
		if err == io.EOF {
			break
		} else if err != nil {
			log.Fatal(err)
		}
		//fmt.Println("Read ", a, " and ", b)
		la = append(la, a)
		mb[b]++
	}
	sim := 0
	for _, v := range la {
		sim += (v * mb[v])
	}
	fmt.Println("answer ", sim)
}
