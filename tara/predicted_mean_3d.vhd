library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity predicted_mean_3d is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    start       : in  std_logic;
    chi0_x_pos_pred : in signed(47 downto 0);
    chi0_x_vel_pred : in signed(47 downto 0);
    chi0_y_pos_pred : in signed(47 downto 0);
    chi0_y_vel_pred : in signed(47 downto 0);
    chi0_z_pos_pred : in signed(47 downto 0);
    chi0_z_vel_pred : in signed(47 downto 0);
    chi1_x_pos_pred, chi1_x_vel_pred, chi1_y_pos_pred, chi1_y_vel_pred, chi1_z_pos_pred, chi1_z_vel_pred : in signed(47 downto 0);
    chi2_x_pos_pred, chi2_x_vel_pred, chi2_y_pos_pred, chi2_y_vel_pred, chi2_z_pos_pred, chi2_z_vel_pred : in signed(47 downto 0);
    chi3_x_pos_pred, chi3_x_vel_pred, chi3_y_pos_pred, chi3_y_vel_pred, chi3_z_pos_pred, chi3_z_vel_pred : in signed(47 downto 0);
    chi4_x_pos_pred, chi4_x_vel_pred, chi4_y_pos_pred, chi4_y_vel_pred, chi4_z_pos_pred, chi4_z_vel_pred : in signed(47 downto 0);
    chi5_x_pos_pred, chi5_x_vel_pred, chi5_y_pos_pred, chi5_y_vel_pred, chi5_z_pos_pred, chi5_z_vel_pred : in signed(47 downto 0);
    chi6_x_pos_pred, chi6_x_vel_pred, chi6_y_pos_pred, chi6_y_vel_pred, chi6_z_pos_pred, chi6_z_vel_pred : in signed(47 downto 0);
    chi7_x_pos_pred, chi7_x_vel_pred, chi7_y_pos_pred, chi7_y_vel_pred, chi7_z_pos_pred, chi7_z_vel_pred : in signed(47 downto 0);
    chi8_x_pos_pred, chi8_x_vel_pred, chi8_y_pos_pred, chi8_y_vel_pred, chi8_z_pos_pred, chi8_z_vel_pred : in signed(47 downto 0);
    chi9_x_pos_pred, chi9_x_vel_pred, chi9_y_pos_pred, chi9_y_vel_pred, chi9_z_pos_pred, chi9_z_vel_pred : in signed(47 downto 0);
    chi10_x_pos_pred, chi10_x_vel_pred, chi10_y_pos_pred, chi10_y_vel_pred, chi10_z_pos_pred, chi10_z_vel_pred : in signed(47 downto 0);
    chi11_x_pos_pred, chi11_x_vel_pred, chi11_y_pos_pred, chi11_y_vel_pred, chi11_z_pos_pred, chi11_z_vel_pred : in signed(47 downto 0);
    chi12_x_pos_pred, chi12_x_vel_pred, chi12_y_pos_pred, chi12_y_vel_pred, chi12_z_pos_pred, chi12_z_vel_pred : in signed(47 downto 0);
    x_pos_mean_pred : out signed(47 downto 0);
    x_vel_mean_pred : out signed(47 downto 0);
    y_pos_mean_pred : out signed(47 downto 0);
    y_vel_mean_pred : out signed(47 downto 0);
    z_pos_mean_pred : out signed(47 downto 0);
    z_vel_mean_pred : out signed(47 downto 0);
    done        : out std_logic
  );
