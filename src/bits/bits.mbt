///|
/// Counts the number of set bits (1s) in a 64-bit unsigned integer using Brian
/// Kernighan's population count algorithm.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to count set bits in.
///
/// Returns the number of set bits as a `UInt64`.
///
/// Example:
///
/// ```moonbit
/// test "popcnt" {
///   inspect(popcnt(0b1101UL), content="3")
///   inspect(popcnt(0UL), content="0")
///   inspect(popcnt(0xFFFFFFFFFFFFFFFFUL), content="64")
/// }
/// ```
///
pub fn popcnt(x : UInt64) -> UInt64 {
  let mut x = x
  x = x - ((x >> 1) & 0x5555_5555_5555_5555UL)
  x = (x & 0x3333_3333_3333_3333UL) + ((x >> 2) & 0x3333_3333_3333_3333UL)
  x = (x + (x >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  (x * 0x0101_0101_0101_0101UL) >> 56
}

///|
/// Counts the number of consecutive "11" bit pairs in a 64-bit unsigned integer.
///
/// This function analyzes the binary representation of the input value and
/// counts how many times two consecutive 1 bits appear. For example, in the
/// binary number `1011`, there is one "11" pair at positions 0-1.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to analyze for consecutive 1-bit pairs.
///
/// Returns the count of "11" bit pairs as an `Int`.
///
/// Example:
///
/// ```moonbit
/// test "count_11_pairs" {
///   inspect(count_11_pairs(0b1101UL), content="1")  // One "11" pair
///   inspect(count_11_pairs(0b1111UL), content="2")  // Three "11" pairs
///   inspect(count_11_pairs(0b1010UL), content="0")  // No "11" pairs
/// }
/// ```
///
pub fn count_11_pairs(x : UInt64) -> Int {
  let mut x = x
  let ex11 = x & (x >> 1) & 0x5555_5555_5555_5555UL
  let ex10or01 = (ex11 | (ex11 << 1)) ^ x
  x = ex11 |
    (
      ((ex11 | (ex11 << 1)) + ((ex10or01 << 1) & 0x5555555555555555UL)) &
      (ex10or01 & 0x5555555555555555UL)
    )
  x = (x & 0x3333_3333_3333_3333UL) + ((x >> 2) & 0x3333_3333_3333_3333UL)
  x = (x + (x >> 4)) & 0x0F0F0F0F0F0F0F0FUL
  ((0x0101_0101_0101_0101UL * x) >> 56).to_int()
}

///|
/// Finds the bit position of the nth set bit (1) in a 64-bit unsigned integer.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to search within.
/// * `n` : The index of the set bit to find (1-based).
///
/// Returns the bit position (0-63) of the nth set bit as an `Int`.
///
/// Example:
///
/// ```moonbit
/// test "select_nth_one" {
///   inspect(select_nth_one(0b1101UL, 1), content="0")  // First set bit at position 0
///   inspect(select_nth_one(0b1101UL, 2), content="2")  // Second set bit at position 2
///   inspect(select_nth_one(0b1001UL, 2), content="3")  // Third set bit at position 3
/// }
/// ```
///
pub fn select_nth_one(x : UInt64, idx : Int) -> Int {
  let mut sum = x
  sum = sum - ((sum >> 1) & 0x5555_5555_5555_5555UL)
  sum = (sum & 0x3333_3333_3333_3333UL) + ((sum >> 2) & 0x3333_3333_3333_3333UL)
  sum = (sum + (sum >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  sum = sum * 0x0101_0101_0101_0101UL
  let b = sum + @constants.ps_overflow[idx]
  let idx = (idx.to_uint64() - 1) << 8
  if (b & 0x0000_0000_8000_0000UL) != 0 {
    if (b & 0x0000_0000_0000_8000UL) != 0 {
      if (b & 0x0000_0000_0000_0080UL) != 0 {
        return @constants.lt_sel[((x & 0xFFUL) + idx).to_int()].to_int()
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
/// Finds the bit position of the most significant (leftmost) set bit in a 64-bit
/// unsigned integer.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to find the leading one bit in.
///
/// Returns the bit position (0-63) of the most significant set bit as a `UInt`.
/// If the input is 0, the behavior is undefined.
///
/// Example:
///
/// ```moonbit
/// test "leading_one" {
///  inspect(leading_one(1UL), content="0")
///  inspect(leading_one(2UL), content="1")
///  inspect(leading_one(4UL), content="2")
///  inspect(leading_one(8UL), content="3")
///  inspect(leading_one(0x80000000UL), content="31")
///  inspect(leading_one(0x100000000UL), content="32")
///  inspect(leading_one(0x8000000000000000UL), content="63")
/// }
/// ```
///
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
        return 16 + @constants.lt_hi[t.to_int()]
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
/// Counts the number of trailing zero bits in a 64-bit unsigned integer.
///
/// This function efficiently determines how many consecutive zero bits appear at
/// the least significant (rightmost) end of the binary representation. Uses a
/// combination of bit manipulation techniques and lookup tables for optimal
/// performance.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to count trailing zeros in.
///
/// Returns the number of trailing zero bits as a `UInt`. If the input is 0,
/// returns 64.
///
/// Example:
///
/// ```moonbit
/// test "trailing_zeros" {
///  inspect(trailing_zeros(1UL), content="0") 
///  inspect(trailing_zeros(2UL), content="1") 
///  inspect(trailing_zeros(4UL), content="2") 
///  inspect(trailing_zeros(8UL), content="3") 
///  inspect(trailing_zeros(16UL), content="4") 
/// }
/// ```
///
pub fn trailing_zeros(x : UInt64) -> UInt {
  if x == 0 {
    return 64
  }
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
/// Checks whether a specific bit is set (equals 1) in a 64-bit unsigned integer.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to examine.
/// * `idx` : The bit position to check (0-63, where 0 is the least significant
/// bit).
///
/// Returns `true` if the bit at the specified position is set (1), `false`
/// otherwise.
///
/// Example:
///
/// ```moonbit
/// test "bit" {
///   inspect!(bit(0b1101UL, 0), content="true")   // LSB is set
///   inspect!(bit(0b1101UL, 1), content="false")  // Second bit is not set
///   inspect!(bit(0b1101UL, 2), content="true")   // Third bit is set
///   inspect!(bit(0b1101UL, 3), content="true")   // Fourth bit is set
/// }
/// ```
///
pub fn bit(x : UInt64, idx : Int) -> Bool {
  guard idx >= 0 && idx < 64 else { abort("Index out of bounds") }
  (x & (1UL << idx)) != 0
}

///|
/// Reverses the bit order of a 64-bit unsigned integer, swapping the most
/// significant bit with the least significant bit, and so on.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer whose bits are to be reversed.
///
/// Returns the 64-bit unsigned integer with all bits in reversed order.
///
/// Example:
///
/// ```moonbit
/// test "reverse" {
///  inspect(reverse(0UL), content="0")
///  inspect(reverse(1UL), content="9223372036854775808")
///  inspect(reverse(0x8000000000000000UL), content="1")
///  inspect(reverse(0xFFFFFFFFFFFFFFFFUL), content="18446744073709551615")
/// }
/// ```
///
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

// implementation with carry

///|
/// Counts the number of consecutive "11" bit pairs in a 64-bit unsigned integer
/// with carry propagation from previous operations.
///
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to analyze for consecutive 1-bit pairs.
/// * `carry` : The carry value from previous operations, used to handle bit
/// pairs that span across word boundaries.
///
/// Returns a tuple containing:
///
/// * The count of "11" bit pairs as an `Int`
/// * The new carry value as a `UInt64` for use in subsequent operations
///
/// Example:
///
/// ```moonbit
/// test "count_11_pairs_with_carry" {
///  inspect(count_11_pairs_with_carry(0b1100UL, 0UL), content="(1, 0)")
///  inspect(count_11_pairs_with_carry(0b1111UL, 0UL), content="(2, 0)")
///  inspect(count_11_pairs_with_carry(0b0000UL, 0UL), content="(0, 0)")
/// }
/// ```
///
pub fn count_11_pairs_with_carry(x : UInt64, carry : UInt64) -> (Int, UInt64) {
  let mut x = x
  let ex11 = x & (x >> 1) & 0x5555_5555_5555_5555UL
  let ex10or01 = (ex11 | (ex11 << 1)) ^ x
  let t = (ex11 | (ex11 << 1)) +
    (((ex10or01 << 1) & 0x5555555555555555UL) | carry)
  let new_carry = (ex10or01 >> 63) | (t < (ex11 | (ex11 << 1))).to_uint64()
  x = ex11 | (t & (ex10or01 & 0x5555_5555_5555_5555UL))
  x = (x & 0x3333333333333333UL) + ((x >> 2) & 0x3333333333333333UL)
  x = (x + (x >> 4)) & 0x0F0F_0F0F_0F0F_0F0FUL
  (((0x0101_0101_0101_0101UL * x) >> 56).to_int(), new_carry)
}

///|
/// Counts the number of consecutive "10" bit pairs in a 64-bit unsigned integer
/// with carry propagation from previous operations.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to analyze for consecutive "10" bit
/// pairs.
/// * `carry` : The carry value from previous operations, used to handle bit
/// pairs that span across word boundaries.
///
/// Returns a tuple containing:
///
/// * The count of "10" bit pairs as an `Int`
/// * The new carry value as a `UInt64` for use in subsequent operations
///
/// Example:
///
/// ```moonbit
/// test "count_10_pairs" {
///  inspect(count_10_pairs(0xFFFF_FFFF_FFFF_FFFFUL, 0UL), content="(0, 1)")
///  inspect(count_10_pairs(0xFFFF_FFFF_FFFF_FFFFUL, 1UL), content="(0, 1)")
///
///  inspect(count_10_pairs(0UL, 1UL), content="(1, 0)")
///
///  inspect(count_10_pairs(0x8000_0000_0000_0001UL, 0UL), content="(1, 1)")
/// }
/// ```
///
pub fn count_10_pairs(x : UInt64, carry : UInt64) -> (Int, UInt64) {
  let res = popcnt((x ^ ((x << 1) | carry)) & x.lnot())
  (res.to_int(), x >> 63)
}

///|
/// Extracts positions where "10" bit patterns occur in a 64-bit unsigned
/// integer, considering carry from previous operations.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to analyze for "10" bit patterns.
/// * `carry` : The carry value from previous operations, representing the
/// leftmost bit context for detecting cross-boundary "10" patterns.
///
/// Returns a `UInt64` bitmask where each set bit marks the position of the '0'
/// in a "10" bit pattern.
///
/// Example:
///
/// ```moonbit
/// test "extract_10_pairs" {
///  inspect(extract_10_pairs(0b10UL, 0UL), content="4") 
///  inspect(extract_10_pairs(0b1010UL, 0UL), content="20") 
///  inspect(extract_10_pairs(0b11100UL, 0UL), content="32") 
/// }
/// ```
///
pub fn extract_10_pairs(x : UInt64, carry : UInt64) -> UInt64 {
  (x ^ ((x << 1) | carry)) & x.lnot()
}

///|
/// Counts the number of consecutive "01" bit pairs in a 64-bit unsigned integer
/// with carry propagation from previous operations.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to analyze for consecutive "01" bit
/// pairs.
/// * `carry` : The carry value from previous operations, used to handle bit
/// pairs that span across word boundaries.
///
/// Returns a tuple containing:
///
/// * The count of "01" bit pairs as an `Int`
/// * The new carry value as a `UInt64` for use in subsequent operations
///
/// Example:
///
/// ```moonbit
/// test "count_01_pairs" {
///   inspect(count_01_pairs(0b01UL, 0UL), content="(1, 0)")
///   inspect(count_01_pairs(0b0101UL, 0UL), content="(2, 0)")
///   inspect(count_01_pairs(0b1010UL, 0UL), content="(0, 1)")
/// }
/// ```
///
pub fn count_01_pairs(x : UInt64, carry : UInt64) -> (Int, UInt64) {
  let res = popcnt((x ^ ((x << 1) | carry)) & x)
  (res.to_int(), x >> 63)
}

///|
/// Extracts positions where "01" bit patterns occur in a 64-bit unsigned
/// integer, considering carry from previous operations.
///
/// Parameters:
///
/// * `x` : The 64-bit unsigned integer to analyze for "01" bit patterns.
/// * `carry` : The carry value from previous operations, representing the
/// leftmost bit context for detecting cross-boundary "01" patterns.
///
/// Returns a `UInt64` bitmask where each set bit marks the position of the '1'
/// in an "01" bit pattern.
///
/// Example:
///
/// ```moonbit
/// test "extract_01_pairs" {
///  inspect(extract_01_pairs(0b0101UL, 0UL), content="5") 
///  inspect(extract_01_pairs(0b1010UL, 0UL), content="10") 
///  inspect(extract_01_pairs(0b0011UL, 0UL), content="1") 
///  inspect(extract_01_pairs(0b1100UL, 0UL), content="4") 
/// }
/// ```
///
pub fn extract_01_pairs(x : UInt64, carry : UInt64) -> UInt64 {
  (x ^ ((x << 1) | carry)) & x
}

// implementation with array

///|
/// Writes a specified number of bits from a value into a bit array at a given
/// position.
///
/// This function modifies the bit array in-place by writing `len` bits from the
/// value `x`
///
/// Parameters:
///
/// * `word` : The array of 64-bit unsigned integers to write bits into.
/// * `idx` : The index of the array element where writing begins.
/// * `x` : The source value containing the bits to write.
/// * `offset` : The bit offset within the array element where writing starts
/// (0-63).
/// * `len` : The number of bits to write from the source value.
///
/// Example:
///
/// ```moonbit
/// test "write_bits" {
///  let word = Array::make(2, 0UL)
///  write_bits(word, 0, 0x123UL, 8, 12)
///  inspect!(word[0], content="74496") // 0x123 << 8 = 74496
/// }
/// ```
///
pub fn write_bits(
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
/// Reads a specified number of bits from a bit array starting at a given
/// position and offset.
///
/// Extracts `len` consecutive bits from the bit array, starting from bit
/// position `offset` within the array element at index `idx`. If the requested
/// bits span across multiple array elements, the function automatically handles
/// the cross-boundary reading and combines the bits appropriately.
///
/// Parameters:
///
/// * `word` : The array of 64-bit unsigned integers to read bits from.
/// * `idx` : The index of the array element where reading begins.
/// * `offset` : The bit offset within the array element where reading starts
/// (0-63).
/// * `len` : The number of consecutive bits to read.
///
/// Returns a `UInt64` containing the extracted bits, right-aligned (least
/// significant bits).
///
/// Example:
///
/// ```moonbit
/// test "read_bits" {
///  let word = [0x123456789ABCDEF0UL]
///  inspect(read_bits(word, 0, 0, 8), content="240") 
///  inspect(read_bits(word, 0, 4, 8), content="239") 
///  inspect(read_bits(word, 0, 8, 16), content="48350")
///  inspect(read_bits(word, 0, 0, 64), content="1311768467463790320")
/// }
/// ```
///
pub fn read_bits(
  word : Array[UInt64],
  idx : Int,
  offset : Int,
  len : Int
) -> UInt64 {
  let w = word[idx] >> offset
  if offset + len > 64 {
    return w |
      (
        (word[idx + 1] & @constants.lo_set[(offset + len) & 0x3F]) <<
        (64 - offset)
      )
  } else {
    return w & @constants.lo_set[len]
  }
}

///|
/// Reads the length of a unary-encoded value from a bit array starting at a
/// specified position.
///
/// Parameters:
///
/// * `word` : The array of 64-bit unsigned integers containing the bit data to
/// read from.
/// * `idx` : The index of the array element where reading begins.
/// * `offset` : The bit offset within the array element where reading starts
/// (0-63).
///
/// Returns the length of the unary-encoded value as a `UInt`. If no set bit is
/// found in the remaining array, returns 0.
///
/// Example:
///
/// ```moonbit
/// test "read_unary" {
///  let word = [0b1000UL, 0UL, 0UL]
///  inspect(read_unary(word, 0, 0), content="3")
///  inspect(read_unary(word, 0, 2), content="1")
///  assert_true(bit_at(word, 0, 3))
/// }
/// ```
///
pub fn read_unary(word : Array[UInt64], idx : Int, offset : Int) -> UInt {
  let w = word[idx] >> offset
  if w != 0 {
    return trailing_zeros(w)
  } else {
    let w = word[idx + 1]
    if w != 0 {
      return trailing_zeros(w) + 64 - offset.reinterpret_as_uint()
    }
    for cnt in (idx + 2)..<word.length() {
      if word[cnt] != 0 {
        return trailing_zeros(word[cnt]) +
          (cnt << 6).reinterpret_as_uint() -
          offset.reinterpret_as_uint()
      }
    }
  }
  0
}

///|
/// Checks whether a specific bit is set in a bit array at a given position and
/// offset.
///
/// Parameters:
///
/// * `word` : The array of 64-bit unsigned integers representing the bit array
/// to examine.
/// * `idx` : The starting index of the array element to check within.
/// * `offset` : The bit position within the bit array, starting from the element
/// at `idx`. Can be any non-negative integer, and will automatically span across
/// multiple array elements if needed.
///
/// Returns `true` if the bit at the specified position is set (1), `false`
/// otherwise.
///
/// Example:
///
/// ```moonbit
/// test "read_unary" {
///  let word = [0b1000UL, 0UL, 0UL]
///  inspect(read_unary(word, 0, 0), content="3")
///  inspect(read_unary(word, 0, 2), content="1")
///  assert_true(bit_at(word, 0, 3))
/// }
/// ```
///
pub fn bit_at(word : Array[UInt64], idx : Int, offset : Int) -> Bool {
  guard idx >= 0 && idx < word.length() else { abort("Index out of bounds") }
  guard offset >= 0 else { abort("Offset must be non-negative") }
  if offset < 64 {
    return (word[idx] & (1UL << offset)) != 0
  } else {
    let idx_offset = offset / 64
    if idx + idx_offset < word.length() {
      return (word[idx + idx_offset] & (1UL << (offset % 64))) != 0
    }
    abort("Index out of bounds")
  }
}
