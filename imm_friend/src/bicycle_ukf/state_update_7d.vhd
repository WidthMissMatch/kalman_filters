library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity state_update_7d is
  port (
    clk   : in  std_logic;
    start : in  std_logic;

    s1_pred, s2_pred, s3_pred, s4_pred, s5_pred, s6_pred, s7_pred : in signed(47 downto 0);

    p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred : in signed(47 downto 0);
    p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred : in signed(47 downto 0);
    p33_pred, p34_pred, p35_pred, p36_pred, p37_pred : in signed(47 downto 0);
    p44_pred, p45_pred, p46_pred, p47_pred : in signed(47 downto 0);
    p55_pred, p56_pred, p57_pred : in signed(47 downto 0);
    p66_pred, p67_pred : in signed(47 downto 0);
    p77_pred : in signed(47 downto 0);

    k11, k12, k13 : in signed(47 downto 0);
    k21, k22, k23 : in signed(47 downto 0);
    k31, k32, k33 : in signed(47 downto 0);
    k41, k42, k43 : in signed(47 downto 0);
    k51, k52, k53 : in signed(47 downto 0);
    k61, k62, k63 : in signed(47 downto 0);
    k71, k72, k73 : in signed(47 downto 0);

    nu_1, nu_2, nu_3 : in signed(47 downto 0);

    s1_upd, s2_upd, s3_upd, s4_upd, s5_upd, s6_upd, s7_upd : buffer signed(47 downto 0);

    p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd, p17_upd : buffer signed(47 downto 0);
    p22_upd, p23_upd, p24_upd, p25_upd, p26_upd, p27_upd : buffer signed(47 downto 0);
    p33_upd, p34_upd, p35_upd, p36_upd, p37_upd : buffer signed(47 downto 0);
    p44_upd, p45_upd, p46_upd, p47_upd : buffer signed(47 downto 0);
    p55_upd, p56_upd, p57_upd : buffer signed(47 downto 0);
    p66_upd, p67_upd : buffer signed(47 downto 0);
    p77_upd : buffer signed(47 downto 0);

    done : out std_logic
  );
end entity;

architecture Behavioral of state_update_7d is

  type state_type is (IDLE, UPDATE_STATE, CONSTRUCT_A, COMPUTE_AP,
                      COMPUTE_APAT, COMPUTE_KR, COMPUTE_KRK,
                      ADD_APAT_KRK, FINISHED);
  signal state : state_type := IDLE;

  constant Q : integer := 24;
  constant UNITY : signed(47 downto 0) := to_signed(16777216, 48);
  constant SAFE_MAX_P : signed(47 downto 0) := signed'(x"3FFFFFFFFFFF");

  constant R11 : signed(47 downto 0) := to_signed(4194304, 48);
  constant R22 : signed(47 downto 0) := to_signed(4194304, 48);
  constant R33 : signed(47 downto 0) := to_signed(4194304, 48);

  type a_matrix is array(1 to 7, 1 to 7) of signed(47 downto 0);
  signal a : a_matrix;

  type ap_matrix is array(1 to 7, 1 to 7) of signed(95 downto 0);
  signal ap : ap_matrix;

  type p144_matrix is array(1 to 7, 1 to 7) of signed(143 downto 0);
  signal apat_mat, krk_mat : p144_matrix;

  type kr_matrix is array(1 to 7, 1 to 3) of signed(95 downto 0);
  signal kr : kr_matrix;

  signal kr11, kr12, kr13 : signed(47 downto 0);
  signal kr21, kr22, kr23 : signed(47 downto 0);
  signal kr31, kr32, kr33 : signed(47 downto 0);
  signal kr41, kr42, kr43 : signed(47 downto 0);
  signal kr51, kr52, kr53 : signed(47 downto 0);
  signal kr61, kr62, kr63 : signed(47 downto 0);
  signal kr71, kr72, kr73 : signed(47 downto 0);

  function get_p(r, c : integer;
    p11v, p12v, p13v, p14v, p15v, p16v, p17v,
    p22v, p23v, p24v, p25v, p26v, p27v,
    p33v, p34v, p35v, p36v, p37v,
    p44v, p45v, p46v, p47v,
    p55v, p56v, p57v,
    p66v, p67v,
    p77v : signed(47 downto 0)) return signed is
    variable ri, ci : integer;
  begin

    if r <= c then ri := r; ci := c;
    else ri := c; ci := r;
    end if;
    case ri is
      when 1 =>
        case ci is
          when 1 => return p11v; when 2 => return p12v; when 3 => return p13v;
          when 4 => return p14v; when 5 => return p15v; when 6 => return p16v;
          when others => return p17v;
        end case;
      when 2 =>
        case ci is
          when 2 => return p22v; when 3 => return p23v; when 4 => return p24v;
          when 5 => return p25v; when 6 => return p26v;
          when others => return p27v;
        end case;
      when 3 =>
        case ci is
          when 3 => return p33v; when 4 => return p34v; when 5 => return p35v;
          when 6 => return p36v;
          when others => return p37v;
        end case;
      when 4 =>
        case ci is
          when 4 => return p44v; when 5 => return p45v; when 6 => return p46v;
          when others => return p47v;
        end case;
      when 5 =>
        case ci is
          when 5 => return p55v; when 6 => return p56v;
          when others => return p57v;
        end case;
      when 6 =>
        case ci is
          when 6 => return p66v;
          when others => return p67v;
        end case;
      when others => return p77v;
    end case;
  end function;

  function sat_cov(val : signed(143 downto 0); is_diag : boolean) return signed is
    variable shifted : signed(47 downto 0);
  begin
    shifted := resize(shift_right(val, 2*Q), 48);
    if is_diag then
      if shifted > SAFE_MAX_P then return SAFE_MAX_P;
      elsif shifted < to_signed(0, 48) then return UNITY;
      else return shifted;
      end if;
    else
      return shifted;
    end if;
  end function;

