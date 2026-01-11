library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RSA is
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
end RSA;

architecture rtl of RSA is
    constant k_bits : integer := 16;
    constant log_k  : integer := 4;

    -- Constants
    constant P_cleartext : std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(32768, k_bits));
    constant C_cryptotext: std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(61967, k_bits));
    constant priv_k      : std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(54463, k_bits));
    constant publ_k      : std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(127, k_bits));
    constant n_modulo    : std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(63383, k_bits));

    signal x, y, m, z : std_logic_vector(k_bits-1 downto 0);
    signal done_sig   : std_logic;

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

    component display is
        port (
            clk      : in std_logic;
            data_in  : in std_logic_vector(15 downto 0);
            seg      : out std_logic_vector(6 downto 0);
            dp       : out std_logic;
            an       : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    -- MUX for x (exponent) controlled by sw2
    -- sw2=0 -> priv_k, sw2=1 -> publ_k
    x <= priv_k when sw2 = '0' else publ_k;

    -- MUX for y (base) controlled by sw1
    -- sw1=0 -> cleartext, sw1=1 -> cryptotext
    y <= P_cleartext when sw1 = '0' else C_cryptotext;

    -- Modulus is constant
    m <= n_modulo;

    -- Instantiate modm_exponentiation
    EXP: modm_exponentiation
        generic map (k => k_bits, log_k => log_k)
        port map (
            x => x,
            y => y,
            m => m,
            clk => clk,
            reset => btn, -- Button acts as reset
            z => z,
            done => done_sig
        );

    led <= done_sig;

    -- Instantiate display
    DISP: display
        port map (
            clk => clk,
            data_in => z,
            seg => seg,
            dp => dp,
            an => an
        );

end rtl;
