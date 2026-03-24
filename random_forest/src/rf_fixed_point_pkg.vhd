library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package rf_fixed_point_pkg is

    constant Q          : integer := 24;
    constant Q_SCALE    : integer := 16777216;

    subtype q24_t is signed(47 downto 0);

    constant N_FEATURES : integer := 9;
    type feature_vector_t is array(0 to N_FEATURES-1) of q24_t;

    constant N_CLASSES       : integer := 10;
    constant CLASS_DRONE     : integer := 0;
    constant CLASS_MISSILE   : integer := 1;
    constant CLASS_CAR       : integer := 2;
    constant CLASS_F1        : integer := 3;
    constant CLASS_CAT       : integer := 4;
    constant CLASS_BIRD      : integer := 5;
    constant CLASS_AIRPLANE  : integer := 6;
    constant CLASS_BALL      : integer := 7;
    constant CLASS_ARTILLERY : integer := 8;
    constant CLASS_PEDESTRIAN: integer := 9;

    constant N_TREES      : integer := 20;

    constant MAX_TREES    : integer := 64;

    type class_count_t is array(0 to N_CLASSES-1) of integer range 0 to MAX_TREES;

    type tree_pred_t is array(0 to MAX_TREES-1) of integer range 0 to N_CLASSES-1;

    type integer_array_t is array(0 to N_CLASSES-1) of integer;

    function mul_q2424(a, b : q24_t) return q24_t;

    function abs_q24(a : q24_t) return q24_t;

    function sign_q24(a : q24_t) return q24_t;

end package rf_fixed_point_pkg;

package body rf_fixed_point_pkg is

    function mul_q2424(a, b : q24_t) return q24_t is
        variable prod96 : signed(95 downto 0);
    begin
        prod96 := resize(a, 96) * resize(b, 96);
        return prod96(71 downto 24);
    end function;

    function abs_q24(a : q24_t) return q24_t is
    begin
        if a(47) = '1' then
            return -a;
        else
            return a;
        end if;
    end function;

    function sign_q24(a : q24_t) return q24_t is
        constant ONE  : q24_t := to_signed(Q_SCALE, 48);
        constant MONE : q24_t := to_signed(-Q_SCALE, 48);
    begin
        if a(47) = '1' then
            return MONE;
        else
            return ONE;
        end if;
    end function;

end package body rf_fixed_point_pkg;