begin

  process(clk)
    variable knu_sum : signed(143 downto 0);
    variable p_val : signed(47 downto 0);
    variable ap_sum : signed(95 downto 0);
    variable apat_sum, krk_sum : signed(143 downto 0);
  begin
    if rising_edge(clk) then
      case state is
        when IDLE =>
          done <= '0';
          if start = '1' then

            kr11 <= k11; kr12 <= k12; kr13 <= k13;
            kr21 <= k21; kr22 <= k22; kr23 <= k23;
            kr31 <= k31; kr32 <= k32; kr33 <= k33;
            kr41 <= k41; kr42 <= k42; kr43 <= k43;
            kr51 <= k51; kr52 <= k52; kr53 <= k53;
            kr61 <= k61; kr62 <= k62; kr63 <= k63;
            kr71 <= k71; kr72 <= k72; kr73 <= k73;
            state <= UPDATE_STATE;
          end if;

        when UPDATE_STATE =>

          knu_sum := resize(kr11 * nu_1, 144) + resize(kr12 * nu_2, 144) + resize(kr13 * nu_3, 144);
          s1_upd <= s1_pred + resize(shift_right(knu_sum, Q), 48);

          knu_sum := resize(kr21 * nu_1, 144) + resize(kr22 * nu_2, 144) + resize(kr23 * nu_3, 144);
          s2_upd <= s2_pred + resize(shift_right(knu_sum, Q), 48);

          knu_sum := resize(kr31 * nu_1, 144) + resize(kr32 * nu_2, 144) + resize(kr33 * nu_3, 144);
          s3_upd <= s3_pred + resize(shift_right(knu_sum, Q), 48);

          knu_sum := resize(kr41 * nu_1, 144) + resize(kr42 * nu_2, 144) + resize(kr43 * nu_3, 144);
          s4_upd <= s4_pred + resize(shift_right(knu_sum, Q), 48);

          knu_sum := resize(kr51 * nu_1, 144) + resize(kr52 * nu_2, 144) + resize(kr53 * nu_3, 144);
          s5_upd <= s5_pred + resize(shift_right(knu_sum, Q), 48);

          knu_sum := resize(kr61 * nu_1, 144) + resize(kr62 * nu_2, 144) + resize(kr63 * nu_3, 144);
          s6_upd <= s6_pred + resize(shift_right(knu_sum, Q), 48);

          knu_sum := resize(kr71 * nu_1, 144) + resize(kr72 * nu_2, 144) + resize(kr73 * nu_3, 144);
          s7_upd <= s7_pred + resize(shift_right(knu_sum, Q), 48);

          state <= CONSTRUCT_A;

        when CONSTRUCT_A =>

          for r in 1 to 7 loop
            for c in 1 to 7 loop
              if r = c then
                a(r,c) <= UNITY;
              else
                a(r,c) <= (others => '0');
              end if;
            end loop;
          end loop;

          a(1,1) <= UNITY - kr11;
          a(2,1) <= -kr21;
          a(3,1) <= -kr31;
          a(4,1) <= -kr41;
          a(5,1) <= -kr51;
          a(6,1) <= -kr61;
          a(7,1) <= -kr71;

          a(1,2) <= -kr12;
          a(2,2) <= UNITY - kr22;
          a(3,2) <= -kr32;
          a(4,2) <= -kr42;
          a(5,2) <= -kr52;
          a(6,2) <= -kr62;
          a(7,2) <= -kr72;

          a(1,7) <= -kr13;
          a(2,7) <= -kr23;
          a(3,7) <= -kr33;
          a(4,7) <= -kr43;
          a(5,7) <= -kr53;
          a(6,7) <= -kr63;
          a(7,7) <= UNITY - kr73;

          state <= COMPUTE_AP;

        when COMPUTE_AP =>

          for r in 1 to 7 loop
            for c in 1 to 7 loop
              ap_sum := (others => '0');
              for k in 1 to 7 loop
                p_val := get_p(k, c,
                  p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred,
                  p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred,
                  p33_pred, p34_pred, p35_pred, p36_pred, p37_pred,
                  p44_pred, p45_pred, p46_pred, p47_pred,
                  p55_pred, p56_pred, p57_pred,
                  p66_pred, p67_pred,
                  p77_pred);
                ap_sum := ap_sum + a(r,k) * p_val;
              end loop;
              ap(r,c) <= ap_sum;
            end loop;
          end loop;
          state <= COMPUTE_APAT;

        when COMPUTE_APAT =>

          for r in 1 to 7 loop
            for c in r to 7 loop
              apat_sum := (others => '0');
              for k in 1 to 7 loop
                apat_sum := apat_sum + ap(r,k) * a(c,k);
              end loop;
              apat_mat(r,c) <= apat_sum;
              if r /= c then
                apat_mat(c,r) <= apat_sum;
              end if;
            end loop;
          end loop;
          state <= COMPUTE_KR;

        when COMPUTE_KR =>

          kr(1,1) <= kr11 * R11; kr(1,2) <= kr12 * R22; kr(1,3) <= kr13 * R33;
          kr(2,1) <= kr21 * R11; kr(2,2) <= kr22 * R22; kr(2,3) <= kr23 * R33;
          kr(3,1) <= kr31 * R11; kr(3,2) <= kr32 * R22; kr(3,3) <= kr33 * R33;
          kr(4,1) <= kr41 * R11; kr(4,2) <= kr42 * R22; kr(4,3) <= kr43 * R33;
          kr(5,1) <= kr51 * R11; kr(5,2) <= kr52 * R22; kr(5,3) <= kr53 * R33;
          kr(6,1) <= kr61 * R11; kr(6,2) <= kr62 * R22; kr(6,3) <= kr63 * R33;
          kr(7,1) <= kr71 * R11; kr(7,2) <= kr72 * R22; kr(7,3) <= kr73 * R33;
          state <= COMPUTE_KRK;

        when COMPUTE_KRK =>

          krk_mat(1,1) <= kr(1,1)*kr11 + kr(1,2)*kr12 + kr(1,3)*kr13;
          krk_mat(1,2) <= kr(1,1)*kr21 + kr(1,2)*kr22 + kr(1,3)*kr23;
          krk_mat(1,3) <= kr(1,1)*kr31 + kr(1,2)*kr32 + kr(1,3)*kr33;
          krk_mat(1,4) <= kr(1,1)*kr41 + kr(1,2)*kr42 + kr(1,3)*kr43;
          krk_mat(1,5) <= kr(1,1)*kr51 + kr(1,2)*kr52 + kr(1,3)*kr53;
          krk_mat(1,6) <= kr(1,1)*kr61 + kr(1,2)*kr62 + kr(1,3)*kr63;
          krk_mat(1,7) <= kr(1,1)*kr71 + kr(1,2)*kr72 + kr(1,3)*kr73;

          krk_mat(2,2) <= kr(2,1)*kr21 + kr(2,2)*kr22 + kr(2,3)*kr23;
          krk_mat(2,3) <= kr(2,1)*kr31 + kr(2,2)*kr32 + kr(2,3)*kr33;
          krk_mat(2,4) <= kr(2,1)*kr41 + kr(2,2)*kr42 + kr(2,3)*kr43;
          krk_mat(2,5) <= kr(2,1)*kr51 + kr(2,2)*kr52 + kr(2,3)*kr53;
          krk_mat(2,6) <= kr(2,1)*kr61 + kr(2,2)*kr62 + kr(2,3)*kr63;
          krk_mat(2,7) <= kr(2,1)*kr71 + kr(2,2)*kr72 + kr(2,3)*kr73;

          krk_mat(3,3) <= kr(3,1)*kr31 + kr(3,2)*kr32 + kr(3,3)*kr33;
          krk_mat(3,4) <= kr(3,1)*kr41 + kr(3,2)*kr42 + kr(3,3)*kr43;
          krk_mat(3,5) <= kr(3,1)*kr51 + kr(3,2)*kr52 + kr(3,3)*kr53;
          krk_mat(3,6) <= kr(3,1)*kr61 + kr(3,2)*kr62 + kr(3,3)*kr63;
          krk_mat(3,7) <= kr(3,1)*kr71 + kr(3,2)*kr72 + kr(3,3)*kr73;

          krk_mat(4,4) <= kr(4,1)*kr41 + kr(4,2)*kr42 + kr(4,3)*kr43;
          krk_mat(4,5) <= kr(4,1)*kr51 + kr(4,2)*kr52 + kr(4,3)*kr53;
          krk_mat(4,6) <= kr(4,1)*kr61 + kr(4,2)*kr62 + kr(4,3)*kr63;
          krk_mat(4,7) <= kr(4,1)*kr71 + kr(4,2)*kr72 + kr(4,3)*kr73;

          krk_mat(5,5) <= kr(5,1)*kr51 + kr(5,2)*kr52 + kr(5,3)*kr53;
          krk_mat(5,6) <= kr(5,1)*kr61 + kr(5,2)*kr62 + kr(5,3)*kr63;
          krk_mat(5,7) <= kr(5,1)*kr71 + kr(5,2)*kr72 + kr(5,3)*kr73;

          krk_mat(6,6) <= kr(6,1)*kr61 + kr(6,2)*kr62 + kr(6,3)*kr63;
          krk_mat(6,7) <= kr(6,1)*kr71 + kr(6,2)*kr72 + kr(6,3)*kr73;

          krk_mat(7,7) <= kr(7,1)*kr71 + kr(7,2)*kr72 + kr(7,3)*kr73;

          krk_mat(2,1) <= kr(1,1)*kr21 + kr(1,2)*kr22 + kr(1,3)*kr23;
          krk_mat(3,1) <= kr(1,1)*kr31 + kr(1,2)*kr32 + kr(1,3)*kr33;
          krk_mat(3,2) <= kr(2,1)*kr31 + kr(2,2)*kr32 + kr(2,3)*kr33;
          krk_mat(4,1) <= kr(1,1)*kr41 + kr(1,2)*kr42 + kr(1,3)*kr43;
          krk_mat(4,2) <= kr(2,1)*kr41 + kr(2,2)*kr42 + kr(2,3)*kr43;
          krk_mat(4,3) <= kr(3,1)*kr41 + kr(3,2)*kr42 + kr(3,3)*kr43;
          krk_mat(5,1) <= kr(1,1)*kr51 + kr(1,2)*kr52 + kr(1,3)*kr53;
          krk_mat(5,2) <= kr(2,1)*kr51 + kr(2,2)*kr52 + kr(2,3)*kr53;
          krk_mat(5,3) <= kr(3,1)*kr51 + kr(3,2)*kr52 + kr(3,3)*kr53;
          krk_mat(5,4) <= kr(4,1)*kr51 + kr(4,2)*kr52 + kr(4,3)*kr53;
          krk_mat(6,1) <= kr(1,1)*kr61 + kr(1,2)*kr62 + kr(1,3)*kr63;
          krk_mat(6,2) <= kr(2,1)*kr61 + kr(2,2)*kr62 + kr(2,3)*kr63;
          krk_mat(6,3) <= kr(3,1)*kr61 + kr(3,2)*kr62 + kr(3,3)*kr63;
          krk_mat(6,4) <= kr(4,1)*kr61 + kr(4,2)*kr62 + kr(4,3)*kr63;
          krk_mat(6,5) <= kr(5,1)*kr61 + kr(5,2)*kr62 + kr(5,3)*kr63;
          krk_mat(7,1) <= kr(1,1)*kr71 + kr(1,2)*kr72 + kr(1,3)*kr73;
          krk_mat(7,2) <= kr(2,1)*kr71 + kr(2,2)*kr72 + kr(2,3)*kr73;
          krk_mat(7,3) <= kr(3,1)*kr71 + kr(3,2)*kr72 + kr(3,3)*kr73;
          krk_mat(7,4) <= kr(4,1)*kr71 + kr(4,2)*kr72 + kr(4,3)*kr73;
          krk_mat(7,5) <= kr(5,1)*kr71 + kr(5,2)*kr72 + kr(5,3)*kr73;
          krk_mat(7,6) <= kr(6,1)*kr71 + kr(6,2)*kr72 + kr(6,3)*kr73;

          state <= ADD_APAT_KRK;

        when ADD_APAT_KRK =>

          p11_upd <= sat_cov(apat_mat(1,1) + krk_mat(1,1), true);
          p12_upd <= sat_cov(apat_mat(1,2) + krk_mat(1,2), false);
          p13_upd <= sat_cov(apat_mat(1,3) + krk_mat(1,3), false);
          p14_upd <= sat_cov(apat_mat(1,4) + krk_mat(1,4), false);
          p15_upd <= sat_cov(apat_mat(1,5) + krk_mat(1,5), false);
          p16_upd <= sat_cov(apat_mat(1,6) + krk_mat(1,6), false);
          p17_upd <= sat_cov(apat_mat(1,7) + krk_mat(1,7), false);

          p22_upd <= sat_cov(apat_mat(2,2) + krk_mat(2,2), true);
          p23_upd <= sat_cov(apat_mat(2,3) + krk_mat(2,3), false);
          p24_upd <= sat_cov(apat_mat(2,4) + krk_mat(2,4), false);
          p25_upd <= sat_cov(apat_mat(2,5) + krk_mat(2,5), false);
          p26_upd <= sat_cov(apat_mat(2,6) + krk_mat(2,6), false);
          p27_upd <= sat_cov(apat_mat(2,7) + krk_mat(2,7), false);

          p33_upd <= sat_cov(apat_mat(3,3) + krk_mat(3,3), true);
          p34_upd <= sat_cov(apat_mat(3,4) + krk_mat(3,4), false);
          p35_upd <= sat_cov(apat_mat(3,5) + krk_mat(3,5), false);
          p36_upd <= sat_cov(apat_mat(3,6) + krk_mat(3,6), false);
          p37_upd <= sat_cov(apat_mat(3,7) + krk_mat(3,7), false);

          p44_upd <= sat_cov(apat_mat(4,4) + krk_mat(4,4), true);
          p45_upd <= sat_cov(apat_mat(4,5) + krk_mat(4,5), false);
          p46_upd <= sat_cov(apat_mat(4,6) + krk_mat(4,6), false);
          p47_upd <= sat_cov(apat_mat(4,7) + krk_mat(4,7), false);

          p55_upd <= sat_cov(apat_mat(5,5) + krk_mat(5,5), true);
          p56_upd <= sat_cov(apat_mat(5,6) + krk_mat(5,6), false);
          p57_upd <= sat_cov(apat_mat(5,7) + krk_mat(5,7), false);

          p66_upd <= sat_cov(apat_mat(6,6) + krk_mat(6,6), true);
          p67_upd <= sat_cov(apat_mat(6,7) + krk_mat(6,7), false);

          p77_upd <= sat_cov(apat_mat(7,7) + krk_mat(7,7), true);

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

end Behavioral;
