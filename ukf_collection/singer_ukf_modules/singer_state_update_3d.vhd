library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity state_update_3d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        x_pos_pred, x_vel_pred, x_acc_pred : in signed(47 downto 0);
        y_pos_pred, y_vel_pred, y_acc_pred : in signed(47 downto 0);
        z_pos_pred, z_vel_pred, z_acc_pred : in signed(47 downto 0);

        p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred : in signed(47 downto 0);
        p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred           : in signed(47 downto 0);
        p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred                     : in signed(47 downto 0);
        p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred                               : in signed(47 downto 0);
        p55_pred, p56_pred, p57_pred, p58_pred, p59_pred                                         : in signed(47 downto 0);
        p66_pred, p67_pred, p68_pred, p69_pred                                                   : in signed(47 downto 0);
        p77_pred, p78_pred, p79_pred                                                             : in signed(47 downto 0);
        p88_pred, p89_pred                                                                       : in signed(47 downto 0);
        p99_pred                                                                                 : in signed(47 downto 0);

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

        x_pos_upd, x_vel_upd, x_acc_upd : buffer signed(47 downto 0);
        y_pos_upd, y_vel_upd, y_acc_upd : buffer signed(47 downto 0);
        z_pos_upd, z_vel_upd, z_acc_upd : buffer signed(47 downto 0);

        p11_upd, p12_upd, p13_upd, p14_upd, p15_upd, p16_upd, p17_upd, p18_upd, p19_upd : buffer signed(47 downto 0);
        p22_upd, p23_upd, p24_upd, p25_upd, p26_upd, p27_upd, p28_upd, p29_upd           : buffer signed(47 downto 0);
        p33_upd, p34_upd, p35_upd, p36_upd, p37_upd, p38_upd, p39_upd                    : buffer signed(47 downto 0);
        p44_upd, p45_upd, p46_upd, p47_upd, p48_upd, p49_upd                             : buffer signed(47 downto 0);
        p55_upd, p56_upd, p57_upd, p58_upd, p59_upd                                      : buffer signed(47 downto 0);
        p66_upd, p67_upd, p68_upd, p69_upd                                               : buffer signed(47 downto 0);
        p77_upd, p78_upd, p79_upd                                                        : buffer signed(47 downto 0);
        p88_upd, p89_upd                                                                 : buffer signed(47 downto 0);
        p99_upd                                                                          : buffer signed(47 downto 0);

        done : out std_logic
    );
end state_update_3d;

architecture Behavioral of state_update_3d is

    constant Q : integer := 24;
    constant UNITY : signed(47 downto 0) := to_signed(16777216, 48);

    constant SAFE_MAX_P : signed(47 downto 0) := signed'(X"3FFFFFFFFFFF");

    constant R11_Q24_24 : signed(47 downto 0) := to_signed(4194304, 48);
    constant R22_Q24_24 : signed(47 downto 0) := to_signed(4194304, 48);
    constant R33_Q24_24 : signed(47 downto 0) := to_signed(4194304, 48);

    type state_type is (IDLE, UPDATE_STATE, CONSTRUCT_A, COMPUTE_AP, SHIFT_AP,
                        COMPUTE_APAT, COMPUTE_KR, WAIT_KR, COMPUTE_KRK, ADD_APAT_KRK, FINISHED);
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

    signal a11, a12, a13 : signed(47 downto 0);

    signal a21, a22, a23 : signed(47 downto 0);

    signal a31, a32, a33 : signed(47 downto 0);

    signal a44, a45, a46 : signed(47 downto 0);

    signal a54, a55, a56 : signed(47 downto 0);

    signal a64, a65, a66 : signed(47 downto 0);

    signal a77, a78, a79 : signed(47 downto 0);

    signal a87, a88, a89 : signed(47 downto 0);

    signal a97, a98, a99 : signed(47 downto 0);

    type ap_matrix is array (0 to 80) of signed(95 downto 0);
    signal ap : ap_matrix := (others => (others => '0'));

    type ap_shifted_matrix is array (0 to 80) of signed(47 downto 0);
    signal ap_s : ap_shifted_matrix := (others => (others => '0'));

    signal apat_11, apat_12, apat_13, apat_14, apat_15, apat_16, apat_17, apat_18, apat_19 : signed(95 downto 0);
    signal apat_22, apat_23, apat_24, apat_25, apat_26, apat_27, apat_28, apat_29           : signed(95 downto 0);
    signal apat_33, apat_34, apat_35, apat_36, apat_37, apat_38, apat_39                    : signed(95 downto 0);
    signal apat_44, apat_45, apat_46, apat_47, apat_48, apat_49                             : signed(95 downto 0);
    signal apat_55, apat_56, apat_57, apat_58, apat_59                                      : signed(95 downto 0);
    signal apat_66, apat_67, apat_68, apat_69                                               : signed(95 downto 0);
    signal apat_77, apat_78, apat_79                                                        : signed(95 downto 0);
    signal apat_88, apat_89                                                                 : signed(95 downto 0);
    signal apat_99                                                                          : signed(95 downto 0);

    signal kr_11, kr_12, kr_13 : signed(95 downto 0);
    signal kr_21, kr_22, kr_23 : signed(95 downto 0);
    signal kr_31, kr_32, kr_33 : signed(95 downto 0);
    signal kr_41, kr_42, kr_43 : signed(95 downto 0);
    signal kr_51, kr_52, kr_53 : signed(95 downto 0);
    signal kr_61, kr_62, kr_63 : signed(95 downto 0);
    signal kr_71, kr_72, kr_73 : signed(95 downto 0);
    signal kr_81, kr_82, kr_83 : signed(95 downto 0);
    signal kr_91, kr_92, kr_93 : signed(95 downto 0);

    signal kr_11_s, kr_12_s, kr_13_s : signed(47 downto 0);
    signal kr_21_s, kr_22_s, kr_23_s : signed(47 downto 0);
    signal kr_31_s, kr_32_s, kr_33_s : signed(47 downto 0);
    signal kr_41_s, kr_42_s, kr_43_s : signed(47 downto 0);
    signal kr_51_s, kr_52_s, kr_53_s : signed(47 downto 0);
    signal kr_61_s, kr_62_s, kr_63_s : signed(47 downto 0);
    signal kr_71_s, kr_72_s, kr_73_s : signed(47 downto 0);
    signal kr_81_s, kr_82_s, kr_83_s : signed(47 downto 0);
    signal kr_91_s, kr_92_s, kr_93_s : signed(47 downto 0);

    signal krk_11, krk_12, krk_13, krk_14, krk_15, krk_16, krk_17, krk_18, krk_19 : signed(95 downto 0);
    signal krk_22, krk_23, krk_24, krk_25, krk_26, krk_27, krk_28, krk_29         : signed(95 downto 0);
    signal krk_33, krk_34, krk_35, krk_36, krk_37, krk_38, krk_39                 : signed(95 downto 0);
    signal krk_44, krk_45, krk_46, krk_47, krk_48, krk_49                         : signed(95 downto 0);
    signal krk_55, krk_56, krk_57, krk_58, krk_59                                 : signed(95 downto 0);
    signal krk_66, krk_67, krk_68, krk_69                                         : signed(95 downto 0);
    signal krk_77, krk_78, krk_79                                                 : signed(95 downto 0);
    signal krk_88, krk_89                                                         : signed(95 downto 0);
    signal krk_99                                                                 : signed(95 downto 0);

    function saturate_covariance(val : signed(95 downto 0)) return signed is
        variable shifted : signed(47 downto 0);
    begin
        shifted := resize(shift_right(val, Q), 48);

        if shifted > SAFE_MAX_P then
            report "WARNING: Covariance saturated to SAFE_MAX_P (" &
                   integer'image(to_integer(shifted)) & " > " &
                   integer'image(to_integer(SAFE_MAX_P)) & ")" severity warning;
            return SAFE_MAX_P;
        elsif shifted < to_signed(0, 48) then
            report "ERROR: Covariance negative, resetting to 1.0 (" &
                   integer'image(to_integer(shifted)) & ")" severity error;
            return UNITY;
        else
            return shifted;
        end if;
    end function;

