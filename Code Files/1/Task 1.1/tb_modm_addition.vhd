------------------------------------------------------------
-- Testbench for modulo m adder (Task 1.1)
-- File   : tb_modm_addition.vhd
-- Purpose: Test modm_addition (z = (x + y) mod m)
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;      

entity tb_modm_addition is
end tb_modm_addition;
 
architecture behavior of tb_modm_addition is 

  
  constant k : integer := 8;

 
  constant m : std_logic_vector := std_logic_vector( to_unsigned(239, k) );
 
    component modm_addition
    generic(
      k : integer                      -- bit-width
    );
    port(
      x, y, m : in  std_logic_vector(k-1 downto 0); -- inputs
      z       : out std_logic_vector(k-1 downto 0)  -- output
    );
  end component;
   
  
  signal x, y : std_logic_vector(k-1 downto 0) := (others => '0');
 
  signal z1   : std_logic_vector(k-1 downto 0) := (others => '0');
 
begin

  ----------------------------------------------------------
  -- DUT instantiation: modm_addition under test
  ----------------------------------------------------------
  dut1: modm_addition
    generic map (
      k => k                 -- pass bit-width generic
    )
    port map (
      x => x,                -- connect testbench x to DUT x
      y => y,                -- connect testbench y to DUT y
      m => m,                -- constant modulus
      z => z1                -- DUT output observed on z1
    );

  ----------------------------------------------------------
  -- Stimulus process:
  ----------------------------------------------------------
  
stim_proc: process
  begin		
    -- Test vector: x = 129, y = 105
    x <= std_logic_vector( to_unsigned(129, k) );
    y <= std_logic_vector( to_unsigned(105, k) );

   
    wait for 100 ns;	

    wait;
  end process;

end behavior;
