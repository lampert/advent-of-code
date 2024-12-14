package main

import ( "fmt"; "regexp"; "bufio"; "os"; "strconv" )

func main() {
	re := regexp.MustCompile(`mul\(([0-9]+),([0-9]+)\)`)

	lscan := bufio.NewScanner(os.Stdin)
    mul:=0
	for lscan.Scan() {
		line := lscan.Text()
        matches := re.FindAllStringSubmatch(line, -1)
        for _,m:=range matches {
            a,_:=strconv.Atoi(m[1])
            b,_:=strconv.Atoi(m[2])
            mul+=(a*b)
            fmt.Println(m," -> ",a," * ",b," = ",a*b,"  tot ",mul)
        }
	}
	fmt.Println("answer ", mul)
}
