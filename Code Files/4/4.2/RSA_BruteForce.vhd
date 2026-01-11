library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RSA_BruteForce is
    port (
        clk : in std_logic;
        sw1 : in std_logic; -- Reset
        btn : in std_logic; -- Next match button (Center button)
        led : out std_logic; -- Status LED (1 = Match Found, 0 = Searching)
        seg : out std_logic_vector(6 downto 0);
        dp  : out std_logic;
        an  : out std_logic_vector(3 downto 0)
    );
end RSA_BruteForce;

architecture behavioral of RSA_BruteForce is
    -- Constants for the attack
    constant k_bits : integer := 16;
    constant log_k  : integer := 4;
    
    -- m = 64507
    constant m_val : std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(64507, k_bits));
    -- Plaintext = 1000
    constant p_val : std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(1000, k_bits));
    -- Ciphertext = 12486
    constant c_val : std_logic_vector(k_bits-1 downto 0) := std_logic_vector(to_unsigned(12486, k_bits));
    
    -- We are looking for an exponent 'key' such that:
    -- Plaintext^key mod m = Ciphertext
    -- (Finding encryption key e)
    -- OR
    -- Ciphertext^key mod m = Plaintext
    -- (Finding decryption key d)
    
    -- Based on "look for the encryption key", we use Base = Plaintext, Target = Ciphertext.
    constant base_val   : std_logic_vector(k_bits-1 downto 0) := p_val;
    constant target_val : std_logic_vector(k_bits-1 downto 0) := c_val;

    -- Signals
    signal candidate_key : std_logic_vector(k_bits-1 downto 0) := (others => '0');
    signal result        : std_logic_vector(k_bits-1 downto 0);
    signal exp_done      : std_logic;
    signal exp_reset     : std_logic := '1';
    
    -- State Machine
    type state_type is (INIT, RESET_EXP, START_EXP, WAIT_EXP, CHECK_RESULT, FOUND_WAIT, NEXT_KEY);
    signal state : state_type := INIT;
    
    -- Button Debounce
    signal btn_cnt : unsigned(19 downto 0) := (others => '0');
    signal btn_stable : std_logic := '0';
    signal btn_sync : std_logic_vector(1 downto 0) := (others => '0');
    signal btn_rise : std_logic;
    signal btn_stable_prev : std_logic := '0';
    
    -- Display
    signal display_data : std_logic_vector(15 downto 0);
    
    component modm_exponentiation is
        generic(
            k: integer;
            log_k: integer
        );
        port (
            x, y, m: in std_logic_vector(k-1 downto 0);
            clk, reset: in std_logic;
            z: out std_logic_vector(k-1 downto 0);
            done: out std_logic
        );
    end component;
    
    component display is
        port ( clk      : in std_logic;
               data_in  : in std_logic_vector(15 downto 0);
               seg      : out std_logic_vector(6 downto 0);
               dp       : out std_logic;
               an       : out std_logic_vector(3 downto 0));
    end component;

begin

    -- Button Debouncer
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync <= btn_sync(0) & btn; -- Synchronize input
            
            if (btn_sync(1) = '1') then
                if (btn_cnt < x"FFFFF") then
                    btn_cnt <= btn_cnt + 1;
                else
                    btn_stable <= '1';
                end if;
            else
                btn_cnt <= (others => '0');
                btn_stable <= '0';
            end if;
            
            -- Edge detection on stable signal
            btn_stable_prev <= btn_stable;
            if btn_stable = '1' and btn_stable_prev = '0' then
                btn_rise <= '1';
            else
                btn_rise <= '0';
            end if;
        end if;
    end process;

  ``    -- State Machine```

    -- Instantiate Exponentiation Module
    -- x^y mod m
    -- x = base_val (Plaintext)
    -- y = candidate_key
    -- m = m_val
    EXP_MOD : modm_exponentiation
    generic map (
        k => k_bits,
        log_k => log_k
    )
    port map (
        x => candidate_key,
        y => base_val,
        m => m_val,
        clk => clk,
        reset => exp_reset,
        z => result,
        done => exp_done
    );

    -- Display the candidate key
    display_data <= candidate_key;

    DISP_MOD : display
    port map (
        clk => clk,
        data_in => display_data,
        seg => seg,
        dp => dp,
        an => an
    );

end behavioral;