end entity;
architecture Behavioral of predicted_mean_3d is
  constant W0 : signed(47 downto 0) := to_signed(5592405, 48);
  constant W1 : signed(47 downto 0) := to_signed(932068, 48);
  constant Q : integer := 24;
  type state_type is (IDLE, MULTIPLY, ACCUMULATE, OUTPUT, FINISHED);
  signal state : state_type := IDLE;
  signal w_chi0_xp, w_chi1_xp, w_chi2_xp, w_chi3_xp, w_chi4_xp, w_chi5_xp, w_chi6_xp : signed(95 downto 0) := (others => '0');
  signal w_chi7_xp, w_chi8_xp, w_chi9_xp, w_chi10_xp, w_chi11_xp, w_chi12_xp : signed(95 downto 0) := (others => '0');
  signal w_chi0_xv, w_chi1_xv, w_chi2_xv, w_chi3_xv, w_chi4_xv, w_chi5_xv, w_chi6_xv : signed(95 downto 0) := (others => '0');
  signal w_chi7_xv, w_chi8_xv, w_chi9_xv, w_chi10_xv, w_chi11_xv, w_chi12_xv : signed(95 downto 0) := (others => '0');
  signal w_chi0_yp, w_chi1_yp, w_chi2_yp, w_chi3_yp, w_chi4_yp, w_chi5_yp, w_chi6_yp : signed(95 downto 0) := (others => '0');
  signal w_chi7_yp, w_chi8_yp, w_chi9_yp, w_chi10_yp, w_chi11_yp, w_chi12_yp : signed(95 downto 0) := (others => '0');
  signal w_chi0_yv, w_chi1_yv, w_chi2_yv, w_chi3_yv, w_chi4_yv, w_chi5_yv, w_chi6_yv : signed(95 downto 0) := (others => '0');
  signal w_chi7_yv, w_chi8_yv, w_chi9_yv, w_chi10_yv, w_chi11_yv, w_chi12_yv : signed(95 downto 0) := (others => '0');
  signal w_chi0_zp, w_chi1_zp, w_chi2_zp, w_chi3_zp, w_chi4_zp, w_chi5_zp, w_chi6_zp : signed(95 downto 0) := (others => '0');
  signal w_chi7_zp, w_chi8_zp, w_chi9_zp, w_chi10_zp, w_chi11_zp, w_chi12_zp : signed(95 downto 0) := (others => '0');
  signal w_chi0_zv, w_chi1_zv, w_chi2_zv, w_chi3_zv, w_chi4_zv, w_chi5_zv, w_chi6_zv : signed(95 downto 0) := (others => '0');
  signal w_chi7_zv, w_chi8_zv, w_chi9_zv, w_chi10_zv, w_chi11_zv, w_chi12_zv : signed(95 downto 0) := (others => '0');
  signal sum_xp, sum_xv, sum_yp, sum_yv, sum_zp, sum_zv : signed(43 downto 0) := (others => '0');
  signal x_pos_mean_int, x_vel_mean_int, y_pos_mean_int, y_vel_mean_int, z_pos_mean_int, z_vel_mean_int : signed(47 downto 0) := (others => '0');
