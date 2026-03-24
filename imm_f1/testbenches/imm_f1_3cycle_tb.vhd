library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity imm_f1_3cycle_tb is
end imm_f1_3cycle_tb;

architecture Behavioral of imm_f1_3cycle_tb is

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

  constant N_CYCLES : integer := 3;
  type meas_array_t is array (0 to N_CYCLES-1) of signed(47 downto 0);

  constant MEAS_X : meas_array_t := (
    0 => signed'(X"0000327F28A6"),
    1 => signed'(X"000033854174"),
    2 => signed'(X"00003391B7F1")
  );
  constant MEAS_Y : meas_array_t := (
    0 => signed'(X"FFFFFFDC988A"),
    1 => signed'(X"FFFFFFDB3AA6"),
    2 => signed'(X"FFFFFFDB41D1")
  );
  constant MEAS_Z : meas_array_t := (
    0 => signed'(X"00000AA50972"),
    1 => signed'(X"00000AA99C02"),
    2 => signed'(X"00000ABA4BE1")
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
    file out_file : text open write_mode is "imm_vhdl_output.txt";
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

      wait until done_sig = '1' for 200 us;

      write(L, string'("Cycle "));
      write(L, i);
      write(L, string'(": imm_x=0x"));
      hwrite48(L, px);
      write(L, string'(" imm_y=0x"));
      hwrite48(L, py);
      write(L, string'(" imm_z=0x"));
      hwrite48(L, pz);
      write(L, string'(" p_ca="));
      write(L, to_integer(p_ca));
      write(L, string'(" p_si="));
      write(L, to_integer(p_si));
      write(L, string'(" p_bi="));
      write(L, to_integer(p_bi));
      writeline(out_file, L);

      wait for CLK_PERIOD * 5;
    end loop;

    report "IMM 3-cycle test complete";
    wait;
  end process;

end Behavioral;
