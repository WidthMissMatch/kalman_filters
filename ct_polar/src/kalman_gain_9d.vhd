library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity kalman_gain_9d is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    pxz_11, pxz_12, pxz_13 : in signed(47 downto 0);
    pxz_21, pxz_22, pxz_23 : in signed(47 downto 0);
    pxz_31, pxz_32, pxz_33 : in signed(47 downto 0);
    pxz_41, pxz_42, pxz_43 : in signed(47 downto 0);
    pxz_51, pxz_52, pxz_53 : in signed(47 downto 0);
    pxz_61, pxz_62, pxz_63 : in signed(47 downto 0);
    pxz_71, pxz_72, pxz_73 : in signed(47 downto 0);
    pxz_81, pxz_82, pxz_83 : in signed(47 downto 0);
    pxz_91, pxz_92, pxz_93 : in signed(47 downto 0);

    s11, s12, s22, s13, s23, s33 : in signed(47 downto 0);

    k11, k12, k13 : buffer signed(47 downto 0);
    k21, k22, k23 : buffer signed(47 downto 0);
    k31, k32, k33 : buffer signed(47 downto 0);
    k41, k42, k43 : buffer signed(47 downto 0);
    k51, k52, k53 : buffer signed(47 downto 0);
    k61, k62, k63 : buffer signed(47 downto 0);
    k71, k72, k73 : buffer signed(47 downto 0);
    k81, k82, k83 : buffer signed(47 downto 0);
    k91, k92, k93 : buffer signed(47 downto 0);

    error : out std_logic;
    done  : out std_logic
  );
end entity;

architecture Behavioral of kalman_gain_9d is

  component matrix_inverse_3x3 is
    port (
      clk     : in  std_logic;
      start   : in  std_logic;
      s11_in, s12_in, s22_in : in signed(47 downto 0);
      s13_in, s23_in, s33_in : in signed(47 downto 0);
      s11_inv_out, s12_inv_out, s22_inv_out : out signed(47 downto 0);
      s13_inv_out, s23_inv_out, s33_inv_out : out signed(47 downto 0);
      singular_error : out std_logic;
      done    : out std_logic
    );
  end component;

  type state_type is (IDLE, INVERT_S, LATCH_S_INV, MULTIPLY, NORMALIZE, ERROR_STATE, FINISHED);
  signal state : state_type := IDLE;

  constant Q : integer := 24;

  signal sinv_11, sinv_12, sinv_22, sinv_13, sinv_23, sinv_33 : signed(47 downto 0);
  signal sinv_done, sinv_error : std_logic;
  signal sinv_start : std_logic := '0';

  signal si11, si12, si22, si13, si23, si33 : signed(47 downto 0);

  type k_int_array is array(1 to 9, 1 to 3) of signed(95 downto 0);
  signal k_int : k_int_array;

  function dot3(p1, p2, p3, s1, s2, s3 : signed(47 downto 0)) return signed is
    variable prod : signed(95 downto 0);
  begin
    prod := p1 * s1 + p2 * s2 + p3 * s3;
    return prod;
  end function;

