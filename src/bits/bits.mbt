///|
pub type Bit UInt64

///|
pub fn Bit::from(v : UInt64) -> Bit {
  Bit(v)
}

///|
pub fn Bit::toUInt64(self : Bit) -> UInt64 {
  self._
}

///|
pub fn Bit::popcnt(self : Bit) -> Int {
  self._.popcnt()
}

///|
pub fn Bit::cnt11(self : Bit) -> Int {
  cnt11(self._)
}

pub fn Bit::count11_carry(self : Bit, c : Bit) -> Int {
  count11_carry(self._, c._)
}


///|
pub fn count11_carry(x : UInt64, c : UInt64) -> Int {
  let mut x = x
  let ex11 = x & (x >> 1) & 0x5555_5555_5555_5555UL
  let ex10or01 = (ex11 | (ex11 << 1)) ^ x
  let t = (ex11 | (ex11 << 1)) +
    (((ex10or01 << 1) & 0x5555_5555_5555_5555UL) | c)
  x = ex11 | (t & (ex10or01 & 0x5555_5555_5555_5555UL))
  x = (x + (x >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  return ((0x0101_0101_0101_0101UL * x) >> 56).to_int()
}

///|
pub fn cnt11(x : UInt64) -> Int {
  let mut x = x
  let ex11 = x & (x >> 1) & 0x5555_5555_5555_5555UL
  let ex10or01 = (ex11 | (ex11 << 1)) ^ x
  x = ex11 |
    (
      ((ex11 | (ex11 << 1)) + ((ex10or01 << 1) & 0x5555_5555_5555_5555UL)) &
      (ex10or01 & 0x5555_5555_5555_5555UL)
    )
  x = (x & 0x3333_3333_3333_3333UL) + ((x >> 2) & 0x3333_3333_3333_3333UL)
  ((0x0101_0101_0101_0101UL * x) >> 56).to_int()
}
