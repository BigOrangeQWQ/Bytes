///|
struct Bit {
  mut value : UInt64
}

///|
pub fn Bit::from(v : UInt64) -> Bit {
  { value: v }
}

///|
pub fn Bit::to_uint64(self : Bit) -> UInt64 {
  self.value
}

///|
pub fn Bit::to_uint(self : Bit) -> UInt {
  self.value.to_uint()
}

///|
pub fn Bit::to_int(self : Bit) -> Int {
  self.value.to_int()
}

///|
pub fn Bit::to_bool(self : Bit) -> Bool {
  self.value != 0
}

///|
pub fn Bit::to_byte(self : Bit) -> Byte {
  self.value.to_byte()
}

///|
pub fn Bit::reinterpret_as_int64(self : Bit) -> Int64 {
  self.value.reinterpret_as_int64()
}

///|
pub fn Bit::reinterpret_as_double(self : Bit) -> Double {
  self.value.reinterpret_as_double()
}

///|
pub fn Bit::popcnt(self : Bit) -> Int {
  self.value.popcnt()
}

///|
pub fn Bit::popcnt11(self : Bit) -> Int {
  cnt11(self.value)
}

///|
pub fn Bit::select1(self : Bit, i : Int) -> Int {
  select1(self.value, i)
}

///|
pub fn Bit::leading_one(self : Bit) -> UInt {
  leading_one(self.value)
}

///|
pub fn Bit::trailing_zeros(self : Bit) -> UInt {
  trailing_zeros(self.value)
}

///|
pub fn Bit::reverse(self : Bit) -> Unit {
  self.value = reverse(self.value)
}

///|
pub fn Bit::bit(self : Bit, idx : Int) -> Bool {
  bit(self.value, idx)
}
