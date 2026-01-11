------------------------------------------------------------
-- Testbench for modulo m adder (Task 1.2 only)
-- File   : tb_modm_adder.vhd
-- Purpose: Test RTL datapath modm_adder (z = (x + y) mod m)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_modm_adder is
end tb_modm_adder;
 
architecture behavior of tb_modm_adder is 
  constant k : integer := 8;
  constant m : std_logic_vector := std_logic_vector( to_unsigned(239, k) );
 
  component modm_adder
    generic( k: integer );
    port(
      x, y, m : in  std_logic_vector(k-1 downto 0);
      z       : out std_logic_vector(k-1 downto 0)
    );
  end component;
   
  signal x, y : std_logic_vector(k-1 downto 0) := (others => '0');
  signal z_rtl: std_logic_vector(k-1 downto 0) := (others => '0');
 
begin

  -- DUT: RTL/datapath implementation
  dut_rtl: modm_adder
    generic map ( k => k )
    port map (
      x => x,
      y => y,
      m => m,
      z => z_rtl
    );

  -- Stimulus
  stim_proc: process
  begin		
    -- Example 1: x = 129, y = 105 ? expect 234
    x <= std_logic_vector( to_unsigned(129, k) );
    y <= std_logic_vector( to_unsigned(105, k) );
    wait for 50 ns;

    -- Example 2: x = 234, y = 238 ? expect 233
    x <= std_logic_vector( to_unsigned(234, k) );
    y <= std_logic_vector( to_unsigned(238, k) );
    wait for 50 ns;

    -- Example 3: x = 215, y = 35 ? expect 11
    x <= std_logic_vector( to_unsigned(215, k) );
    y <= std_logic_vector( to_unsigned(35,  k) );
    wait for 50 ns;

    wait;
  end process;

end behavior;
