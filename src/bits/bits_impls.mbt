///|
pub fn cnt(x : UInt64) -> UInt64 {
  let mut x = x
  x = x - ((x >> 1) & 0x5555_5555_5555_5555UL)
  x = (x & 0x3333_3333_3333_3333UL) + ((x >> 2) & 0x3333_3333_3333_3333UL)
  x = (x + (x >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  (x * 0x0101_0101_0101_0101UL) >> 56
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
pub fn select1(x : UInt64, i : Int) -> Int {
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

///|
pub fn leading_one(x : UInt64) -> UInt {
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
pub fn trailing_zeros(x : UInt64) -> UInt {
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
    return 3 +
      @constants.lt_lo[((x & 0x7FF) >> 3).to_int()]
      .to_int()
      .reinterpret_as_uint()
  }
  return @constants.lt_deBruijn_to_idx[((
      (x & (x.lnot() + 1)) * @constants.deBruijn64
    ) >>
    58).to_int()]
}

///|
pub fn bit(x : UInt64, i : Int) -> Bool {
  (x & (1UL << i)) != 0
}

///|
pub fn reverse(x : UInt64) -> UInt64 {
  let mut x = x
  x = ((x & 0x5555555555555555UL) << 1) | ((x & 0xAAAAAAAAAAAAAAAAUL) >> 1)
  x = ((x & 0x3333333333333333UL) << 2) | ((x & 0xCCCCCCCCCCCCCCCCUL) >> 2)
  x = ((x & 0x0F0F0F0F0F0F0F0FUL) << 4) | ((x & 0xF0F0F0F0F0F0F0F0UL) >> 4)
  x = ((x & 0x00FF00FF00FF00FFUL) << 8) | ((x & 0xFF00FF00FF00FF00UL) >> 8)
  x = ((x & 0x0000FFFF0000FFFFUL) << 16) | ((x & 0xFFFF0000FFFF0000UL) >> 16)
  x = ((x & 0x00000000FFFFFFFFUL) << 32) | ((x & 0xFFFFFFFF00000000UL) >> 32)
  x
}

///| implementation with carry
pub fn cnt11_carry(x : UInt64, carry : UInt64) -> (Int, UInt64) {
  let mut x = x
  let ex11 = x & (x >> 1) & 0x5555_5555_5555_5555UL
  let ex10or01 = (ex11 | (ex11 << 1)) ^ x
  let t = (ex11 | (ex11 << 1)) +
    (((ex10or01 << 1) & 0x5555555555555555UL) | carry)
  let new_carry = (ex10or01 >> 63) | (t < (ex11 | (ex11 << 1))).to_uint64()
  x = ex11 | (t & (ex10or01 & 0x5555_5555_5555_5555UL))
  x = (x + (x >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  (((0x0101_0101_0101_0101UL * x) >> 56).to_int(), new_carry)
}

///|
pub fn cnt10_carry(x : UInt64, carry : UInt64) -> (UInt, UInt64) {
  let res = cnt(x ^ (((x << 1) | carry) & x.lnot()))
  (res.to_uint(), x >> 63)
}

///|
pub fn map10(x : UInt64, carry : UInt64) -> UInt64 {
  (x ^ ((x << 1) | carry)) & x.lnot()
}

///|
pub fn cnt01(x : UInt64, carry : UInt64) -> (UInt, UInt64) {
  let res = cnt((x ^ ((x << 1) | carry)) & x)
  (res.to_uint(), x >> 63)
}

///|
pub fn map01(x : UInt64, carry : UInt64) -> UInt64 {
  (x ^ ((x << 1) | carry)) & x
}

// implementation with array

///|
pub fn write_int(
  word : Array[UInt64],
  idx : Int,
  x : UInt64,
  offset : Int,
  len : Int
) -> Unit {
  let x = x & @constants.lo_set[len]
  if offset + len < 64 {
    word[idx] = word[idx] &
      (
        (@constants.max_uint64_value << (offset + len)) |
        @constants.lo_set[offset]
      )
    word[idx] = word[idx] | (x << offset)
  } else {
    word[idx] = word[idx] & @constants.lo_set[offset]
    word[idx] = word[idx] | (x << offset)
    let offset = (offset + len) & 63
    if offset != 0 {
      word[idx + 1] = word[idx + 1] & @constants.lo_set[offset].lnot()
      word[idx + 1] = word[idx + 1] | (x >> (len - offset))
    }
  }
}

///|
pub fn read_int(
  word : Array[UInt64],
  idx : Int,
  offset : Int,
  len : Int
) -> UInt64 {
  let w = word[idx] >> offset
  if offset + len > 64 {
    return w |
      (
        (word[idx + 1] & @constants.lo_set[(offset + len) & 63]) <<
        (64 - offset)
      )
  } else {
    return w & @constants.lo_set[len]
  }
}

///|
pub fn read_unary(word : Array[UInt64], idx : Int, offset : Int) -> UInt64 {
  let w = word[idx] >> offset
  if w != 0 {
    return trailing_zeros(w).to_uint64()
  } else {
    let w = word[idx + 1]
    if w != 0 {
      return trailing_zeros(w).to_uint64() + 64 - offset.to_uint64()
    }
    for cnt in (idx + 2)..<word.length() {
      if word[cnt] != 0 {
        return trailing_zeros(word[idx]).to_uint64() +
          (idx << 6).to_uint64() -
          offset.to_uint64()
      }
    }
  }
  0
}
