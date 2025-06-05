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

///|
pub fn cnt(x : UInt64) -> UInt64 {
  let mut x = x
  x = x - ((x >> 1) & 0x5555_5555_5555_5555UL)
  x = (x & 0x3333_3333_3333_3333UL) + ((x >> 2) & 0x3333_3333_3333_3333UL)
  x = (x + (x >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  (x * 0x0101_0101_0101_0101UL) >> 56
}

///|
pub fn cnt32(x : UInt64) -> UInt {
  let mut x = x
  x = x - ((x >> 1) & 0x5555_5555UL)
  x = (x & 0x3333_3333UL) + ((x >> 2) & 0x3333_3333UL)
  x = ((0x1010_1010UL * x) >> 28) + ((0x0101_0101UL * x) >> 28)
  x.to_uint()
}

// pub fn sel(x: UInt64, i: Int) -> UInt16 {
//   let mut sum = x;
//   sum = sum - ((sum >> 1) & 0x5555_5555_5555_5555UL);
//   sum = (sum & 0x3333_3333_3333_3333UL) + ((sum >> 2) & 0x3333_3333_3333_3333UL);
//   sum = (sum + (sum >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL;
//   sum = (sum * 0x0101_0101_0101_0101UL)
//   let b = sum + @constants.ps_overflow[i]
//   let idx = (i.to_uint64() - 1) << 8
//   if (b &0x0000_0000_8000_0000UL) != 0 {
//     if (b&0x0000_0000_0000_8000UL) != 0 {
//       if (b&0x0000_0000_0000_0080UL) != 0 {
//         return @constants.lt_sel[(x & 0xFFUL + idx).to_int()]
//       } else {
//         return 8 + @constants.lt_sel[((((x>>8)&0xFFUL)  + idx - ((sum&0xFFUL)<<8))&0x7FFUL).to_int()]
//       }
//     } else {
//       if (b&0x0000_0000_0080_0000UL) != 0 {
//         return 16 + @constants.lt_sel[
//           ((((x>>16)&0xFFUL) + idx - (sum&0xFF00UL))&0x7FFUL).to_int()
//         ]
//       } else {
//         return 24 + @constants.lt_sel[
//           ((((x>>24)&0xFFUL) + idx - ((sum>>8)&0xFF00UL))&0x7FFUL).to_int()
//         ]
//       }
//     }
//   } else {
//     if (b&0x0000_8000_0000_0000UL) != 0 {
//       if (b&0x0000_0080_0000_0000UL) != 0 {
//         return 32 + @constants.lt_sel[
//           ((((x>>32)&0xFFUL) + idx - ((sum>>16)&0xFF00UL))&0x7FFUL).to_int()
//         ]
//       } else {
//         return 40 + @constants.lt_sel[
//           ((((x>>40)&0xFFUL) + idx - ((sum>>24)&0xFF00UL))&0x7FFUL).to_int()
//         ]
//       }
//     } else {
//       if (b&0x0080_0000_0000_0000UL) != 0 {
//         return 48 + @constants.lt_sel[
//           ((((x>>48)&0xFFUL) + idx - ((sum>>32)&0xFF00UL))&0x7FFUL).to_int()
//         ]
//       } else {
//         return 56 + @constants.lt_sel[
//           ((((x>>56)&0xFFUL) + idx - ((sum>>40)&0xFF00UL))&0x7FFUL).to_int()
//         ]
//       }
//     }
//   }
//   0
// }

///|
pub fn sel(x : UInt64, i : Int) -> Int {
  let mut sum = x
  sum = sum - ((sum >> 1) & 0x5555_5555_5555_5555UL)
  sum = (sum & 0x3333_3333_3333_3333UL) + ((sum >> 2) & 0x3333_3333_3333_3333UL)
  sum = (sum + (sum >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  sum = sum * 0x0101_0101_0101_0101UL
  let b = sum + @constants.ps_overflow[i]
  let idx = (i.to_uint64() - 1) << 8
  if (b & 0x0000_0000_8000_0000UL) != 0 {
    if (b & 0x0000_0000_0000_8000UL) != 0 {
      if (b & 0x0000_0000_0000_0080UL) != 0 {
        return @constants.lt_sel[(x & (0xFFUL + idx)).to_int()].to_int()
      } else {
        return 8 +
          @constants.lt_sel[((((x >> 8) & 0xFFUL) + idx - ((sum & 0xFFUL) << 8)) &
          0x7FFUL).to_int()].to_int()
      }
    } else if (b & 0x0000_0000_0080_0000UL) != 0 {
      return 16 +
        @constants.lt_sel[((((x >> 16) & 0xFFUL) + idx - (sum & 0xFF00UL)) &
        0x7FFUL).to_int()].to_int()
    } else {
      return 24 +
        @constants.lt_sel[((
          ((x >> 24) & 0xFFUL) + idx - ((sum >> 8) & 0xFF00UL)
        ) &
        0x7FFUL).to_int()].to_int()
    }
  } else if (b & 0x0000_8000_0000_0000UL) != 0 {
    if (b & 0x0000_0080_0000_0000UL) != 0 {
      return 32 +
        @constants.lt_sel[((
          ((x >> 32) & 0xFFUL) + idx - ((sum >> 16) & 0xFF00UL)
        ) &
        0x7FFUL).to_int()].to_int()
    } else {
      return 40 +
        @constants.lt_sel[((
          ((x >> 40) & 0xFFUL) + idx - ((sum >> 24) & 0xFF00UL)
        ) &
        0x7FFUL).to_int()].to_int()
    }
  } else if (b & 0x0080_0000_0000_0000UL) != 0 {
    return 48 +
      @constants.lt_sel[((((x >> 48) & 0xFFUL) + idx - ((sum >> 32) & 0xFF00UL)) &
      0x7FFUL).to_int()].to_int()
  } else {
    return 56 +
      @constants.lt_sel[((((x >> 56) & 0xFFUL) + idx - ((sum >> 40) & 0xFF00UL)) &
      0x7FFUL).to_int()].to_int()
  }
  0
}

// ///|
// pub fn hi(x : UInt64) -> Int {
//   let mut tt = x >> 32
//   let mut t: UInt64 = 0UL
//   if tt != 0 {
//     t = tt >> 16
//     if t != 0 {
//       tt = t >> 8
//       if tt != 0 {
//         return 56 + @constants.lt_hi[tt.to_int()].to_int()
//       } else {
//         return 48 + @constants.lt_hi[t.to_int()].to_int()
//       }
//     } else {
//       t = tt >> 8
//       if t != 0 {
//         return 40 + @constants.lt_hi[t.to_int()].to_int()
//       } else {
//         return 32 + @constants.lt_hi[tt.to_int()].to_int()
//       }
//     }
//   } else {
//     t = x >> 16
//     if t != 0 {
//       tt = t >> 8
//       if tt != 0 {
//         return 24 + @constants.lt_hi[tt.to_int()].to_int()
//       } else {
//         return 16
//       }
//     } else {
//       tt = x >> 8
//       if tt != 0 {
//         return 8 + @constants.lt_hi[tt.to_int()].to_int()
//       } else {
//         return @constants.lt_hi[x.to_int()].to_int()
//       }
//     }
//   }
// }

///|
pub fn hi(x : UInt64) -> UInt {
  let mut tt = x >> 32
  let mut t : UInt64 = 0UL
  if tt != 0 {
    t = tt >> 16
    if t != 0 {
      tt = t >> 8
      if tt != 0 {
        return 56 + @constants.lt_hi[tt.to_int()]
      } else {
        return 48 + @constants.lt_hi[t.to_int()]
      }
    } else {
      t = tt >> 8
      if t != 0 {
        return 40 + @constants.lt_hi[t.to_int()]
      } else {
        return 32 + @constants.lt_hi[tt.to_int()]
      }
    }
  } else {
    t = x >> 16
    if t != 0 {
      tt = t >> 8
      if tt != 0 {
        return 24 + @constants.lt_hi[tt.to_int()]
      } else {
        return 16
      }
    } else {
      tt = x >> 8
      if tt != 0 {
        return 8 + @constants.lt_hi[tt.to_int()]
      } else {
        return @constants.lt_hi[x.to_int()]
      }
    }
  }
}

///|
pub fn lo(x : UInt64) -> UInt {
  if (x & 1) == 1 {
    return 0
  }
  if (x & 3) == 1 {
    return 1
  }
  if (x & 7) == 1 {
    return 2
  }
  if (x & 0x7FF) == 1 {
    return @constants.lt_lo[((x & 0x7FF) >> 3).to_int()]
      .to_int()
      .reinterpret_as_uint() +
      3
  }
  return @constants.lt_deBruijn_to_idx[((
      (x & (x.lnot() + 1)) * @constants.deBruijn64
    ) >>
    58).to_int()]
}

///|
pub fn rev(x : UInt64) -> UInt64 {
  let mut x = x
  x = ((x & 0x5555555555555555UL) << 1) | ((x & 0xAAAAAAAAAAAAAAAAUL) >> 1)
  x = ((x & 0x3333333333333333UL) << 2) | ((x & 0xCCCCCCCCCCCCCCCCUL) >> 2)
  x = ((x & 0x0F0F0F0F0F0F0F0FUL) << 4) | ((x & 0xF0F0F0F0F0F0F0F0UL) >> 4)
  x = ((x & 0x00FF00FF00FF00FFUL) << 8) | ((x & 0xFF00FF00FF00FF00UL) >> 8)
  x = ((x & 0x0000FFFF0000FFFFUL) << 16) | ((x & 0xFFFF0000FFFF0000UL) >> 16)
  x = ((x & 0x00000000FFFFFFFFUL) << 32) | ((x & 0xFFFFFFFF00000000UL) >> 32)
  x
}
