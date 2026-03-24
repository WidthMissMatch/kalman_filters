library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity state_update_potter_3d is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        start : in  std_logic;
        cycle_num : in integer range 0 to 1000;

        x_pos_pred, x_vel_pred, x_acc_pred : in signed(47 downto 0);
        y_pos_pred, y_vel_pred, y_acc_pred : in signed(47 downto 0);
        z_pos_pred, z_vel_pred, z_acc_pred : in signed(47 downto 0);

        l11_pred, l21_pred, l31_pred, l41_pred, l51_pred, l61_pred, l71_pred, l81_pred, l91_pred : in signed(47 downto 0);
        l22_pred, l32_pred, l42_pred, l52_pred, l62_pred, l72_pred, l82_pred, l92_pred           : in signed(47 downto 0);
        l33_pred, l43_pred, l53_pred, l63_pred, l73_pred, l83_pred, l93_pred                     : in signed(47 downto 0);
        l44_pred, l54_pred, l64_pred, l74_pred, l84_pred, l94_pred                               : in signed(47 downto 0);
        l55_pred, l65_pred, l75_pred, l85_pred, l95_pred                                         : in signed(47 downto 0);
        l66_pred, l76_pred, l86_pred, l96_pred                                                   : in signed(47 downto 0);
        l77_pred, l87_pred, l97_pred                                                             : in signed(47 downto 0);
        l88_pred, l98_pred                                                                       : in signed(47 downto 0);
        l99_pred                                                                                 : in signed(47 downto 0);

        k11, k12, k13 : in signed(47 downto 0);
        k21, k22, k23 : in signed(47 downto 0);
        k31, k32, k33 : in signed(47 downto 0);
        k41, k42, k43 : in signed(47 downto 0);
        k51, k52, k53 : in signed(47 downto 0);
        k61, k62, k63 : in signed(47 downto 0);
        k71, k72, k73 : in signed(47 downto 0);
        k81, k82, k83 : in signed(47 downto 0);
        k91, k92, k93 : in signed(47 downto 0);

        nu_x, nu_y, nu_z : in signed(47 downto 0);

        s11_in, s22_in, s33_in : in signed(47 downto 0);

        x_pos_upd, x_vel_upd, x_acc_upd : buffer signed(47 downto 0);
        y_pos_upd, y_vel_upd, y_acc_upd : buffer signed(47 downto 0);
        z_pos_upd, z_vel_upd, z_acc_upd : buffer signed(47 downto 0);

        l11_upd, l21_upd, l31_upd, l41_upd, l51_upd, l61_upd, l71_upd, l81_upd, l91_upd : buffer signed(47 downto 0);
        l22_upd, l32_upd, l42_upd, l52_upd, l62_upd, l72_upd, l82_upd, l92_upd           : buffer signed(47 downto 0);
        l33_upd, l43_upd, l53_upd, l63_upd, l73_upd, l83_upd, l93_upd                    : buffer signed(47 downto 0);
        l44_upd, l54_upd, l64_upd, l74_upd, l84_upd, l94_upd                             : buffer signed(47 downto 0);
        l55_upd, l65_upd, l75_upd, l85_upd, l95_upd                                      : buffer signed(47 downto 0);
        l66_upd, l76_upd, l86_upd, l96_upd                                               : buffer signed(47 downto 0);
        l77_upd, l87_upd, l97_upd                                                        : buffer signed(47 downto 0);
        l88_upd, l98_upd                                                                 : buffer signed(47 downto 0);
        l99_upd                                                                          : buffer signed(47 downto 0);

        done : out std_logic
    );
end state_update_potter_3d;

