------------------------------------------------------------
-- Modulo m addition simulation-only VHDL code (modm_addition.vhd)
-- Function : z = (x + y) mod m
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;     
use std.textio.all;            


entity modm_addition is
  generic(
    k : integer              
  );
  port(
    x, y, m : in  std_logic_vector(k-1 downto 0); 
    z       : out std_logic_vector(k-1 downto 0)  
  );
end modm_addition;


architecture rtl of modm_addition is
begin

  
  process(x, y, m)
    
    variable z1, z2 : integer;  
    variable c1, c2 : integer;  
    variable L      : line;    

  begin
   
    z1 := to_integer( unsigned('0' & x) + unsigned(y) );
    z2 := (z1 mod 2**k) + (2**k - to_integer(unsigned(m)));

    c1 := z1 / 2**k;
    c2 := z2 / 2**k;

    if (c1 = 0) and (c2 = 0) then
      -- No overflow in z1 and z2: result = z1 mod 2^k
      z <= std_logic_vector( to_unsigned(z1 mod 2**k, k) );
    else
      -- Overflow occurred: use adjusted value z2
      z <= std_logic_vector( to_unsigned(z2 mod 2**k, k) );
    end if;

    write(L, string'("x = "));
    write(L, to_integer(unsigned(x)));
    write(L, string'("; y = "));
    write(L, to_integer(unsigned(y)));
    write(L, string'("; m = "));
    write(L, to_integer(unsigned(m)));
    write(L, string'("; z1 = "));
    write(L, z1);
    write(L, string'("; z2 = "));
    write(L, z2);
    write(L, string'("; c1 = "));
    write(L, c1);
    write(L, string'("; c2 = "));
    write(L, c2);
    writeline(output, L);  

  end process;

end rtl;