begin
  process(clk, rst)
    variable temp_xp, temp_xv, temp_yp, temp_yv, temp_zp, temp_zv : signed(43 downto 0);
  begin
    if rst = '1' then
      state <= IDLE;
      done <= '0';
      sum_xp <= (others => '0'); sum_xv <= (others => '0');
      sum_yp <= (others => '0'); sum_yv <= (others => '0');
      sum_zp <= (others => '0'); sum_zv <= (others => '0');
      x_pos_mean_int <= (others => '0'); x_vel_mean_int <= (others => '0');
      y_pos_mean_int <= (others => '0'); y_vel_mean_int <= (others => '0');
      z_pos_mean_int <= (others => '0'); z_vel_mean_int <= (others => '0');
      w_chi0_xp <= (others => '0'); w_chi1_xp <= (others => '0'); w_chi2_xp <= (others => '0'); w_chi3_xp <= (others => '0');
      w_chi4_xp <= (others => '0'); w_chi5_xp <= (others => '0'); w_chi6_xp <= (others => '0'); w_chi7_xp <= (others => '0');
      w_chi8_xp <= (others => '0'); w_chi9_xp <= (others => '0'); w_chi10_xp <= (others => '0'); w_chi11_xp <= (others => '0'); w_chi12_xp <= (others => '0');
      w_chi0_xv <= (others => '0'); w_chi1_xv <= (others => '0'); w_chi2_xv <= (others => '0'); w_chi3_xv <= (others => '0');
      w_chi4_xv <= (others => '0'); w_chi5_xv <= (others => '0'); w_chi6_xv <= (others => '0'); w_chi7_xv <= (others => '0');
      w_chi8_xv <= (others => '0'); w_chi9_xv <= (others => '0'); w_chi10_xv <= (others => '0'); w_chi11_xv <= (others => '0'); w_chi12_xv <= (others => '0');
      w_chi0_yp <= (others => '0'); w_chi1_yp <= (others => '0'); w_chi2_yp <= (others => '0'); w_chi3_yp <= (others => '0');
      w_chi4_yp <= (others => '0'); w_chi5_yp <= (others => '0'); w_chi6_yp <= (others => '0'); w_chi7_yp <= (others => '0');
      w_chi8_yp <= (others => '0'); w_chi9_yp <= (others => '0'); w_chi10_yp <= (others => '0'); w_chi11_yp <= (others => '0'); w_chi12_yp <= (others => '0');
      w_chi0_yv <= (others => '0'); w_chi1_yv <= (others => '0'); w_chi2_yv <= (others => '0'); w_chi3_yv <= (others => '0');
      w_chi4_yv <= (others => '0'); w_chi5_yv <= (others => '0'); w_chi6_yv <= (others => '0'); w_chi7_yv <= (others => '0');
      w_chi8_yv <= (others => '0'); w_chi9_yv <= (others => '0'); w_chi10_yv <= (others => '0'); w_chi11_yv <= (others => '0'); w_chi12_yv <= (others => '0');
      w_chi0_zp <= (others => '0'); w_chi1_zp <= (others => '0'); w_chi2_zp <= (others => '0'); w_chi3_zp <= (others => '0');
      w_chi4_zp <= (others => '0'); w_chi5_zp <= (others => '0'); w_chi6_zp <= (others => '0'); w_chi7_zp <= (others => '0');
      w_chi8_zp <= (others => '0'); w_chi9_zp <= (others => '0'); w_chi10_zp <= (others => '0'); w_chi11_zp <= (others => '0'); w_chi12_zp <= (others => '0');
      w_chi0_zv <= (others => '0'); w_chi1_zv <= (others => '0'); w_chi2_zv <= (others => '0'); w_chi3_zv <= (others => '0');
      w_chi4_zv <= (others => '0'); w_chi5_zv <= (others => '0'); w_chi6_zv <= (others => '0'); w_chi7_zv <= (others => '0');
      w_chi8_zv <= (others => '0'); w_chi9_zv <= (others => '0'); w_chi10_zv <= (others => '0'); w_chi11_zv <= (others => '0'); w_chi12_zv <= (others => '0');
    elsif rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then
            state <= MULTIPLY;
          end if;
        when MULTIPLY =>
          report "PREDICTED_MEAN_3D: MULTIPLY state" & LF &
                 "  chi0_x_pos_pred=" & integer'image(to_integer(chi0_x_pos_pred)) & LF &
                 "  chi1_x_pos_pred=" & integer'image(to_integer(chi1_x_pos_pred));
          w_chi0_xp <= W0 * chi0_x_pos_pred;
          w_chi1_xp <= W1 * chi1_x_pos_pred; w_chi2_xp <= W1 * chi2_x_pos_pred; w_chi3_xp <= W1 * chi3_x_pos_pred;
          w_chi4_xp <= W1 * chi4_x_pos_pred; w_chi5_xp <= W1 * chi5_x_pos_pred; w_chi6_xp <= W1 * chi6_x_pos_pred;
          w_chi7_xp <= W1 * chi7_x_pos_pred; w_chi8_xp <= W1 * chi8_x_pos_pred; w_chi9_xp <= W1 * chi9_x_pos_pred;
          w_chi10_xp <= W1 * chi10_x_pos_pred; w_chi11_xp <= W1 * chi11_x_pos_pred; w_chi12_xp <= W1 * chi12_x_pos_pred;
          w_chi0_xv <= W0 * chi0_x_vel_pred;
          w_chi1_xv <= W1 * chi1_x_vel_pred; w_chi2_xv <= W1 * chi2_x_vel_pred; w_chi3_xv <= W1 * chi3_x_vel_pred;
          w_chi4_xv <= W1 * chi4_x_vel_pred; w_chi5_xv <= W1 * chi5_x_vel_pred; w_chi6_xv <= W1 * chi6_x_vel_pred;
          w_chi7_xv <= W1 * chi7_x_vel_pred; w_chi8_xv <= W1 * chi8_x_vel_pred; w_chi9_xv <= W1 * chi9_x_vel_pred;
          w_chi10_xv <= W1 * chi10_x_vel_pred; w_chi11_xv <= W1 * chi11_x_vel_pred; w_chi12_xv <= W1 * chi12_x_vel_pred;
          w_chi0_yp <= W0 * chi0_y_pos_pred;
          w_chi1_yp <= W1 * chi1_y_pos_pred; w_chi2_yp <= W1 * chi2_y_pos_pred; w_chi3_yp <= W1 * chi3_y_pos_pred;
          w_chi4_yp <= W1 * chi4_y_pos_pred; w_chi5_yp <= W1 * chi5_y_pos_pred; w_chi6_yp <= W1 * chi6_y_pos_pred;
          w_chi7_yp <= W1 * chi7_y_pos_pred; w_chi8_yp <= W1 * chi8_y_pos_pred; w_chi9_yp <= W1 * chi9_y_pos_pred;
          w_chi10_yp <= W1 * chi10_y_pos_pred; w_chi11_yp <= W1 * chi11_y_pos_pred; w_chi12_yp <= W1 * chi12_y_pos_pred;
          w_chi0_yv <= W0 * chi0_y_vel_pred;
          w_chi1_yv <= W1 * chi1_y_vel_pred; w_chi2_yv <= W1 * chi2_y_vel_pred; w_chi3_yv <= W1 * chi3_y_vel_pred;
          w_chi4_yv <= W1 * chi4_y_vel_pred; w_chi5_yv <= W1 * chi5_y_vel_pred; w_chi6_yv <= W1 * chi6_y_vel_pred;
          w_chi7_yv <= W1 * chi7_y_vel_pred; w_chi8_yv <= W1 * chi8_y_vel_pred; w_chi9_yv <= W1 * chi9_y_vel_pred;
          w_chi10_yv <= W1 * chi10_y_vel_pred; w_chi11_yv <= W1 * chi11_y_vel_pred; w_chi12_yv <= W1 * chi12_y_vel_pred;
          w_chi0_zp <= W0 * chi0_z_pos_pred;
          w_chi1_zp <= W1 * chi1_z_pos_pred; w_chi2_zp <= W1 * chi2_z_pos_pred; w_chi3_zp <= W1 * chi3_z_pos_pred;
          w_chi4_zp <= W1 * chi4_z_pos_pred; w_chi5_zp <= W1 * chi5_z_pos_pred; w_chi6_zp <= W1 * chi6_z_pos_pred;
          w_chi7_zp <= W1 * chi7_z_pos_pred; w_chi8_zp <= W1 * chi8_z_pos_pred; w_chi9_zp <= W1 * chi9_z_pos_pred;
          w_chi10_zp <= W1 * chi10_z_pos_pred; w_chi11_zp <= W1 * chi11_z_pos_pred; w_chi12_zp <= W1 * chi12_z_pos_pred;
          w_chi0_zv <= W0 * chi0_z_vel_pred;
          w_chi1_zv <= W1 * chi1_z_vel_pred; w_chi2_zv <= W1 * chi2_z_vel_pred; w_chi3_zv <= W1 * chi3_z_vel_pred;
          w_chi4_zv <= W1 * chi4_z_vel_pred; w_chi5_zv <= W1 * chi5_z_vel_pred; w_chi6_zv <= W1 * chi6_z_vel_pred;
          w_chi7_zv <= W1 * chi7_z_vel_pred; w_chi8_zv <= W1 * chi8_z_vel_pred; w_chi9_zv <= W1 * chi9_z_vel_pred;
          w_chi10_zv <= W1 * chi10_z_vel_pred; w_chi11_zv <= W1 * chi11_z_vel_pred; w_chi12_zv <= W1 * chi12_z_vel_pred;
          state <= ACCUMULATE;
        when ACCUMULATE =>
          temp_xp := resize(shift_right(w_chi0_xp, Q), 44) +
                     resize(shift_right(w_chi1_xp, Q), 44) + resize(shift_right(w_chi2_xp, Q), 44) + resize(shift_right(w_chi3_xp, Q), 44) +
                     resize(shift_right(w_chi4_xp, Q), 44) + resize(shift_right(w_chi5_xp, Q), 44) + resize(shift_right(w_chi6_xp, Q), 44) +
                     resize(shift_right(w_chi7_xp, Q), 44) + resize(shift_right(w_chi8_xp, Q), 44) + resize(shift_right(w_chi9_xp, Q), 44) +
                     resize(shift_right(w_chi10_xp, Q), 44) + resize(shift_right(w_chi11_xp, Q), 44) + resize(shift_right(w_chi12_xp, Q), 44);
          temp_xv := resize(shift_right(w_chi0_xv, Q), 44) +
                     resize(shift_right(w_chi1_xv, Q), 44) + resize(shift_right(w_chi2_xv, Q), 44) + resize(shift_right(w_chi3_xv, Q), 44) +
                     resize(shift_right(w_chi4_xv, Q), 44) + resize(shift_right(w_chi5_xv, Q), 44) + resize(shift_right(w_chi6_xv, Q), 44) +
                     resize(shift_right(w_chi7_xv, Q), 44) + resize(shift_right(w_chi8_xv, Q), 44) + resize(shift_right(w_chi9_xv, Q), 44) +
                     resize(shift_right(w_chi10_xv, Q), 44) + resize(shift_right(w_chi11_xv, Q), 44) + resize(shift_right(w_chi12_xv, Q), 44);
          temp_yp := resize(shift_right(w_chi0_yp, Q), 44) +
                     resize(shift_right(w_chi1_yp, Q), 44) + resize(shift_right(w_chi2_yp, Q), 44) + resize(shift_right(w_chi3_yp, Q), 44) +
                     resize(shift_right(w_chi4_yp, Q), 44) + resize(shift_right(w_chi5_yp, Q), 44) + resize(shift_right(w_chi6_yp, Q), 44) +
                     resize(shift_right(w_chi7_yp, Q), 44) + resize(shift_right(w_chi8_yp, Q), 44) + resize(shift_right(w_chi9_yp, Q), 44) +
                     resize(shift_right(w_chi10_yp, Q), 44) + resize(shift_right(w_chi11_yp, Q), 44) + resize(shift_right(w_chi12_yp, Q), 44);
          temp_yv := resize(shift_right(w_chi0_yv, Q), 44) +
                     resize(shift_right(w_chi1_yv, Q), 44) + resize(shift_right(w_chi2_yv, Q), 44) + resize(shift_right(w_chi3_yv, Q), 44) +
                     resize(shift_right(w_chi4_yv, Q), 44) + resize(shift_right(w_chi5_yv, Q), 44) + resize(shift_right(w_chi6_yv, Q), 44) +
                     resize(shift_right(w_chi7_yv, Q), 44) + resize(shift_right(w_chi8_yv, Q), 44) + resize(shift_right(w_chi9_yv, Q), 44) +
                     resize(shift_right(w_chi10_yv, Q), 44) + resize(shift_right(w_chi11_yv, Q), 44) + resize(shift_right(w_chi12_yv, Q), 44);
          temp_zp := resize(shift_right(w_chi0_zp, Q), 44) +
                     resize(shift_right(w_chi1_zp, Q), 44) + resize(shift_right(w_chi2_zp, Q), 44) + resize(shift_right(w_chi3_zp, Q), 44) +
                     resize(shift_right(w_chi4_zp, Q), 44) + resize(shift_right(w_chi5_zp, Q), 44) + resize(shift_right(w_chi6_zp, Q), 44) +
                     resize(shift_right(w_chi7_zp, Q), 44) + resize(shift_right(w_chi8_zp, Q), 44) + resize(shift_right(w_chi9_zp, Q), 44) +
                     resize(shift_right(w_chi10_zp, Q), 44) + resize(shift_right(w_chi11_zp, Q), 44) + resize(shift_right(w_chi12_zp, Q), 44);
          temp_zv := resize(shift_right(w_chi0_zv, Q), 44) +
                     resize(shift_right(w_chi1_zv, Q), 44) + resize(shift_right(w_chi2_zv, Q), 44) + resize(shift_right(w_chi3_zv, Q), 44) +
                     resize(shift_right(w_chi4_zv, Q), 44) + resize(shift_right(w_chi5_zv, Q), 44) + resize(shift_right(w_chi6_zv, Q), 44) +
                     resize(shift_right(w_chi7_zv, Q), 44) + resize(shift_right(w_chi8_zv, Q), 44) + resize(shift_right(w_chi9_zv, Q), 44) +
                     resize(shift_right(w_chi10_zv, Q), 44) + resize(shift_right(w_chi11_zv, Q), 44) + resize(shift_right(w_chi12_zv, Q), 44);
          sum_xp <= temp_xp; sum_xv <= temp_xv;
          sum_yp <= temp_yp; sum_yv <= temp_yv;
          sum_zp <= temp_zp; sum_zv <= temp_zv;
          state <= OUTPUT;
        when OUTPUT =>
          report "PREDICTED_MEAN_3D: OUTPUT state" & LF &
                 "  sum_xp (44-bit)=" & integer'image(to_integer(sum_xp(31 downto 0))) & LF &
                 "  sum_yp (44-bit)=" & integer'image(to_integer(sum_yp(31 downto 0))) & LF &
                 "  sum_zp (44-bit)=" & integer'image(to_integer(sum_zp(31 downto 0)));
          if resize(sum_xp, 48) > to_signed(16#7FFFFFFF#, 48) then
            x_pos_mean_int <= to_signed(16#7FFFFFFF#, 48);
          elsif resize(sum_xp, 48) < to_signed(-16#80000000#, 48) then
            x_pos_mean_int <= to_signed(-16#80000000#, 48);
          else
            x_pos_mean_int <= resize(sum_xp, 48);
          end if;
          if resize(sum_yp, 48) > to_signed(16#7FFFFFFF#, 48) then
            y_pos_mean_int <= to_signed(16#7FFFFFFF#, 48);
          elsif resize(sum_yp, 48) < to_signed(-16#80000000#, 48) then
            y_pos_mean_int <= to_signed(-16#80000000#, 48);
          else
            y_pos_mean_int <= resize(sum_yp, 48);
          end if;
          if resize(sum_zp, 48) > to_signed(16#7FFFFFFF#, 48) then
            z_pos_mean_int <= to_signed(16#7FFFFFFF#, 48);
          elsif resize(sum_zp, 48) < to_signed(-16#80000000#, 48) then
            z_pos_mean_int <= to_signed(-16#80000000#, 48);
          else
            z_pos_mean_int <= resize(sum_zp, 48);
          end if;
          x_vel_mean_int <= resize(sum_xv, 48);
          y_vel_mean_int <= resize(sum_yv, 48);
          z_vel_mean_int <= resize(sum_zv, 48);
          state <= FINISHED;
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
  x_pos_mean_pred <= x_pos_mean_int;
  x_vel_mean_pred <= x_vel_mean_int;
  y_pos_mean_pred <= y_pos_mean_int;
  y_vel_mean_pred <= y_vel_mean_int;
  z_pos_mean_pred <= z_pos_mean_int;
  z_vel_mean_pred <= z_vel_mean_int;
end Behavioral;
