///|
test "array/mutable" {
  let x = [1, 2, 3]
  let y = fn(x : Array[Int]) {
    x.push(4)
    x[2] = 5
  }
  y(x)
}

///|
test "read_unary/first_word_match" {
  let word = [0b1000UL, 0UL, 0UL]
  inspect(read_unary(word, 0, 0), content="3")
  inspect(read_unary(word, 0, 2), content="1")
  assert_true(bit_at(word, 0, 3))
}

///|
test "read_unary/second_word_match" {
  let word = [0b11UL, 0b1000UL, 0UL]
  inspect(read_unary(word, 0, 2), content="65")
  assert_true(bit_at(word, 0, 67))
}

///|
test "read_unary/later_word_match" {
  let word = [0b1UL, 0UL, 0b1000UL, 0UL]
  inspect(read_unary(word, 0, 1), content="130")
  assert_true(bit_at(word, 0, 131))

  // Let me try a clearer case
  let word2 = [0UL, 0UL, 0b1000UL]
  inspect(read_unary(word2, 0, 0), content="131")
  assert_true(bit_at(word2, 0, 131))
}

///|
test "read_bits" {
  let word = [0x123456789ABCDEF0UL]
  inspect(read_bits(word, 0, 0, 8), content="240") // 0xF0
  inspect(read_bits(word, 0, 4, 8), content="239") // 0xEF
  inspect(read_bits(word, 0, 8, 16), content="48350") // 0xBCDF
  inspect(read_bits(word, 0, 0, 64), content="1311768467463790320") // full word
}

///|
test "read_bits/cross_word_boundary" {
  let word = [0xFFFFFFFFFFFFFFFFUL, 0x123456789ABCDEF0UL]
  inspect(read_bits(word, 0, 60, 8), content="15") // 0x0F [last 4 bits of first word] [4 bits from second word] 
  inspect(read_bits(word, 0, 56, 16), content="61695") // 8 bits from first word + 8 bits from second word 
  inspect(read_bits(word, 0, 32, 40), content="1035087118335") // spans across boundary
}

///|
test "read_bits/edge_cases" {
  let word = [0x123456789ABCDEF0UL, 0xFEDCBA9876543210UL]
  inspect(read_bits(word, 0, 0, 0), content="0")
  inspect(read_bits(word, 0, 63, 1), content="0")
  inspect(read_bits(word, 0, 0, 1), content="0")
  inspect(read_bits(word, 1, 0, 64), content="18364758544493064720")
}

///|
test "write_bits" {
  let word = Array::make(2, 0UL)
  write_bits(word, 0, 0x123UL, 8, 12)
  inspect!(word[0], content="74496") // 0x123 << 8 = 74496
  let word2 = Array::make(2, 0UL)
  write_bits(word2, 0, 0xFFUL, 0, 8)
  inspect!(word2[0], content="255") // 0xFF = 255
  let word3 = Array::make(2, 0UL)
  write_bits(word3, 0, 0x1FFUL, 4, 8) // 0x1FF should be truncated to 0xFF for 8 bits
  inspect!(word3[0], content="4080") // 0xFF << 4 = 4080
}

///|
test "write_bits/cross_word_boundary" {
  // Test writing that spans across two 64-bit words
  let word = Array::make(2, 0UL)
  write_bits(word, 0, 0x123456UL, 56, 16) // 8 bits in first word, 8 bits in second word
  inspect!(word[0] >> 56, content="86") // Lower 8 bits of 0x123456 = 0x56 = 86
  inspect!(word[1] & 0xFFUL, content="52") // Upper 8 bits of 0x123456 = 0x12 = 18, but need to check actual bit layout

  // Test exact boundary case
  let word2 = Array::make(2, 0UL)
  write_bits(word2, 0, 0xFFUL, 60, 8) // 4 bits in first word, 4 bits in second word
  inspect!(word2[0] >> 60, content="15") // Lower 4 bits of 0xFF = 0xF = 15
  inspect!(word2[1] & 0xFUL, content="15") // Upper 4 bits of 0xFF = 0xF = 15
}

///|
test "write_bits/edge_cases" {
  // Test with zero value
  let word = Array::make(2, 0xFFFFFFFFFFFFFFFFUL)
  write_bits(word, 0, 0UL, 10, 8)
  inspect!((word[0] >> 10) & 0xFFUL, content="0")

  // Test with maximum length (64 bits spanning two words)
  let word2 = Array::make(2, 0UL)
  write_bits(word2, 0, 0x123456789ABCDEF0UL, 32, 64)
  inspect!(word2[0] >> 32, content="2596069104") // Lower 32 bits of the value
  inspect!(word2[1] & 0xFFFFFFFFUL, content="305419896") // Upper 32 bits of the value

  // Test writing at the end of a word (offset + len = 64)
  let word3 = Array::make(2, 0UL)
  write_bits(word3, 0, 0xFFUL, 56, 8)
  inspect!(word3[0] >> 56, content="255")
}

