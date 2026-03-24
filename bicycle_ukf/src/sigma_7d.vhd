library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sigma_7d is
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    cholesky_done   : in  std_logic;

    px_mean         : in  signed(47 downto 0);
    py_mean         : in  signed(47 downto 0);
    v_mean          : in  signed(47 downto 0);
    theta_mean      : in  signed(47 downto 0);
    omega_mean      : in  signed(47 downto 0);
    a_mean          : in  signed(47 downto 0);
    z_mean          : in  signed(47 downto 0);

    l11             : in  signed(47 downto 0);
    l21, l22        : in  signed(47 downto 0);
    l31, l32, l33   : in  signed(47 downto 0);
    l41, l42, l43, l44 : in  signed(47 downto 0);
    l51, l52, l53, l54, l55 : in  signed(47 downto 0);
    l61, l62, l63, l64, l65, l66 : in  signed(47 downto 0);
    l71, l72, l73, l74, l75, l76, l77 : in  signed(47 downto 0);

    chi0_px, chi0_py, chi0_v, chi0_theta, chi0_omega, chi0_a, chi0_z : out signed(47 downto 0);

    chi1_px, chi1_py, chi1_v, chi1_theta, chi1_omega, chi1_a, chi1_z : out signed(47 downto 0);
    chi2_px, chi2_py, chi2_v, chi2_theta, chi2_omega, chi2_a, chi2_z : out signed(47 downto 0);
    chi3_px, chi3_py, chi3_v, chi3_theta, chi3_omega, chi3_a, chi3_z : out signed(47 downto 0);
    chi4_px, chi4_py, chi4_v, chi4_theta, chi4_omega, chi4_a, chi4_z : out signed(47 downto 0);
    chi5_px, chi5_py, chi5_v, chi5_theta, chi5_omega, chi5_a, chi5_z : out signed(47 downto 0);
    chi6_px, chi6_py, chi6_v, chi6_theta, chi6_omega, chi6_a, chi6_z : out signed(47 downto 0);
    chi7_px, chi7_py, chi7_v, chi7_theta, chi7_omega, chi7_a, chi7_z : out signed(47 downto 0);

    chi8_px,  chi8_py,  chi8_v,  chi8_theta,  chi8_omega,  chi8_a,  chi8_z  : out signed(47 downto 0);
    chi9_px,  chi9_py,  chi9_v,  chi9_theta,  chi9_omega,  chi9_a,  chi9_z  : out signed(47 downto 0);
    chi10_px, chi10_py, chi10_v, chi10_theta, chi10_omega, chi10_a, chi10_z : out signed(47 downto 0);
    chi11_px, chi11_py, chi11_v, chi11_theta, chi11_omega, chi11_a, chi11_z : out signed(47 downto 0);
    chi12_px, chi12_py, chi12_v, chi12_theta, chi12_omega, chi12_a, chi12_z : out signed(47 downto 0);
    chi13_px, chi13_py, chi13_v, chi13_theta, chi13_omega, chi13_a, chi13_z : out signed(47 downto 0);
    chi14_px, chi14_py, chi14_v, chi14_theta, chi14_omega, chi14_a, chi14_z : out signed(47 downto 0);

    done            : out std_logic
  );
end entity;

