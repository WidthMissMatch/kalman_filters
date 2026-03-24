library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity state_update_9d is
    port (
        clk   : in  std_logic;
        start : in  std_logic;

        s1_pred, s2_pred, s3_pred : in signed(47 downto 0);
        s4_pred, s5_pred, s6_pred : in signed(47 downto 0);
        s7_pred, s8_pred, s9_pred : in signed(47 downto 0);

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

        nu_1, nu_2, nu_3 : in signed(47 downto 0);

        s1_upd, s2_upd, s3_upd : buffer signed(47 downto 0);
        s4_upd, s5_upd, s6_upd : buffer signed(47 downto 0);
        s7_upd, s8_upd, s9_upd : buffer signed(47 downto 0);

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
end state_update_9d;

architecture Behavioral of state_update_9d is

    constant Q : integer := 24;
    constant UNITY : signed(47 downto 0) := to_signed(16777216, 48);

    constant SAFE_MAX_P : signed(47 downto 0) := signed'(X"3FFFFFFFFFFF");

    constant R11_Q24_24 : signed(47 downto 0) := to_signed(33554432, 48);
    constant R22_Q24_24 : signed(47 downto 0) := to_signed(33554432, 48);
    constant R33_Q24_24 : signed(47 downto 0) := to_signed(33554432, 48);

    type state_type is (IDLE, UPDATE_STATE, CONSTRUCT_A, COMPUTE_AP,
                        COMPUTE_APAT, COMPUTE_KR, COMPUTE_KRK, ADD_APAT_KRK, FINISHED);
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

    signal nu_1_reg, nu_2_reg, nu_3_reg : signed(47 downto 0);

    type a_matrix_type is array (1 to 9, 1 to 9) of signed(47 downto 0);
    signal a_mat : a_matrix_type;

    type ap_matrix_type is array (1 to 9, 1 to 9) of signed(95 downto 0);
    signal ap : ap_matrix_type;

    signal apat_11, apat_12, apat_13, apat_14, apat_15, apat_16, apat_17, apat_18, apat_19 : signed(143 downto 0);
    signal apat_22, apat_23, apat_24, apat_25, apat_26, apat_27, apat_28, apat_29           : signed(143 downto 0);
    signal apat_33, apat_34, apat_35, apat_36, apat_37, apat_38, apat_39                    : signed(143 downto 0);
    signal apat_44, apat_45, apat_46, apat_47, apat_48, apat_49                             : signed(143 downto 0);
    signal apat_55, apat_56, apat_57, apat_58, apat_59                                      : signed(143 downto 0);
    signal apat_66, apat_67, apat_68, apat_69                                               : signed(143 downto 0);
    signal apat_77, apat_78, apat_79                                                        : signed(143 downto 0);
    signal apat_88, apat_89                                                                 : signed(143 downto 0);
    signal apat_99                                                                          : signed(143 downto 0);

    signal kr_11, kr_12, kr_13 : signed(95 downto 0);
    signal kr_21, kr_22, kr_23 : signed(95 downto 0);
    signal kr_31, kr_32, kr_33 : signed(95 downto 0);
    signal kr_41, kr_42, kr_43 : signed(95 downto 0);
    signal kr_51, kr_52, kr_53 : signed(95 downto 0);
    signal kr_61, kr_62, kr_63 : signed(95 downto 0);
    signal kr_71, kr_72, kr_73 : signed(95 downto 0);
    signal kr_81, kr_82, kr_83 : signed(95 downto 0);
    signal kr_91, kr_92, kr_93 : signed(95 downto 0);

    signal krk_11, krk_12, krk_13, krk_14, krk_15, krk_16, krk_17, krk_18, krk_19 : signed(143 downto 0);
    signal krk_22, krk_23, krk_24, krk_25, krk_26, krk_27, krk_28, krk_29         : signed(143 downto 0);
    signal krk_33, krk_34, krk_35, krk_36, krk_37, krk_38, krk_39                 : signed(143 downto 0);
    signal krk_44, krk_45, krk_46, krk_47, krk_48, krk_49                         : signed(143 downto 0);
    signal krk_55, krk_56, krk_57, krk_58, krk_59                                 : signed(143 downto 0);
    signal krk_66, krk_67, krk_68, krk_69                                         : signed(143 downto 0);
    signal krk_77, krk_78, krk_79                                                 : signed(143 downto 0);
    signal krk_88, krk_89                                                         : signed(143 downto 0);
    signal krk_99                                                                 : signed(143 downto 0);

    function get_p(
        r, c : integer;
        pp11, pp12, pp13, pp14, pp15, pp16, pp17, pp18, pp19 : signed(47 downto 0);
        pp22, pp23, pp24, pp25, pp26, pp27, pp28, pp29       : signed(47 downto 0);
        pp33, pp34, pp35, pp36, pp37, pp38, pp39             : signed(47 downto 0);
        pp44, pp45, pp46, pp47, pp48, pp49                   : signed(47 downto 0);
        pp55, pp56, pp57, pp58, pp59                         : signed(47 downto 0);
        pp66, pp67, pp68, pp69                               : signed(47 downto 0);
        pp77, pp78, pp79                                     : signed(47 downto 0);
        pp88, pp89                                           : signed(47 downto 0);
        pp99                                                 : signed(47 downto 0)
    ) return signed is
        variable rr, cc : integer;
        variable result : signed(47 downto 0);
    begin

        if r <= c then
            rr := r; cc := c;
        else
            rr := c; cc := r;
        end if;

        result := (others => '0');
        case rr is
            when 1 =>
                case cc is
                    when 1 => result := pp11;
                    when 2 => result := pp12;
                    when 3 => result := pp13;
                    when 4 => result := pp14;
                    when 5 => result := pp15;
                    when 6 => result := pp16;
                    when 7 => result := pp17;
                    when 8 => result := pp18;
                    when 9 => result := pp19;
                    when others => null;
                end case;
            when 2 =>
                case cc is
                    when 2 => result := pp22;
                    when 3 => result := pp23;
                    when 4 => result := pp24;
                    when 5 => result := pp25;
                    when 6 => result := pp26;
                    when 7 => result := pp27;
                    when 8 => result := pp28;
                    when 9 => result := pp29;
                    when others => null;
                end case;
            when 3 =>
                case cc is
                    when 3 => result := pp33;
                    when 4 => result := pp34;
                    when 5 => result := pp35;
                    when 6 => result := pp36;
                    when 7 => result := pp37;
                    when 8 => result := pp38;
                    when 9 => result := pp39;
                    when others => null;
                end case;
            when 4 =>
                case cc is
                    when 4 => result := pp44;
                    when 5 => result := pp45;
                    when 6 => result := pp46;
                    when 7 => result := pp47;
                    when 8 => result := pp48;
                    when 9 => result := pp49;
                    when others => null;
                end case;
            when 5 =>
                case cc is
                    when 5 => result := pp55;
                    when 6 => result := pp56;
                    when 7 => result := pp57;
                    when 8 => result := pp58;
                    when 9 => result := pp59;
                    when others => null;
                end case;
            when 6 =>
                case cc is
                    when 6 => result := pp66;
                    when 7 => result := pp67;
                    when 8 => result := pp68;
                    when 9 => result := pp69;
                    when others => null;
                end case;
            when 7 =>
                case cc is
                    when 7 => result := pp77;
                    when 8 => result := pp78;
                    when 9 => result := pp79;
                    when others => null;
                end case;
            when 8 =>
                case cc is
                    when 8 => result := pp88;
                    when 9 => result := pp89;
                    when others => null;
                end case;
            when 9 =>
                result := pp99;
            when others => null;
        end case;
        return result;
    end function;

    function sat_cov(val : signed(143 downto 0); is_diag : boolean) return signed is
        variable shifted : signed(47 downto 0);
    begin
        shifted := resize(shift_right(val, 2*Q), 48);

        if is_diag then
            if shifted > SAFE_MAX_P then
                return SAFE_MAX_P;
            elsif shifted < UNITY then
                return UNITY;
            else
                return shifted;
            end if;
        else
            if shifted > SAFE_MAX_P then
                return SAFE_MAX_P;
            elsif shifted < -SAFE_MAX_P then
                return -SAFE_MAX_P;
            else
                return shifted;
            end if;
        end if;
    end function;

begin

    process(clk)
        variable temp_sum : signed(143 downto 0);
        variable p_val    : signed(47 downto 0);
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

                        nu_1_reg <= nu_1; nu_2_reg <= nu_2; nu_3_reg <= nu_3;

                        state <= UPDATE_STATE;
                    end if;

                when UPDATE_STATE =>

                    temp_sum := resize(k11_reg * nu_1_reg, 144) + resize(k12_reg * nu_2_reg, 144) + resize(k13_reg * nu_3_reg, 144);
                    s1_upd <= s1_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k21_reg * nu_1_reg, 144) + resize(k22_reg * nu_2_reg, 144) + resize(k23_reg * nu_3_reg, 144);
                    s2_upd <= s2_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k31_reg * nu_1_reg, 144) + resize(k32_reg * nu_2_reg, 144) + resize(k33_reg * nu_3_reg, 144);
                    s3_upd <= s3_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k41_reg * nu_1_reg, 144) + resize(k42_reg * nu_2_reg, 144) + resize(k43_reg * nu_3_reg, 144);
                    s4_upd <= s4_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k51_reg * nu_1_reg, 144) + resize(k52_reg * nu_2_reg, 144) + resize(k53_reg * nu_3_reg, 144);
                    s5_upd <= s5_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k61_reg * nu_1_reg, 144) + resize(k62_reg * nu_2_reg, 144) + resize(k63_reg * nu_3_reg, 144);
                    s6_upd <= s6_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k71_reg * nu_1_reg, 144) + resize(k72_reg * nu_2_reg, 144) + resize(k73_reg * nu_3_reg, 144);
                    s7_upd <= s7_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k81_reg * nu_1_reg, 144) + resize(k82_reg * nu_2_reg, 144) + resize(k83_reg * nu_3_reg, 144);
                    s8_upd <= s8_pred + resize(shift_right(temp_sum, Q), 48);

                    temp_sum := resize(k91_reg * nu_1_reg, 144) + resize(k92_reg * nu_2_reg, 144) + resize(k93_reg * nu_3_reg, 144);
                    s9_upd <= s9_pred + resize(shift_right(temp_sum, Q), 48);

                    state <= CONSTRUCT_A;

                when CONSTRUCT_A =>

                    for r in 1 to 9 loop
                        for c in 1 to 9 loop
                            a_mat(r, c) <= (others => '0');
                        end loop;
                    end loop;

                    a_mat(3, 3) <= UNITY;
                    a_mat(4, 4) <= UNITY;
                    a_mat(5, 5) <= UNITY;
                    a_mat(6, 6) <= UNITY;
                    a_mat(8, 8) <= UNITY;
                    a_mat(9, 9) <= UNITY;

                    a_mat(1, 1) <= UNITY - k11_reg;
                    a_mat(2, 1) <= -k21_reg;
                    a_mat(3, 1) <= -k31_reg;
                    a_mat(4, 1) <= -k41_reg;
                    a_mat(5, 1) <= -k51_reg;
                    a_mat(6, 1) <= -k61_reg;
                    a_mat(7, 1) <= -k71_reg;
                    a_mat(8, 1) <= -k81_reg;
                    a_mat(9, 1) <= -k91_reg;

                    a_mat(1, 2) <= -k12_reg;
                    a_mat(2, 2) <= UNITY - k22_reg;
                    a_mat(3, 2) <= -k32_reg;
                    a_mat(4, 2) <= -k42_reg;
                    a_mat(5, 2) <= -k52_reg;
                    a_mat(6, 2) <= -k62_reg;
                    a_mat(7, 2) <= -k72_reg;
                    a_mat(8, 2) <= -k82_reg;
                    a_mat(9, 2) <= -k92_reg;

                    a_mat(1, 7) <= -k13_reg;
                    a_mat(2, 7) <= -k23_reg;
                    a_mat(3, 7) <= -k33_reg;
                    a_mat(4, 7) <= -k43_reg;
                    a_mat(5, 7) <= -k53_reg;
                    a_mat(6, 7) <= -k63_reg;
                    a_mat(7, 7) <= UNITY - k73_reg;
                    a_mat(8, 7) <= -k83_reg;
                    a_mat(9, 7) <= -k93_reg;

                    state <= COMPUTE_AP;

                when COMPUTE_AP =>

                    for c in 1 to 9 loop
                        ap(1, c) <= (a_mat(1,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(1,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(1,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(2, c) <= (a_mat(2,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(2,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(2,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(3, c) <= (a_mat(3,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(3,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + resize(UNITY * get_p(3, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred), 96)
                        + (a_mat(3,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(4, c) <= (a_mat(4,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(4,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + resize(UNITY * get_p(4, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred), 96)
                        + (a_mat(4,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(5, c) <= (a_mat(5,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(5,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + resize(UNITY * get_p(5, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred), 96)
                        + (a_mat(5,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(6, c) <= (a_mat(6,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(6,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + resize(UNITY * get_p(6, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred), 96)
                        + (a_mat(6,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(7, c) <= (a_mat(7,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(7,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(7,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(8, c) <= (a_mat(8,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(8,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + resize(UNITY * get_p(8, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred), 96)
                        + (a_mat(8,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    for c in 1 to 9 loop
                        ap(9, c) <= (a_mat(9,1) * get_p(1, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + (a_mat(9,2) * get_p(2, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred))
                        + resize(UNITY * get_p(9, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred), 96)
                        + (a_mat(9,7) * get_p(7, c,
                            p11_pred, p12_pred, p13_pred, p14_pred, p15_pred, p16_pred, p17_pred, p18_pred, p19_pred,
                            p22_pred, p23_pred, p24_pred, p25_pred, p26_pred, p27_pred, p28_pred, p29_pred,
                            p33_pred, p34_pred, p35_pred, p36_pred, p37_pred, p38_pred, p39_pred,
                            p44_pred, p45_pred, p46_pred, p47_pred, p48_pred, p49_pred,
                            p55_pred, p56_pred, p57_pred, p58_pred, p59_pred,
                            p66_pred, p67_pred, p68_pred, p69_pred,
                            p77_pred, p78_pred, p79_pred,
                            p88_pred, p89_pred,
                            p99_pred));
                    end loop;

                    state <= COMPUTE_APAT;

                when COMPUTE_APAT =>

                    apat_11 <= resize(ap(1,1) * a_mat(1,1), 144) + resize(ap(1,2) * a_mat(1,2), 144) + resize(ap(1,7) * a_mat(1,7), 144);
                    apat_12 <= resize(ap(1,1) * a_mat(2,1), 144) + resize(ap(1,2) * a_mat(2,2), 144) + resize(ap(1,7) * a_mat(2,7), 144);
                    apat_13 <= resize(ap(1,1) * a_mat(3,1), 144) + resize(ap(1,2) * a_mat(3,2), 144) + resize(ap(1,3), 144) + resize(ap(1,7) * a_mat(3,7), 144);
                    apat_14 <= resize(ap(1,1) * a_mat(4,1), 144) + resize(ap(1,2) * a_mat(4,2), 144) + resize(ap(1,4), 144) + resize(ap(1,7) * a_mat(4,7), 144);
                    apat_15 <= resize(ap(1,1) * a_mat(5,1), 144) + resize(ap(1,2) * a_mat(5,2), 144) + resize(ap(1,5), 144) + resize(ap(1,7) * a_mat(5,7), 144);
                    apat_16 <= resize(ap(1,1) * a_mat(6,1), 144) + resize(ap(1,2) * a_mat(6,2), 144) + resize(ap(1,6), 144) + resize(ap(1,7) * a_mat(6,7), 144);
                    apat_17 <= resize(ap(1,1) * a_mat(7,1), 144) + resize(ap(1,2) * a_mat(7,2), 144) + resize(ap(1,7) * a_mat(7,7), 144);
                    apat_18 <= resize(ap(1,1) * a_mat(8,1), 144) + resize(ap(1,2) * a_mat(8,2), 144) + resize(ap(1,8), 144) + resize(ap(1,7) * a_mat(8,7), 144);
                    apat_19 <= resize(ap(1,1) * a_mat(9,1), 144) + resize(ap(1,2) * a_mat(9,2), 144) + resize(ap(1,9), 144) + resize(ap(1,7) * a_mat(9,7), 144);

                    apat_22 <= resize(ap(2,1) * a_mat(2,1), 144) + resize(ap(2,2) * a_mat(2,2), 144) + resize(ap(2,7) * a_mat(2,7), 144);
                    apat_23 <= resize(ap(2,1) * a_mat(3,1), 144) + resize(ap(2,2) * a_mat(3,2), 144) + resize(ap(2,3), 144) + resize(ap(2,7) * a_mat(3,7), 144);
                    apat_24 <= resize(ap(2,1) * a_mat(4,1), 144) + resize(ap(2,2) * a_mat(4,2), 144) + resize(ap(2,4), 144) + resize(ap(2,7) * a_mat(4,7), 144);
                    apat_25 <= resize(ap(2,1) * a_mat(5,1), 144) + resize(ap(2,2) * a_mat(5,2), 144) + resize(ap(2,5), 144) + resize(ap(2,7) * a_mat(5,7), 144);
                    apat_26 <= resize(ap(2,1) * a_mat(6,1), 144) + resize(ap(2,2) * a_mat(6,2), 144) + resize(ap(2,6), 144) + resize(ap(2,7) * a_mat(6,7), 144);
                    apat_27 <= resize(ap(2,1) * a_mat(7,1), 144) + resize(ap(2,2) * a_mat(7,2), 144) + resize(ap(2,7) * a_mat(7,7), 144);
                    apat_28 <= resize(ap(2,1) * a_mat(8,1), 144) + resize(ap(2,2) * a_mat(8,2), 144) + resize(ap(2,8), 144) + resize(ap(2,7) * a_mat(8,7), 144);
                    apat_29 <= resize(ap(2,1) * a_mat(9,1), 144) + resize(ap(2,2) * a_mat(9,2), 144) + resize(ap(2,9), 144) + resize(ap(2,7) * a_mat(9,7), 144);

                    apat_33 <= resize(ap(3,1) * a_mat(3,1), 144) + resize(ap(3,2) * a_mat(3,2), 144) + resize(ap(3,3), 144) + resize(ap(3,7) * a_mat(3,7), 144);
                    apat_34 <= resize(ap(3,1) * a_mat(4,1), 144) + resize(ap(3,2) * a_mat(4,2), 144) + resize(ap(3,4), 144) + resize(ap(3,7) * a_mat(4,7), 144);
                    apat_35 <= resize(ap(3,1) * a_mat(5,1), 144) + resize(ap(3,2) * a_mat(5,2), 144) + resize(ap(3,5), 144) + resize(ap(3,7) * a_mat(5,7), 144);
                    apat_36 <= resize(ap(3,1) * a_mat(6,1), 144) + resize(ap(3,2) * a_mat(6,2), 144) + resize(ap(3,6), 144) + resize(ap(3,7) * a_mat(6,7), 144);
                    apat_37 <= resize(ap(3,1) * a_mat(7,1), 144) + resize(ap(3,2) * a_mat(7,2), 144) + resize(ap(3,7) * a_mat(7,7), 144);
                    apat_38 <= resize(ap(3,1) * a_mat(8,1), 144) + resize(ap(3,2) * a_mat(8,2), 144) + resize(ap(3,8), 144) + resize(ap(3,7) * a_mat(8,7), 144);
                    apat_39 <= resize(ap(3,1) * a_mat(9,1), 144) + resize(ap(3,2) * a_mat(9,2), 144) + resize(ap(3,9), 144) + resize(ap(3,7) * a_mat(9,7), 144);

                    apat_44 <= resize(ap(4,1) * a_mat(4,1), 144) + resize(ap(4,2) * a_mat(4,2), 144) + resize(ap(4,4), 144) + resize(ap(4,7) * a_mat(4,7), 144);
                    apat_45 <= resize(ap(4,1) * a_mat(5,1), 144) + resize(ap(4,2) * a_mat(5,2), 144) + resize(ap(4,5), 144) + resize(ap(4,7) * a_mat(5,7), 144);
                    apat_46 <= resize(ap(4,1) * a_mat(6,1), 144) + resize(ap(4,2) * a_mat(6,2), 144) + resize(ap(4,6), 144) + resize(ap(4,7) * a_mat(6,7), 144);
                    apat_47 <= resize(ap(4,1) * a_mat(7,1), 144) + resize(ap(4,2) * a_mat(7,2), 144) + resize(ap(4,7) * a_mat(7,7), 144);
                    apat_48 <= resize(ap(4,1) * a_mat(8,1), 144) + resize(ap(4,2) * a_mat(8,2), 144) + resize(ap(4,8), 144) + resize(ap(4,7) * a_mat(8,7), 144);
                    apat_49 <= resize(ap(4,1) * a_mat(9,1), 144) + resize(ap(4,2) * a_mat(9,2), 144) + resize(ap(4,9), 144) + resize(ap(4,7) * a_mat(9,7), 144);

                    apat_55 <= resize(ap(5,1) * a_mat(5,1), 144) + resize(ap(5,2) * a_mat(5,2), 144) + resize(ap(5,5), 144) + resize(ap(5,7) * a_mat(5,7), 144);
                    apat_56 <= resize(ap(5,1) * a_mat(6,1), 144) + resize(ap(5,2) * a_mat(6,2), 144) + resize(ap(5,6), 144) + resize(ap(5,7) * a_mat(6,7), 144);
                    apat_57 <= resize(ap(5,1) * a_mat(7,1), 144) + resize(ap(5,2) * a_mat(7,2), 144) + resize(ap(5,7) * a_mat(7,7), 144);
                    apat_58 <= resize(ap(5,1) * a_mat(8,1), 144) + resize(ap(5,2) * a_mat(8,2), 144) + resize(ap(5,8), 144) + resize(ap(5,7) * a_mat(8,7), 144);
                    apat_59 <= resize(ap(5,1) * a_mat(9,1), 144) + resize(ap(5,2) * a_mat(9,2), 144) + resize(ap(5,9), 144) + resize(ap(5,7) * a_mat(9,7), 144);

                    apat_66 <= resize(ap(6,1) * a_mat(6,1), 144) + resize(ap(6,2) * a_mat(6,2), 144) + resize(ap(6,6), 144) + resize(ap(6,7) * a_mat(6,7), 144);
                    apat_67 <= resize(ap(6,1) * a_mat(7,1), 144) + resize(ap(6,2) * a_mat(7,2), 144) + resize(ap(6,7) * a_mat(7,7), 144);
                    apat_68 <= resize(ap(6,1) * a_mat(8,1), 144) + resize(ap(6,2) * a_mat(8,2), 144) + resize(ap(6,8), 144) + resize(ap(6,7) * a_mat(8,7), 144);
                    apat_69 <= resize(ap(6,1) * a_mat(9,1), 144) + resize(ap(6,2) * a_mat(9,2), 144) + resize(ap(6,9), 144) + resize(ap(6,7) * a_mat(9,7), 144);

                    apat_77 <= resize(ap(7,1) * a_mat(7,1), 144) + resize(ap(7,2) * a_mat(7,2), 144) + resize(ap(7,7) * a_mat(7,7), 144);
                    apat_78 <= resize(ap(7,1) * a_mat(8,1), 144) + resize(ap(7,2) * a_mat(8,2), 144) + resize(ap(7,8), 144) + resize(ap(7,7) * a_mat(8,7), 144);
                    apat_79 <= resize(ap(7,1) * a_mat(9,1), 144) + resize(ap(7,2) * a_mat(9,2), 144) + resize(ap(7,9), 144) + resize(ap(7,7) * a_mat(9,7), 144);

                    apat_88 <= resize(ap(8,1) * a_mat(8,1), 144) + resize(ap(8,2) * a_mat(8,2), 144) + resize(ap(8,8), 144) + resize(ap(8,7) * a_mat(8,7), 144);
                    apat_89 <= resize(ap(8,1) * a_mat(9,1), 144) + resize(ap(8,2) * a_mat(9,2), 144) + resize(ap(8,9), 144) + resize(ap(8,7) * a_mat(9,7), 144);

                    apat_99 <= resize(ap(9,1) * a_mat(9,1), 144) + resize(ap(9,2) * a_mat(9,2), 144) + resize(ap(9,9), 144) + resize(ap(9,7) * a_mat(9,7), 144);

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

                    state <= COMPUTE_KRK;

                when COMPUTE_KRK =>

                    krk_11 <= resize(kr_11 * k11_reg, 144) + resize(kr_12 * k12_reg, 144) + resize(kr_13 * k13_reg, 144);
                    krk_12 <= resize(kr_11 * k21_reg, 144) + resize(kr_12 * k22_reg, 144) + resize(kr_13 * k23_reg, 144);
                    krk_13 <= resize(kr_11 * k31_reg, 144) + resize(kr_12 * k32_reg, 144) + resize(kr_13 * k33_reg, 144);
                    krk_14 <= resize(kr_11 * k41_reg, 144) + resize(kr_12 * k42_reg, 144) + resize(kr_13 * k43_reg, 144);
                    krk_15 <= resize(kr_11 * k51_reg, 144) + resize(kr_12 * k52_reg, 144) + resize(kr_13 * k53_reg, 144);
                    krk_16 <= resize(kr_11 * k61_reg, 144) + resize(kr_12 * k62_reg, 144) + resize(kr_13 * k63_reg, 144);
                    krk_17 <= resize(kr_11 * k71_reg, 144) + resize(kr_12 * k72_reg, 144) + resize(kr_13 * k73_reg, 144);
                    krk_18 <= resize(kr_11 * k81_reg, 144) + resize(kr_12 * k82_reg, 144) + resize(kr_13 * k83_reg, 144);
                    krk_19 <= resize(kr_11 * k91_reg, 144) + resize(kr_12 * k92_reg, 144) + resize(kr_13 * k93_reg, 144);

                    krk_22 <= resize(kr_21 * k21_reg, 144) + resize(kr_22 * k22_reg, 144) + resize(kr_23 * k23_reg, 144);
                    krk_23 <= resize(kr_21 * k31_reg, 144) + resize(kr_22 * k32_reg, 144) + resize(kr_23 * k33_reg, 144);
                    krk_24 <= resize(kr_21 * k41_reg, 144) + resize(kr_22 * k42_reg, 144) + resize(kr_23 * k43_reg, 144);
                    krk_25 <= resize(kr_21 * k51_reg, 144) + resize(kr_22 * k52_reg, 144) + resize(kr_23 * k53_reg, 144);
                    krk_26 <= resize(kr_21 * k61_reg, 144) + resize(kr_22 * k62_reg, 144) + resize(kr_23 * k63_reg, 144);
                    krk_27 <= resize(kr_21 * k71_reg, 144) + resize(kr_22 * k72_reg, 144) + resize(kr_23 * k73_reg, 144);
                    krk_28 <= resize(kr_21 * k81_reg, 144) + resize(kr_22 * k82_reg, 144) + resize(kr_23 * k83_reg, 144);
                    krk_29 <= resize(kr_21 * k91_reg, 144) + resize(kr_22 * k92_reg, 144) + resize(kr_23 * k93_reg, 144);

                    krk_33 <= resize(kr_31 * k31_reg, 144) + resize(kr_32 * k32_reg, 144) + resize(kr_33 * k33_reg, 144);
                    krk_34 <= resize(kr_31 * k41_reg, 144) + resize(kr_32 * k42_reg, 144) + resize(kr_33 * k43_reg, 144);
                    krk_35 <= resize(kr_31 * k51_reg, 144) + resize(kr_32 * k52_reg, 144) + resize(kr_33 * k53_reg, 144);
                    krk_36 <= resize(kr_31 * k61_reg, 144) + resize(kr_32 * k62_reg, 144) + resize(kr_33 * k63_reg, 144);
                    krk_37 <= resize(kr_31 * k71_reg, 144) + resize(kr_32 * k72_reg, 144) + resize(kr_33 * k73_reg, 144);
                    krk_38 <= resize(kr_31 * k81_reg, 144) + resize(kr_32 * k82_reg, 144) + resize(kr_33 * k83_reg, 144);
                    krk_39 <= resize(kr_31 * k91_reg, 144) + resize(kr_32 * k92_reg, 144) + resize(kr_33 * k93_reg, 144);

                    krk_44 <= resize(kr_41 * k41_reg, 144) + resize(kr_42 * k42_reg, 144) + resize(kr_43 * k43_reg, 144);
                    krk_45 <= resize(kr_41 * k51_reg, 144) + resize(kr_42 * k52_reg, 144) + resize(kr_43 * k53_reg, 144);
                    krk_46 <= resize(kr_41 * k61_reg, 144) + resize(kr_42 * k62_reg, 144) + resize(kr_43 * k63_reg, 144);
                    krk_47 <= resize(kr_41 * k71_reg, 144) + resize(kr_42 * k72_reg, 144) + resize(kr_43 * k73_reg, 144);
                    krk_48 <= resize(kr_41 * k81_reg, 144) + resize(kr_42 * k82_reg, 144) + resize(kr_43 * k83_reg, 144);
                    krk_49 <= resize(kr_41 * k91_reg, 144) + resize(kr_42 * k92_reg, 144) + resize(kr_43 * k93_reg, 144);

                    krk_55 <= resize(kr_51 * k51_reg, 144) + resize(kr_52 * k52_reg, 144) + resize(kr_53 * k53_reg, 144);
                    krk_56 <= resize(kr_51 * k61_reg, 144) + resize(kr_52 * k62_reg, 144) + resize(kr_53 * k63_reg, 144);
                    krk_57 <= resize(kr_51 * k71_reg, 144) + resize(kr_52 * k72_reg, 144) + resize(kr_53 * k73_reg, 144);
                    krk_58 <= resize(kr_51 * k81_reg, 144) + resize(kr_52 * k82_reg, 144) + resize(kr_53 * k83_reg, 144);
                    krk_59 <= resize(kr_51 * k91_reg, 144) + resize(kr_52 * k92_reg, 144) + resize(kr_53 * k93_reg, 144);

                    krk_66 <= resize(kr_61 * k61_reg, 144) + resize(kr_62 * k62_reg, 144) + resize(kr_63 * k63_reg, 144);
                    krk_67 <= resize(kr_61 * k71_reg, 144) + resize(kr_62 * k72_reg, 144) + resize(kr_63 * k73_reg, 144);
                    krk_68 <= resize(kr_61 * k81_reg, 144) + resize(kr_62 * k82_reg, 144) + resize(kr_63 * k83_reg, 144);
                    krk_69 <= resize(kr_61 * k91_reg, 144) + resize(kr_62 * k92_reg, 144) + resize(kr_63 * k93_reg, 144);

                    krk_77 <= resize(kr_71 * k71_reg, 144) + resize(kr_72 * k72_reg, 144) + resize(kr_73 * k73_reg, 144);
                    krk_78 <= resize(kr_71 * k81_reg, 144) + resize(kr_72 * k82_reg, 144) + resize(kr_73 * k83_reg, 144);
                    krk_79 <= resize(kr_71 * k91_reg, 144) + resize(kr_72 * k92_reg, 144) + resize(kr_73 * k93_reg, 144);

                    krk_88 <= resize(kr_81 * k81_reg, 144) + resize(kr_82 * k82_reg, 144) + resize(kr_83 * k83_reg, 144);
                    krk_89 <= resize(kr_81 * k91_reg, 144) + resize(kr_82 * k92_reg, 144) + resize(kr_83 * k93_reg, 144);

                    krk_99 <= resize(kr_91 * k91_reg, 144) + resize(kr_92 * k92_reg, 144) + resize(kr_93 * k93_reg, 144);

                    state <= ADD_APAT_KRK;

                when ADD_APAT_KRK =>

                    p11_upd <= sat_cov(apat_11 + krk_11, true);
                    p12_upd <= sat_cov(apat_12 + krk_12, false);
                    p13_upd <= sat_cov(apat_13 + krk_13, false);
                    p14_upd <= sat_cov(apat_14 + krk_14, false);
                    p15_upd <= sat_cov(apat_15 + krk_15, false);
                    p16_upd <= sat_cov(apat_16 + krk_16, false);
                    p17_upd <= sat_cov(apat_17 + krk_17, false);
                    p18_upd <= sat_cov(apat_18 + krk_18, false);
                    p19_upd <= sat_cov(apat_19 + krk_19, false);

                    p22_upd <= sat_cov(apat_22 + krk_22, true);
                    p23_upd <= sat_cov(apat_23 + krk_23, false);
                    p24_upd <= sat_cov(apat_24 + krk_24, false);
                    p25_upd <= sat_cov(apat_25 + krk_25, false);
                    p26_upd <= sat_cov(apat_26 + krk_26, false);
                    p27_upd <= sat_cov(apat_27 + krk_27, false);
                    p28_upd <= sat_cov(apat_28 + krk_28, false);
                    p29_upd <= sat_cov(apat_29 + krk_29, false);

                    p33_upd <= sat_cov(apat_33 + krk_33, true);
                    p34_upd <= sat_cov(apat_34 + krk_34, false);
                    p35_upd <= sat_cov(apat_35 + krk_35, false);
                    p36_upd <= sat_cov(apat_36 + krk_36, false);
                    p37_upd <= sat_cov(apat_37 + krk_37, false);
                    p38_upd <= sat_cov(apat_38 + krk_38, false);
                    p39_upd <= sat_cov(apat_39 + krk_39, false);

                    p44_upd <= sat_cov(apat_44 + krk_44, true);
                    p45_upd <= sat_cov(apat_45 + krk_45, false);
                    p46_upd <= sat_cov(apat_46 + krk_46, false);
                    p47_upd <= sat_cov(apat_47 + krk_47, false);
                    p48_upd <= sat_cov(apat_48 + krk_48, false);
                    p49_upd <= sat_cov(apat_49 + krk_49, false);

                    p55_upd <= sat_cov(apat_55 + krk_55, true);
                    p56_upd <= sat_cov(apat_56 + krk_56, false);
                    p57_upd <= sat_cov(apat_57 + krk_57, false);
                    p58_upd <= sat_cov(apat_58 + krk_58, false);
                    p59_upd <= sat_cov(apat_59 + krk_59, false);

                    p66_upd <= sat_cov(apat_66 + krk_66, true);
                    p67_upd <= sat_cov(apat_67 + krk_67, false);
                    p68_upd <= sat_cov(apat_68 + krk_68, false);
                    p69_upd <= sat_cov(apat_69 + krk_69, false);

                    p77_upd <= sat_cov(apat_77 + krk_77, true);
                    p78_upd <= sat_cov(apat_78 + krk_78, false);
                    p79_upd <= sat_cov(apat_79 + krk_79, false);

                    p88_upd <= sat_cov(apat_88 + krk_88, true);
                    p89_upd <= sat_cov(apat_89 + krk_89, false);

                    p99_upd <= sat_cov(apat_99 + krk_99, true);

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