begin

    process(clk)
        variable temp_sum : signed(95 downto 0);
    begin
        if rising_edge(clk) then
            case state is

                when IDLE =>
                    done <= '0';

                    if start = '1' then

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

                    temp_sum := (k11_reg * nu_x_reg) + (k12_reg * nu_y_reg) + (k13_reg * nu_z_reg);
                    x_pos_upd <= x_pos_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k21_reg * nu_x_reg) + (k22_reg * nu_y_reg) + (k23_reg * nu_z_reg);
                    x_vel_upd <= x_vel_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k31_reg * nu_x_reg) + (k32_reg * nu_y_reg) + (k33_reg * nu_z_reg);
                    x_acc_upd <= x_acc_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k41_reg * nu_x_reg) + (k42_reg * nu_y_reg) + (k43_reg * nu_z_reg);
                    y_pos_upd <= y_pos_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k51_reg * nu_x_reg) + (k52_reg * nu_y_reg) + (k53_reg * nu_z_reg);
                    y_vel_upd <= y_vel_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k61_reg * nu_x_reg) + (k62_reg * nu_y_reg) + (k63_reg * nu_z_reg);
                    y_acc_upd <= y_acc_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k71_reg * nu_x_reg) + (k72_reg * nu_y_reg) + (k73_reg * nu_z_reg);
                    z_pos_upd <= z_pos_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k81_reg * nu_x_reg) + (k82_reg * nu_y_reg) + (k83_reg * nu_z_reg);
                    z_vel_upd <= z_vel_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := (k91_reg * nu_x_reg) + (k92_reg * nu_y_reg) + (k93_reg * nu_z_reg);
                    z_acc_upd <= z_acc_pred + resize(shift_right(temp_sum, Q), 48);

                    state <= CONSTRUCT_A;

                when CONSTRUCT_A =>

                    a11 <= UNITY - k11_reg;
                    a12 <= -k12_reg;
                    a13 <= -k13_reg;

                    a21 <= -k21_reg;
                    a22 <= UNITY - k22_reg;
                    a23 <= -k23_reg;

                    a31 <= -k31_reg;
                    a32 <= -k32_reg;
                    a33 <= UNITY - k33_reg;

                    a44 <= UNITY - k41_reg;
                    a45 <= -k42_reg;
                    a46 <= -k43_reg;

                    a54 <= -k51_reg;
                    a55 <= UNITY - k52_reg;
                    a56 <= -k53_reg;

                    a64 <= -k61_reg;
                    a65 <= -k62_reg;
                    a66 <= UNITY - k63_reg;

                    a77 <= UNITY - k71_reg;
                    a78 <= -k72_reg;
                    a79 <= -k73_reg;

                    a87 <= -k81_reg;
                    a88 <= UNITY - k82_reg;
                    a89 <= -k83_reg;

                    a97 <= -k91_reg;
                    a98 <= -k92_reg;
                    a99 <= UNITY - k93_reg;

                    state <= COMPUTE_AP;

                when COMPUTE_AP =>

                    ap(0) <= (a11 * p11_pred) + (a12 * p12_pred) + (a13 * p13_pred);
                    ap(1) <= (a11 * p12_pred) + (a12 * p22_pred) + (a13 * p23_pred);
                    ap(2) <= (a11 * p13_pred) + (a12 * p23_pred) + (a13 * p33_pred);
                    ap(3) <= (a11 * p14_pred) + (a12 * p24_pred) + (a13 * p34_pred);
                    ap(4) <= (a11 * p15_pred) + (a12 * p25_pred) + (a13 * p35_pred);
                    ap(5) <= (a11 * p16_pred) + (a12 * p26_pred) + (a13 * p36_pred);
                    ap(6) <= (a11 * p17_pred) + (a12 * p27_pred) + (a13 * p37_pred);
                    ap(7) <= (a11 * p18_pred) + (a12 * p28_pred) + (a13 * p38_pred);
                    ap(8) <= (a11 * p19_pred) + (a12 * p29_pred) + (a13 * p39_pred);

                    ap(9) <= (a21 * p11_pred) + (a22 * p12_pred) + (a23 * p13_pred);
                    ap(10) <= (a21 * p12_pred) + (a22 * p22_pred) + (a23 * p23_pred);
                    ap(11) <= (a21 * p13_pred) + (a22 * p23_pred) + (a23 * p33_pred);
                    ap(12) <= (a21 * p14_pred) + (a22 * p24_pred) + (a23 * p34_pred);
                    ap(13) <= (a21 * p15_pred) + (a22 * p25_pred) + (a23 * p35_pred);
                    ap(14) <= (a21 * p16_pred) + (a22 * p26_pred) + (a23 * p36_pred);
                    ap(15) <= (a21 * p17_pred) + (a22 * p27_pred) + (a23 * p37_pred);
                    ap(16) <= (a21 * p18_pred) + (a22 * p28_pred) + (a23 * p38_pred);
                    ap(17) <= (a21 * p19_pred) + (a22 * p29_pred) + (a23 * p39_pred);

                    ap(18) <= (a31 * p11_pred) + (a32 * p12_pred) + (a33 * p13_pred);
                    ap(19) <= (a31 * p12_pred) + (a32 * p22_pred) + (a33 * p23_pred);
                    ap(20) <= (a31 * p13_pred) + (a32 * p23_pred) + (a33 * p33_pred);
                    ap(21) <= (a31 * p14_pred) + (a32 * p24_pred) + (a33 * p34_pred);
                    ap(22) <= (a31 * p15_pred) + (a32 * p25_pred) + (a33 * p35_pred);
                    ap(23) <= (a31 * p16_pred) + (a32 * p26_pred) + (a33 * p36_pred);
                    ap(24) <= (a31 * p17_pred) + (a32 * p27_pred) + (a33 * p37_pred);
                    ap(25) <= (a31 * p18_pred) + (a32 * p28_pred) + (a33 * p38_pred);
                    ap(26) <= (a31 * p19_pred) + (a32 * p29_pred) + (a33 * p39_pred);

                    ap(27) <= (a44 * p14_pred) + (a45 * p15_pred) + (a46 * p16_pred);
                    ap(28) <= (a44 * p24_pred) + (a45 * p25_pred) + (a46 * p26_pred);
                    ap(29) <= (a44 * p34_pred) + (a45 * p35_pred) + (a46 * p36_pred);
                    ap(30) <= (a44 * p44_pred) + (a45 * p45_pred) + (a46 * p46_pred);
                    ap(31) <= (a44 * p45_pred) + (a45 * p55_pred) + (a46 * p56_pred);
                    ap(32) <= (a44 * p46_pred) + (a45 * p56_pred) + (a46 * p66_pred);
                    ap(33) <= (a44 * p47_pred) + (a45 * p57_pred) + (a46 * p67_pred);
                    ap(34) <= (a44 * p48_pred) + (a45 * p58_pred) + (a46 * p68_pred);
                    ap(35) <= (a44 * p49_pred) + (a45 * p59_pred) + (a46 * p69_pred);

                    ap(36) <= (a54 * p14_pred) + (a55 * p15_pred) + (a56 * p16_pred);
                    ap(37) <= (a54 * p24_pred) + (a55 * p25_pred) + (a56 * p26_pred);
                    ap(38) <= (a54 * p34_pred) + (a55 * p35_pred) + (a56 * p36_pred);
                    ap(39) <= (a54 * p44_pred) + (a55 * p45_pred) + (a56 * p46_pred);
                    ap(40) <= (a54 * p45_pred) + (a55 * p55_pred) + (a56 * p56_pred);
                    ap(41) <= (a54 * p46_pred) + (a55 * p56_pred) + (a56 * p66_pred);
                    ap(42) <= (a54 * p47_pred) + (a55 * p57_pred) + (a56 * p67_pred);
                    ap(43) <= (a54 * p48_pred) + (a55 * p58_pred) + (a56 * p68_pred);
                    ap(44) <= (a54 * p49_pred) + (a55 * p59_pred) + (a56 * p69_pred);

                    ap(45) <= (a64 * p14_pred) + (a65 * p15_pred) + (a66 * p16_pred);
                    ap(46) <= (a64 * p24_pred) + (a65 * p25_pred) + (a66 * p26_pred);
                    ap(47) <= (a64 * p34_pred) + (a65 * p35_pred) + (a66 * p36_pred);
                    ap(48) <= (a64 * p44_pred) + (a65 * p45_pred) + (a66 * p46_pred);
                    ap(49) <= (a64 * p45_pred) + (a65 * p55_pred) + (a66 * p56_pred);
                    ap(50) <= (a64 * p46_pred) + (a65 * p56_pred) + (a66 * p66_pred);
                    ap(51) <= (a64 * p47_pred) + (a65 * p57_pred) + (a66 * p67_pred);
                    ap(52) <= (a64 * p48_pred) + (a65 * p58_pred) + (a66 * p68_pred);
                    ap(53) <= (a64 * p49_pred) + (a65 * p59_pred) + (a66 * p69_pred);

                    ap(54) <= (a77 * p17_pred) + (a78 * p18_pred) + (a79 * p19_pred);
                    ap(55) <= (a77 * p27_pred) + (a78 * p28_pred) + (a79 * p29_pred);
                    ap(56) <= (a77 * p37_pred) + (a78 * p38_pred) + (a79 * p39_pred);
                    ap(57) <= (a77 * p47_pred) + (a78 * p48_pred) + (a79 * p49_pred);
                    ap(58) <= (a77 * p57_pred) + (a78 * p58_pred) + (a79 * p59_pred);
                    ap(59) <= (a77 * p67_pred) + (a78 * p68_pred) + (a79 * p69_pred);
                    ap(60) <= (a77 * p77_pred) + (a78 * p78_pred) + (a79 * p79_pred);
                    ap(61) <= (a77 * p78_pred) + (a78 * p88_pred) + (a79 * p89_pred);
                    ap(62) <= (a77 * p79_pred) + (a78 * p89_pred) + (a79 * p99_pred);

                    ap(63) <= (a87 * p17_pred) + (a88 * p18_pred) + (a89 * p19_pred);
                    ap(64) <= (a87 * p27_pred) + (a88 * p28_pred) + (a89 * p29_pred);
                    ap(65) <= (a87 * p37_pred) + (a88 * p38_pred) + (a89 * p39_pred);
                    ap(66) <= (a87 * p47_pred) + (a88 * p48_pred) + (a89 * p49_pred);
                    ap(67) <= (a87 * p57_pred) + (a88 * p58_pred) + (a89 * p59_pred);
                    ap(68) <= (a87 * p67_pred) + (a88 * p68_pred) + (a89 * p69_pred);
                    ap(69) <= (a87 * p77_pred) + (a88 * p78_pred) + (a89 * p79_pred);
                    ap(70) <= (a87 * p78_pred) + (a88 * p88_pred) + (a89 * p89_pred);
                    ap(71) <= (a87 * p79_pred) + (a88 * p89_pred) + (a89 * p99_pred);

                    ap(72) <= (a97 * p17_pred) + (a98 * p18_pred) + (a99 * p19_pred);
                    ap(73) <= (a97 * p27_pred) + (a98 * p28_pred) + (a99 * p29_pred);
                    ap(74) <= (a97 * p37_pred) + (a98 * p38_pred) + (a99 * p39_pred);
                    ap(75) <= (a97 * p47_pred) + (a98 * p48_pred) + (a99 * p49_pred);
                    ap(76) <= (a97 * p57_pred) + (a98 * p58_pred) + (a99 * p59_pred);
                    ap(77) <= (a97 * p67_pred) + (a98 * p68_pred) + (a99 * p69_pred);
                    ap(78) <= (a97 * p77_pred) + (a98 * p78_pred) + (a99 * p79_pred);
                    ap(79) <= (a97 * p78_pred) + (a98 * p88_pred) + (a99 * p89_pred);
                    ap(80) <= (a97 * p79_pred) + (a98 * p89_pred) + (a99 * p99_pred);

                    state <= SHIFT_AP;

                when SHIFT_AP =>

                    for i in 0 to 80 loop
                        ap_s(i) <= resize(shift_right(ap(i), Q), 48);
                    end loop;
                    state <= COMPUTE_APAT;

                when COMPUTE_APAT =>

                    apat_11 <= resize(ap_s(0) * a11, 96) + resize(ap_s(1) * a12, 96) + resize(ap_s(2) * a13, 96);

                    apat_12 <= resize(ap_s(0) * a21, 96) + resize(ap_s(1) * a22, 96) + resize(ap_s(2) * a23, 96);

                    apat_13 <= resize(ap_s(0) * a31, 96) + resize(ap_s(1) * a32, 96) + resize(ap_s(2) * a33, 96);

                    apat_14 <= resize(ap_s(3) * a44, 96) + resize(ap_s(4) * a45, 96) + resize(ap_s(5) * a46, 96);

                    apat_15 <= resize(ap_s(3) * a54, 96) + resize(ap_s(4) * a55, 96) + resize(ap_s(5) * a56, 96);

                    apat_16 <= resize(ap_s(3) * a64, 96) + resize(ap_s(4) * a65, 96) + resize(ap_s(5) * a66, 96);

                    apat_17 <= resize(ap_s(6) * a77, 96) + resize(ap_s(7) * a78, 96) + resize(ap_s(8) * a79, 96);

                    apat_18 <= resize(ap_s(6) * a87, 96) + resize(ap_s(7) * a88, 96) + resize(ap_s(8) * a89, 96);

                    apat_19 <= resize(ap_s(6) * a97, 96) + resize(ap_s(7) * a98, 96) + resize(ap_s(8) * a99, 96);

                    apat_22 <= resize(ap_s(9) * a21, 96) + resize(ap_s(10) * a22, 96) + resize(ap_s(11) * a23, 96);

                    apat_23 <= resize(ap_s(9) * a31, 96) + resize(ap_s(10) * a32, 96) + resize(ap_s(11) * a33, 96);

                    apat_24 <= resize(ap_s(12) * a44, 96) + resize(ap_s(13) * a45, 96) + resize(ap_s(14) * a46, 96);

                    apat_25 <= resize(ap_s(12) * a54, 96) + resize(ap_s(13) * a55, 96) + resize(ap_s(14) * a56, 96);

                    apat_26 <= resize(ap_s(12) * a64, 96) + resize(ap_s(13) * a65, 96) + resize(ap_s(14) * a66, 96);

                    apat_27 <= resize(ap_s(15) * a77, 96) + resize(ap_s(16) * a78, 96) + resize(ap_s(17) * a79, 96);

                    apat_28 <= resize(ap_s(15) * a87, 96) + resize(ap_s(16) * a88, 96) + resize(ap_s(17) * a89, 96);

                    apat_29 <= resize(ap_s(15) * a97, 96) + resize(ap_s(16) * a98, 96) + resize(ap_s(17) * a99, 96);

                    apat_33 <= resize(ap_s(18) * a31, 96) + resize(ap_s(19) * a32, 96) + resize(ap_s(20) * a33, 96);

                    apat_34 <= resize(ap_s(21) * a44, 96) + resize(ap_s(22) * a45, 96) + resize(ap_s(23) * a46, 96);

                    apat_35 <= resize(ap_s(21) * a54, 96) + resize(ap_s(22) * a55, 96) + resize(ap_s(23) * a56, 96);

                    apat_36 <= resize(ap_s(21) * a64, 96) + resize(ap_s(22) * a65, 96) + resize(ap_s(23) * a66, 96);

                    apat_37 <= resize(ap_s(24) * a77, 96) + resize(ap_s(25) * a78, 96) + resize(ap_s(26) * a79, 96);

                    apat_38 <= resize(ap_s(24) * a87, 96) + resize(ap_s(25) * a88, 96) + resize(ap_s(26) * a89, 96);

                    apat_39 <= resize(ap_s(24) * a97, 96) + resize(ap_s(25) * a98, 96) + resize(ap_s(26) * a99, 96);

                    apat_44 <= resize(ap_s(30) * a44, 96) + resize(ap_s(31) * a45, 96) + resize(ap_s(32) * a46, 96);

                    apat_45 <= resize(ap_s(30) * a54, 96) + resize(ap_s(31) * a55, 96) + resize(ap_s(32) * a56, 96);

                    apat_46 <= resize(ap_s(30) * a64, 96) + resize(ap_s(31) * a65, 96) + resize(ap_s(32) * a66, 96);

                    apat_47 <= resize(ap_s(33) * a77, 96) + resize(ap_s(34) * a78, 96) + resize(ap_s(35) * a79, 96);

                    apat_48 <= resize(ap_s(33) * a87, 96) + resize(ap_s(34) * a88, 96) + resize(ap_s(35) * a89, 96);

                    apat_49 <= resize(ap_s(33) * a97, 96) + resize(ap_s(34) * a98, 96) + resize(ap_s(35) * a99, 96);

                    apat_55 <= resize(ap_s(39) * a54, 96) + resize(ap_s(40) * a55, 96) + resize(ap_s(41) * a56, 96);

                    apat_56 <= resize(ap_s(39) * a64, 96) + resize(ap_s(40) * a65, 96) + resize(ap_s(41) * a66, 96);

                    apat_57 <= resize(ap_s(42) * a77, 96) + resize(ap_s(43) * a78, 96) + resize(ap_s(44) * a79, 96);

                    apat_58 <= resize(ap_s(42) * a87, 96) + resize(ap_s(43) * a88, 96) + resize(ap_s(44) * a89, 96);

                    apat_59 <= resize(ap_s(42) * a97, 96) + resize(ap_s(43) * a98, 96) + resize(ap_s(44) * a99, 96);

                    apat_66 <= resize(ap_s(48) * a64, 96) + resize(ap_s(49) * a65, 96) + resize(ap_s(50) * a66, 96);

                    apat_67 <= resize(ap_s(51) * a77, 96) + resize(ap_s(52) * a78, 96) + resize(ap_s(53) * a79, 96);

                    apat_68 <= resize(ap_s(51) * a87, 96) + resize(ap_s(52) * a88, 96) + resize(ap_s(53) * a89, 96);

                    apat_69 <= resize(ap_s(51) * a97, 96) + resize(ap_s(52) * a98, 96) + resize(ap_s(53) * a99, 96);

                    apat_77 <= resize(ap_s(60) * a77, 96) + resize(ap_s(61) * a78, 96) + resize(ap_s(62) * a79, 96);

                    apat_78 <= resize(ap_s(60) * a87, 96) + resize(ap_s(61) * a88, 96) + resize(ap_s(62) * a89, 96);

                    apat_79 <= resize(ap_s(60) * a97, 96) + resize(ap_s(61) * a98, 96) + resize(ap_s(62) * a99, 96);

                    apat_88 <= resize(ap_s(69) * a87, 96) + resize(ap_s(70) * a88, 96) + resize(ap_s(71) * a89, 96);

                    apat_89 <= resize(ap_s(69) * a97, 96) + resize(ap_s(70) * a98, 96) + resize(ap_s(71) * a99, 96);

                    apat_99 <= resize(ap_s(78) * a97, 96) + resize(ap_s(79) * a98, 96) + resize(ap_s(80) * a99, 96);

                    state <= COMPUTE_KR;
                when COMPUTE_KR =>

                    kr_11 <= k11_reg * R11_Q24_24;
                    kr_12 <= k12_reg * R22_Q24_24;
                    kr_13 <= k13_reg * R33_Q24_24;

                    kr_21 <= k21_reg * R11_Q24_24;
                    kr_22 <= k22_reg * R22_Q24_24;
                    kr_23 <= k23_reg * R33_Q24_24;

                    kr_31 <= k31_reg * R11_Q24_24;
                    kr_32 <= k32_reg * R22_Q24_24;
                    kr_33 <= k33_reg * R33_Q24_24;

                    kr_41 <= k41_reg * R11_Q24_24;
                    kr_42 <= k42_reg * R22_Q24_24;
                    kr_43 <= k43_reg * R33_Q24_24;

                    kr_51 <= k51_reg * R11_Q24_24;
                    kr_52 <= k52_reg * R22_Q24_24;
                    kr_53 <= k53_reg * R33_Q24_24;

                    kr_61 <= k61_reg * R11_Q24_24;
                    kr_62 <= k62_reg * R22_Q24_24;
                    kr_63 <= k63_reg * R33_Q24_24;

                    kr_71 <= k71_reg * R11_Q24_24;
                    kr_72 <= k72_reg * R22_Q24_24;
                    kr_73 <= k73_reg * R33_Q24_24;

                    kr_81 <= k81_reg * R11_Q24_24;
                    kr_82 <= k82_reg * R22_Q24_24;
                    kr_83 <= k83_reg * R33_Q24_24;

                    kr_91 <= k91_reg * R11_Q24_24;
                    kr_92 <= k92_reg * R22_Q24_24;
                    kr_93 <= k93_reg * R33_Q24_24;

                    state <= WAIT_KR;

                when WAIT_KR =>

                    kr_11_s <= resize(shift_right(kr_11, Q), 48); kr_12_s <= resize(shift_right(kr_12, Q), 48); kr_13_s <= resize(shift_right(kr_13, Q), 48);
                    kr_21_s <= resize(shift_right(kr_21, Q), 48); kr_22_s <= resize(shift_right(kr_22, Q), 48); kr_23_s <= resize(shift_right(kr_23, Q), 48);
                    kr_31_s <= resize(shift_right(kr_31, Q), 48); kr_32_s <= resize(shift_right(kr_32, Q), 48); kr_33_s <= resize(shift_right(kr_33, Q), 48);
                    kr_41_s <= resize(shift_right(kr_41, Q), 48); kr_42_s <= resize(shift_right(kr_42, Q), 48); kr_43_s <= resize(shift_right(kr_43, Q), 48);
                    kr_51_s <= resize(shift_right(kr_51, Q), 48); kr_52_s <= resize(shift_right(kr_52, Q), 48); kr_53_s <= resize(shift_right(kr_53, Q), 48);
                    kr_61_s <= resize(shift_right(kr_61, Q), 48); kr_62_s <= resize(shift_right(kr_62, Q), 48); kr_63_s <= resize(shift_right(kr_63, Q), 48);
                    kr_71_s <= resize(shift_right(kr_71, Q), 48); kr_72_s <= resize(shift_right(kr_72, Q), 48); kr_73_s <= resize(shift_right(kr_73, Q), 48);
                    kr_81_s <= resize(shift_right(kr_81, Q), 48); kr_82_s <= resize(shift_right(kr_82, Q), 48); kr_83_s <= resize(shift_right(kr_83, Q), 48);
                    kr_91_s <= resize(shift_right(kr_91, Q), 48); kr_92_s <= resize(shift_right(kr_92, Q), 48); kr_93_s <= resize(shift_right(kr_93, Q), 48);

                    state <= COMPUTE_KRK;

                when COMPUTE_KRK =>

                    krk_11 <= resize(kr_11_s * k11_reg, 96) + resize(kr_12_s * k12_reg, 96) + resize(kr_13_s * k13_reg, 96);

                    krk_12 <= resize(kr_11_s * k21_reg, 96) + resize(kr_12_s * k22_reg, 96) + resize(kr_13_s * k23_reg, 96);

                    krk_13 <= resize(kr_11_s * k31_reg, 96) + resize(kr_12_s * k32_reg, 96) + resize(kr_13_s * k33_reg, 96);

                    krk_14 <= resize(kr_11_s * k41_reg, 96) + resize(kr_12_s * k42_reg, 96) + resize(kr_13_s * k43_reg, 96);

                    krk_15 <= resize(kr_11_s * k51_reg, 96) + resize(kr_12_s * k52_reg, 96) + resize(kr_13_s * k53_reg, 96);

                    krk_16 <= resize(kr_11_s * k61_reg, 96) + resize(kr_12_s * k62_reg, 96) + resize(kr_13_s * k63_reg, 96);

                    krk_17 <= resize(kr_11_s * k71_reg, 96) + resize(kr_12_s * k72_reg, 96) + resize(kr_13_s * k73_reg, 96);

                    krk_18 <= resize(kr_11_s * k81_reg, 96) + resize(kr_12_s * k82_reg, 96) + resize(kr_13_s * k83_reg, 96);

                    krk_19 <= resize(kr_11_s * k91_reg, 96) + resize(kr_12_s * k92_reg, 96) + resize(kr_13_s * k93_reg, 96);

                    krk_22 <= resize(kr_21_s * k21_reg, 96) + resize(kr_22_s * k22_reg, 96) + resize(kr_23_s * k23_reg, 96);

                    krk_23 <= resize(kr_21_s * k31_reg, 96) + resize(kr_22_s * k32_reg, 96) + resize(kr_23_s * k33_reg, 96);

                    krk_24 <= resize(kr_21_s * k41_reg, 96) + resize(kr_22_s * k42_reg, 96) + resize(kr_23_s * k43_reg, 96);

                    krk_25 <= resize(kr_21_s * k51_reg, 96) + resize(kr_22_s * k52_reg, 96) + resize(kr_23_s * k53_reg, 96);

                    krk_26 <= resize(kr_21_s * k61_reg, 96) + resize(kr_22_s * k62_reg, 96) + resize(kr_23_s * k63_reg, 96);

                    krk_27 <= resize(kr_21_s * k71_reg, 96) + resize(kr_22_s * k72_reg, 96) + resize(kr_23_s * k73_reg, 96);

                    krk_28 <= resize(kr_21_s * k81_reg, 96) + resize(kr_22_s * k82_reg, 96) + resize(kr_23_s * k83_reg, 96);

                    krk_29 <= resize(kr_21_s * k91_reg, 96) + resize(kr_22_s * k92_reg, 96) + resize(kr_23_s * k93_reg, 96);

                    krk_33 <= resize(kr_31_s * k31_reg, 96) + resize(kr_32_s * k32_reg, 96) + resize(kr_33_s * k33_reg, 96);

                    krk_34 <= resize(kr_31_s * k41_reg, 96) + resize(kr_32_s * k42_reg, 96) + resize(kr_33_s * k43_reg, 96);

                    krk_35 <= resize(kr_31_s * k51_reg, 96) + resize(kr_32_s * k52_reg, 96) + resize(kr_33_s * k53_reg, 96);

                    krk_36 <= resize(kr_31_s * k61_reg, 96) + resize(kr_32_s * k62_reg, 96) + resize(kr_33_s * k63_reg, 96);

                    krk_37 <= resize(kr_31_s * k71_reg, 96) + resize(kr_32_s * k72_reg, 96) + resize(kr_33_s * k73_reg, 96);

                    krk_38 <= resize(kr_31_s * k81_reg, 96) + resize(kr_32_s * k82_reg, 96) + resize(kr_33_s * k83_reg, 96);

                    krk_39 <= resize(kr_31_s * k91_reg, 96) + resize(kr_32_s * k92_reg, 96) + resize(kr_33_s * k93_reg, 96);

                    krk_44 <= resize(kr_41_s * k41_reg, 96) + resize(kr_42_s * k42_reg, 96) + resize(kr_43_s * k43_reg, 96);

                    krk_45 <= resize(kr_41_s * k51_reg, 96) + resize(kr_42_s * k52_reg, 96) + resize(kr_43_s * k53_reg, 96);

                    krk_46 <= resize(kr_41_s * k61_reg, 96) + resize(kr_42_s * k62_reg, 96) + resize(kr_43_s * k63_reg, 96);

                    krk_47 <= resize(kr_41_s * k71_reg, 96) + resize(kr_42_s * k72_reg, 96) + resize(kr_43_s * k73_reg, 96);

                    krk_48 <= resize(kr_41_s * k81_reg, 96) + resize(kr_42_s * k82_reg, 96) + resize(kr_43_s * k83_reg, 96);

                    krk_49 <= resize(kr_41_s * k91_reg, 96) + resize(kr_42_s * k92_reg, 96) + resize(kr_43_s * k93_reg, 96);

                    krk_55 <= resize(kr_51_s * k51_reg, 96) + resize(kr_52_s * k52_reg, 96) + resize(kr_53_s * k53_reg, 96);

                    krk_56 <= resize(kr_51_s * k61_reg, 96) + resize(kr_52_s * k62_reg, 96) + resize(kr_53_s * k63_reg, 96);

                    krk_57 <= resize(kr_51_s * k71_reg, 96) + resize(kr_52_s * k72_reg, 96) + resize(kr_53_s * k73_reg, 96);

                    krk_58 <= resize(kr_51_s * k81_reg, 96) + resize(kr_52_s * k82_reg, 96) + resize(kr_53_s * k83_reg, 96);

                    krk_59 <= resize(kr_51_s * k91_reg, 96) + resize(kr_52_s * k92_reg, 96) + resize(kr_53_s * k93_reg, 96);

                    krk_66 <= resize(kr_61_s * k61_reg, 96) + resize(kr_62_s * k62_reg, 96) + resize(kr_63_s * k63_reg, 96);

                    krk_67 <= resize(kr_61_s * k71_reg, 96) + resize(kr_62_s * k72_reg, 96) + resize(kr_63_s * k73_reg, 96);

                    krk_68 <= resize(kr_61_s * k81_reg, 96) + resize(kr_62_s * k82_reg, 96) + resize(kr_63_s * k83_reg, 96);

                    krk_69 <= resize(kr_61_s * k91_reg, 96) + resize(kr_62_s * k92_reg, 96) + resize(kr_63_s * k93_reg, 96);

                    krk_77 <= resize(kr_71_s * k71_reg, 96) + resize(kr_72_s * k72_reg, 96) + resize(kr_73_s * k73_reg, 96);

                    krk_78 <= resize(kr_71_s * k81_reg, 96) + resize(kr_72_s * k82_reg, 96) + resize(kr_73_s * k83_reg, 96);

                    krk_79 <= resize(kr_71_s * k91_reg, 96) + resize(kr_72_s * k92_reg, 96) + resize(kr_73_s * k93_reg, 96);

                    krk_88 <= resize(kr_81_s * k81_reg, 96) + resize(kr_82_s * k82_reg, 96) + resize(kr_83_s * k83_reg, 96);

                    krk_89 <= resize(kr_81_s * k91_reg, 96) + resize(kr_82_s * k92_reg, 96) + resize(kr_83_s * k93_reg, 96);

                    krk_99 <= resize(kr_91_s * k91_reg, 96) + resize(kr_92_s * k92_reg, 96) + resize(kr_93_s * k93_reg, 96);

                    state <= ADD_APAT_KRK;
                when ADD_APAT_KRK =>

                    temp_sum := apat_11 + krk_11;

                    p11_upd <= saturate_covariance(temp_sum);
                    p12_upd <= resize(shift_right(apat_12 + krk_12, Q), 48);
                    p13_upd <= resize(shift_right(apat_13 + krk_13, Q), 48);
                    p14_upd <= resize(shift_right(apat_14 + krk_14, Q), 48);
                    p15_upd <= resize(shift_right(apat_15 + krk_15, Q), 48);
                    p16_upd <= resize(shift_right(apat_16 + krk_16, Q), 48);
                    p17_upd <= resize(shift_right(apat_17 + krk_17, Q), 48);
                    p18_upd <= resize(shift_right(apat_18 + krk_18, Q), 48);
                    p19_upd <= resize(shift_right(apat_19 + krk_19, Q), 48);

                    p22_upd <= saturate_covariance(apat_22 + krk_22);
                    p23_upd <= resize(shift_right(apat_23 + krk_23, Q), 48);
                    p24_upd <= resize(shift_right(apat_24 + krk_24, Q), 48);
                    p25_upd <= resize(shift_right(apat_25 + krk_25, Q), 48);
                    p26_upd <= resize(shift_right(apat_26 + krk_26, Q), 48);
                    p27_upd <= resize(shift_right(apat_27 + krk_27, Q), 48);
                    p28_upd <= resize(shift_right(apat_28 + krk_28, Q), 48);
                    p29_upd <= resize(shift_right(apat_29 + krk_29, Q), 48);

                    p33_upd <= saturate_covariance(apat_33 + krk_33);
                    p34_upd <= resize(shift_right(apat_34 + krk_34, Q), 48);
                    p35_upd <= resize(shift_right(apat_35 + krk_35, Q), 48);
                    p36_upd <= resize(shift_right(apat_36 + krk_36, Q), 48);
                    p37_upd <= resize(shift_right(apat_37 + krk_37, Q), 48);
                    p38_upd <= resize(shift_right(apat_38 + krk_38, Q), 48);
                    p39_upd <= resize(shift_right(apat_39 + krk_39, Q), 48);

                    p44_upd <= saturate_covariance(apat_44 + krk_44);
                    p45_upd <= resize(shift_right(apat_45 + krk_45, Q), 48);
                    p46_upd <= resize(shift_right(apat_46 + krk_46, Q), 48);
                    p47_upd <= resize(shift_right(apat_47 + krk_47, Q), 48);
                    p48_upd <= resize(shift_right(apat_48 + krk_48, Q), 48);
                    p49_upd <= resize(shift_right(apat_49 + krk_49, Q), 48);

                    p55_upd <= saturate_covariance(apat_55 + krk_55);
                    p56_upd <= resize(shift_right(apat_56 + krk_56, Q), 48);
                    p57_upd <= resize(shift_right(apat_57 + krk_57, Q), 48);
                    p58_upd <= resize(shift_right(apat_58 + krk_58, Q), 48);
                    p59_upd <= resize(shift_right(apat_59 + krk_59, Q), 48);

                    p66_upd <= saturate_covariance(apat_66 + krk_66);
                    p67_upd <= resize(shift_right(apat_67 + krk_67, Q), 48);
                    p68_upd <= resize(shift_right(apat_68 + krk_68, Q), 48);
                    p69_upd <= resize(shift_right(apat_69 + krk_69, Q), 48);

                    p77_upd <= saturate_covariance(apat_77 + krk_77);
                    p78_upd <= resize(shift_right(apat_78 + krk_78, Q), 48);
                    p79_upd <= resize(shift_right(apat_79 + krk_79, Q), 48);

                    p88_upd <= saturate_covariance(apat_88 + krk_88);
                    p89_upd <= resize(shift_right(apat_89 + krk_89, Q), 48);

                    p99_upd <= saturate_covariance(apat_99 + krk_99);

                    state <= FINISHED;
                when FINISHED =>
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