///|
test "map01" {
  // Basic cases - testing common bit patterns
  inspect(extract_01_pairs(0b0101UL, 0UL), content="5") // 0b0101 -> should identify 01 patterns
  inspect(extract_01_pairs(0b1010UL, 0UL), content="10") // 0b1010 -> no 01 patterns
  inspect(extract_01_pairs(0b0011UL, 0UL), content="1") // 0b0011 -> one 01 pattern at position 1
  inspect(extract_01_pairs(0b1100UL, 0UL), content="4") // 0b1100 -> no 01 patterns
}

///|
test "map01/boundary" {
  // Edge cases with extreme values
  inspect(extract_01_pairs(0UL, 0UL), content="0") // All zeros
  inspect(extract_01_pairs(@constants.max_uint64_value, 0UL), content="1") // All ones
  inspect(extract_01_pairs(1UL, 0UL), content="1") // Single bit at LSB
  inspect(
    extract_01_pairs(0x8000000000000000UL, 0UL),
    content="9223372036854775808",
  ) // Single bit at MSB
  inspect(extract_01_pairs(0xFFFFFFFFFFFFFFFFUL, 0UL), content="1") // All bits set
}

///|
test "map01/carry" {
  // Testing carry behavior - when carry=1, it affects the leftmost comparison
  inspect(extract_01_pairs(0b1UL, 1UL), content="0") // carry creates 11 pattern
  inspect(extract_01_pairs(0b0UL, 1UL), content="0") // carry creates 10 pattern  
  inspect(extract_01_pairs(0b10UL, 1UL), content="2") // carry + bit pattern creates 01
  inspect(extract_01_pairs(0b101UL, 1UL), content="4") // mixed pattern with carry
}

///|
test "cnt01" {
  // Basic cases with no carry
  inspect(count_01_pairs(0b0101_0101_0101_0101UL, 0UL), content="(8, 0)")
  inspect(count_01_pairs(0b1010_1010_1010_1010UL, 0UL), content="(8, 0)")
  inspect(count_01_pairs(0b0011_0011_0011_0011UL, 0UL), content="(4, 0)")

  // Cases with carry affecting the result
  inspect(count_01_pairs(0b1111_1111_1111_1111UL, 1UL), content="(0, 0)")
  inspect(count_01_pairs(0b0000_0000_0000_0001UL, 1UL), content="(0, 0)")
  inspect(count_01_pairs(0b1000_0000_0000_0000UL, 1UL), content="(1, 0)")
}

///|
test "cnt01/boundary" {
  // Edge cases with all zeros and all ones
  inspect(count_01_pairs(0UL, 0UL), content="(0, 0)")
  inspect(count_01_pairs(0UL, 1UL), content="(0, 0)")
  inspect(count_01_pairs(0xFFFFFFFFFFFFFFFFUL, 0UL), content="(1, 1)")
  inspect(count_01_pairs(0xFFFFFFFFFFFFFFFFUL, 1UL), content="(0, 1)")

  // Maximum value patterns
  inspect(count_01_pairs(0x8000000000000000UL, 0UL), content="(1, 1)")
  inspect(count_01_pairs(0x0000000000000001UL, 0UL), content="(1, 0)")
}

///|
test "cnt01/carry_propagation" {
  // Test cases specifically for carry bit propagation
  inspect(count_01_pairs(0b0101010101010101UL, 1UL), content="(7, 0)")
  inspect(count_01_pairs(0b1010101010101010UL, 1UL), content="(8, 0)")
  inspect(count_01_pairs(0b0000000000000000UL, 1UL), content="(0, 0)")
  inspect(count_01_pairs(0b1111111111111111UL, 0UL), content="(1, 0)")
}

///|
test "map10" {
  // Basic cases - simple 10 patterns
  inspect(extract_10_pairs(0b10UL, 0UL), content="4") // 10 -> should mark position 1
  inspect(extract_10_pairs(0b1010UL, 0UL), content="20") // 1010 -> should mark positions 1 and 3
  inspect(extract_10_pairs(0b11100UL, 0UL), content="32") // 11100 -> only one 1->0 transition at position 2

  // With carry bit
  inspect(extract_10_pairs(0b01UL, 1UL), content="2") // carry=1 makes it effectively 101, so 1->0 at position 1
  inspect(extract_10_pairs(0b0UL, 1UL), content="1") // carry=1 makes it effectively 10, so 1->0 at position 0
}