architecture Behavioral of state_update_potter_3d is

    constant Q : integer := 24;

    constant R11_Q24_24 : signed(47 downto 0) := to_signed(2181038, 48);
    constant R22_Q24_24 : signed(47 downto 0) := to_signed(2181038, 48);
    constant R33_Q24_24 : signed(47 downto 0) := to_signed(2181038, 48);

    component sqrt_cordic is
        port (
            clk : in std_logic;
            start_rt : in std_logic;
            x_in : in signed(47 downto 0);
            x_out : out signed(47 downto 0);
            done : out std_logic;
            negative_input : out std_logic
        );
    end component;

    component cholesky_rank1_downdate is
        port (
            clk, reset, start : in std_logic;
            l11_in, l21_in, l31_in, l41_in, l51_in, l61_in, l71_in, l81_in, l91_in : in signed(47 downto 0);
            l22_in, l32_in, l42_in, l52_in, l62_in, l72_in, l82_in, l92_in : in signed(47 downto 0);
            l33_in, l43_in, l53_in, l63_in, l73_in, l83_in, l93_in : in signed(47 downto 0);
            l44_in, l54_in, l64_in, l74_in, l84_in, l94_in : in signed(47 downto 0);
            l55_in, l65_in, l75_in, l85_in, l95_in : in signed(47 downto 0);
            l66_in, l76_in, l86_in, l96_in : in signed(47 downto 0);
            l77_in, l87_in, l97_in : in signed(47 downto 0);
            l88_in, l98_in : in signed(47 downto 0);
            l99_in : in signed(47 downto 0);
            w1_in, w2_in, w3_in, w4_in, w5_in, w6_in, w7_in, w8_in, w9_in : in signed(47 downto 0);
            l11_out, l21_out, l31_out, l41_out, l51_out, l61_out, l71_out, l81_out, l91_out : buffer signed(47 downto 0);
            l22_out, l32_out, l42_out, l52_out, l62_out, l72_out, l82_out, l92_out : buffer signed(47 downto 0);
            l33_out, l43_out, l53_out, l63_out, l73_out, l83_out, l93_out : buffer signed(47 downto 0);
            l44_out, l54_out, l64_out, l74_out, l84_out, l94_out : buffer signed(47 downto 0);
            l55_out, l65_out, l75_out, l85_out, l95_out : buffer signed(47 downto 0);
            l66_out, l76_out, l86_out, l96_out : buffer signed(47 downto 0);
            l77_out, l87_out, l97_out : buffer signed(47 downto 0);
            l88_out, l98_out : buffer signed(47 downto 0);
            l99_out : buffer signed(47 downto 0);
            done : buffer std_logic;
            error : buffer std_logic
        );
    end component;

    type state_type is (IDLE, UPDATE_STATE, COMPUTE_SQRT_R, WAIT_SQRT_R, COMPUTE_KR,
                        DOWNDATE_1, WAIT_DOWNDATE_1,
                        DOWNDATE_2, WAIT_DOWNDATE_2,
                        DOWNDATE_3, WAIT_DOWNDATE_3, FINISHED);
    signal state : state_type := IDLE;

    signal k11_reg, k12_reg, k13_reg : signed(47 downto 0);
    signal k21_reg, k22_reg, k23_reg : signed(47 downto 0);
    signal k31_reg, k32_reg, k33_reg : signed(47 downto 0);
    signal k41_reg, k42_reg, k43_reg : signed(47 downto 0);
    signal k51_reg, k52_reg, k53_reg : signed(47 downto 0);
    signal k61_reg, k62_reg, k63_reg : signed(47 downto 0);
    signal k71_reg, k72_reg, k73_reg : signed(47 downto 0);
    signal k81_reg, k82_reg, k83_reg : signed(47 downto 0);
    signal k91_reg, k92_reg, k93_reg : signed(47 downto 0);

    signal nu_x_reg, nu_y_reg, nu_z_reg : signed(47 downto 0);

    signal sqrt_r11, sqrt_r22, sqrt_r33 : signed(47 downto 0) := (others => '0');
    signal sqrt_start : std_logic := '0';
    signal sqrt_in, sqrt_out : signed(47 downto 0) := (others => '0');
    signal sqrt_done : std_logic;
    signal sqrt_idx : integer range 0 to 2 := 0;

    signal w1_1, w1_2, w1_3, w1_4, w1_5, w1_6, w1_7, w1_8, w1_9 : signed(47 downto 0);
    signal w2_1, w2_2, w2_3, w2_4, w2_5, w2_6, w2_7, w2_8, w2_9 : signed(47 downto 0);
    signal w3_1, w3_2, w3_3, w3_4, w3_5, w3_6, w3_7, w3_8, w3_9 : signed(47 downto 0);

    signal l11_d1_raw, l21_d1_raw, l31_d1_raw, l41_d1_raw, l51_d1_raw, l61_d1_raw, l71_d1_raw, l81_d1_raw, l91_d1_raw : signed(47 downto 0);
    signal l22_d1_raw, l32_d1_raw, l42_d1_raw, l52_d1_raw, l62_d1_raw, l72_d1_raw, l82_d1_raw, l92_d1_raw : signed(47 downto 0);
    signal l33_d1_raw, l43_d1_raw, l53_d1_raw, l63_d1_raw, l73_d1_raw, l83_d1_raw, l93_d1_raw : signed(47 downto 0);
    signal l44_d1_raw, l54_d1_raw, l64_d1_raw, l74_d1_raw, l84_d1_raw, l94_d1_raw : signed(47 downto 0);
    signal l55_d1_raw, l65_d1_raw, l75_d1_raw, l85_d1_raw, l95_d1_raw : signed(47 downto 0);
    signal l66_d1_raw, l76_d1_raw, l86_d1_raw, l96_d1_raw : signed(47 downto 0);
    signal l77_d1_raw, l87_d1_raw, l97_d1_raw : signed(47 downto 0);
    signal l88_d1_raw, l98_d1_raw : signed(47 downto 0);
    signal l99_d1_raw : signed(47 downto 0);

    signal l11_d2_raw, l21_d2_raw, l31_d2_raw, l41_d2_raw, l51_d2_raw, l61_d2_raw, l71_d2_raw, l81_d2_raw, l91_d2_raw : signed(47 downto 0);
    signal l22_d2_raw, l32_d2_raw, l42_d2_raw, l52_d2_raw, l62_d2_raw, l72_d2_raw, l82_d2_raw, l92_d2_raw : signed(47 downto 0);
    signal l33_d2_raw, l43_d2_raw, l53_d2_raw, l63_d2_raw, l73_d2_raw, l83_d2_raw, l93_d2_raw : signed(47 downto 0);
    signal l44_d2_raw, l54_d2_raw, l64_d2_raw, l74_d2_raw, l84_d2_raw, l94_d2_raw : signed(47 downto 0);
    signal l55_d2_raw, l65_d2_raw, l75_d2_raw, l85_d2_raw, l95_d2_raw : signed(47 downto 0);
    signal l66_d2_raw, l76_d2_raw, l86_d2_raw, l96_d2_raw : signed(47 downto 0);
    signal l77_d2_raw, l87_d2_raw, l97_d2_raw : signed(47 downto 0);
    signal l88_d2_raw, l98_d2_raw : signed(47 downto 0);
    signal l99_d2_raw : signed(47 downto 0);

    signal l11_upd_raw, l21_upd_raw, l31_upd_raw, l41_upd_raw, l51_upd_raw, l61_upd_raw, l71_upd_raw, l81_upd_raw, l91_upd_raw : signed(47 downto 0);
    signal l22_upd_raw, l32_upd_raw, l42_upd_raw, l52_upd_raw, l62_upd_raw, l72_upd_raw, l82_upd_raw, l92_upd_raw : signed(47 downto 0);
    signal l33_upd_raw, l43_upd_raw, l53_upd_raw, l63_upd_raw, l73_upd_raw, l83_upd_raw, l93_upd_raw : signed(47 downto 0);
    signal l44_upd_raw, l54_upd_raw, l64_upd_raw, l74_upd_raw, l84_upd_raw, l94_upd_raw : signed(47 downto 0);
    signal l55_upd_raw, l65_upd_raw, l75_upd_raw, l85_upd_raw, l95_upd_raw : signed(47 downto 0);
    signal l66_upd_raw, l76_upd_raw, l86_upd_raw, l96_upd_raw : signed(47 downto 0);
    signal l77_upd_raw, l87_upd_raw, l97_upd_raw : signed(47 downto 0);
    signal l88_upd_raw, l98_upd_raw : signed(47 downto 0);
    signal l99_upd_raw : signed(47 downto 0);

    signal l11_d1, l21_d1, l31_d1, l41_d1, l51_d1, l61_d1, l71_d1, l81_d1, l91_d1 : signed(47 downto 0);
    signal l22_d1, l32_d1, l42_d1, l52_d1, l62_d1, l72_d1, l82_d1, l92_d1 : signed(47 downto 0);
    signal l33_d1, l43_d1, l53_d1, l63_d1, l73_d1, l83_d1, l93_d1 : signed(47 downto 0);
    signal l44_d1, l54_d1, l64_d1, l74_d1, l84_d1, l94_d1 : signed(47 downto 0);
    signal l55_d1, l65_d1, l75_d1, l85_d1, l95_d1 : signed(47 downto 0);
    signal l66_d1, l76_d1, l86_d1, l96_d1 : signed(47 downto 0);
    signal l77_d1, l87_d1, l97_d1 : signed(47 downto 0);
    signal l88_d1, l98_d1 : signed(47 downto 0);
    signal l99_d1 : signed(47 downto 0);

    signal l11_d2, l21_d2, l31_d2, l41_d2, l51_d2, l61_d2, l71_d2, l81_d2, l91_d2 : signed(47 downto 0);
    signal l22_d2, l32_d2, l42_d2, l52_d2, l62_d2, l72_d2, l82_d2, l92_d2 : signed(47 downto 0);
    signal l33_d2, l43_d2, l53_d2, l63_d2, l73_d2, l83_d2, l93_d2 : signed(47 downto 0);
    signal l44_d2, l54_d2, l64_d2, l74_d2, l84_d2, l94_d2 : signed(47 downto 0);
    signal l55_d2, l65_d2, l75_d2, l85_d2, l95_d2 : signed(47 downto 0);
    signal l66_d2, l76_d2, l86_d2, l96_d2 : signed(47 downto 0);
    signal l77_d2, l87_d2, l97_d2 : signed(47 downto 0);
    signal l88_d2, l98_d2 : signed(47 downto 0);
    signal l99_d2 : signed(47 downto 0);

    signal downdate1_start, downdate1_done, downdate1_error : std_logic := '0';
    signal downdate2_start, downdate2_done, downdate2_error : std_logic := '0';
    signal downdate3_start, downdate3_done, downdate3_error : std_logic := '0';

