package main

import ( "fmt"; "regexp"; "bufio"; "os"; "strconv" )

func main() {
	re := regexp.MustCompile(`mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)`)

	lscan := bufio.NewScanner(os.Stdin)
    mul_enabled:=true
    mul:=0
	for lscan.Scan() {
		line := lscan.Text()
        //fmt.Printf("%q\n",line)
        matches := re.FindAllStringSubmatch(line, -1)
        for _,m:=range matches {
            //fmt.Printf("%q\n",m)
            if (m[0]=="do()") {
                fmt.Printf("%q\n",m)
                mul_enabled=true
            } else if (m[0]=="don't()") {
                fmt.Printf("%q\n",m)
                mul_enabled=false
            } else {  // mul statement
                if (mul_enabled) {
                    a,_:=strconv.Atoi(m[1])
                    b,_:=strconv.Atoi(m[2])
                    mul+=(a*b)
                    fmt.Println(m," -> ",a," * ",b," = ",a*b,"  tot ",mul)
                }
            }
        }
	}
	fmt.Println("answer ", mul)
}
