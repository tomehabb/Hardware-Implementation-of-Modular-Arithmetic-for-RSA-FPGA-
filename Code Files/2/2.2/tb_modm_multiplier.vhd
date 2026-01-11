------------------------------------------------------------
-- Testbench for modulo m multiplier (Task 2.2)
-- File   : tb_modm_multiplier.vhd
-- Purpose: Verify that modm_multiplier computes (x * y) mod m
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_modm_multiplier is
end tb_modm_multiplier;

architecture behavior of tb_modm_multiplier is

  -- parameters
  constant k      : integer := 8;
  constant log_k  : integer := 3;  -- since 2^3 = 8 >= k

  -- modulo value
  constant m_c : std_logic_vector(k-1 downto 0) :=
    std_logic_vector( to_unsigned(239, k) );

  -- DUT component declaration
  component modm_multiplier
    generic (
      k      : integer;
      log_k  : integer
    );
    port (
      x, y, m : in  std_logic_vector(k-1 downto 0);
      clk, reset : in std_logic;
      z : out std_logic_vector(k-1 downto 0);
      done : out std_logic
    );
  end component;

  -- signals
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';

  signal x, y, m  : std_logic_vector(k-1 downto 0) := (others => '0');
  signal z        : std_logic_vector(k-1 downto 0);
  signal done     : std_logic;

  -- cycle counter: ONLY driven in one clocked process
  signal cycle_cnt : integer := 0;
  signal start_cnt : std_logic := '0';

begin

  ----------------------------------------------------------
  -- Clock generation: 10 ns period
  ----------------------------------------------------------
  clk_process : process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;

  ----------------------------------------------------------
  -- DUT instantiation
  ----------------------------------------------------------
  dut: modm_multiplier
    generic map (
      k     => k,
      log_k => log_k
    )
    port map (
      x     => x,
      y     => y,
      m     => m,
      clk   => clk,
      reset => reset,
      z     => z,
      done  => done
    );

  ----------------------------------------------------------
  -- Simple cycle counter (only here we assign cycle_cnt)
  ----------------------------------------------------------
  count_cycles : process(clk)
  begin
    if rising_edge(clk) then
      if start_cnt = '1' and done = '0' then
        cycle_cnt <= cycle_cnt + 1;
      elsif start_cnt = '0' then
        cycle_cnt <= 0;
      end if;
    end if;
  end process;

  ----------------------------------------------------------
  -- Stimulus process
  ----------------------------------------------------------
  stim_proc : process
    variable exp : integer;
  begin

    ------------------------------------------------------
    -- Global reset
    ------------------------------------------------------
    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    -- set modulo
    m <= m_c;

    ------------------------------------------------------
    -- TEST 1: x = 15, y = 7
    -- expect z = (15 * 7) mod 239 = 105
    ------------------------------------------------------
    x <= std_logic_vector( to_unsigned(15, k) );
    y <= std_logic_vector( to_unsigned(7,  k) );

    start_cnt <= '1';                 -- start counting cycles

    wait until done = '1';            -- wait for multiplier to finish
    wait for 10 ns;                   -- let z settle
    start_cnt <= '0';                 -- stop counting

    exp := (15 * 7) mod 239;

    assert to_integer(unsigned(z)) = exp
      report "TEST 1 FAILED: got " &
             integer'image(to_integer(unsigned(z))) &
             " expected " & integer'image(exp)
      severity error;

    ------------------------------------------------------
    -- TEST 2: x = 234, y = 238
    ------------------------------------------------------
    reset <= '1';
    wait for 10 ns;
    reset <= '0';

    x <= std_logic_vector( to_unsigned(234, k) );
    y <= std_logic_vector( to_unsigned(238, k) );

    start_cnt <= '1';
    wait until done = '1';
    wait for 10 ns;
    start_cnt <= '0';

    exp := (234 * 238) mod 239;

    assert to_integer(unsigned(z)) = exp
      report "TEST 2 FAILED: got " &
             integer'image(to_integer(unsigned(z))) &
             " expected " & integer'image(exp)
      severity error;

    ------------------------------------------------------
    -- End of simulation
    ------------------------------------------------------
    wait;
  end process;

end behavior;