begin

    sqrt_inst : sqrt_cordic
        port map (
            clk => clk,
            start_rt => sqrt_start,
            x_in => sqrt_in,
            x_out => sqrt_out,
            done => sqrt_done,
            negative_input => open
        );

    downdate_inst_1 : cholesky_rank1_downdate
        port map (
            clk => clk, reset => reset, start => downdate1_start,
            l11_in => l11_pred, l21_in => l21_pred, l31_in => l31_pred, l41_in => l41_pred, l51_in => l51_pred, l61_in => l61_pred, l71_in => l71_pred, l81_in => l81_pred, l91_in => l91_pred,
            l22_in => l22_pred, l32_in => l32_pred, l42_in => l42_pred, l52_in => l52_pred, l62_in => l62_pred, l72_in => l72_pred, l82_in => l82_pred, l92_in => l92_pred,
            l33_in => l33_pred, l43_in => l43_pred, l53_in => l53_pred, l63_in => l63_pred, l73_in => l73_pred, l83_in => l83_pred, l93_in => l93_pred,
            l44_in => l44_pred, l54_in => l54_pred, l64_in => l64_pred, l74_in => l74_pred, l84_in => l84_pred, l94_in => l94_pred,
            l55_in => l55_pred, l65_in => l65_pred, l75_in => l75_pred, l85_in => l85_pred, l95_in => l95_pred,
            l66_in => l66_pred, l76_in => l76_pred, l86_in => l86_pred, l96_in => l96_pred,
            l77_in => l77_pred, l87_in => l87_pred, l97_in => l97_pred,
            l88_in => l88_pred, l98_in => l98_pred,
            l99_in => l99_pred,
            w1_in => w1_1, w2_in => w1_2, w3_in => w1_3, w4_in => w1_4, w5_in => w1_5, w6_in => w1_6, w7_in => w1_7, w8_in => w1_8, w9_in => w1_9,
            l11_out => l11_d1_raw, l21_out => l21_d1_raw, l31_out => l31_d1_raw, l41_out => l41_d1_raw, l51_out => l51_d1_raw, l61_out => l61_d1_raw, l71_out => l71_d1_raw, l81_out => l81_d1_raw, l91_out => l91_d1_raw,
            l22_out => l22_d1_raw, l32_out => l32_d1_raw, l42_out => l42_d1_raw, l52_out => l52_d1_raw, l62_out => l62_d1_raw, l72_out => l72_d1_raw, l82_out => l82_d1_raw, l92_out => l92_d1_raw,
            l33_out => l33_d1_raw, l43_out => l43_d1_raw, l53_out => l53_d1_raw, l63_out => l63_d1_raw, l73_out => l73_d1_raw, l83_out => l83_d1_raw, l93_out => l93_d1_raw,
            l44_out => l44_d1_raw, l54_out => l54_d1_raw, l64_out => l64_d1_raw, l74_out => l74_d1_raw, l84_out => l84_d1_raw, l94_out => l94_d1_raw,
            l55_out => l55_d1_raw, l65_out => l65_d1_raw, l75_out => l75_d1_raw, l85_out => l85_d1_raw, l95_out => l95_d1_raw,
            l66_out => l66_d1_raw, l76_out => l76_d1_raw, l86_out => l86_d1_raw, l96_out => l96_d1_raw,
            l77_out => l77_d1_raw, l87_out => l87_d1_raw, l97_out => l97_d1_raw,
            l88_out => l88_d1_raw, l98_out => l98_d1_raw,
            l99_out => l99_d1_raw,
            done => downdate1_done,
            error => downdate1_error
        );

    downdate_inst_2 : cholesky_rank1_downdate
        port map (
            clk => clk, reset => reset, start => downdate2_start,
            l11_in => l11_d1, l21_in => l21_d1, l31_in => l31_d1, l41_in => l41_d1, l51_in => l51_d1, l61_in => l61_d1, l71_in => l71_d1, l81_in => l81_d1, l91_in => l91_d1,
            l22_in => l22_d1, l32_in => l32_d1, l42_in => l42_d1, l52_in => l52_d1, l62_in => l62_d1, l72_in => l72_d1, l82_in => l82_d1, l92_in => l92_d1,
            l33_in => l33_d1, l43_in => l43_d1, l53_in => l53_d1, l63_in => l63_d1, l73_in => l73_d1, l83_in => l83_d1, l93_in => l93_d1,
            l44_in => l44_d1, l54_in => l54_d1, l64_in => l64_d1, l74_in => l74_d1, l84_in => l84_d1, l94_in => l94_d1,
            l55_in => l55_d1, l65_in => l65_d1, l75_in => l75_d1, l85_in => l85_d1, l95_in => l95_d1,
            l66_in => l66_d1, l76_in => l76_d1, l86_in => l86_d1, l96_in => l96_d1,
            l77_in => l77_d1, l87_in => l87_d1, l97_in => l97_d1,
            l88_in => l88_d1, l98_in => l98_d1,
            l99_in => l99_d1,
            w1_in => w2_1, w2_in => w2_2, w3_in => w2_3, w4_in => w2_4, w5_in => w2_5, w6_in => w2_6, w7_in => w2_7, w8_in => w2_8, w9_in => w2_9,
            l11_out => l11_d2_raw, l21_out => l21_d2_raw, l31_out => l31_d2_raw, l41_out => l41_d2_raw, l51_out => l51_d2_raw, l61_out => l61_d2_raw, l71_out => l71_d2_raw, l81_out => l81_d2_raw, l91_out => l91_d2_raw,
            l22_out => l22_d2_raw, l32_out => l32_d2_raw, l42_out => l42_d2_raw, l52_out => l52_d2_raw, l62_out => l62_d2_raw, l72_out => l72_d2_raw, l82_out => l82_d2_raw, l92_out => l92_d2_raw,
            l33_out => l33_d2_raw, l43_out => l43_d2_raw, l53_out => l53_d2_raw, l63_out => l63_d2_raw, l73_out => l73_d2_raw, l83_out => l83_d2_raw, l93_out => l93_d2_raw,
            l44_out => l44_d2_raw, l54_out => l54_d2_raw, l64_out => l64_d2_raw, l74_out => l74_d2_raw, l84_out => l84_d2_raw, l94_out => l94_d2_raw,
            l55_out => l55_d2_raw, l65_out => l65_d2_raw, l75_out => l75_d2_raw, l85_out => l85_d2_raw, l95_out => l95_d2_raw,
            l66_out => l66_d2_raw, l76_out => l76_d2_raw, l86_out => l86_d2_raw, l96_out => l96_d2_raw,
            l77_out => l77_d2_raw, l87_out => l87_d2_raw, l97_out => l97_d2_raw,
            l88_out => l88_d2_raw, l98_out => l98_d2_raw,
            l99_out => l99_d2_raw,
            done => downdate2_done,
            error => downdate2_error
        );

    downdate_inst_3 : cholesky_rank1_downdate
        port map (
            clk => clk, reset => reset, start => downdate3_start,
            l11_in => l11_d2, l21_in => l21_d2, l31_in => l31_d2, l41_in => l41_d2, l51_in => l51_d2, l61_in => l61_d2, l71_in => l71_d2, l81_in => l81_d2, l91_in => l91_d2,
            l22_in => l22_d2, l32_in => l32_d2, l42_in => l42_d2, l52_in => l52_d2, l62_in => l62_d2, l72_in => l72_d2, l82_in => l82_d2, l92_in => l92_d2,
            l33_in => l33_d2, l43_in => l43_d2, l53_in => l53_d2, l63_in => l63_d2, l73_in => l73_d2, l83_in => l83_d2, l93_in => l93_d2,
            l44_in => l44_d2, l54_in => l54_d2, l64_in => l64_d2, l74_in => l74_d2, l84_in => l84_d2, l94_in => l94_d2,
            l55_in => l55_d2, l65_in => l65_d2, l75_in => l75_d2, l85_in => l85_d2, l95_in => l95_d2,
            l66_in => l66_d2, l76_in => l76_d2, l86_in => l86_d2, l96_in => l96_d2,
            l77_in => l77_d2, l87_in => l87_d2, l97_in => l97_d2,
            l88_in => l88_d2, l98_in => l98_d2,
            l99_in => l99_d2,
            w1_in => w3_1, w2_in => w3_2, w3_in => w3_3, w4_in => w3_4, w5_in => w3_5, w6_in => w3_6, w7_in => w3_7, w8_in => w3_8, w9_in => w3_9,
            l11_out => l11_upd_raw, l21_out => l21_upd_raw, l31_out => l31_upd_raw, l41_out => l41_upd_raw, l51_out => l51_upd_raw, l61_out => l61_upd_raw, l71_out => l71_upd_raw, l81_out => l81_upd_raw, l91_out => l91_upd_raw,
            l22_out => l22_upd_raw, l32_out => l32_upd_raw, l42_out => l42_upd_raw, l52_out => l52_upd_raw, l62_out => l62_upd_raw, l72_out => l72_upd_raw, l82_out => l82_upd_raw, l92_out => l92_upd_raw,
            l33_out => l33_upd_raw, l43_out => l43_upd_raw, l53_out => l53_upd_raw, l63_out => l63_upd_raw, l73_out => l73_upd_raw, l83_out => l83_upd_raw, l93_out => l93_upd_raw,
            l44_out => l44_upd_raw, l54_out => l54_upd_raw, l64_out => l64_upd_raw, l74_out => l74_upd_raw, l84_out => l84_upd_raw, l94_out => l94_upd_raw,
            l55_out => l55_upd_raw, l65_out => l65_upd_raw, l75_out => l75_upd_raw, l85_out => l85_upd_raw, l95_out => l95_upd_raw,
            l66_out => l66_upd_raw, l76_out => l76_upd_raw, l86_out => l86_upd_raw, l96_out => l96_upd_raw,
            l77_out => l77_upd_raw, l87_out => l87_upd_raw, l97_out => l97_upd_raw,
            l88_out => l88_upd_raw, l98_out => l98_upd_raw,
            l99_out => l99_upd_raw,
            done => downdate3_done,
            error => downdate3_error
        );

    process(downdate1_error, l11_d1_raw, l11_pred, l21_d1_raw, l21_pred, l31_d1_raw, l31_pred,
            l41_d1_raw, l41_pred, l51_d1_raw, l51_pred, l61_d1_raw, l61_pred,
            l71_d1_raw, l71_pred, l81_d1_raw, l81_pred, l91_d1_raw, l91_pred,
            l22_d1_raw, l22_pred, l32_d1_raw, l32_pred, l42_d1_raw, l42_pred,
            l52_d1_raw, l52_pred, l62_d1_raw, l62_pred, l72_d1_raw, l72_pred,
            l82_d1_raw, l82_pred, l92_d1_raw, l92_pred,
            l33_d1_raw, l33_pred, l43_d1_raw, l43_pred, l53_d1_raw, l53_pred,
            l63_d1_raw, l63_pred, l73_d1_raw, l73_pred, l83_d1_raw, l83_pred, l93_d1_raw, l93_pred,
            l44_d1_raw, l44_pred, l54_d1_raw, l54_pred, l64_d1_raw, l64_pred,
            l74_d1_raw, l74_pred, l84_d1_raw, l84_pred, l94_d1_raw, l94_pred,
            l55_d1_raw, l55_pred, l65_d1_raw, l65_pred, l75_d1_raw, l75_pred,
            l85_d1_raw, l85_pred, l95_d1_raw, l95_pred,
            l66_d1_raw, l66_pred, l76_d1_raw, l76_pred, l86_d1_raw, l86_pred, l96_d1_raw, l96_pred,
            l77_d1_raw, l77_pred, l87_d1_raw, l87_pred, l97_d1_raw, l97_pred,
            l88_d1_raw, l88_pred, l98_d1_raw, l98_pred,
            l99_d1_raw, l99_pred)
    begin
        if downdate1_error = '1' then

            l11_d1 <= l11_pred; l21_d1 <= l21_pred; l31_d1 <= l31_pred; l41_d1 <= l41_pred; l51_d1 <= l51_pred; l61_d1 <= l61_pred; l71_d1 <= l71_pred; l81_d1 <= l81_pred; l91_d1 <= l91_pred;
            l22_d1 <= l22_pred; l32_d1 <= l32_pred; l42_d1 <= l42_pred; l52_d1 <= l52_pred; l62_d1 <= l62_pred; l72_d1 <= l72_pred; l82_d1 <= l82_pred; l92_d1 <= l92_pred;
            l33_d1 <= l33_pred; l43_d1 <= l43_pred; l53_d1 <= l53_pred; l63_d1 <= l63_pred; l73_d1 <= l73_pred; l83_d1 <= l83_pred; l93_d1 <= l93_pred;
            l44_d1 <= l44_pred; l54_d1 <= l54_pred; l64_d1 <= l64_pred; l74_d1 <= l74_pred; l84_d1 <= l84_pred; l94_d1 <= l94_pred;
            l55_d1 <= l55_pred; l65_d1 <= l65_pred; l75_d1 <= l75_pred; l85_d1 <= l85_pred; l95_d1 <= l95_pred;
            l66_d1 <= l66_pred; l76_d1 <= l76_pred; l86_d1 <= l86_pred; l96_d1 <= l96_pred;
            l77_d1 <= l77_pred; l87_d1 <= l87_pred; l97_d1 <= l97_pred;
            l88_d1 <= l88_pred; l98_d1 <= l98_pred;
            l99_d1 <= l99_pred;
        else

            l11_d1 <= l11_d1_raw; l21_d1 <= l21_d1_raw; l31_d1 <= l31_d1_raw; l41_d1 <= l41_d1_raw; l51_d1 <= l51_d1_raw; l61_d1 <= l61_d1_raw; l71_d1 <= l71_d1_raw; l81_d1 <= l81_d1_raw; l91_d1 <= l91_d1_raw;
            l22_d1 <= l22_d1_raw; l32_d1 <= l32_d1_raw; l42_d1 <= l42_d1_raw; l52_d1 <= l52_d1_raw; l62_d1 <= l62_d1_raw; l72_d1 <= l72_d1_raw; l82_d1 <= l82_d1_raw; l92_d1 <= l92_d1_raw;
            l33_d1 <= l33_d1_raw; l43_d1 <= l43_d1_raw; l53_d1 <= l53_d1_raw; l63_d1 <= l63_d1_raw; l73_d1 <= l73_d1_raw; l83_d1 <= l83_d1_raw; l93_d1 <= l93_d1_raw;
            l44_d1 <= l44_d1_raw; l54_d1 <= l54_d1_raw; l64_d1 <= l64_d1_raw; l74_d1 <= l74_d1_raw; l84_d1 <= l84_d1_raw; l94_d1 <= l94_d1_raw;
            l55_d1 <= l55_d1_raw; l65_d1 <= l65_d1_raw; l75_d1 <= l75_d1_raw; l85_d1 <= l85_d1_raw; l95_d1 <= l95_d1_raw;
            l66_d1 <= l66_d1_raw; l76_d1 <= l76_d1_raw; l86_d1 <= l86_d1_raw; l96_d1 <= l96_d1_raw;
            l77_d1 <= l77_d1_raw; l87_d1 <= l87_d1_raw; l97_d1 <= l97_d1_raw;
            l88_d1 <= l88_d1_raw; l98_d1 <= l98_d1_raw;
            l99_d1 <= l99_d1_raw;
        end if;
    end process;

    process(downdate2_error, l11_d2_raw, l11_d1, l21_d2_raw, l21_d1, l31_d2_raw, l31_d1,
            l41_d2_raw, l41_d1, l51_d2_raw, l51_d1, l61_d2_raw, l61_d1,
            l71_d2_raw, l71_d1, l81_d2_raw, l81_d1, l91_d2_raw, l91_d1,
            l22_d2_raw, l22_d1, l32_d2_raw, l32_d1, l42_d2_raw, l42_d1,
            l52_d2_raw, l52_d1, l62_d2_raw, l62_d1, l72_d2_raw, l72_d1,
            l82_d2_raw, l82_d1, l92_d2_raw, l92_d1,
            l33_d2_raw, l33_d1, l43_d2_raw, l43_d1, l53_d2_raw, l53_d1,
            l63_d2_raw, l63_d1, l73_d2_raw, l73_d1, l83_d2_raw, l83_d1, l93_d2_raw, l93_d1,
            l44_d2_raw, l44_d1, l54_d2_raw, l54_d1, l64_d2_raw, l64_d1,
            l74_d2_raw, l74_d1, l84_d2_raw, l84_d1, l94_d2_raw, l94_d1,
            l55_d2_raw, l55_d1, l65_d2_raw, l65_d1, l75_d2_raw, l75_d1,
            l85_d2_raw, l85_d1, l95_d2_raw, l95_d1,
            l66_d2_raw, l66_d1, l76_d2_raw, l76_d1, l86_d2_raw, l86_d1, l96_d2_raw, l96_d1,
            l77_d2_raw, l77_d1, l87_d2_raw, l87_d1, l97_d2_raw, l97_d1,
            l88_d2_raw, l88_d1, l98_d2_raw, l98_d1,
            l99_d2_raw, l99_d1)
    begin
        if downdate2_error = '1' then

            l11_d2 <= l11_d1; l21_d2 <= l21_d1; l31_d2 <= l31_d1; l41_d2 <= l41_d1; l51_d2 <= l51_d1; l61_d2 <= l61_d1; l71_d2 <= l71_d1; l81_d2 <= l81_d1; l91_d2 <= l91_d1;
            l22_d2 <= l22_d1; l32_d2 <= l32_d1; l42_d2 <= l42_d1; l52_d2 <= l52_d1; l62_d2 <= l62_d1; l72_d2 <= l72_d1; l82_d2 <= l82_d1; l92_d2 <= l92_d1;
            l33_d2 <= l33_d1; l43_d2 <= l43_d1; l53_d2 <= l53_d1; l63_d2 <= l63_d1; l73_d2 <= l73_d1; l83_d2 <= l83_d1; l93_d2 <= l93_d1;
            l44_d2 <= l44_d1; l54_d2 <= l54_d1; l64_d2 <= l64_d1; l74_d2 <= l74_d1; l84_d2 <= l84_d1; l94_d2 <= l94_d1;
            l55_d2 <= l55_d1; l65_d2 <= l65_d1; l75_d2 <= l75_d1; l85_d2 <= l85_d1; l95_d2 <= l95_d1;
            l66_d2 <= l66_d1; l76_d2 <= l76_d1; l86_d2 <= l86_d1; l96_d2 <= l96_d1;
            l77_d2 <= l77_d1; l87_d2 <= l87_d1; l97_d2 <= l97_d1;
            l88_d2 <= l88_d1; l98_d2 <= l98_d1;
            l99_d2 <= l99_d1;
        else

            l11_d2 <= l11_d2_raw; l21_d2 <= l21_d2_raw; l31_d2 <= l31_d2_raw; l41_d2 <= l41_d2_raw; l51_d2 <= l51_d2_raw; l61_d2 <= l61_d2_raw; l71_d2 <= l71_d2_raw; l81_d2 <= l81_d2_raw; l91_d2 <= l91_d2_raw;
            l22_d2 <= l22_d2_raw; l32_d2 <= l32_d2_raw; l42_d2 <= l42_d2_raw; l52_d2 <= l52_d2_raw; l62_d2 <= l62_d2_raw; l72_d2 <= l72_d2_raw; l82_d2 <= l82_d2_raw; l92_d2 <= l92_d2_raw;
            l33_d2 <= l33_d2_raw; l43_d2 <= l43_d2_raw; l53_d2 <= l53_d2_raw; l63_d2 <= l63_d2_raw; l73_d2 <= l73_d2_raw; l83_d2 <= l83_d2_raw; l93_d2 <= l93_d2_raw;
            l44_d2 <= l44_d2_raw; l54_d2 <= l54_d2_raw; l64_d2 <= l64_d2_raw; l74_d2 <= l74_d2_raw; l84_d2 <= l84_d2_raw; l94_d2 <= l94_d2_raw;
            l55_d2 <= l55_d2_raw; l65_d2 <= l65_d2_raw; l75_d2 <= l75_d2_raw; l85_d2 <= l85_d2_raw; l95_d2 <= l95_d2_raw;
            l66_d2 <= l66_d2_raw; l76_d2 <= l76_d2_raw; l86_d2 <= l86_d2_raw; l96_d2 <= l96_d2_raw;
            l77_d2 <= l77_d2_raw; l87_d2 <= l87_d2_raw; l97_d2 <= l97_d2_raw;
            l88_d2 <= l88_d2_raw; l98_d2 <= l98_d2_raw;
            l99_d2 <= l99_d2_raw;
        end if;
    end process;

    process(downdate3_error, l11_upd_raw, l11_d2, l21_upd_raw, l21_d2, l31_upd_raw, l31_d2,
            l41_upd_raw, l41_d2, l51_upd_raw, l51_d2, l61_upd_raw, l61_d2,
            l71_upd_raw, l71_d2, l81_upd_raw, l81_d2, l91_upd_raw, l91_d2,
            l22_upd_raw, l22_d2, l32_upd_raw, l32_d2, l42_upd_raw, l42_d2,
            l52_upd_raw, l52_d2, l62_upd_raw, l62_d2, l72_upd_raw, l72_d2,
            l82_upd_raw, l82_d2, l92_upd_raw, l92_d2,
            l33_upd_raw, l33_d2, l43_upd_raw, l43_d2, l53_upd_raw, l53_d2,
            l63_upd_raw, l63_d2, l73_upd_raw, l73_d2, l83_upd_raw, l83_d2, l93_upd_raw, l93_d2,
            l44_upd_raw, l44_d2, l54_upd_raw, l54_d2, l64_upd_raw, l64_d2,
            l74_upd_raw, l74_d2, l84_upd_raw, l84_d2, l94_upd_raw, l94_d2,
            l55_upd_raw, l55_d2, l65_upd_raw, l65_d2, l75_upd_raw, l75_d2,
            l85_upd_raw, l85_d2, l95_upd_raw, l95_d2,
            l66_upd_raw, l66_d2, l76_upd_raw, l76_d2, l86_upd_raw, l86_d2, l96_upd_raw, l96_d2,
            l77_upd_raw, l77_d2, l87_upd_raw, l87_d2, l97_upd_raw, l97_d2,
            l88_upd_raw, l88_d2, l98_upd_raw, l98_d2,
            l99_upd_raw, l99_d2)
    begin
        if downdate3_error = '1' then

            l11_upd <= l11_d2; l21_upd <= l21_d2; l31_upd <= l31_d2; l41_upd <= l41_d2; l51_upd <= l51_d2; l61_upd <= l61_d2; l71_upd <= l71_d2; l81_upd <= l81_d2; l91_upd <= l91_d2;
            l22_upd <= l22_d2; l32_upd <= l32_d2; l42_upd <= l42_d2; l52_upd <= l52_d2; l62_upd <= l62_d2; l72_upd <= l72_d2; l82_upd <= l82_d2; l92_upd <= l92_d2;
            l33_upd <= l33_d2; l43_upd <= l43_d2; l53_upd <= l53_d2; l63_upd <= l63_d2; l73_upd <= l73_d2; l83_upd <= l83_d2; l93_upd <= l93_d2;
            l44_upd <= l44_d2; l54_upd <= l54_d2; l64_upd <= l64_d2; l74_upd <= l74_d2; l84_upd <= l84_d2; l94_upd <= l94_d2;
            l55_upd <= l55_d2; l65_upd <= l65_d2; l75_upd <= l75_d2; l85_upd <= l85_d2; l95_upd <= l95_d2;
            l66_upd <= l66_d2; l76_upd <= l76_d2; l86_upd <= l86_d2; l96_upd <= l96_d2;
            l77_upd <= l77_d2; l87_upd <= l87_d2; l97_upd <= l97_d2;
            l88_upd <= l88_d2; l98_upd <= l98_d2;
            l99_upd <= l99_d2;
        else

            l11_upd <= l11_upd_raw; l21_upd <= l21_upd_raw; l31_upd <= l31_upd_raw; l41_upd <= l41_upd_raw; l51_upd <= l51_upd_raw; l61_upd <= l61_upd_raw; l71_upd <= l71_upd_raw; l81_upd <= l81_upd_raw; l91_upd <= l91_upd_raw;
            l22_upd <= l22_upd_raw; l32_upd <= l32_upd_raw; l42_upd <= l42_upd_raw; l52_upd <= l52_upd_raw; l62_upd <= l62_upd_raw; l72_upd <= l72_upd_raw; l82_upd <= l82_upd_raw; l92_upd <= l92_upd_raw;
            l33_upd <= l33_upd_raw; l43_upd <= l43_upd_raw; l53_upd <= l53_upd_raw; l63_upd <= l63_upd_raw; l73_upd <= l73_upd_raw; l83_upd <= l83_upd_raw; l93_upd <= l93_upd_raw;
            l44_upd <= l44_upd_raw; l54_upd <= l54_upd_raw; l64_upd <= l64_upd_raw; l74_upd <= l74_upd_raw; l84_upd <= l84_upd_raw; l94_upd <= l94_upd_raw;
            l55_upd <= l55_upd_raw; l65_upd <= l65_upd_raw; l75_upd <= l75_upd_raw; l85_upd <= l85_upd_raw; l95_upd <= l95_upd_raw;
            l66_upd <= l66_upd_raw; l76_upd <= l76_upd_raw; l86_upd <= l86_upd_raw; l96_upd <= l96_upd_raw;
            l77_upd <= l77_upd_raw; l87_upd <= l87_upd_raw; l97_upd <= l97_upd_raw;
            l88_upd <= l88_upd_raw; l98_upd <= l98_upd_raw;
            l99_upd <= l99_upd_raw;
        end if;
    end process;

    process(clk)
        variable temp_prod : signed(95 downto 0);
        variable temp_sum : signed(95 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                done <= '0';
                sqrt_start <= '0';
                downdate1_start <= '0';
                downdate2_start <= '0';
                downdate3_start <= '0';
                sqrt_idx <= 0;
            else
                case state is

                    when IDLE =>
                        done <= '0';
                        sqrt_start <= '0';
                        downdate1_start <= '0';
                        downdate2_start <= '0';
                        downdate3_start <= '0';
                        if start = '1' then

                            if cycle_num >= 1 and cycle_num <= 2 then
                                report "POTTER[" & integer'image(cycle_num) & "]: IDLE -> UPDATE_STATE (start='1')";
                            end if;

                            k11_reg <= k11; k12_reg <= k12; k13_reg <= k13;
                            k21_reg <= k21; k22_reg <= k22; k23_reg <= k23;
                            k31_reg <= k31; k32_reg <= k32; k33_reg <= k33;
                            k41_reg <= k41; k42_reg <= k42; k43_reg <= k43;
                            k51_reg <= k51; k52_reg <= k52; k53_reg <= k53;
                            k61_reg <= k61; k62_reg <= k62; k63_reg <= k63;
                            k71_reg <= k71; k72_reg <= k72; k73_reg <= k73;
                            k81_reg <= k81; k82_reg <= k82; k83_reg <= k83;
                            k91_reg <= k91; k92_reg <= k92; k93_reg <= k93;

                            nu_x_reg <= nu_x; nu_y_reg <= nu_y; nu_z_reg <= nu_z;

                            state <= UPDATE_STATE;
                        end if;

                    when UPDATE_STATE =>

                        if cycle_num >= 1 and cycle_num <= 2 then
                            report "POTTER[" & integer'image(cycle_num) & "]: UPDATE_STATE - Computing x_pos_upd" & LF &
                                   "  x_pos_pred (input) = " & integer'image(to_integer(x_pos_pred)) & LF &
                                   "  k11_reg = " & integer'image(to_integer(k11_reg)) & LF &
                                   "  nu_x_reg (innovation) = " & integer'image(to_integer(nu_x_reg));
                        end if;

                        temp_sum := resize((k11_reg * nu_x_reg) + (k12_reg * nu_y_reg) + (k13_reg * nu_z_reg), 96);
                        x_pos_upd <= x_pos_pred + resize(shift_right(temp_sum, Q), 48);

                        if cycle_num >= 1 and cycle_num <= 2 then
                            report "POTTER[" & integer'image(cycle_num) & "]: UPDATE_STATE - Computed:" & LF &
                                   "  K*nu term = " & integer'image(to_integer(resize(shift_right(temp_sum, Q), 48))) & LF &
                                   "  x_pos_upd = x_pos_pred + K*nu = " & integer'image(to_integer(x_pos_upd));
                        end if;

                        temp_sum := resize((k21_reg * nu_x_reg) + (k22_reg * nu_y_reg) + (k23_reg * nu_z_reg), 96);
                        x_vel_upd <= x_vel_pred + resize(shift_right(temp_sum, Q), 48);

                        temp_sum := resize((k31_reg * nu_x_reg) + (k32_reg * nu_y_reg) + (k33_reg * nu_z_reg), 96);
                        x_acc_upd <= x_acc_pred + resize(shift_right(temp_sum, Q), 48);

                        temp_sum := resize((k41_reg * nu_x_reg) + (k42_reg * nu_y_reg) + (k43_reg * nu_z_reg), 96);
                        y_pos_upd <= y_pos_pred + resize(shift_right(temp_sum, Q), 48);

                        temp_sum := resize((k51_reg * nu_x_reg) + (k52_reg * nu_y_reg) + (k53_reg * nu_z_reg), 96);
                        y_vel_upd <= y_vel_pred + resize(shift_right(temp_sum, Q), 48);

                        temp_sum := resize((k61_reg * nu_x_reg) + (k62_reg * nu_y_reg) + (k63_reg * nu_z_reg), 96);
                        y_acc_upd <= y_acc_pred + resize(shift_right(temp_sum, Q), 48);

                        temp_sum := resize((k71_reg * nu_x_reg) + (k72_reg * nu_y_reg) + (k73_reg * nu_z_reg), 96);
                        z_pos_upd <= z_pos_pred + resize(shift_right(temp_sum, Q), 48);

                        temp_sum := resize((k81_reg * nu_x_reg) + (k82_reg * nu_y_reg) + (k83_reg * nu_z_reg), 96);
                        z_vel_upd <= z_vel_pred + resize(shift_right(temp_sum, Q), 48);

                        temp_sum := resize((k91_reg * nu_x_reg) + (k92_reg * nu_y_reg) + (k93_reg * nu_z_reg), 96);
                        z_acc_upd <= z_acc_pred + resize(shift_right(temp_sum, Q), 48);

                        if cycle_num >= 1 and cycle_num <= 2 then
                            report "POTTER[" & integer'image(cycle_num) & "]: UPDATE_STATE -> COMPUTE_SQRT_R";
                        end if;
                        state <= COMPUTE_SQRT_R;

                    when COMPUTE_SQRT_R =>

                        sqrt_idx <= 0;
                        sqrt_in <= s11_in;
                        sqrt_start <= '1';
                        state <= WAIT_SQRT_R;

                    when WAIT_SQRT_R =>
                        sqrt_start <= '0';
                        if sqrt_done = '1' then

                            case sqrt_idx is
                                when 0 => sqrt_r11 <= sqrt_out;
                                when 1 => sqrt_r22 <= sqrt_out;
                                when 2 => sqrt_r33 <= sqrt_out;
                                when others => null;
                            end case;

                            if sqrt_idx < 2 then
                                sqrt_idx <= sqrt_idx + 1;
                                if sqrt_idx = 0 then
                                    sqrt_in <= s22_in;
                                else
                                    sqrt_in <= s33_in;
                                end if;
                                sqrt_start <= '1';
                            else

                                if cycle_num >= 1 and cycle_num <= 2 then
                                    report "POTTER[" & integer'image(cycle_num) & "]: WAIT_SQRT_R -> COMPUTE_KR (all sqrts done)";
                                end if;
                                state <= COMPUTE_KR;
                            end if;
                        end if;

                    when COMPUTE_KR =>

                        if cycle_num >= 1 and cycle_num <= 2 then
                            report "POTTER[" & integer'image(cycle_num) & "]: COMPUTE_KR - Computing w=K*sqrt(S) vectors for downdates";
                        end if;

                        temp_prod := k11_reg * sqrt_r11; w1_1 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k21_reg * sqrt_r11; w1_2 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k31_reg * sqrt_r11; w1_3 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k41_reg * sqrt_r11; w1_4 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k51_reg * sqrt_r11; w1_5 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k61_reg * sqrt_r11; w1_6 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k71_reg * sqrt_r11; w1_7 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k81_reg * sqrt_r11; w1_8 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k91_reg * sqrt_r11; w1_9 <= resize(shift_right(temp_prod, Q), 48);

                        temp_prod := k12_reg * sqrt_r22; w2_1 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k22_reg * sqrt_r22; w2_2 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k32_reg * sqrt_r22; w2_3 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k42_reg * sqrt_r22; w2_4 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k52_reg * sqrt_r22; w2_5 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k62_reg * sqrt_r22; w2_6 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k72_reg * sqrt_r22; w2_7 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k82_reg * sqrt_r22; w2_8 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k92_reg * sqrt_r22; w2_9 <= resize(shift_right(temp_prod, Q), 48);

                        temp_prod := k13_reg * sqrt_r33; w3_1 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k23_reg * sqrt_r33; w3_2 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k33_reg * sqrt_r33; w3_3 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k43_reg * sqrt_r33; w3_4 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k53_reg * sqrt_r33; w3_5 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k63_reg * sqrt_r33; w3_6 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k73_reg * sqrt_r33; w3_7 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k83_reg * sqrt_r33; w3_8 <= resize(shift_right(temp_prod, Q), 48);
                        temp_prod := k93_reg * sqrt_r33; w3_9 <= resize(shift_right(temp_prod, Q), 48);

                        if cycle_num >= 1 and cycle_num <= 2 then
                            report "POTTER[" & integer'image(cycle_num) & "]: COMPUTE_KR -> DOWNDATE_1";
                        end if;
                        state <= DOWNDATE_1;

                    when DOWNDATE_1 =>

                        downdate1_start <= '1';
                        state <= WAIT_DOWNDATE_1;

                    when WAIT_DOWNDATE_1 =>
                        downdate1_start <= '0';
                        if downdate1_done = '1' then
                            if cycle_num >= 1 and cycle_num <= 2 then
                                report "POTTER[" & integer'image(cycle_num) & "]: DOWNDATE_1 complete" & LF &
                                   "  l11_pred (input) = " & integer'image(to_integer(l11_pred)) & LF &
                                   "  l11_d1 (output) = " & integer'image(to_integer(l11_d1)) & LF &
                                   "  downdate1_error = " & std_logic'image(downdate1_error) & LF &
                                   "  w1_1 = " & integer'image(to_integer(w1_1));
                                if downdate1_error = '1' then
                                    report "POTTER[" & integer'image(cycle_num) & "]: *** DOWNDATE_1 FAILED (L² < w²) ***" severity warning;
                                end if;
                            else
                                if downdate1_error = '1' then
                                    report "POTTER FIX: Downdate 1 failed (L² < w²) - preserving L_pred" severity warning;
                                end if;
                            end if;
                            state <= DOWNDATE_2;
                        end if;

                    when DOWNDATE_2 =>

                        downdate2_start <= '1';
                        state <= WAIT_DOWNDATE_2;

                    when WAIT_DOWNDATE_2 =>
                        downdate2_start <= '0';
                        if downdate2_done = '1' then
                            if cycle_num >= 1 and cycle_num <= 2 then
                                report "POTTER[" & integer'image(cycle_num) & "]: DOWNDATE_2 complete" & LF &
                                   "  l11_d1 (input) = " & integer'image(to_integer(l11_d1)) & LF &
                                   "  l11_d2 (output) = " & integer'image(to_integer(l11_d2)) & LF &
                                   "  downdate2_error = " & std_logic'image(downdate2_error) & LF &
                                   "  w2_1 = " & integer'image(to_integer(w2_1));
                                if downdate2_error = '1' then
                                    report "POTTER[" & integer'image(cycle_num) & "]: *** DOWNDATE_2 FAILED (L² < w²) ***" severity warning;
                                end if;
                            else
                                if downdate2_error = '1' then
                                    report "POTTER FIX: Downdate 2 failed (L² < w²) - preserving L_d1" severity warning;
                                end if;
                            end if;
                            state <= DOWNDATE_3;
                        end if;

                    when DOWNDATE_3 =>

                        downdate3_start <= '1';
                        state <= WAIT_DOWNDATE_3;

                    when WAIT_DOWNDATE_3 =>
                        downdate3_start <= '0';
                        if downdate3_done = '1' then
                            if cycle_num >= 1 and cycle_num <= 2 then
                                report "POTTER[" & integer'image(cycle_num) & "]: DOWNDATE_3 complete" & LF &
                                   "  l11_d2 (input) = " & integer'image(to_integer(l11_d2)) & LF &
                                   "  l11_upd (output) = " & integer'image(to_integer(l11_upd)) & LF &
                                   "  downdate3_error = " & std_logic'image(downdate3_error) & LF &
                                   "  w3_1 = " & integer'image(to_integer(w3_1));
                                if downdate3_error = '1' then
                                    report "POTTER[" & integer'image(cycle_num) & "]: *** DOWNDATE_3 FAILED (L² < w²) ***" severity warning;
                                end if;
                                report "POTTER[" & integer'image(cycle_num) & "]: All downdates complete -> FINISHED";
                            else
                                if downdate3_error = '1' then
                                    report "POTTER FIX: Downdate 3 failed (L² < w²) - preserving L_d2" severity warning;
                                end if;
                            end if;
                            state <= FINISHED;
                        end if;

                    when FINISHED =>
                        done <= '1';

                        report "STATE_UPDATE_POTTER: FINISHED - Cycle " & integer'image(cycle_num) & " outputs:" & LF &
                               "  x_pos_upd = " & integer'image(to_integer(x_pos_upd)) & LF &
                               "  x_vel_upd = " & integer'image(to_integer(x_vel_upd)) & LF &
                               "  x_acc_upd = " & integer'image(to_integer(x_acc_upd)) & LF &
                               "  y_pos_upd = " & integer'image(to_integer(y_pos_upd)) & LF &
                               "  z_pos_upd = " & integer'image(to_integer(z_pos_upd));

                        if cycle_num = 1 then
                            report "STATE_UPDATE[1]: innovation[0]=" & integer'image(to_integer(nu_x)) &
                                   " x_upd[0]=" & integer'image(to_integer(x_pos_upd)) &
                                   " EXPECTED=73944822" &
                                   " (Python baseline: x_pos should be 4.407m)";
                        end if;

                        if start = '0' then
                            state <= IDLE;
                        end if;

                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

end Behavioral;