begin

  inv_inst : matrix_inverse_3x3
    port map (
      clk     => clk,
      start   => sinv_start,
      s11_in  => s11, s12_in => s12, s22_in => s22,
      s13_in  => s13, s23_in => s23, s33_in => s33,
      s11_inv_out => sinv_11, s12_inv_out => sinv_12, s22_inv_out => sinv_22,
      s13_inv_out => sinv_13, s23_inv_out => sinv_23, s33_inv_out => sinv_33,
      singular_error => sinv_error,
      done    => sinv_done
    );

  process(clk)
    variable k_val : signed(95 downto 0);
    variable k_sat : signed(47 downto 0);
    constant K_MAX : signed(47 downto 0) := to_signed(16777216, 48);
    constant K_MIN : signed(47 downto 0) := to_signed(-16777216, 48);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          error <= '0';
          sinv_start <= '0';
          if start = '1' then
            sinv_start <= '1';
            state <= INVERT_S;
          end if;

        when INVERT_S =>
          sinv_start <= '0';
          if sinv_done = '1' then
            if sinv_error = '1' then
              state <= ERROR_STATE;
            else
              state <= LATCH_S_INV;
            end if;
          end if;

        when LATCH_S_INV =>

          si11 <= sinv_11; si12 <= sinv_12; si22 <= sinv_22;
          si13 <= sinv_13; si23 <= sinv_23; si33 <= sinv_33;
          state <= MULTIPLY;

        when MULTIPLY =>

          k_int(1,1) <= dot3(pxz_11, pxz_12, pxz_13, si11, si12, si13);
          k_int(1,2) <= dot3(pxz_11, pxz_12, pxz_13, si12, si22, si23);
          k_int(1,3) <= dot3(pxz_11, pxz_12, pxz_13, si13, si23, si33);

          k_int(2,1) <= dot3(pxz_21, pxz_22, pxz_23, si11, si12, si13);
          k_int(2,2) <= dot3(pxz_21, pxz_22, pxz_23, si12, si22, si23);
          k_int(2,3) <= dot3(pxz_21, pxz_22, pxz_23, si13, si23, si33);

          k_int(3,1) <= dot3(pxz_31, pxz_32, pxz_33, si11, si12, si13);
          k_int(3,2) <= dot3(pxz_31, pxz_32, pxz_33, si12, si22, si23);
          k_int(3,3) <= dot3(pxz_31, pxz_32, pxz_33, si13, si23, si33);

          k_int(4,1) <= dot3(pxz_41, pxz_42, pxz_43, si11, si12, si13);
          k_int(4,2) <= dot3(pxz_41, pxz_42, pxz_43, si12, si22, si23);
          k_int(4,3) <= dot3(pxz_41, pxz_42, pxz_43, si13, si23, si33);

          k_int(5,1) <= dot3(pxz_51, pxz_52, pxz_53, si11, si12, si13);
          k_int(5,2) <= dot3(pxz_51, pxz_52, pxz_53, si12, si22, si23);
          k_int(5,3) <= dot3(pxz_51, pxz_52, pxz_53, si13, si23, si33);

          k_int(6,1) <= dot3(pxz_61, pxz_62, pxz_63, si11, si12, si13);
          k_int(6,2) <= dot3(pxz_61, pxz_62, pxz_63, si12, si22, si23);
          k_int(6,3) <= dot3(pxz_61, pxz_62, pxz_63, si13, si23, si33);

          k_int(7,1) <= dot3(pxz_71, pxz_72, pxz_73, si11, si12, si13);
          k_int(7,2) <= dot3(pxz_71, pxz_72, pxz_73, si12, si22, si23);
          k_int(7,3) <= dot3(pxz_71, pxz_72, pxz_73, si13, si23, si33);

          k_int(8,1) <= dot3(pxz_81, pxz_82, pxz_83, si11, si12, si13);
          k_int(8,2) <= dot3(pxz_81, pxz_82, pxz_83, si12, si22, si23);
          k_int(8,3) <= dot3(pxz_81, pxz_82, pxz_83, si13, si23, si33);

          k_int(9,1) <= dot3(pxz_91, pxz_92, pxz_93, si11, si12, si13);
          k_int(9,2) <= dot3(pxz_91, pxz_92, pxz_93, si12, si22, si23);
          k_int(9,3) <= dot3(pxz_91, pxz_92, pxz_93, si13, si23, si33);

          state <= NORMALIZE;

        when NORMALIZE =>

          k11 <= resize(shift_right(k_int(1,1), Q), 48);
          k12 <= resize(shift_right(k_int(1,2), Q), 48);
          k13 <= resize(shift_right(k_int(1,3), Q), 48);
          k21 <= resize(shift_right(k_int(2,1), Q), 48);
          k22 <= resize(shift_right(k_int(2,2), Q), 48);
          k23 <= resize(shift_right(k_int(2,3), Q), 48);
          k31 <= resize(shift_right(k_int(3,1), Q), 48);
          k32 <= resize(shift_right(k_int(3,2), Q), 48);
          k33 <= resize(shift_right(k_int(3,3), Q), 48);
          k41 <= resize(shift_right(k_int(4,1), Q), 48);
          k42 <= resize(shift_right(k_int(4,2), Q), 48);
          k43 <= resize(shift_right(k_int(4,3), Q), 48);
          k51 <= resize(shift_right(k_int(5,1), Q), 48);
          k52 <= resize(shift_right(k_int(5,2), Q), 48);
          k53 <= resize(shift_right(k_int(5,3), Q), 48);
          k61 <= resize(shift_right(k_int(6,1), Q), 48);
          k62 <= resize(shift_right(k_int(6,2), Q), 48);
          k63 <= resize(shift_right(k_int(6,3), Q), 48);
          k71 <= resize(shift_right(k_int(7,1), Q), 48);
          k72 <= resize(shift_right(k_int(7,2), Q), 48);
          k73 <= resize(shift_right(k_int(7,3), Q), 48);
          k81 <= resize(shift_right(k_int(8,1), Q), 48);
          k82 <= resize(shift_right(k_int(8,2), Q), 48);
          k83 <= resize(shift_right(k_int(8,3), Q), 48);
          k91 <= resize(shift_right(k_int(9,1), Q), 48);
          k92 <= resize(shift_right(k_int(9,2), Q), 48);
          k93 <= resize(shift_right(k_int(9,3), Q), 48);
          state <= FINISHED;

        when ERROR_STATE =>
          error <= '1';
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

        when FINISHED =>
          done <= '1';
          if start = '0' then
            state <= IDLE;
          end if;

        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

end Behavioral;
