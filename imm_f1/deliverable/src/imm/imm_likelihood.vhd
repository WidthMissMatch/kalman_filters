library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_likelihood is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    nu1_x, nu1_y, nu1_z : in signed(47 downto 0);
    s1_11, s1_22, s1_33 : in signed(47 downto 0);

    nu2_x, nu2_y, nu2_z : in signed(47 downto 0);
    s2_11, s2_22, s2_33 : in signed(47 downto 0);

    nu3_x, nu3_y, nu3_z : in signed(47 downto 0);
    s3_11, s3_22, s3_33 : in signed(47 downto 0);

    L1_out, L2_out, L3_out : out signed(47 downto 0);
    done : out std_logic
  );
end entity;

architecture Behavioral of imm_likelihood is

  constant Q : integer := 24;
  constant ONE_Q24 : signed(47 downto 0) := to_signed(16777216, 48);

  constant NEG_HALF : signed(47 downto 0) := to_signed(-8388608, 48);

  component log_lut is
    port (
      clk : in std_logic; start : in std_logic;
      x_in : in signed(47 downto 0);
      y_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  component exp_lut is
    port (
      clk : in std_logic; start : in std_logic;
      x_in : in signed(47 downto 0);
      y_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  function nr_initial_guess(s_val : signed(47 downto 0)) return signed is
    variable msb_pos : integer range 0 to 47;
    variable result : signed(47 downto 0);
    variable abs_s : signed(47 downto 0);
  begin

    if s_val < 0 then
      abs_s := -s_val;
    else
      abs_s := s_val;
    end if;

    msb_pos := 0;
    for i in 47 downto 0 loop
      if abs_s(i) = '1' then
        msb_pos := i;
        exit;
      end if;
    end loop;

    result := (others => '0');
    if msb_pos <= 47 then
      result(47 - msb_pos) := '1';
    end if;
    return result;
  end function;

  type state_type is (IDLE, COMPUTE_NU_SQ, COMPUTE_S_RECIP, APPLY_S_INV,
                      START_LOG1, WAIT_LOG1,
                      START_LOG2, WAIT_LOG2, START_LOG3, WAIT_LOG3,
                      COMPUTE_LOGLIK, MAX_SUBTRACT,
                      START_EXP1, WAIT_EXP1,
                      WAIT_EXP2, WAIT_EXP3, OUTPUT);
  signal state : state_type := IDLE;

  signal nu1_x_sq, nu1_y_sq, nu1_z_sq : signed(47 downto 0) := (others => '0');
  signal nu2_x_sq, nu2_y_sq, nu2_z_sq : signed(47 downto 0) := (others => '0');
  signal nu3_x_sq, nu3_y_sq, nu3_z_sq : signed(47 downto 0) := (others => '0');

  signal rs1_11, rs1_22, rs1_33 : signed(47 downto 0) := (others => '0');
  signal rs2_11, rs2_22, rs2_33 : signed(47 downto 0) := (others => '0');
  signal rs3_11, rs3_22, rs3_33 : signed(47 downto 0) := (others => '0');

  signal nr_iter : integer range 0 to 7 := 0;

  signal mahal1, mahal2, mahal3 : signed(47 downto 0) := (others => '0');

  signal logdet1, logdet2, logdet3 : signed(47 downto 0) := (others => '0');

  signal logL1, logL2, logL3 : signed(47 downto 0) := (others => '0');

  signal max_logL : signed(47 downto 0) := (others => '0');

  signal log_start, log_done : std_logic := '0';
  signal log_in, log_out_sig : signed(47 downto 0) := (others => '0');
  signal exp_start, exp_done : std_logic := '0';
  signal exp_in, exp_out_sig : signed(47 downto 0) := (others => '0');

  signal log_accum : signed(47 downto 0) := (others => '0');
  signal log_step : integer range 0 to 8 := 0;

begin

  log_inst : log_lut port map (
    clk => clk, start => log_start,
    x_in => log_in, y_out => log_out_sig, done => log_done
  );

  exp_inst : exp_lut port map (
    clk => clk, start => exp_start,
    x_in => exp_in, y_out => exp_out_sig, done => exp_done
  );

  process(clk)
    variable prod96 : signed(95 downto 0);
    variable div_result : signed(47 downto 0);
    variable nu_sq_sum : signed(47 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          log_start <= '0';
          exp_start <= '0';
          if start = '1' then
            state <= COMPUTE_NU_SQ;
          end if;

        when COMPUTE_NU_SQ =>

          prod96 := nu1_x * nu1_x;
          nu1_x_sq <= resize(shift_right(prod96, Q), 48);
          prod96 := nu1_y * nu1_y;
          nu1_y_sq <= resize(shift_right(prod96, Q), 48);
          prod96 := nu1_z * nu1_z;
          nu1_z_sq <= resize(shift_right(prod96, Q), 48);

          prod96 := nu2_x * nu2_x;
          nu2_x_sq <= resize(shift_right(prod96, Q), 48);
          prod96 := nu2_y * nu2_y;
          nu2_y_sq <= resize(shift_right(prod96, Q), 48);
          prod96 := nu2_z * nu2_z;
          nu2_z_sq <= resize(shift_right(prod96, Q), 48);

          prod96 := nu3_x * nu3_x;
          nu3_x_sq <= resize(shift_right(prod96, Q), 48);
          prod96 := nu3_y * nu3_y;
          nu3_y_sq <= resize(shift_right(prod96, Q), 48);
          prod96 := nu3_z * nu3_z;
          nu3_z_sq <= resize(shift_right(prod96, Q), 48);

          rs1_11 <= nr_initial_guess(s1_11);
          rs1_22 <= nr_initial_guess(s1_22);
          rs1_33 <= nr_initial_guess(s1_33);
          rs2_11 <= nr_initial_guess(s2_11);
          rs2_22 <= nr_initial_guess(s2_22);
          rs2_33 <= nr_initial_guess(s2_33);
          rs3_11 <= nr_initial_guess(s3_11);
          rs3_22 <= nr_initial_guess(s3_22);
          rs3_33 <= nr_initial_guess(s3_33);
          nr_iter <= 0;
          state <= COMPUTE_S_RECIP;

        when COMPUTE_S_RECIP =>

          if nr_iter < 6 then

            prod96 := s1_11 * rs1_11;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs1_11 * div_result;
            rs1_11 <= resize(shift_right(prod96, Q), 48);

            prod96 := s1_22 * rs1_22;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs1_22 * div_result;
            rs1_22 <= resize(shift_right(prod96, Q), 48);

            prod96 := s1_33 * rs1_33;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs1_33 * div_result;
            rs1_33 <= resize(shift_right(prod96, Q), 48);

            prod96 := s2_11 * rs2_11;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs2_11 * div_result;
            rs2_11 <= resize(shift_right(prod96, Q), 48);

            prod96 := s2_22 * rs2_22;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs2_22 * div_result;
            rs2_22 <= resize(shift_right(prod96, Q), 48);

            prod96 := s2_33 * rs2_33;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs2_33 * div_result;
            rs2_33 <= resize(shift_right(prod96, Q), 48);

            prod96 := s3_11 * rs3_11;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs3_11 * div_result;
            rs3_11 <= resize(shift_right(prod96, Q), 48);

            prod96 := s3_22 * rs3_22;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs3_22 * div_result;
            rs3_22 <= resize(shift_right(prod96, Q), 48);

            prod96 := s3_33 * rs3_33;
            div_result := to_signed(2 * (2**Q), 48) - resize(shift_right(prod96, Q), 48);
            prod96 := rs3_33 * div_result;
            rs3_33 <= resize(shift_right(prod96, Q), 48);

            nr_iter <= nr_iter + 1;
          else
            state <= APPLY_S_INV;
          end if;

        when APPLY_S_INV =>

          prod96 := nu1_x_sq * rs1_11;
          nu_sq_sum := resize(shift_right(prod96, Q), 48);
          prod96 := nu1_y_sq * rs1_22;
          nu_sq_sum := nu_sq_sum + resize(shift_right(prod96, Q), 48);
          prod96 := nu1_z_sq * rs1_33;
          mahal1 <= nu_sq_sum + resize(shift_right(prod96, Q), 48);

          prod96 := nu2_x_sq * rs2_11;
          nu_sq_sum := resize(shift_right(prod96, Q), 48);
          prod96 := nu2_y_sq * rs2_22;
          nu_sq_sum := nu_sq_sum + resize(shift_right(prod96, Q), 48);
          prod96 := nu2_z_sq * rs2_33;
          mahal2 <= nu_sq_sum + resize(shift_right(prod96, Q), 48);

          prod96 := nu3_x_sq * rs3_11;
          nu_sq_sum := resize(shift_right(prod96, Q), 48);
          prod96 := nu3_y_sq * rs3_22;
          nu_sq_sum := nu_sq_sum + resize(shift_right(prod96, Q), 48);
          prod96 := nu3_z_sq * rs3_33;
          mahal3 <= nu_sq_sum + resize(shift_right(prod96, Q), 48);

          log_accum <= (others => '0');
          log_step <= 0;
          log_in <= s1_11;
          log_start <= '1';
          state <= START_LOG1;

        when START_LOG1 =>
          log_start <= '0';
          state <= WAIT_LOG1;

        when WAIT_LOG1 =>
          if log_done = '1' then
            log_accum <= log_accum + log_out_sig;
            case log_step is
              when 0 =>
                log_in <= s1_22;
                log_start <= '1';
                log_step <= 1;
                state <= START_LOG1;
              when 1 =>
                log_in <= s1_33;
                log_start <= '1';
                log_step <= 2;
                state <= START_LOG1;
              when 2 =>
                logdet1 <= log_accum + log_out_sig;
                log_accum <= (others => '0');
                log_step <= 0;
                log_in <= s2_11;
                log_start <= '1';
                state <= START_LOG2;
              when others => null;
            end case;
          end if;

        when START_LOG2 =>
          log_start <= '0';
          state <= WAIT_LOG2;

        when WAIT_LOG2 =>
          if log_done = '1' then
            log_accum <= log_accum + log_out_sig;
            case log_step is
              when 0 =>
                log_in <= s2_22;
                log_start <= '1';
                log_step <= 1;
                state <= START_LOG2;
              when 1 =>
                log_in <= s2_33;
                log_start <= '1';
                log_step <= 2;
                state <= START_LOG2;
              when 2 =>
                logdet2 <= log_accum + log_out_sig;
                log_accum <= (others => '0');
                log_step <= 0;
                log_in <= s3_11;
                log_start <= '1';
                state <= START_LOG3;
              when others => null;
            end case;
          end if;

        when START_LOG3 =>
          log_start <= '0';
          state <= WAIT_LOG3;

        when WAIT_LOG3 =>
          if log_done = '1' then
            log_accum <= log_accum + log_out_sig;
            case log_step is
              when 0 =>
                log_in <= s3_22;
                log_start <= '1';
                log_step <= 1;
                state <= START_LOG3;
              when 1 =>
                log_in <= s3_33;
                log_start <= '1';
                log_step <= 2;
                state <= START_LOG3;
              when 2 =>
                logdet3 <= log_accum + log_out_sig;
                state <= COMPUTE_LOGLIK;
              when others => null;
            end case;
          end if;

        when COMPUTE_LOGLIK =>

          prod96 := NEG_HALF * (mahal1 + logdet1);
          logL1 <= resize(shift_right(prod96, Q), 48);
          prod96 := NEG_HALF * (mahal2 + logdet2);
          logL2 <= resize(shift_right(prod96, Q), 48);
          prod96 := NEG_HALF * (mahal3 + logdet3);
          logL3 <= resize(shift_right(prod96, Q), 48);
          state <= MAX_SUBTRACT;

        when MAX_SUBTRACT =>

          max_logL <= logL1;
          if logL2 > logL1 then max_logL <= logL2; end if;
          if logL3 > logL1 and logL3 > logL2 then max_logL <= logL3; end if;
          state <= START_EXP1;

        when START_EXP1 =>
          exp_in <= logL1 - max_logL;
          exp_start <= '1';
          state <= WAIT_EXP1;

        when WAIT_EXP1 =>
          exp_start <= '0';
          if exp_done = '1' then
            L1_out <= exp_out_sig;
            exp_in <= logL2 - max_logL;
            exp_start <= '1';
            state <= WAIT_EXP2;
          end if;

        when WAIT_EXP2 =>
          exp_start <= '0';
          if exp_done = '1' then
            L2_out <= exp_out_sig;
            exp_in <= logL3 - max_logL;
            exp_start <= '1';
            state <= WAIT_EXP3;
          end if;

        when WAIT_EXP3 =>
          exp_start <= '0';
          if exp_done = '1' then
            L3_out <= exp_out_sig;
            state <= OUTPUT;
          end if;

        when OUTPUT =>
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

      end case;
    end if;
  end process;

end Behavioral;
