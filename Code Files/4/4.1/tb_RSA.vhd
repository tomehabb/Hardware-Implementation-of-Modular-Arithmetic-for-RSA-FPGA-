library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_RSA is
end tb_RSA;

architecture testbench of tb_RSA is
    component RSA is
        port (
            sw1 : in std_logic;
            sw2 : in std_logic;
            btn : in std_logic;
            clk : in std_logic;
            led : out std_logic;
            seg : out std_logic_vector(6 downto 0);
            dp  : out std_logic;
            an  : out std_logic_vector(3 downto 0)
        );
    end component;

    signal sw1, sw2, btn, clk, led, dp : std_logic;
    signal seg : std_logic_vector(6 downto 0);
    signal an : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: RSA port map (
        sw1 => sw1,
        sw2 => sw2,
        btn => btn,
        clk => clk,
        led => led,
        seg => seg,
        dp => dp,
        an => an
    );

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulus: process
    begin
        -- Test Case 1: Encryption
        -- sw2 = 1 (Public Key), sw1 = 0 (Cleartext)
        -- Expected result: Cryptotext (61967)
        report "Starting Test Case 1: Encryption";
        sw2 <= '1';
        sw1 <= '0';
        btn <= '1'; -- Reset
        wait for 100 ns;
        btn <= '0'; -- Release reset
        
        wait until led = '1';
        report "Encryption Done. Check waveform for result (should be 61967 / 0xF20F)";
        wait for 100 ns;

        -- Test Case 2: Decryption
        -- sw2 = 0 (Private Key), sw1 = 1 (Cryptotext)
        -- Expected result: Cleartext (32768)
        report "Starting Test Case 2: Decryption";
        sw2 <= '0';
        sw1 <= '1';
        btn <= '1'; -- Reset
        wait for 100 ns;
        btn <= '0'; -- Release reset

        wait until led = '1';
        report "Decryption Done. Check waveform for result (should be 32768 / 0x8000)";
        wait for 100 ns;

        report "Simulation Finished";
        wait;
    end process;

end testbench;
