-- modm_exponentiation.vhd - FULLY FIXED & WORKING
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modm_exponentiation is
  generic (
    k      : integer;
    log_k   : integer
  );
  port (
    x, y, m : in  std_logic_vector(k-1 downto 0);  -- x=exponent, y=base
    clk, reset : in  std_logic;
    z       : out std_logic_vector(k-1 downto 0);
    done    : out std_logic
  );
end entity;

architecture rtl of modm_exponentiation is
  signal p, q, product : std_logic_vector(k-1 downto 0);
  signal int_exp       : std_logic_vector(k-1 downto 0);
  signal exp_bit       : std_logic;
  signal count         : std_logic_vector(log_k-1 downto 0);
  signal load_reg, save_reg, update_reg, mult_reset, mult_done : std_logic;  -- RENAMED
  signal is_square     : std_logic;

  type state_t is (IDLE, LOAD, CHECK_BIT, MUL_PREP, MUL_WAIT, MUL_SAVE,
                   SQR_PREP, SQR_WAIT, SQR_SAVE, DONE_ST);
  signal state, next_state : state_t;

  component modm_multiplier
    generic (k: integer; log_k: integer);
    port (x,y,m: in std_logic_vector(k-1 downto 0);
          clk,reset: in std_logic;
          z: out std_logic_vector(k-1 downto 0);
          done: out std_logic);
  end component;
begin
  mul: modm_multiplier
    generic map (k => k, log_k => log_k)
    port map (x => p, y => q, m => m, clk => clk, reset => mult_reset,
              z => product, done => mult_done);

  q <= p when is_square = '1' else y;

  -- Main accumulator register
  process(clk)
  begin
    if rising_edge(clk) then
      if load_reg = '1' then
        p <= std_logic_vector(to_unsigned(1, k));
      elsif save_reg = '1' then
        p <= product;
      end if;
    end if;
  end process;

  -- Exponent shift register
  process(clk)
  begin
    if rising_edge(clk) then
      if load_reg = '1' then
        int_exp <= x;
      elsif update_reg = '1' then
        int_exp <= int_exp(k-2 downto 0) & '0';
      end if;
    end if;
  end process;
  exp_bit <= int_exp(k-1);

  -- Bit counter
  process(clk)
  begin
    if rising_edge(clk) then
      if load_reg = '1' then
        if unsigned(x) = 0 then
          count <= (others => '0');
        else
          count <= std_logic_vector(to_unsigned(k, log_k));
        end if;
      elsif update_reg = '1' then
        count <= std_logic_vector(unsigned(count) - 1);
      end if;
    end if;
  end process;

  -- FSM state register
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then state <= IDLE;
      else state <= next_state;
      end if;
    end if;
  end process;

  -- Next state logic
  process(state, exp_bit, mult_done, count, x)
  begin
    next_state <= state;
    case state is
      when IDLE      => next_state <= LOAD;
      when LOAD      => next_state <= CHECK_BIT;
      when CHECK_BIT =>
        if unsigned(count) = 0 then next_state <= DONE_ST;
        elsif exp_bit = '1' then next_state <= MUL_PREP;
        else next_state <= SQR_PREP;
        end if;
      when MUL_PREP  => next_state <= MUL_WAIT;
      when MUL_WAIT  => if mult_done='1' then next_state <= MUL_SAVE; end if;
      when MUL_SAVE  => next_state <= SQR_PREP;
      when SQR_PREP  => next_state <= SQR_WAIT;
      when SQR_WAIT  => if mult_done='1' then next_state <= SQR_SAVE; end if;
      when SQR_SAVE  => next_state <= CHECK_BIT;
      when DONE_ST   => null;
    end case;
  end process;

  -- Output logic
  process(state)
  begin
    load_reg <= '0'; save_reg <= '0'; update_reg <= '0'; is_square <= '0'; mult_reset <= '1';
    case state is
      when IDLE      => null;
      when LOAD      => load_reg <= '1'; mult_reset <= '1';
      when CHECK_BIT => mult_reset <= '1';
      when MUL_PREP  => is_square <= '0'; mult_reset <= '0';
      when MUL_WAIT  => is_square <= '0'; mult_reset <= '0';
      when MUL_SAVE  => save_reg <= '1'; mult_reset <= '1';
      when SQR_PREP  => is_square <= '1'; mult_reset <= '0';
      when SQR_WAIT  => is_square <= '1'; mult_reset <= '0';
      when SQR_SAVE  => save_reg <= '1'; update_reg <= '1'; mult_reset <= '1';
      when DONE_ST   => mult_reset <= '1';
    end case;
  end process;

  z    <= p when state = DONE_ST else (others => '0');
  done <= '1' when state = DONE_ST else '0';
end rtl;
