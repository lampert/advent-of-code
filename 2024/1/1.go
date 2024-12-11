package main

import ( "fmt"; "log"; "io"; "slices" )

func main() {
    var la,lb []int
	for {
        var a,b int
		_,err:=fmt.Scanf("%d %d", &a, &b)
        if (err==io.EOF) {
            break
        } else if err!=nil {
            log.Fatal(err)
        } 
		//fmt.Println("Read ", a, " and ", b)
        la=append(la,a)
        lb=append(lb,b)
	}
    slices.Sort(la)
    slices.Sort(lb)
    //fmt.Println("la ",la)
    //fmt.Println("lb ",lb)
    tot:=0
    for i:=0; i<len(la); i++ {
        dis:=la[i] - lb[i]
        if (dis<0) { dis=-dis }
        tot+=dis
    }
    fmt.Println("answer ",tot)
}
