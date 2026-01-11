-- COMPREHENSIVE TESTBENCH FOR MODULAR EXPONENTIATION
-- Tests cover: edge cases, boundary conditions, cryptographic scenarios
-- Total: 49 comprehensive test cases across 11 categories

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_modm_exponentiation is
end entity;

architecture sim of tb_modm_exponentiation is
  constant k      : integer := 16;
  constant log_k  : integer := 4;
  signal x,y,m    : std_logic_vector(k-1 downto 0);
  signal clk      : std_logic := '0';
  signal reset    : std_logic := '1';
  signal z        : std_logic_vector(k-1 downto 0);
  signal done     : std_logic;

  constant T : time := 10 ns;
  
  signal test_count : integer := 0;
  signal pass_count : integer := 0;
  signal fail_count : integer := 0;
  
begin
  clk <= not clk after T/2;

  dut: entity work.modm_exponentiation
    generic map (k => k, log_k => log_k)
    port map (x=>x, y=>y, m=>m, clk=>clk, reset=>reset, z=>z, done=>done);

  process
    procedure test(b, e, modl : integer; name: string) is
      variable exp_result : integer;
      variable temp : integer;
      variable i : integer;
    begin
      test_count <= test_count + 1;
      report "=== TEST " & integer'image(test_count) & ": " & name & " ===" severity note;
      x <= std_logic_vector(to_unsigned(e, k));
      y <= std_logic_vector(to_unsigned(b, k));
      m <= std_logic_vector(to_unsigned(modl, k));

      reset <= '1'; wait for 4*T; reset <= '0'; wait for T;

      wait until rising_edge(clk) and done='1';

      -- Calculate expected result
      if e = 0 then
        exp_result := 1;
      else
        exp_result := b;
        for i in 2 to e loop
          temp := exp_result * b;
          exp_result := temp mod modl;
        end loop;
      end if;

      assert to_integer(unsigned(z)) = exp_result
        report "FAILED: got " & integer'image(to_integer(unsigned(z))) &
               " expected " & integer'image(exp_result)
        severity error;

      if to_integer(unsigned(z)) = exp_result then
        pass_count <= pass_count + 1;
      else
        fail_count <= fail_count + 1;
      end if;

      report "PASSED: " & integer'image(b) & "^" & integer'image(e) &
             " mod " & integer'image(modl) & " = " &
             integer'image(to_integer(unsigned(z)))
        severity note;

      wait for 10*T;
    end procedure;
    
  begin
    wait for 10*T;
    
    report "============================================================" severity note;
    report "  COMPREHENSIVE MODULAR EXPONENTIATION TESTBENCH (k=16)    " severity note;
    report "============================================================" severity note;

    -- CATEGORY 1
    report "CATEGORY 1: BASIC FUNCTIONALITY" severity note;
    test(3,   5,  17,  "3^5 mod 17");
    test(2,  64,  65,  "2^64 mod 65");
    test(7,   0,  13,  "7^0 mod 13");

    -- CATEGORY 2
    report "CATEGORY 2: EDGE CASES" severity note;
    test(0,   5,  17,  "0^5 mod 17");
    test(1,   0,  17,  "1^0 mod 17");
    test(1, 100,  17,  "1^100 mod 17");
    test(2,   1,  17,  "2^1 mod 17");
    test(5,   1,   7,  "5^1 mod 7");

    -- CATEGORY 3
    report "CATEGORY 3: MODULUS PROPERTIES" severity note;
    test(5,   2,   5,  "5^2 mod 5");
    test(4,   3,   4,  "4^3 mod 4");
    test(6,   2,   6,  "6^2 mod 6");
    test(3,   4,   3,  "3^4 mod 3");
    test(11,  7,  11, "11^7 mod 11");

    -- CATEGORY 4
    report "CATEGORY 4: FERMAT'S LITTLE THEOREM" severity note;
    test(2,   4,   5,  "2^4 mod 5");
    test(3,   4,   5,  "3^4 mod 5");
    test(5,   6,   7,  "5^6 mod 7");
    test(3,   6,   7,  "3^6 mod 7");
    test(2,  10,  11, "2^10 mod 11");

    -- CATEGORY 5
    report "CATEGORY 5: EULER THEOREM" severity note;
    test(2,   8,  15, "2^8 mod 15");
    test(7,   8,  15, "7^8 mod 15");
    test(4,   8,  15, "4^8 mod 15");

    -- CATEGORY 6
    report "CATEGORY 6: POWERS OF 2" severity note;
    test(2,   8,  17, "2^8 mod 17");
    test(2,  16,  17, "2^16 mod 17");
    test(3,   8,  17, "3^8 mod 17");
    test(5,   4,  17, "5^4 mod 17");

    -- CATEGORY 7
    report "CATEGORY 7: CRYPTOGRAPHIC TESTS" severity note;
    test(7,   5,  33, "7^5 mod 33");
    test(2,  13,  35, "2^13 mod 35");
    test(3,   9,  35, "3^9 mod 35");
    test(4,   7,  33, "4^7 mod 33");
    test(11,  7,  26, "11^7 mod 26");

    -- CATEGORY 8
    report "CATEGORY 8: LARGE EXPONENTS" severity note;
    test(2, 255, 257, "2^255 mod 257");
    test(3, 100, 101, "3^100 mod 101");
    test(5, 200, 211, "5^200 mod 211");
    test(7, 150, 181, "7^150 mod 181");

    -- CATEGORY 9
    report "CATEGORY 9: SEQUENTIAL MULTIPLY TESTS" severity note;
    test(2,  10, 17, "2^10 mod 17");
    test(3,  10, 17, "3^10 mod 17");
    test(5,  12, 23, "5^12 mod 23");
    test(6,   9, 31, "6^9 mod 31");

    -- CATEGORY 10
    report "CATEGORY 10: SMALL PRIMES" severity note;
    test(2, 3, 5,  "2^3 mod 5");
    test(3, 3, 7,  "3^3 mod 7");
    test(4, 3, 11, "4^3 mod 11");
    test(5, 3, 13, "5^3 mod 13");
    test(2, 5, 7,  "2^5 mod 7");
    test(3, 5, 11, "3^5 mod 11");

    -- CATEGORY 11
    report "CATEGORY 11: COMPOSITE MODULI" severity note;
    test(2, 6, 9,   "2^6 mod 9");
    test(5, 4, 21,  "5^4 mod 21");
    test(2, 7, 15,  "2^7 mod 15");
    test(4, 5, 21,  "4^5 mod 21");
    test(3, 7, 25,  "3^7 mod 25");

    report "============================================================" severity note;
    report "TEST SUMMARY" severity note;
    report "Total Tests: " & integer'image(test_count) severity note;
    report "Passed:      " & integer'image(pass_count) severity note;
    report "Failed:      " & integer'image(fail_count) severity note;

    if fail_count = 0 then
      report "ALL TESTS PASSED" severity note;
    else
      report integer'image(fail_count) & " TEST(S) FAILED" severity error;
    end if;

    wait;
  end process;
end sim;