///|
test "map10/boundary" {
  // All zeros
  inspect(extract_10_pairs(0UL, 0UL), content="0")

  // All ones 
  inspect(extract_10_pairs(@constants.max_uint64_value, 0UL), content="0")

  // Maximum value with carry
  inspect(extract_10_pairs(@constants.max_uint64_value, 1UL), content="0")

  // Single bit patterns
  inspect(extract_10_pairs(1UL, 0UL), content="2") // Just 1, no 1->0 transition
  inspect(extract_10_pairs(2UL, 0UL), content="4") // 10 pattern
}

///|
test "map10/edge_cases" {
  // High bit patterns
  inspect(extract_10_pairs(0x8000000000000000UL, 0UL), content="0") // Single high bit
  inspect(extract_10_pairs(0xC000000000000000UL, 0UL), content="0") // 11 followed by 0s

  // Alternating patterns
  inspect(
    extract_10_pairs(0x5555555555555555UL, 0UL),
    content="12297829382473034410",
  ) // 0101... -> all 1->0 transitions
  inspect(
    extract_10_pairs(0xAAAAAAAAAAAAAAAAUL, 0UL),
    content="6148914691236517204",
  ) // 1010... -> no 1->0 (only 0->1)
}

///|
test "cnt10" {
  // Basic cases: simple 10 patterns
  inspect(count_10_pairs(0b1010_1010UL, 0UL), content="(4, 0)")
  inspect(count_10_pairs(0b1100_1100UL, 0UL), content="(2, 0)")
  inspect(count_10_pairs(0b1000_0000UL, 0UL), content="(1, 0)")

  // No 10 patterns
  inspect(count_10_pairs(0b0000_0000UL, 0UL), content="(0, 0)")
  inspect(count_10_pairs(0b1111_1111UL, 0UL), content="(1, 0)")
  inspect(count_10_pairs(0b0101_0101UL, 0UL), content="(4, 0)")
}

///|
test "cnt10/carry_effects" {
  // Carry bit creates 10 pattern at position 0
  inspect(count_10_pairs(0b0000_0000UL, 1UL), content="(1, 0)")
  inspect(count_10_pairs(0b0000_0001UL, 1UL), content="(1, 0)")

  // Carry bit doesn't create 10 pattern
  inspect(count_10_pairs(0b1000_0000UL, 0UL), content="(1, 0)")
  inspect(count_10_pairs(0b1000_0000UL, 1UL), content="(2, 0)")
}

///|
test "cnt10/boundary_cases" {
  // Maximum value - all 1s, no 10 patterns
  // println(0UL.lnot())
  inspect(count_10_pairs(0xFFFF_FFFF_FFFF_FFFFUL, 0UL), content="(0, 1)")
  inspect(count_10_pairs(0xFFFF_FFFF_FFFF_FFFFUL, 1UL), content="(0, 1)")

  // Minimum value - all 0s
  inspect(count_10_pairs(0UL, 0UL), content="(0, 0)")
  inspect(count_10_pairs(0UL, 1UL), content="(1, 0)")

  // MSB set - check carry output
  inspect(count_10_pairs(0x8000_0000_0000_0000UL, 0UL), content="(0, 1)")
  inspect(count_10_pairs(0x8000_0000_0000_0001UL, 0UL), content="(1, 1)")
}

///|
test "count_11_pairs_carry" {
  // Basic test cases with no carry
  // println(count_11_pairs_carry(0b1100UL, 0UL)) // should return (1, 0)
  inspect(count_11_pairs_with_carry(0b1100UL, 0UL), content="(1, 0)")
  inspect(count_11_pairs_with_carry(0b1111UL, 0UL), content="(2, 0)")
  inspect(count_11_pairs_with_carry(0b0000UL, 0UL), content="(0, 0)")

  // Test cases with carry
  inspect(count_11_pairs_with_carry(0b1010UL, 1UL), content="(0, 0)")
  inspect(count_11_pairs_with_carry(0b0101UL, 1UL), content="(1, 0)")
}

