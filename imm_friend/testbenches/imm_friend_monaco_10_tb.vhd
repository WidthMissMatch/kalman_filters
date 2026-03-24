library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.ENV.ALL;

entity imm_friend_monaco_10_tb is
end imm_friend_monaco_10_tb;

architecture Behavioral of imm_friend_monaco_10_tb is

  component imm_friend_top is
    port (
      clk, reset, start : in std_logic;
      z_x_meas, z_y_meas, z_z_meas : in signed(47 downto 0);
      px_out, py_out, pz_out : out signed(47 downto 0);
      prob_ctra_out, prob_singer_out, prob_bike_out : out signed(47 downto 0);
      done : out std_logic
    );
  end component;

  signal clk, reset, start, done_sig : std_logic := '0';
  signal z_x, z_y, z_z : signed(47 downto 0) := (others => '0');
  signal px, py, pz : signed(47 downto 0);
  signal p_ct, p_si, p_bi : signed(47 downto 0);
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
    0 => signed'(X"FFFFFFDC988A"),
    1 => signed'(X"FFFFFFA2DCC3"),
    2 => signed'(X"FFFFFF5D04E7"),
    3 => signed'(X"FFFFFF1DEA55"),
    4 => signed'(X"FFFFFEE7E9DB"),
    5 => signed'(X"FFFFFEA25483"),
    6 => signed'(X"FFFFFE4C5CE1"),
    7 => signed'(X"FFFFFE07C46D"),
    8 => signed'(X"FFFFFDB8C8BD"),
    9 => signed'(X"FFFFFD62E765")
  );
  constant MEAS_Z : meas_array_t := (
    0 => signed'(X"00000AA50972"),
    1 => signed'(X"00000AA99C02"),
    2 => signed'(X"00000ABA4BE1"),
    3 => signed'(X"00000ABE2CDB"),
    4 => signed'(X"00000AC53F7B"),
    5 => signed'(X"00000AD01AC5"),
    6 => signed'(X"00000AD42B27"),
    7 => signed'(X"00000ADB9E34"),
    8 => signed'(X"00000AE0F14D"),
    9 => signed'(X"00000AE67A2F")
  );

  function to_hex48(val : signed(47 downto 0)) return string is
    variable uv : unsigned(47 downto 0);
    variable result : string(1 to 12);
    variable nibble : integer;
    constant hex_chars : string(1 to 16) := "0123456789ABCDEF";
  begin
    uv := unsigned(val);
    for i in 11 downto 0 loop
      nibble := to_integer(uv(i*4+3 downto i*4));
      result(12-i) := hex_chars(nibble+1);
    end loop;
    return result;
  end function;

begin

  dut : imm_friend_top port map (
    clk => clk, reset => reset, start => start,
    z_x_meas => z_x, z_y_meas => z_y, z_z_meas => z_z,
    px_out => px, py_out => py, pz_out => pz,
    prob_ctra_out => p_ct, prob_singer_out => p_si, prob_bike_out => p_bi,
    done => done_sig
  );

  clk_proc : process
  begin
    clk <= '0'; wait for CLK_PERIOD/2;
    clk <= '1'; wait for CLK_PERIOD/2;
  end process;

  stim_proc : process
  begin
    report "=== IMM FRIEND (Singer+CTRA+Bicycle) SMOKE TEST START ===";
    reset <= '1';
    wait for CLK_PERIOD * 5;
    reset <= '0';
    wait for CLK_PERIOD * 2;

    for i in 0 to N_CYCLES-1 loop
      z_x <= MEAS_X(i);
      z_y <= MEAS_Y(i);
      z_z <= MEAS_Z(i);

      report "--- Starting cycle " & integer'image(i) &
             " meas_x=0x" & to_hex48(MEAS_X(i));

      start <= '1';
      wait for CLK_PERIOD;
      start <= '0';

      wait until done_sig = '1' for 200 us;

      if done_sig = '1' then
        report "Cycle " & integer'image(i) & " DONE:" &
               " px=0x" & to_hex48(px) &
               " py=0x" & to_hex48(py) &
               " pz=0x" & to_hex48(pz) &
               " p_ct=" & integer'image(to_integer(p_ct)) &
               " p_si=" & integer'image(to_integer(p_si)) &
               " p_bi=" & integer'image(to_integer(p_bi));
      else
        report "Cycle " & integer'image(i) & " TIMEOUT after 200us!" severity error;
      end if;

      wait for CLK_PERIOD * 5;
    end loop;

    report "=== IMM FRIEND SMOKE TEST COMPLETE - ALL 10 CYCLES DONE ===";
    finish;
  end process;

end Behavioral;