architecture Behavioral of sigma_7d is

  type state_type is (IDLE, LATCH_INPUTS, CALCULATE, FINISHED);
  signal state : state_type := IDLE;

  constant Q : integer := 24;

  constant GAMMA : signed(47 downto 0) := to_signed(44394976, 48);

  signal px_r, py_r, v_r, theta_r, omega_r, a_r, z_r : signed(47 downto 0);

  signal l11_r : signed(47 downto 0);
  signal l21_r, l22_r : signed(47 downto 0);
  signal l31_r, l32_r, l33_r : signed(47 downto 0);
  signal l41_r, l42_r, l43_r, l44_r : signed(47 downto 0);
  signal l51_r, l52_r, l53_r, l54_r, l55_r : signed(47 downto 0);
  signal l61_r, l62_r, l63_r, l64_r, l65_r, l66_r : signed(47 downto 0);
  signal l71_r, l72_r, l73_r, l74_r, l75_r, l76_r, l77_r : signed(47 downto 0);

  function gamma_scale(l_val : signed(47 downto 0)) return signed is
    variable prod : signed(95 downto 0);
  begin
    prod := GAMMA * l_val;
    return resize(shift_right(prod, Q), 48);
  end function;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        done <= '0';
      else
        case state is
          when IDLE =>
            done <= '0';
            if cholesky_done = '1' then
              state <= LATCH_INPUTS;
            end if;

          when LATCH_INPUTS =>

            px_r <= px_mean; py_r <= py_mean; v_r <= v_mean;
            theta_r <= theta_mean; omega_r <= omega_mean;
            a_r <= a_mean; z_r <= z_mean;

            l11_r <= l11;
            l21_r <= l21; l22_r <= l22;
            l31_r <= l31; l32_r <= l32; l33_r <= l33;
            l41_r <= l41; l42_r <= l42; l43_r <= l43; l44_r <= l44;
            l51_r <= l51; l52_r <= l52; l53_r <= l53; l54_r <= l54; l55_r <= l55;
            l61_r <= l61; l62_r <= l62; l63_r <= l63; l64_r <= l64; l65_r <= l65; l66_r <= l66;
            l71_r <= l71; l72_r <= l72; l73_r <= l73; l74_r <= l74; l75_r <= l75; l76_r <= l76; l77_r <= l77;

            state <= CALCULATE;

          when CALCULATE =>

            chi0_px <= px_r; chi0_py <= py_r; chi0_v <= v_r;
            chi0_theta <= theta_r; chi0_omega <= omega_r;
            chi0_a <= a_r; chi0_z <= z_r;

            chi1_px    <= px_r    + gamma_scale(l11_r);
            chi1_py    <= py_r    + gamma_scale(l21_r);
            chi1_v     <= v_r     + gamma_scale(l31_r);
            chi1_theta <= theta_r + gamma_scale(l41_r);
            chi1_omega <= omega_r + gamma_scale(l51_r);
            chi1_a     <= a_r     + gamma_scale(l61_r);
            chi1_z     <= z_r     + gamma_scale(l71_r);

            chi2_px    <= px_r;
            chi2_py    <= py_r    + gamma_scale(l22_r);
            chi2_v     <= v_r     + gamma_scale(l32_r);
            chi2_theta <= theta_r + gamma_scale(l42_r);
            chi2_omega <= omega_r + gamma_scale(l52_r);
            chi2_a     <= a_r     + gamma_scale(l62_r);
            chi2_z     <= z_r     + gamma_scale(l72_r);

            chi3_px    <= px_r;
            chi3_py    <= py_r;
            chi3_v     <= v_r     + gamma_scale(l33_r);
            chi3_theta <= theta_r + gamma_scale(l43_r);
            chi3_omega <= omega_r + gamma_scale(l53_r);
            chi3_a     <= a_r     + gamma_scale(l63_r);
            chi3_z     <= z_r     + gamma_scale(l73_r);

            chi4_px    <= px_r;
            chi4_py    <= py_r;
            chi4_v     <= v_r;
            chi4_theta <= theta_r + gamma_scale(l44_r);
            chi4_omega <= omega_r + gamma_scale(l54_r);
            chi4_a     <= a_r     + gamma_scale(l64_r);
            chi4_z     <= z_r     + gamma_scale(l74_r);

            chi5_px    <= px_r;
            chi5_py    <= py_r;
            chi5_v     <= v_r;
            chi5_theta <= theta_r;
            chi5_omega <= omega_r + gamma_scale(l55_r);
            chi5_a     <= a_r     + gamma_scale(l65_r);
            chi5_z     <= z_r     + gamma_scale(l75_r);

            chi6_px    <= px_r;
            chi6_py    <= py_r;
            chi6_v     <= v_r;
            chi6_theta <= theta_r;
            chi6_omega <= omega_r;
            chi6_a     <= a_r     + gamma_scale(l66_r);
            chi6_z     <= z_r     + gamma_scale(l76_r);

            chi7_px    <= px_r;
            chi7_py    <= py_r;
            chi7_v     <= v_r;
            chi7_theta <= theta_r;
            chi7_omega <= omega_r;
            chi7_a     <= a_r;
            chi7_z     <= z_r     + gamma_scale(l77_r);

            chi8_px    <= px_r    - gamma_scale(l11_r);
            chi8_py    <= py_r    - gamma_scale(l21_r);
            chi8_v     <= v_r     - gamma_scale(l31_r);
            chi8_theta <= theta_r - gamma_scale(l41_r);
            chi8_omega <= omega_r - gamma_scale(l51_r);
            chi8_a     <= a_r     - gamma_scale(l61_r);
            chi8_z     <= z_r     - gamma_scale(l71_r);

            chi9_px    <= px_r;
            chi9_py    <= py_r    - gamma_scale(l22_r);
            chi9_v     <= v_r     - gamma_scale(l32_r);
            chi9_theta <= theta_r - gamma_scale(l42_r);
            chi9_omega <= omega_r - gamma_scale(l52_r);
            chi9_a     <= a_r     - gamma_scale(l62_r);
            chi9_z     <= z_r     - gamma_scale(l72_r);

            chi10_px    <= px_r;
            chi10_py    <= py_r;
            chi10_v     <= v_r     - gamma_scale(l33_r);
            chi10_theta <= theta_r - gamma_scale(l43_r);
            chi10_omega <= omega_r - gamma_scale(l53_r);
            chi10_a     <= a_r     - gamma_scale(l63_r);
            chi10_z     <= z_r     - gamma_scale(l73_r);

            chi11_px    <= px_r;
            chi11_py    <= py_r;
            chi11_v     <= v_r;
            chi11_theta <= theta_r - gamma_scale(l44_r);
            chi11_omega <= omega_r - gamma_scale(l54_r);
            chi11_a     <= a_r     - gamma_scale(l64_r);
            chi11_z     <= z_r     - gamma_scale(l74_r);

            chi12_px    <= px_r;
            chi12_py    <= py_r;
            chi12_v     <= v_r;
            chi12_theta <= theta_r;
            chi12_omega <= omega_r - gamma_scale(l55_r);
            chi12_a     <= a_r     - gamma_scale(l65_r);
            chi12_z     <= z_r     - gamma_scale(l75_r);

            chi13_px    <= px_r;
            chi13_py    <= py_r;
            chi13_v     <= v_r;
            chi13_theta <= theta_r;
            chi13_omega <= omega_r;
            chi13_a     <= a_r     - gamma_scale(l66_r);
            chi13_z     <= z_r     - gamma_scale(l76_r);

            chi14_px    <= px_r;
            chi14_py    <= py_r;
            chi14_v     <= v_r;
            chi14_theta <= theta_r;
            chi14_omega <= omega_r;
            chi14_a     <= a_r;
            chi14_z     <= z_r     - gamma_scale(l77_r);

            state <= FINISHED;

          when FINISHED =>
            done <= '1';
            if cholesky_done = '0' then
              state <= IDLE;
            end if;

          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

end Behavioral;
