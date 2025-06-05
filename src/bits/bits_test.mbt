///|
test "omg" {
  let x = [1, 2, 3]
  let y = fn(x : Array[Int]) {
    x.push(4)
    x[2] = 5
  }
  y(x)
  println(x)
}