///|
test "count_11_pairs_carry/boundary" {
  // Test with maximum UInt64 value
  inspect(count_11_pairs_with_carry(@uint64.max_value, 0UL), content="(32, 0)")
  inspect(count_11_pairs_with_carry(@uint64.max_value, 1UL), content="(32, 1)")

  // Test with alternating pattern that should generate carry
  inspect(
    count_11_pairs_with_carry(0x5555555555555555UL, 0UL),
    content="(0, 0)",
  )
  inspect(
    count_11_pairs_with_carry(0xAAAAAAAAAAAAAAAAUL, 0UL),
    content="(0, 1)",
  )

  // Test edge case with single bit set at MSB
  inspect(
    count_11_pairs_with_carry(0x8000000000000000UL, 0UL),
    content="(0, 1)",
  )
  inspect(
    count_11_pairs_with_carry(0x8000000000000000UL, 1UL),
    content="(0, 1)",
  )
}

///|
test "count_11_pairs_carry/carry_propagation" {
  // Test cases where carry affects the result
  inspect(count_11_pairs_with_carry(0b1110UL, 0UL), content="(1, 0)")
  inspect(count_11_pairs_with_carry(0b0110UL, 1UL), content="(1, 0)")

  // Test with patterns that should produce different carries
  inspect(
    count_11_pairs_with_carry(0x6666666666666666UL, 0UL),
    content="(16, 0)",
  )
  inspect(
    count_11_pairs_with_carry(0x6666666666666666UL, 1UL),
    content="(16, 0)",
  )
}

///|
test "reverse" {
  inspect(reverse(0UL), content="0")
  inspect(reverse(1UL), content="9223372036854775808")
  inspect(reverse(0x8000000000000000UL), content="1")
  inspect(reverse(0xFFFFFFFFFFFFFFFFUL), content="18446744073709551615")
}

///|
test "reverse/patterns" {
  inspect(reverse(0x5555555555555555UL), content="12297829382473034410")
  inspect(reverse(0xAAAAAAAAAAAAAAAAUL), content="6148914691236517205")
  inspect(reverse(0x0F0F0F0F0F0F0F0FUL), content="17361641481138401520")
  inspect(reverse(0xF0F0F0F0F0F0F0F0UL), content="1085102592571150095")
}

///|
test "reverse/symmetry" {
  inspect(reverse(reverse(0x123456789ABCDEF0UL)), content="1311768467463790320")
  inspect(
    reverse(reverse(0xFEDCBA9876543210UL)),
    content="18364758544493064720",
  )
  inspect(reverse(reverse(42UL)), content="42")
}

///|
test "bit" {
  // Test basic bit checking functionality
  inspect(bit(0b1010UL, 0), content="false")
  inspect(bit(0b1010UL, 1), content="true")
  inspect(bit(0b1010UL, 2), content="false")
  inspect(bit(0b1010UL, 3), content="true")
  inspect(bit(0b1010UL, 4), content="false")

  // Test with zero
  inspect(bit(0UL, 0), content="false")
  inspect(bit(0UL, 32), content="false")

  // Test with all bits set
  inspect(bit(@uint64.max_value, 0), content="true")
  inspect(bit(@uint64.max_value, 31), content="true")
  inspect(bit(@uint64.max_value, 63), content="true")
}

///|
test "bit/boundary_cases" {
  // Test boundary positions
  inspect(bit(1UL, 0), content="true")
  inspect(bit(1UL << 63, 63), content="true")
  inspect(bit(1UL << 32, 32), content="true")

  // Test edge case with highest bit
  inspect(bit(0x8000000000000000UL, 63), content="true")
  inspect(bit(0x8000000000000000UL, 62), content="false")
}

///|
test "panic bit/invalid_bit_position" {
  // Test with negative bit position (should panic due to invalid shift)
  ignore(bit(5UL, -1))
}

///|
test "trailing_zeros" {
  // Basic cases
  inspect(trailing_zeros(1UL), content="0")
  inspect(trailing_zeros(2UL), content="1")
  inspect(trailing_zeros(4UL), content="2")
  inspect(trailing_zeros(8UL), content="3")
  inspect(trailing_zeros(16UL), content="4")
}

///|
test "trailing_zeros/boundary" {
  // Edge cases
  inspect(trailing_zeros(0UL), content="64") // All zeros -> 64 trailing zeros
  inspect(trailing_zeros(0x8000000000000000UL), content="63") // Only MSB set -> 63 trailing zeros
  inspect(trailing_zeros(0xFFFFFFFFFFFFFFFFUL), content="0") // All ones -> 0 trailing zeros
}

///|
test "trailing_zeros/powers_of_two" {
  // Powers of 2 have predictable trailing zero counts
  inspect(trailing_zeros(1024UL), content="10") // 2^10
  inspect(trailing_zeros(65536UL), content="16") // 2^16
  inspect(trailing_zeros(16777216UL), content="24") // 2^24
  inspect(trailing_zeros(4294967296UL), content="32") // 2^32
}

