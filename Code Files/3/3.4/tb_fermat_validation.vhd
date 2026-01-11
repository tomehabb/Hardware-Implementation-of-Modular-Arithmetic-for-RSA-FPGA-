----------------------------------------------------------------------------
-- Testbench for Modulo m exponentiation - FERMAT PRIME VALIDATION (8-bit)
-- m = ((2^192-1)-2^16) mod 256 = 249, x = m, y = 0x7FFF...FF mod 256 = 255
-- Fermat: y^m mod m = y mod m = 255 mod 249 = 6
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fermat_validation is
end entity tb_fermat_validation;

architecture testbench of tb_fermat_validation is

    constant k         : integer := 8;
    constant log_k     : integer := 4;
    constant CLK_PERIOD: time := 10 ns;
    constant TIMEOUT   : time := 200 us;

    constant FERMAT_M  : std_logic_vector(7 downto 0) := x"F9";  -- 249
    constant FERMAT_X  : std_logic_vector(7 downto 0) := x"F9";  -- x = m
    constant FERMAT_Y  : std_logic_vector(7 downto 0) := x"FF";  -- y = 0x7FFF...FF mod 256
    constant EXPECTED_Z: integer := 6;                           -- 255 mod 249 = 6

    -- Signals WITHOUT default values (fixes VRFC 10-2859)
    signal clk   : std_logic;
    signal reset : std_logic;
    signal x     : std_logic_vector(k-1 downto 0);
    signal y     : std_logic_vector(k-1 downto 0);
    signal m     : std_logic_vector(k-1 downto 0);
    signal z     : std_logic_vector(k-1 downto 0);
    signal done  : std_logic;
    signal sim_done : boolean;

    -- Hex display function (MOVED to declarative region - fixes syntax error)
    function vec_to_hex(v : std_logic_vector(7 downto 0)) return string is
    begin
        case to_integer(unsigned(v)) is
            when 249 => return "F9";
            when 255 => return "FF";
            when 6   => return "06";
            when others => return "XX";
        end case;
    end function;

    component modm_exponentiation is
        generic (k : integer; log_k : integer);
        port (
            x, y, m : in  std_logic_vector(k-1 downto 0);
            clk     : in  std_logic;
            reset   : in  std_logic;
            z       : out std_logic_vector(k-1 downto 0);
            done    : out std_logic
        );
    end component;

begin

    DUT: modm_exponentiation
        generic map (k => k, log_k => log_k)
        port map (x => x, y => y, m => m, clk => clk, reset => reset, z => z, done => done);

    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stimulus: process
        variable pass_count : integer := 0;
        variable fail_count : integer := 0;
        variable start_time : time;
    begin
        sim_done <= false;
        wait for 2 * CLK_PERIOD;
        
        report "########################################################";
        report "# FERMAT LITTLE THEOREM VALIDATION (Professor's Test)  #";
        report "# m=(2^192-1)-2^16 mod 256=249, x=249, y=255          #";
        report "########################################################";
        
        report "m = ((2^192-1)-2^16) mod 256 = 249 (0xF9)" severity note;
        report "x = m = 249 (0xF9)" severity note;
        report "y = 0x7FFF...FF mod 256 = 255 (0xFF)" severity note;
        report "Expected: 255^249 mod 249 = 255 mod 249 = 6 (0x06)" severity note;
        
        x <= FERMAT_X;
        y <= FERMAT_Y;
        m <= FERMAT_M;
        
        reset <= '1'; wait for 5 * CLK_PERIOD;
        reset <= '0'; start_time := now;
        report "Reset released at " & time'image(start_time) severity note;
        
        wait until done = '1' or (now - start_time) >= TIMEOUT;
        
        if done = '1' then
            report "Done at " & time'image(now) & " (Duration: " & time'image(now - start_time) & ")" severity note;
            wait for CLK_PERIOD;
            
            if to_integer(unsigned(z)) = EXPECTED_Z then
                report "PASS: z=0x" & vec_to_hex(z) & " matches expected 0x06" severity note;
                report "FERMAT'S THEOREM VERIFIED!" severity note;
                pass_count := pass_count + 1;
            else
                report "FAIL: Expected 0x06 but got 0x" & vec_to_hex(z) severity error;
                fail_count := fail_count + 1;
            end if;
        else
            report "FAIL: TIMEOUT after " & time'image(TIMEOUT) severity error;
            report "Last z=0x" & vec_to_hex(z) severity error;
            fail_count := fail_count + 1;
        end if;
        
        report "########################################################";
        report "# Summary: PASSED=" & integer'image(pass_count) & " FAILED=" & integer'image(fail_count) & " #";
        report "########################################################";
        
        sim_done <= true;
        wait;
    end process;

end architecture testbench;
