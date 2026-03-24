library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity imm_f1_10cycle_tb is
end imm_f1_10cycle_tb;

architecture Behavioral of imm_f1_10cycle_tb is

  component imm_f1_top is
    port (
      clk, reset, start : in std_logic;
      z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
      px_out, py_out, pz_out : out signed(47 downto 0);
      prob_ca_out, prob_singer_out, prob_bike_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  signal clk, reset, start, done_sig : std_logic := '0';
  signal z_x, z_y, z_z : signed(47 downto 0) := (others => '0');
  signal px, py, pz : signed(47 downto 0);
  signal p_ca, p_si, p_bi : signed(47 downto 0);
  constant CLK_PERIOD : time := 10 ns;

  constant N_CYCLES : integer := 10;
  type meas_array_t is array (0 to N_CYCLES-1) of signed(47 downto 0);

  constant MEAS_X : meas_array_t := (
    0 => signed'(X"0000007F28A9"),
    1 => signed'(X"0000071D8F1D"),
    2 => signed'(X"00000F27B7B8"),
    3 => signed'(X"00001748C27D"),
    4 => signed'(X"00001CC7E021"),
    5 => signed'(X"00002408D59B"),
    6 => signed'(X"00002D1A01B2"),
    7 => signed'(X"000032EAAB54"),
    8 => signed'(X"00003809B8F8"),
    9 => signed'(X"00003F68815F")
  );

  constant MEAS_Y : meas_array_t := (
    0 => signed'(X"FFFFFF13A6FC"),
    1 => signed'(X"FFFFFC6BB465"),
    2 => signed'(X"FFFFFA91A5F8"),
    3 => signed'(X"FFFFFA5EF0AA"),
    4 => signed'(X"FFFFF623E5CA"),
    5 => signed'(X"FFFFF77E91C9"),
    6 => signed'(X"FFFFF320B479"),
    7 => signed'(X"FFFFEFFC2D30"),
    8 => signed'(X"FFFFEBD901F0"),
    9 => signed'(X"FFFFEA4FEA4A")
  );

  constant MEAS_Z : meas_array_t := (
    0 => signed'(X"000000C742AC"),
    1 => signed'(X"FFFFFF26D5AA"),
    2 => signed'(X"FFFFFE966ADC"),
    3 => signed'(X"FFFFFF1AF35D"),
    4 => signed'(X"FFFFFEA42F76"),
    5 => signed'(X"FFFFFE0FAA19"),
    6 => signed'(X"FFFFFEE9E778"),
    7 => signed'(X"FFFFFEEAE51A"),
    8 => signed'(X"FFFFFDD04AD6"),
    9 => signed'(X"FFFFFEF73B32")
  );

  procedure hwrite48(variable L : inout line; val : in signed(47 downto 0)) is
    variable uval : unsigned(47 downto 0);
  begin
    uval := unsigned(val);
    hwrite(L, std_logic_vector(uval));
  end procedure;

begin

  dut : imm_f1_top port map (
    clk => clk, reset => reset, start => start,
    z_x_meas => z_x, z_y_meas => z_y, z_z_meas => z_z,
    px_out => px, py_out => py, pz_out => pz,
    prob_ca_out => p_ca, prob_singer_out => p_si, prob_bike_out => p_bi,
    done => done_sig
  );

  clk_proc : process
  begin
    clk <= '0'; wait for CLK_PERIOD/2;
    clk <= '1'; wait for CLK_PERIOD/2;
  end process;

  stim_proc : process
    variable L : line;
    file out_file : text open write_mode is "imm_10cycle_output.txt";
  begin

    reset <= '1';
    wait for CLK_PERIOD * 5;
    reset <= '0';
    wait for CLK_PERIOD * 2;

    for i in 0 to N_CYCLES-1 loop

      z_x <= MEAS_X(i);
      z_y <= MEAS_Y(i);
      z_z <= MEAS_Z(i);

      start <= '1';
      wait for CLK_PERIOD;
      start <= '0';

      wait until done_sig = '1' for 150 us;

      if done_sig /= '1' then
        report "TIMEOUT at cycle " & integer'image(i) severity error;
      end if;

      write(L, string'("Cycle "));
      write(L, i);
      write(L, string'(": imm_x=0x"));
      hwrite48(L, px);
      write(L, string'(" imm_y=0x"));
      hwrite48(L, py);
      write(L, string'(" imm_z=0x"));
      hwrite48(L, pz);
      write(L, string'(" p_ca=0x"));
      hwrite48(L, p_ca);
      write(L, string'(" p_si=0x"));
      hwrite48(L, p_si);
      write(L, string'(" p_bi=0x"));
      hwrite48(L, p_bi);
      writeline(out_file, L);

      report "Cycle " & integer'image(i) & " complete";

      wait for CLK_PERIOD * 5;
    end loop;

    report "IMM 10-cycle testbench complete";
    wait;
  end process;

end Behavioral;
