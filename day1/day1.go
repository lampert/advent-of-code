package main
 
import (

    "fmt"
)
 
func main() {

  // the message we try here would be:
  // Faraz owns 500 acres of land
  // or something follwoing the same format

  var name string
  var unit string
  var amount int
  var temp string

  // taking input and storing in variable using the buffer string
  fmt.Scanf("%s %s %d %s", &name, &temp, &amount, &unit)
 
  // print out new string using the extracted values 
  fmt.Printf ("%d %s of land is owned by %s\n",amount, unit, name);



 
}
