------------------------------------------------------------
-- Testbench for Task 1.3
-- Goal : Compare behavioral (modm_addition) vs RTL (modm_adder)
-- File : tb_task1_3.vhd
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_task1_3 is
end tb_task1_3;

architecture behavior of tb_task1_3 is

  -- same width and modulus as in the assignment
  constant k : integer := 8;
  constant m : std_logic_vector := std_logic_vector( to_unsigned(239, k) );

  -- Behavioral model (Task 1.1)
  component modm_addition
    generic ( k : integer );
    port (
      x, y, m : in  std_logic_vector(k-1 downto 0);
      z       : out std_logic_vector(k-1 downto 0)
    );
  end component;

  -- RTL datapath model (Task 1.2)
  component modm_adder
    generic ( k : integer );
    port (
      x, y, m : in  std_logic_vector(k-1 downto 0);
      z       : out std_logic_vector(k-1 downto 0)
    );
  end component;

  -- common inputs
  signal x, y    : std_logic_vector(k-1 downto 0) := (others => '0');

  -- two outputs to compare
  signal z_behav : std_logic_vector(k-1 downto 0) := (others => '0');
  signal z_rtl   : std_logic_vector(k-1 downto 0) := (others => '0');

begin

  ----------------------------------------------------------
  -- DUT 1: behavioral implementation
  ----------------------------------------------------------
  dut_behav : modm_addition
    generic map ( k => k )
    port map (
      x => x,
      y => y,
      m => m,
      z => z_behav
    );

  ----------------------------------------------------------
  -- DUT 2: RTL/datapath implementation
  ----------------------------------------------------------
  dut_rtl : modm_adder
    generic map ( k => k )
    port map (
      x => x,
      y => y,
      m => m,
      z => z_rtl
    );

  ----------------------------------------------------------
  -- Stimulus + comparison for Task 1.3
  ----------------------------------------------------------
  stim_proc : process
  begin

    -- Example 1: x = 129, y = 105  â†’ expected z = 234
    x <= std_logic_vector( to_unsigned(129, k) );
    y <= std_logic_vector( to_unsigned(105, k) );
    wait for 50 ns;

    -- Example 2: x = 234, y = 238  â†’ expected z = 233
    x <= std_logic_vector( to_unsigned(234, k) );
    y <= std_logic_vector( to_unsigned(238, k) );
    wait for 50 ns;

    -- Example 3: x = 215, y = 35   â†’ expected z = 11
    x <= std_logic_vector( to_unsigned(215, k) );
    y <= std_logic_vector( to_unsigned(35,  k) );
    wait for 50 ns;

    -- finish simulation
    wait;
  end process;

end behavior;