///|
test "leading_one" {
  inspect(leading_one(1UL), content="0")
  inspect(leading_one(2UL), content="1")
  inspect(leading_one(4UL), content="2")
  inspect(leading_one(8UL), content="3")
  inspect(leading_one(0x80000000UL), content="31")
  inspect(leading_one(0x100000000UL), content="32")
  inspect(leading_one(0x8000000000000000UL), content="63")
}

///|
test "leading_one/boundary_cases" {
  inspect(leading_one(0UL), content="0")
  inspect(leading_one(@uint64.max_value), content="63")
  inspect(leading_one(0xFFUL), content="7")
  inspect(leading_one(0xFF00UL), content="15")
  inspect(leading_one(0xFF0000UL), content="23")
  inspect(leading_one(0xFF000000UL), content="31")
}

///|
test "leading_one/power_of_two" {
  inspect(leading_one(0x10UL), content="4")
  inspect(leading_one(0x100UL), content="8")
  inspect(leading_one(0x1000UL), content="12")
  inspect(leading_one(0x10000UL), content="16")
  inspect(leading_one(0x100000UL), content="20")
  inspect(leading_one(0x1000000UL), content="24")
  inspect(leading_one(0x10000000UL), content="28")
}

///|
test "select1" {
  // Basic cases with simple bit patterns
  inspect(select_nth_one(0b1UL, 1), content="0") // First bit set at position 0
  inspect(select_nth_one(0b10UL, 1), content="1") // First bit set at position 1
  inspect(select_nth_one(0b101UL, 1), content="0") // First '1' at position 0
  inspect(select_nth_one(0b101UL, 2), content="2") // Second '1' at position 2
  inspect(select_nth_one(0b1111UL, 3), content="2") // Third '1' in consecutive bits
}

///|
test "select1/edge_cases" {
  // Test with maximum value (all bits set)
  inspect(select_nth_one(0xFFFFFFFFFFFFFFFFUL, 1), content="0") // First bit
  inspect(select_nth_one(0xFFFFFFFFFFFFFFFFUL, 32), content="31") // 32nd bit

  // Test with single bit at end
  inspect(select_nth_one(0x8000000000000000UL, 1), content="63")
}

///|
test "panic select1/invalid_i" {
  // Test with i = 0 (should be 1-indexed)
  ignore(select_nth_one(0b1111UL, -1))
  ignore(select_nth_one(0xFFFFFFFFFFFFFFFFUL, 64)) // Last bit)
}

///|
test "count_11_pairs" {
  inspect(count_11_pairs(0UL), content="0")
  inspect(count_11_pairs(3UL), content="1") // 11 in binary
  inspect(count_11_pairs(15UL), content="2") // 1111 in binary (contains 11 twice with overlap)
  inspect(count_11_pairs(51UL), content="2") // 110011 in binary (two separate 11 patterns)
}

///|
test "count_11_pairs/edge_cases" {
  inspect(count_11_pairs(0xFFFFFFFFFFFFFFFFUL), content="32") // All 1s should have maximum 11 patterns
  inspect(count_11_pairs(0xAAAAAAAAAAAAAAAAUL), content="0") // Alternating 10 pattern has no 11s
  inspect(count_11_pairs(0x5555555555555555UL), content="0") // Alternating 01 pattern has no 11s
}

///|
test "count_11_pairs/single_bits" {
  inspect(count_11_pairs(1UL), content="0") // Single 1 bit
  inspect(count_11_pairs(2UL), content="0") // Single 1 bit at position 1
  inspect(count_11_pairs(0x8000000000000000UL), content="0") // Single 1 bit at MSB
}

///|
test "count_11_pairs" {
  inspect(count_11_pairs(0b1101UL), content="1") // One "11" pair
  inspect(count_11_pairs(0b1111UL), content="2") // Three "11" pairs
  inspect(count_11_pairs(0b1010UL), content="0") // No "11" pairs
}

///|
test "select_nth_one" {
  inspect(select_nth_one(0b1101UL, 1), content="0") // First set bit at position 0
  inspect(select_nth_one(0b1101UL, 2), content="2") // Second set bit at position 2
  inspect(select_nth_one(0b1001UL, 2), content="3") // Third set bit at position 3
}

///|
test "bit/documentation" {
  // Test basic bit checking functionality
  inspect!(bit(0b1101UL, 0), content="true") // LSB is set
  inspect!(bit(0b1101UL, 1), content="false") // Second bit is not set
  inspect!(bit(0b1101UL, 2), content="true") // Third bit is set
  inspect!(bit(0b1101UL, 3), content="true") // Fourth bit is set
}
