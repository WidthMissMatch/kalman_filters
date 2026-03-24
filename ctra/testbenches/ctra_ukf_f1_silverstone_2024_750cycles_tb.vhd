library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ctra_ukf_f1_silverstone_2024_750cycles_tb is
end entity ctra_ukf_f1_silverstone_2024_750cycles_tb;

architecture behavioral of ctra_ukf_f1_silverstone_2024_750cycles_tb is

    component ctra_ukf_supreme is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            px_current    : out signed(47 downto 0);
            py_current    : out signed(47 downto 0);
            v_current     : out signed(47 downto 0);
            theta_current : out signed(47 downto 0);
            omega_current : out signed(47 downto 0);
            a_current     : out signed(47 downto 0);
            z_current     : out signed(47 downto 0);
            p11_diag : out signed(47 downto 0);
            p22_diag : out signed(47 downto 0);
            p33_diag : out signed(47 downto 0);
            p44_diag : out signed(47 downto 0);
            p55_diag : out signed(47 downto 0);
            p66_diag : out signed(47 downto 0);
            p77_diag : out signed(47 downto 0);
            done : out std_logic
        );
    end component;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal start : std_logic := '0';
    signal done  : std_logic;

    signal z_x_meas, z_y_meas, z_z_meas : signed(47 downto 0) := (others => '0');

    signal px_out, py_out, v_out, theta_out, omega_out, a_out, z_out : signed(47 downto 0);

    signal p11_out, p22_out, p33_out, p44_out, p55_out, p66_out, p77_out : signed(47 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := 750;

    type meas_triple is array(0 to 2) of signed(47 downto 0);
    type meas_data_array is array(0 to NUM_CYCLES-1) of meas_triple;

    constant MEAS_DATA : meas_data_array := (

        (to_signed(8333481, 48), to_signed(-15489284, 48), to_signed(13058732, 48)),

        (to_signed(134929687, 48), to_signed(-255123428, 48), to_signed(-11680712, 48)),

        (to_signed(285365164, 48), to_signed(-481264283, 48), to_signed(-18593799, 48)),

        (to_signed(437300331, 48), to_signed(-679660594, 48), to_signed(-7356664, 48)),

        (to_signed(545069065, 48), to_signed(-945711963, 48), to_signed(-12588624, 48)),

        (to_signed(676811505, 48), to_signed(-1112846333, 48), to_signed(-20111715, 48)),

        (to_signed(819595152, 48), to_signed(-1356149773, 48), to_signed(-4428351, 48)),

        (to_signed(912233928, 48), to_signed(-1561995863, 48), to_signed(-3819200, 48)),

        (to_signed(997740189, 48), to_signed(-1780168378, 48), to_signed(-22098109, 48)),

        (to_signed(1120977461, 48), to_signed(-1954688899, 48), to_signed(-2527257, 48)),

        (to_signed(1210358108, 48), to_signed(-2176766374, 48), to_signed(-50205231, 48)),

        (to_signed(1316577470, 48), to_signed(-2365732414, 48), to_signed(-38034701, 48)),

        (to_signed(1434708724, 48), to_signed(-2525498933, 48), to_signed(-50546686, 48)),

        (to_signed(1504807907, 48), to_signed(-2770732267, 48), to_signed(-73570459, 48)),

        (to_signed(1604998052, 48), to_signed(-2952144505, 48), to_signed(-46975684, 48)),

        (to_signed(1700001224, 48), to_signed(-3189343537, 48), to_signed(-50027862, 48)),

        (to_signed(1767939829, 48), to_signed(-3384253286, 48), to_signed(-24990549, 48)),

        (to_signed(1865701983, 48), to_signed(-3560077254, 48), to_signed(-42195504, 48)),

        (to_signed(1920693143, 48), to_signed(-3806425203, 48), to_signed(-72358517, 48)),

        (to_signed(1987730207, 48), to_signed(-3971618682, 48), to_signed(-26465747, 48)),

        (to_signed(2111511709, 48), to_signed(-4196272498, 48), to_signed(-39483457, 48)),

        (to_signed(2158631778, 48), to_signed(-4423703314, 48), to_signed(-52599769, 48)),

        (to_signed(2239050083, 48), to_signed(-4609776729, 48), to_signed(-68562266, 48)),

        (to_signed(2289511311, 48), to_signed(-4810190096, 48), to_signed(-83255958, 48)),

        (to_signed(2379778865, 48), to_signed(-5022194694, 48), to_signed(-75800577, 48)),

        (to_signed(2466270536, 48), to_signed(-5265091016, 48), to_signed(-53686558, 48)),

        (to_signed(2520596568, 48), to_signed(-5457066437, 48), to_signed(-42731363, 48)),

        (to_signed(2621707674, 48), to_signed(-5655139855, 48), to_signed(-50854889, 48)),

        (to_signed(2676442815, 48), to_signed(-5901466560, 48), to_signed(-88089983, 48)),

        (to_signed(2742516457, 48), to_signed(-6239626411, 48), to_signed(-103554212, 48)),

        (to_signed(2790395122, 48), to_signed(-6613897591, 48), to_signed(-87813896, 48)),

        (to_signed(2879438914, 48), to_signed(-7017466685, 48), to_signed(-125604977, 48)),

        (to_signed(2896009156, 48), to_signed(-7366869069, 48), to_signed(-96271546, 48)),

        (to_signed(2926362916, 48), to_signed(-7741188208, 48), to_signed(-109927673, 48)),

        (to_signed(3005781134, 48), to_signed(-8120224817, 48), to_signed(-121028020, 48)),

        (to_signed(3019371522, 48), to_signed(-8489668457, 48), to_signed(-145721815, 48)),

        (to_signed(3091230788, 48), to_signed(-8871994463, 48), to_signed(-116108270, 48)),

        (to_signed(3096345596, 48), to_signed(-9224040295, 48), to_signed(-139019848, 48)),

        (to_signed(3111174577, 48), to_signed(-9403421681, 48), to_signed(-152757881, 48)),

        (to_signed(3126071720, 48), to_signed(-9534212368, 48), to_signed(-183448430, 48)),

        (to_signed(3124469444, 48), to_signed(-9603239843, 48), to_signed(-137851424, 48)),

        (to_signed(3104266209, 48), to_signed(-9711064792, 48), to_signed(-109786286, 48)),

        (to_signed(3088761965, 48), to_signed(-9814094449, 48), to_signed(-113778362, 48)),

        (to_signed(3074961634, 48), to_signed(-9944172645, 48), to_signed(-151448403, 48)),

        (to_signed(3044518928, 48), to_signed(-10044991050, 48), to_signed(-156012976, 48)),

        (to_signed(3046558524, 48), to_signed(-10113286530, 48), to_signed(-140174740, 48)),

        (to_signed(3040218364, 48), to_signed(-10235720701, 48), to_signed(-166919529, 48)),

        (to_signed(3054993263, 48), to_signed(-10327724964, 48), to_signed(-147236106, 48)),

        (to_signed(3032333749, 48), to_signed(-10442785117, 48), to_signed(-141576573, 48)),

        (to_signed(2986300980, 48), to_signed(-10546862568, 48), to_signed(-135974677, 48)),

        (to_signed(3010628207, 48), to_signed(-10635721576, 48), to_signed(-160369441, 48)),

        (to_signed(2988041467, 48), to_signed(-10764222732, 48), to_signed(-164236146, 48)),

        (to_signed(2962891925, 48), to_signed(-10881001581, 48), to_signed(-177822495, 48)),

        (to_signed(2941940851, 48), to_signed(-11070963847, 48), to_signed(-179573043, 48)),

        (to_signed(2906405762, 48), to_signed(-11251091728, 48), to_signed(-172107880, 48)),

        (to_signed(2862162582, 48), to_signed(-11429583074, 48), to_signed(-164752726, 48)),

        (to_signed(2789888395, 48), to_signed(-11601263175, 48), to_signed(-158196592, 48)),

        (to_signed(2756210240, 48), to_signed(-11793615966, 48), to_signed(-189607007, 48)),

        (to_signed(2724385475, 48), to_signed(-11945109741, 48), to_signed(-153696644, 48)),

        (to_signed(2692624562, 48), to_signed(-12161780788, 48), to_signed(-185896403, 48)),

        (to_signed(2614970860, 48), to_signed(-12357569536, 48), to_signed(-184701013, 48)),

        (to_signed(2559529404, 48), to_signed(-12587520160, 48), to_signed(-200131436, 48)),

        (to_signed(2483717199, 48), to_signed(-12781574783, 48), to_signed(-231520081, 48)),

        (to_signed(2421843578, 48), to_signed(-13028261749, 48), to_signed(-179269033, 48)),

        (to_signed(2395178692, 48), to_signed(-13239956259, 48), to_signed(-184991439, 48)),

        (to_signed(2343934877, 48), to_signed(-13507899651, 48), to_signed(-205326296, 48)),

        (to_signed(2259606991, 48), to_signed(-13704204071, 48), to_signed(-202735260, 48)),

        (to_signed(2217285784, 48), to_signed(-13919467249, 48), to_signed(-198455928, 48)),

        (to_signed(2146150717, 48), to_signed(-14158720628, 48), to_signed(-236579896, 48)),

        (to_signed(2065726434, 48), to_signed(-14358708265, 48), to_signed(-222514766, 48)),

        (to_signed(2011687473, 48), to_signed(-14580219693, 48), to_signed(-203636738, 48)),

        (to_signed(1960502745, 48), to_signed(-14742853080, 48), to_signed(-241329326, 48)),

        (to_signed(1856099308, 48), to_signed(-14924244941, 48), to_signed(-218682592, 48)),

        (to_signed(1800237052, 48), to_signed(-15166123563, 48), to_signed(-249688033, 48)),

        (to_signed(1636659318, 48), to_signed(-15373908097, 48), to_signed(-222403786, 48)),

        (to_signed(1569040268, 48), to_signed(-15575974437, 48), to_signed(-234068339, 48)),

        (to_signed(1431351125, 48), to_signed(-15807781736, 48), to_signed(-263808981, 48)),

        (to_signed(1299513892, 48), to_signed(-16076979071, 48), to_signed(-220411674, 48)),

        (to_signed(1180709578, 48), to_signed(-16309180877, 48), to_signed(-255518351, 48)),

        (to_signed(1020463900, 48), to_signed(-16540783251, 48), to_signed(-260028921, 48)),

        (to_signed(924763976, 48), to_signed(-16792536203, 48), to_signed(-246311340, 48)),

        (to_signed(809080498, 48), to_signed(-17019316865, 48), to_signed(-233646587, 48)),

        (to_signed(702523776, 48), to_signed(-17254675506, 48), to_signed(-273201378, 48)),

        (to_signed(543673383, 48), to_signed(-17484634702, 48), to_signed(-258365091, 48)),

        (to_signed(406068433, 48), to_signed(-17696146964, 48), to_signed(-255068131, 48)),

        (to_signed(273561814, 48), to_signed(-17908705745, 48), to_signed(-253244253, 48)),

        (to_signed(159684995, 48), to_signed(-18103692303, 48), to_signed(-264522595, 48)),

        (to_signed(12189820, 48), to_signed(-18363525154, 48), to_signed(-276250656, 48)),

        (to_signed(-139866415, 48), to_signed(-18547331531, 48), to_signed(-286587768, 48)),

        (to_signed(-260020120, 48), to_signed(-18784506026, 48), to_signed(-273868011, 48)),

        (to_signed(-404655432, 48), to_signed(-18998815921, 48), to_signed(-295910930, 48)),

        (to_signed(-522150710, 48), to_signed(-19188483679, 48), to_signed(-329323549, 48)),

        (to_signed(-669383004, 48), to_signed(-19384875075, 48), to_signed(-274856788, 48)),

        (to_signed(-782304398, 48), to_signed(-19525856808, 48), to_signed(-268885161, 48)),

        (to_signed(-902588254, 48), to_signed(-19695713628, 48), to_signed(-325563724, 48)),

        (to_signed(-1039766109, 48), to_signed(-19856477925, 48), to_signed(-304730392, 48)),

        (to_signed(-1122863464, 48), to_signed(-19994308095, 48), to_signed(-278922269, 48)),

        (to_signed(-1231681895, 48), to_signed(-20071176758, 48), to_signed(-256077877, 48)),

        (to_signed(-1344206024, 48), to_signed(-20236279679, 48), to_signed(-291535032, 48)),

        (to_signed(-1456457670, 48), to_signed(-20347699147, 48), to_signed(-305384724, 48)),

        (to_signed(-1584498070, 48), to_signed(-20462455379, 48), to_signed(-297526324, 48)),

        (to_signed(-1676039484, 48), to_signed(-20574530494, 48), to_signed(-272678202, 48)),

        (to_signed(-1782962160, 48), to_signed(-20689115035, 48), to_signed(-307869250, 48)),

        (to_signed(-1898902481, 48), to_signed(-20771683385, 48), to_signed(-311726956, 48)),

        (to_signed(-1996378565, 48), to_signed(-20881009985, 48), to_signed(-307704801, 48)),

        (to_signed(-2095123929, 48), to_signed(-21027627944, 48), to_signed(-316886878, 48)),

        (to_signed(-2178487967, 48), to_signed(-21145227339, 48), to_signed(-300121581, 48)),

        (to_signed(-2315434123, 48), to_signed(-21236564008, 48), to_signed(-276209035, 48)),

        (to_signed(-2444405843, 48), to_signed(-21370321215, 48), to_signed(-299861996, 48)),

        (to_signed(-2595095339, 48), to_signed(-21469269738, 48), to_signed(-311684425, 48)),

        (to_signed(-2771157505, 48), to_signed(-21595316211, 48), to_signed(-314514687, 48)),

        (to_signed(-2884530218, 48), to_signed(-21742982784, 48), to_signed(-338013166, 48)),

        (to_signed(-3038974339, 48), to_signed(-21814062548, 48), to_signed(-299405315, 48)),

        (to_signed(-3179711088, 48), to_signed(-21940862465, 48), to_signed(-318582242, 48)),

        (to_signed(-3405317314, 48), to_signed(-22112240096, 48), to_signed(-323359214, 48)),

        (to_signed(-3578083506, 48), to_signed(-22239430675, 48), to_signed(-269814720, 48)),

        (to_signed(-3764777597, 48), to_signed(-22359097012, 48), to_signed(-321428846, 48)),

        (to_signed(-3964854993, 48), to_signed(-22489248699, 48), to_signed(-342108961, 48)),

        (to_signed(-4107127043, 48), to_signed(-22614778328, 48), to_signed(-339704006, 48)),

        (to_signed(-4294737684, 48), to_signed(-22723068147, 48), to_signed(-316338103, 48)),

        (to_signed(-4475134313, 48), to_signed(-22890729380, 48), to_signed(-336760375, 48)),

        (to_signed(-4684715215, 48), to_signed(-23032120818, 48), to_signed(-365845949, 48)),

        (to_signed(-4829136292, 48), to_signed(-23166423674, 48), to_signed(-329326634, 48)),

        (to_signed(-5063911881, 48), to_signed(-23273170685, 48), to_signed(-358900923, 48)),

        (to_signed(-5224663443, 48), to_signed(-23375160328, 48), to_signed(-319035697, 48)),

        (to_signed(-5391876073, 48), to_signed(-23458193700, 48), to_signed(-335117312, 48)),

        (to_signed(-5639360811, 48), to_signed(-23610682297, 48), to_signed(-363515422, 48)),

        (to_signed(-5826359817, 48), to_signed(-23711940518, 48), to_signed(-337291811, 48)),

        (to_signed(-6009303594, 48), to_signed(-23829667423, 48), to_signed(-360418366, 48)),

        (to_signed(-6224698758, 48), to_signed(-23927489556, 48), to_signed(-349978521, 48)),

        (to_signed(-6511388527, 48), to_signed(-24049018047, 48), to_signed(-358633993, 48)),

        (to_signed(-6778187408, 48), to_signed(-24254886907, 48), to_signed(-383352211, 48)),

        (to_signed(-7091125196, 48), to_signed(-24408759307, 48), to_signed(-382335919, 48)),

        (to_signed(-7359322127, 48), to_signed(-24537597232, 48), to_signed(-356645311, 48)),

        (to_signed(-7676658061, 48), to_signed(-24698242573, 48), to_signed(-381928026, 48)),

        (to_signed(-7929194090, 48), to_signed(-24833267675, 48), to_signed(-385469767, 48)),

        (to_signed(-8262303476, 48), to_signed(-25009021062, 48), to_signed(-397108210, 48)),

        (to_signed(-8548530955, 48), to_signed(-25179413141, 48), to_signed(-376363341, 48)),

        (to_signed(-8823444098, 48), to_signed(-25318043146, 48), to_signed(-351252970, 48)),

        (to_signed(-9151708121, 48), to_signed(-25463919199, 48), to_signed(-406152868, 48)),

        (to_signed(-9421206492, 48), to_signed(-25623322221, 48), to_signed(-390222544, 48)),

        (to_signed(-9697057413, 48), to_signed(-25783144450, 48), to_signed(-369321992, 48)),

        (to_signed(-10039921715, 48), to_signed(-25928326734, 48), to_signed(-396737524, 48)),

        (to_signed(-10265446696, 48), to_signed(-26062690819, 48), to_signed(-390221484, 48)),

        (to_signed(-10404656114, 48), to_signed(-26139760269, 48), to_signed(-418114942, 48)),

        (to_signed(-10536371298, 48), to_signed(-26232706209, 48), to_signed(-395585048, 48)),

        (to_signed(-10710712584, 48), to_signed(-26327034237, 48), to_signed(-408390522, 48)),

        (to_signed(-10852585467, 48), to_signed(-26402409720, 48), to_signed(-391192870, 48)),

        (to_signed(-10962147040, 48), to_signed(-26465270011, 48), to_signed(-390289556, 48)),

        (to_signed(-11106393077, 48), to_signed(-26579858485, 48), to_signed(-369244833, 48)),

        (to_signed(-11247644966, 48), to_signed(-26640607973, 48), to_signed(-405445783, 48)),

        (to_signed(-11386506988, 48), to_signed(-26734033121, 48), to_signed(-412184372, 48)),

        (to_signed(-11524925710, 48), to_signed(-26806801399, 48), to_signed(-416298862, 48)),

        (to_signed(-11615047518, 48), to_signed(-26865037246, 48), to_signed(-426928513, 48)),

        (to_signed(-11719454449, 48), to_signed(-26962482451, 48), to_signed(-416767825, 48)),

        (to_signed(-11841783517, 48), to_signed(-27044111938, 48), to_signed(-428845930, 48)),

        (to_signed(-11903923488, 48), to_signed(-27146908067, 48), to_signed(-422506887, 48)),

        (to_signed(-12032703693, 48), to_signed(-27190775862, 48), to_signed(-404670850, 48)),

        (to_signed(-12166067347, 48), to_signed(-27271668944, 48), to_signed(-445106726, 48)),

        (to_signed(-12240492749, 48), to_signed(-27325407432, 48), to_signed(-410539031, 48)),

        (to_signed(-12392193085, 48), to_signed(-27463079641, 48), to_signed(-408647953, 48)),

        (to_signed(-12543684645, 48), to_signed(-27601492509, 48), to_signed(-432726338, 48)),

        (to_signed(-12718500818, 48), to_signed(-27748238540, 48), to_signed(-466344295, 48)),

        (to_signed(-12932756685, 48), to_signed(-27873210492, 48), to_signed(-440943038, 48)),

        (to_signed(-13083874244, 48), to_signed(-28048527823, 48), to_signed(-408985519, 48)),

        (to_signed(-13274160792, 48), to_signed(-28189501088, 48), to_signed(-431129139, 48)),

        (to_signed(-13448343320, 48), to_signed(-28331236744, 48), to_signed(-447510986, 48)),

        (to_signed(-13622328056, 48), to_signed(-28500182430, 48), to_signed(-439432683, 48)),

        (to_signed(-13894374458, 48), to_signed(-28741083098, 48), to_signed(-418480688, 48)),

        (to_signed(-14151344300, 48), to_signed(-28983469357, 48), to_signed(-425625735, 48)),

        (to_signed(-14402063459, 48), to_signed(-29221845557, 48), to_signed(-441021467, 48)),

        (to_signed(-14649268086, 48), to_signed(-29510212639, 48), to_signed(-445381595, 48)),

        (to_signed(-14885315790, 48), to_signed(-29743892171, 48), to_signed(-448014363, 48)),

        (to_signed(-15126739835, 48), to_signed(-30011001572, 48), to_signed(-459131677, 48)),

        (to_signed(-15376262492, 48), to_signed(-30232338401, 48), to_signed(-418769146, 48)),

        (to_signed(-15615467939, 48), to_signed(-30531075254, 48), to_signed(-453492743, 48)),

        (to_signed(-15877568813, 48), to_signed(-30768030032, 48), to_signed(-429879022, 48)),

        (to_signed(-16101841871, 48), to_signed(-31005456776, 48), to_signed(-426990555, 48)),

        (to_signed(-16379109508, 48), to_signed(-31238652668, 48), to_signed(-437979576, 48)),

        (to_signed(-16577473615, 48), to_signed(-31519153371, 48), to_signed(-464184291, 48)),

        (to_signed(-16861054702, 48), to_signed(-31780497429, 48), to_signed(-452383887, 48)),

        (to_signed(-17134373553, 48), to_signed(-31992754610, 48), to_signed(-461777739, 48)),

        (to_signed(-17346241304, 48), to_signed(-32266124227, 48), to_signed(-478326885, 48)),

        (to_signed(-17483243834, 48), to_signed(-32453764670, 48), to_signed(-458950430, 48)),

        (to_signed(-17602815123, 48), to_signed(-32528357526, 48), to_signed(-484542749, 48)),

        (to_signed(-17694814761, 48), to_signed(-32663027732, 48), to_signed(-445205258, 48)),

        (to_signed(-17806581753, 48), to_signed(-32790603019, 48), to_signed(-473295664, 48)),

        (to_signed(-17923470891, 48), to_signed(-32880450242, 48), to_signed(-462495248, 48)),

        (to_signed(-18044183527, 48), to_signed(-33007109110, 48), to_signed(-461486833, 48)),

        (to_signed(-18163119267, 48), to_signed(-33139527992, 48), to_signed(-470952788, 48)),

        (to_signed(-18252923288, 48), to_signed(-33270409182, 48), to_signed(-457135462, 48)),

        (to_signed(-18338791684, 48), to_signed(-33353156749, 48), to_signed(-475315580, 48)),

        (to_signed(-18439021524, 48), to_signed(-33463160578, 48), to_signed(-452648218, 48)),

        (to_signed(-18540784591, 48), to_signed(-33573614744, 48), to_signed(-489465210, 48)),

        (to_signed(-18594250210, 48), to_signed(-33638851126, 48), to_signed(-464380379, 48)),

        (to_signed(-18667962292, 48), to_signed(-33785667303, 48), to_signed(-433588103, 48)),

        (to_signed(-18766526653, 48), to_signed(-33891190030, 48), to_signed(-482517967, 48)),

        (to_signed(-18826390048, 48), to_signed(-33975085961, 48), to_signed(-476723124, 48)),

        (to_signed(-18905263689, 48), to_signed(-34062124181, 48), to_signed(-456347765, 48)),

        (to_signed(-19002687270, 48), to_signed(-34155158522, 48), to_signed(-461574083, 48)),

        (to_signed(-19067405254, 48), to_signed(-34278010980, 48), to_signed(-458403827, 48)),

        (to_signed(-19191772180, 48), to_signed(-34433302608, 48), to_signed(-456025288, 48)),

        (to_signed(-19310782652, 48), to_signed(-34625451871, 48), to_signed(-453529689, 48)),

        (to_signed(-19439046025, 48), to_signed(-34745477580, 48), to_signed(-445506936, 48)),

        (to_signed(-19607612000, 48), to_signed(-34936323605, 48), to_signed(-457195056, 48)),

        (to_signed(-19728005290, 48), to_signed(-35081445630, 48), to_signed(-468064365, 48)),

        (to_signed(-19843720938, 48), to_signed(-35281541587, 48), to_signed(-452736122, 48)),

        (to_signed(-19992044461, 48), to_signed(-35481299613, 48), to_signed(-432186769, 48)),

        (to_signed(-20140325855, 48), to_signed(-35681074648, 48), to_signed(-466328186, 48)),

        (to_signed(-20232631376, 48), to_signed(-35884793549, 48), to_signed(-480494313, 48)),

        (to_signed(-20435994093, 48), to_signed(-36083192850, 48), to_signed(-445612155, 48)),

        (to_signed(-20574822979, 48), to_signed(-36273347566, 48), to_signed(-466247010, 48)),

        (to_signed(-20726171679, 48), to_signed(-36494021063, 48), to_signed(-500720158, 48)),

        (to_signed(-20877705220, 48), to_signed(-36687738726, 48), to_signed(-450067731, 48)),

        (to_signed(-21033045950, 48), to_signed(-36906299698, 48), to_signed(-473249635, 48)),

        (to_signed(-21152948897, 48), to_signed(-37086400612, 48), to_signed(-465798702, 48)),

        (to_signed(-21316573820, 48), to_signed(-37327677336, 48), to_signed(-458721587, 48)),

        (to_signed(-21444762993, 48), to_signed(-37493739465, 48), to_signed(-461355131, 48)),

        (to_signed(-21583883341, 48), to_signed(-37737824709, 48), to_signed(-453653667, 48)),

        (to_signed(-21709317128, 48), to_signed(-37974352132, 48), to_signed(-473867650, 48)),

        (to_signed(-21806807677, 48), to_signed(-38161395213, 48), to_signed(-458958022, 48)),

        (to_signed(-22011919171, 48), to_signed(-38388167338, 48), to_signed(-472926087, 48)),

        (to_signed(-22104028579, 48), to_signed(-38575834268, 48), to_signed(-457181542, 48)),

        (to_signed(-22277549453, 48), to_signed(-38814083879, 48), to_signed(-460257679, 48)),

        (to_signed(-22393360729, 48), to_signed(-39023817120, 48), to_signed(-487280997, 48)),

        (to_signed(-22502123923, 48), to_signed(-39261229376, 48), to_signed(-454372291, 48)),

        (to_signed(-22651233490, 48), to_signed(-39454254766, 48), to_signed(-482892574, 48)),

        (to_signed(-22800290596, 48), to_signed(-39707098083, 48), to_signed(-461854487, 48)),

        (to_signed(-22924106953, 48), to_signed(-39912771427, 48), to_signed(-470760236, 48)),

        (to_signed(-23030601499, 48), to_signed(-40093206117, 48), to_signed(-447593537, 48)),

        (to_signed(-23184153885, 48), to_signed(-40312546030, 48), to_signed(-483693126, 48)),

        (to_signed(-23297000239, 48), to_signed(-40539233474, 48), to_signed(-487314460, 48)),

        (to_signed(-23425101698, 48), to_signed(-40785864798, 48), to_signed(-483286792, 48)),

        (to_signed(-23562032760, 48), to_signed(-40993712257, 48), to_signed(-489554587, 48)),

        (to_signed(-23640365762, 48), to_signed(-41216242397, 48), to_signed(-472554364, 48)),

        (to_signed(-23790934233, 48), to_signed(-41458886253, 48), to_signed(-514599443, 48)),

        (to_signed(-23958342520, 48), to_signed(-41639854457, 48), to_signed(-506478087, 48)),

        (to_signed(-24042409504, 48), to_signed(-41877552784, 48), to_signed(-507906896, 48)),

        (to_signed(-24177812046, 48), to_signed(-42123174830, 48), to_signed(-475240525, 48)),

        (to_signed(-24273579077, 48), to_signed(-42346211783, 48), to_signed(-463676617, 48)),

        (to_signed(-24422348250, 48), to_signed(-42570361955, 48), to_signed(-495320219, 48)),

        (to_signed(-24532148340, 48), to_signed(-42835307851, 48), to_signed(-497592116, 48)),

        (to_signed(-24642922525, 48), to_signed(-43032395358, 48), to_signed(-494776383, 48)),

        (to_signed(-24758041267, 48), to_signed(-43266885392, 48), to_signed(-477650486, 48)),

        (to_signed(-24913048817, 48), to_signed(-43501380008, 48), to_signed(-513419084, 48)),

        (to_signed(-25017533051, 48), to_signed(-43721327238, 48), to_signed(-493886869, 48)),

        (to_signed(-25138899179, 48), to_signed(-43918486527, 48), to_signed(-481550292, 48)),

        (to_signed(-25260901831, 48), to_signed(-44169930688, 48), to_signed(-489529785, 48)),

        (to_signed(-25339331245, 48), to_signed(-44422300585, 48), to_signed(-494781455, 48)),

        (to_signed(-25481166053, 48), to_signed(-44635146991, 48), to_signed(-481192697, 48)),

        (to_signed(-25628124508, 48), to_signed(-44853311592, 48), to_signed(-543365533, 48)),

        (to_signed(-25710581084, 48), to_signed(-45093311646, 48), to_signed(-486665317, 48)),

        (to_signed(-25809386246, 48), to_signed(-45339859538, 48), to_signed(-509037103, 48)),

        (to_signed(-25946678093, 48), to_signed(-45583749313, 48), to_signed(-528801814, 48)),

        (to_signed(-26108500651, 48), to_signed(-45793216816, 48), to_signed(-489537691, 48)),

        (to_signed(-26210143819, 48), to_signed(-46030365015, 48), to_signed(-475093438, 48)),

        (to_signed(-26298163502, 48), to_signed(-46255510765, 48), to_signed(-500324459, 48)),

        (to_signed(-26447371154, 48), to_signed(-46495053736, 48), to_signed(-481867759, 48)),

        (to_signed(-26543395736, 48), to_signed(-46725079754, 48), to_signed(-470804800, 48)),

        (to_signed(-26653188947, 48), to_signed(-46988646260, 48), to_signed(-475793737, 48)),

        (to_signed(-26797079823, 48), to_signed(-47194542474, 48), to_signed(-470340302, 48)),

        (to_signed(-26897870540, 48), to_signed(-47450307684, 48), to_signed(-485403508, 48)),

        (to_signed(-27066594673, 48), to_signed(-47655783931, 48), to_signed(-496588774, 48)),

        (to_signed(-27144744963, 48), to_signed(-47939141860, 48), to_signed(-524730867, 48)),

        (to_signed(-27247139341, 48), to_signed(-48135432743, 48), to_signed(-501982584, 48)),

        (to_signed(-27379800961, 48), to_signed(-48399211732, 48), to_signed(-512186368, 48)),

        (to_signed(-27449402447, 48), to_signed(-48653183898, 48), to_signed(-462861519, 48)),

        (to_signed(-27618769672, 48), to_signed(-48889268205, 48), to_signed(-503817001, 48)),

        (to_signed(-27720144720, 48), to_signed(-49125419514, 48), to_signed(-500381327, 48)),

        (to_signed(-27828554653, 48), to_signed(-49351823685, 48), to_signed(-494778204, 48)),

        (to_signed(-27924553680, 48), to_signed(-49589063315, 48), to_signed(-504881299, 48)),

        (to_signed(-28090810120, 48), to_signed(-49846355158, 48), to_signed(-478756823, 48)),

        (to_signed(-28165191818, 48), to_signed(-50076033701, 48), to_signed(-519223616, 48)),

        (to_signed(-28302520903, 48), to_signed(-50278578797, 48), to_signed(-507094556, 48)),

        (to_signed(-28437145685, 48), to_signed(-50524431795, 48), to_signed(-524398350, 48)),

        (to_signed(-28530912010, 48), to_signed(-50784989893, 48), to_signed(-535670296, 48)),

        (to_signed(-28652972304, 48), to_signed(-51031016107, 48), to_signed(-525396151, 48)),

        (to_signed(-28783238171, 48), to_signed(-51270029868, 48), to_signed(-517423118, 48)),

        (to_signed(-28888853349, 48), to_signed(-51502140497, 48), to_signed(-525673615, 48)),

        (to_signed(-29013345153, 48), to_signed(-51769983193, 48), to_signed(-531757390, 48)),

        (to_signed(-29121832390, 48), to_signed(-51997531603, 48), to_signed(-545403960, 48)),

        (to_signed(-29229484416, 48), to_signed(-52261597698, 48), to_signed(-524873523, 48)),

        (to_signed(-29330840410, 48), to_signed(-52467295610, 48), to_signed(-550393636, 48)),

        (to_signed(-29495072685, 48), to_signed(-52703525277, 48), to_signed(-514066369, 48)),

        (to_signed(-29555375457, 48), to_signed(-52962879908, 48), to_signed(-527104258, 48)),

        (to_signed(-29740768648, 48), to_signed(-53168756229, 48), to_signed(-554610398, 48)),

        (to_signed(-29841677784, 48), to_signed(-53486582167, 48), to_signed(-537101931, 48)),

        (to_signed(-30003145051, 48), to_signed(-53852831031, 48), to_signed(-546555316, 48)),

        (to_signed(-30195002907, 48), to_signed(-54214116655, 48), to_signed(-530660165, 48)),

        (to_signed(-30405411239, 48), to_signed(-54608183550, 48), to_signed(-515642687, 48)),

        (to_signed(-30593702693, 48), to_signed(-55005367939, 48), to_signed(-571708577, 48)),

        (to_signed(-30793729070, 48), to_signed(-55449186970, 48), to_signed(-540435275, 48)),

        (to_signed(-30990592693, 48), to_signed(-55831259521, 48), to_signed(-547168365, 48)),

        (to_signed(-31161697741, 48), to_signed(-56257871460, 48), to_signed(-535335254, 48)),

        (to_signed(-31356412904, 48), to_signed(-56649504038, 48), to_signed(-545047353, 48)),

        (to_signed(-31534090729, 48), to_signed(-56965706391, 48), to_signed(-562992993, 48)),

        (to_signed(-31623566963, 48), to_signed(-57211295543, 48), to_signed(-557031601, 48)),

        (to_signed(-31720452294, 48), to_signed(-57428917836, 48), to_signed(-566034840, 48)),

        (to_signed(-31798918540, 48), to_signed(-57557928787, 48), to_signed(-535628315, 48)),

        (to_signed(-31888940864, 48), to_signed(-57739777592, 48), to_signed(-554324147, 48)),

        (to_signed(-32000360691, 48), to_signed(-57953657543, 48), to_signed(-523785987, 48)),

        (to_signed(-32082798920, 48), to_signed(-58116752520, 48), to_signed(-557701371, 48)),

        (to_signed(-32147811315, 48), to_signed(-58295335210, 48), to_signed(-569569722, 48)),

        (to_signed(-32237056687, 48), to_signed(-58479480940, 48), to_signed(-584081519, 48)),

        (to_signed(-32334595851, 48), to_signed(-58673317568, 48), to_signed(-589938247, 48)),

        (to_signed(-32419224933, 48), to_signed(-58855583609, 48), to_signed(-587264951, 48)),

        (to_signed(-32486705880, 48), to_signed(-59024975024, 48), to_signed(-557206896, 48)),

        (to_signed(-32605014640, 48), to_signed(-59185101830, 48), to_signed(-554154526, 48)),

        (to_signed(-32671405224, 48), to_signed(-59375342335, 48), to_signed(-589752492, 48)),

        (to_signed(-32768501232, 48), to_signed(-59570002327, 48), to_signed(-548432610, 48)),

        (to_signed(-32853286093, 48), to_signed(-59730159512, 48), to_signed(-571777628, 48)),

        (to_signed(-32915724599, 48), to_signed(-59970219101, 48), to_signed(-561434778, 48)),

        (to_signed(-33004835834, 48), to_signed(-60082477413, 48), to_signed(-537073329, 48)),

        (to_signed(-33089560602, 48), to_signed(-60310260076, 48), to_signed(-549299783, 48)),

        (to_signed(-33165831736, 48), to_signed(-60466475290, 48), to_signed(-569075794, 48)),

        (to_signed(-33271906657, 48), to_signed(-60658501501, 48), to_signed(-579746669, 48)),

        (to_signed(-33352862929, 48), to_signed(-60857386376, 48), to_signed(-601051055, 48)),

        (to_signed(-33484115223, 48), to_signed(-61062018400, 48), to_signed(-576960485, 48)),

        (to_signed(-33591856681, 48), to_signed(-61342942014, 48), to_signed(-568455435, 48)),

        (to_signed(-33723065892, 48), to_signed(-61592803057, 48), to_signed(-581736726, 48)),

        (to_signed(-33850887609, 48), to_signed(-61877138173, 48), to_signed(-568222317, 48)),

        (to_signed(-33974162330, 48), to_signed(-62146082107, 48), to_signed(-565576418, 48)),

        (to_signed(-34129507351, 48), to_signed(-62430531214, 48), to_signed(-571483825, 48)),

        (to_signed(-34212307930, 48), to_signed(-62731079657, 48), to_signed(-579462190, 48)),

        (to_signed(-34395923011, 48), to_signed(-62970574584, 48), to_signed(-566572989, 48)),

        (to_signed(-34531048022, 48), to_signed(-63273307576, 48), to_signed(-562833600, 48)),

        (to_signed(-34627268564, 48), to_signed(-63575254960, 48), to_signed(-590131107, 48)),

        (to_signed(-34772363430, 48), to_signed(-63844692953, 48), to_signed(-550250525, 48)),

        (to_signed(-34914121219, 48), to_signed(-64100702325, 48), to_signed(-577660873, 48)),

        (to_signed(-35052997209, 48), to_signed(-64399987066, 48), to_signed(-577775391, 48)),

        (to_signed(-35202691450, 48), to_signed(-64708471356, 48), to_signed(-568294565, 48)),

        (to_signed(-35356486299, 48), to_signed(-64996852040, 48), to_signed(-578348510, 48)),

        (to_signed(-35479107965, 48), to_signed(-65284759132, 48), to_signed(-568355044, 48)),

        (to_signed(-35630687529, 48), to_signed(-65532891466, 48), to_signed(-581613675, 48)),

        (to_signed(-35741913732, 48), to_signed(-65849696225, 48), to_signed(-598790610, 48)),

        (to_signed(-35899687626, 48), to_signed(-66137259661, 48), to_signed(-584535389, 48)),

        (to_signed(-36050016843, 48), to_signed(-66415559798, 48), to_signed(-611873750, 48)),

        (to_signed(-36180506143, 48), to_signed(-66717209393, 48), to_signed(-592948674, 48)),

        (to_signed(-36296878870, 48), to_signed(-66993108386, 48), to_signed(-597506221, 48)),

        (to_signed(-36431567326, 48), to_signed(-67238568112, 48), to_signed(-602694601, 48)),

        (to_signed(-36545915789, 48), to_signed(-67466296980, 48), to_signed(-603643958, 48)),

        (to_signed(-36638044449, 48), to_signed(-67695541999, 48), to_signed(-635344121, 48)),

        (to_signed(-36748034608, 48), to_signed(-67912531718, 48), to_signed(-615262486, 48)),

        (to_signed(-36870661182, 48), to_signed(-68153689612, 48), to_signed(-606783207, 48)),

        (to_signed(-36980070421, 48), to_signed(-68372091261, 48), to_signed(-607943417, 48)),

        (to_signed(-37078286180, 48), to_signed(-68615558925, 48), to_signed(-630151367, 48)),

        (to_signed(-37212443716, 48), to_signed(-68834299969, 48), to_signed(-593806948, 48)),

        (to_signed(-37315037067, 48), to_signed(-69084953164, 48), to_signed(-631604624, 48)),

        (to_signed(-37406752088, 48), to_signed(-69251865164, 48), to_signed(-602838448, 48)),

        (to_signed(-37501554494, 48), to_signed(-69477235150, 48), to_signed(-613966729, 48)),

        (to_signed(-37596032132, 48), to_signed(-69682114102, 48), to_signed(-634006376, 48)),

        (to_signed(-37679770777, 48), to_signed(-69963258706, 48), to_signed(-595410326, 48)),

        (to_signed(-37793408857, 48), to_signed(-70095440162, 48), to_signed(-647251623, 48)),

        (to_signed(-37913756172, 48), to_signed(-70348628871, 48), to_signed(-613835492, 48)),

        (to_signed(-38021009222, 48), to_signed(-70555832543, 48), to_signed(-614206286, 48)),

        (to_signed(-38154190031, 48), to_signed(-70833745458, 48), to_signed(-643660196, 48)),

        (to_signed(-38260975100, 48), to_signed(-71060765948, 48), to_signed(-610170656, 48)),

        (to_signed(-38388801511, 48), to_signed(-71343467826, 48), to_signed(-638850722, 48)),

        (to_signed(-38501838426, 48), to_signed(-71591007409, 48), to_signed(-630935453, 48)),

        (to_signed(-38644425499, 48), to_signed(-71803178041, 48), to_signed(-632534743, 48)),

        (to_signed(-38745127800, 48), to_signed(-72093237135, 48), to_signed(-640278836, 48)),

        (to_signed(-38851420019, 48), to_signed(-72341137954, 48), to_signed(-625545695, 48)),

        (to_signed(-39003798389, 48), to_signed(-72588336429, 48), to_signed(-627332887, 48)),

        (to_signed(-39121102320, 48), to_signed(-72855032129, 48), to_signed(-671726421, 48)),

        (to_signed(-39242131457, 48), to_signed(-73121239229, 48), to_signed(-622253228, 48)),

        (to_signed(-39386309742, 48), to_signed(-73378054358, 48), to_signed(-673773916, 48)),

        (to_signed(-39501686959, 48), to_signed(-73604269313, 48), to_signed(-630304182, 48)),

        (to_signed(-39629378984, 48), to_signed(-73902963515, 48), to_signed(-630939852, 48)),

        (to_signed(-39748071129, 48), to_signed(-74149005327, 48), to_signed(-671458014, 48)),

        (to_signed(-39882798427, 48), to_signed(-74385134530, 48), to_signed(-663358762, 48)),

        (to_signed(-39989537874, 48), to_signed(-74634596315, 48), to_signed(-678328895, 48)),

        (to_signed(-40101713674, 48), to_signed(-74883611275, 48), to_signed(-666695833, 48)),

        (to_signed(-40205842161, 48), to_signed(-75143192601, 48), to_signed(-671569822, 48)),

        (to_signed(-40334214030, 48), to_signed(-75423467533, 48), to_signed(-656633138, 48)),

        (to_signed(-40441633649, 48), to_signed(-75641790398, 48), to_signed(-651121484, 48)),

        (to_signed(-40622969158, 48), to_signed(-75963011965, 48), to_signed(-653133165, 48)),

        (to_signed(-40727797236, 48), to_signed(-76213286748, 48), to_signed(-689424505, 48)),

        (to_signed(-40878580343, 48), to_signed(-76519031821, 48), to_signed(-686764538, 48)),

        (to_signed(-41000210719, 48), to_signed(-76826799197, 48), to_signed(-714333321, 48)),

        (to_signed(-41205803715, 48), to_signed(-77139553379, 48), to_signed(-702445707, 48)),

        (to_signed(-41361624119, 48), to_signed(-77459023581, 48), to_signed(-675573463, 48)),

        (to_signed(-41512885268, 48), to_signed(-77776682367, 48), to_signed(-667491542, 48)),

        (to_signed(-41693755390, 48), to_signed(-78076033403, 48), to_signed(-718140998, 48)),

        (to_signed(-41822236243, 48), to_signed(-78414843906, 48), to_signed(-710207498, 48)),

        (to_signed(-41979256829, 48), to_signed(-78741092248, 48), to_signed(-703041238, 48)),

        (to_signed(-42115643970, 48), to_signed(-79032162357, 48), to_signed(-699891918, 48)),

        (to_signed(-42264079909, 48), to_signed(-79339722129, 48), to_signed(-720169154, 48)),

        (to_signed(-42389983162, 48), to_signed(-79691615050, 48), to_signed(-701465716, 48)),

        (to_signed(-42557161082, 48), to_signed(-79972337575, 48), to_signed(-718524003, 48)),

        (to_signed(-42734431848, 48), to_signed(-80281937635, 48), to_signed(-712810786, 48)),

        (to_signed(-42891472371, 48), to_signed(-80610034725, 48), to_signed(-705397207, 48)),

        (to_signed(-43005328524, 48), to_signed(-80864464287, 48), to_signed(-716165780, 48)),

        (to_signed(-43139163264, 48), to_signed(-81105274421, 48), to_signed(-724646131, 48)),

        (to_signed(-43189718514, 48), to_signed(-81315862172, 48), to_signed(-720215001, 48)),

        (to_signed(-43304089440, 48), to_signed(-81536084747, 48), to_signed(-720909802, 48)),

        (to_signed(-43435180490, 48), to_signed(-81748131799, 48), to_signed(-726686335, 48)),

        (to_signed(-43559482525, 48), to_signed(-81981997705, 48), to_signed(-725871721, 48)),

        (to_signed(-43611458555, 48), to_signed(-82202977394, 48), to_signed(-695760258, 48)),

        (to_signed(-43739526291, 48), to_signed(-82367278082, 48), to_signed(-714221703, 48)),

        (to_signed(-43820269388, 48), to_signed(-82623451180, 48), to_signed(-729640970, 48)),

        (to_signed(-43968956512, 48), to_signed(-82836615532, 48), to_signed(-714038408, 48)),

        (to_signed(-44051924313, 48), to_signed(-83063871231, 48), to_signed(-732377298, 48)),

        (to_signed(-44141442509, 48), to_signed(-83246223950, 48), to_signed(-708140344, 48)),

        (to_signed(-44240404294, 48), to_signed(-83465462325, 48), to_signed(-722665916, 48)),

        (to_signed(-44348405357, 48), to_signed(-83623476730, 48), to_signed(-731713088, 48)),

        (to_signed(-44430066838, 48), to_signed(-83841843865, 48), to_signed(-723446786, 48)),

        (to_signed(-44558090239, 48), to_signed(-84078091642, 48), to_signed(-758358532, 48)),

        (to_signed(-44647382852, 48), to_signed(-84246810290, 48), to_signed(-752072492, 48)),

        (to_signed(-44766697929, 48), to_signed(-84523961450, 48), to_signed(-754793885, 48)),

        (to_signed(-44888394983, 48), to_signed(-84810890438, 48), to_signed(-734060297, 48)),

        (to_signed(-45013396598, 48), to_signed(-85112381671, 48), to_signed(-709087043, 48)),

        (to_signed(-45172513557, 48), to_signed(-85297020894, 48), to_signed(-702414154, 48)),

        (to_signed(-45307693038, 48), to_signed(-85623777620, 48), to_signed(-730839775, 48)),

        (to_signed(-45388828692, 48), to_signed(-85893077603, 48), to_signed(-734837057, 48)),

        (to_signed(-45532998928, 48), to_signed(-86113324438, 48), to_signed(-775151905, 48)),

        (to_signed(-45679441432, 48), to_signed(-86354556000, 48), to_signed(-755735063, 48)),

        (to_signed(-45769169579, 48), to_signed(-86637271940, 48), to_signed(-761542663, 48)),

        (to_signed(-45918112664, 48), to_signed(-86909187665, 48), to_signed(-760341359, 48)),

        (to_signed(-46017078025, 48), to_signed(-87150826020, 48), to_signed(-754121865, 48)),

        (to_signed(-46152540563, 48), to_signed(-87388642256, 48), to_signed(-760596859, 48)),

        (to_signed(-46242854453, 48), to_signed(-87647595986, 48), to_signed(-787191159, 48)),

        (to_signed(-46376362894, 48), to_signed(-87923121352, 48), to_signed(-742698298, 48)),

        (to_signed(-46538374113, 48), to_signed(-88193601024, 48), to_signed(-774505922, 48)),

        (to_signed(-46646281493, 48), to_signed(-88463909634, 48), to_signed(-753756515, 48)),

        (to_signed(-46780138698, 48), to_signed(-88743019190, 48), to_signed(-724235210, 48)),

        (to_signed(-46896389043, 48), to_signed(-89002588977, 48), to_signed(-775719388, 48)),

        (to_signed(-47063924160, 48), to_signed(-89293793399, 48), to_signed(-804007985, 48)),

        (to_signed(-47164609958, 48), to_signed(-89534550430, 48), to_signed(-767617291, 48)),

        (to_signed(-47286747136, 48), to_signed(-89816996638, 48), to_signed(-745610030, 48)),

        (to_signed(-47462395866, 48), to_signed(-90086436255, 48), to_signed(-732487580, 48)),

        (to_signed(-47600188765, 48), to_signed(-90372123688, 48), to_signed(-787418041, 48)),

        (to_signed(-47819187406, 48), to_signed(-90778139935, 48), to_signed(-760455693, 48)),

        (to_signed(-47994132451, 48), to_signed(-91212439109, 48), to_signed(-778594838, 48)),

        (to_signed(-48182211980, 48), to_signed(-91680546579, 48), to_signed(-774565043, 48)),

        (to_signed(-48376096261, 48), to_signed(-92101765291, 48), to_signed(-730545283, 48)),

        (to_signed(-48608718816, 48), to_signed(-92503417423, 48), to_signed(-802330258, 48)),

        (to_signed(-48791298575, 48), to_signed(-92969723206, 48), to_signed(-775062152, 48)),

        (to_signed(-49050436760, 48), to_signed(-93391047381, 48), to_signed(-773677205, 48)),

        (to_signed(-49233454109, 48), to_signed(-93746569865, 48), to_signed(-765410337, 48)),

        (to_signed(-49310912668, 48), to_signed(-93987685481, 48), to_signed(-783848911, 48)),

        (to_signed(-49408641821, 48), to_signed(-94185312598, 48), to_signed(-782190551, 48)),

        (to_signed(-49520738535, 48), to_signed(-94425102889, 48), to_signed(-795795541, 48)),

        (to_signed(-49659980569, 48), to_signed(-94628452079, 48), to_signed(-786575554, 48)),

        (to_signed(-49731894471, 48), to_signed(-94828638903, 48), to_signed(-798714552, 48)),

        (to_signed(-49857389290, 48), to_signed(-95076371103, 48), to_signed(-784394481, 48)),

        (to_signed(-49929373320, 48), to_signed(-95257896312, 48), to_signed(-802889746, 48)),

        (to_signed(-50039562702, 48), to_signed(-95481256869, 48), to_signed(-792228005, 48)),

        (to_signed(-50166586404, 48), to_signed(-95687299307, 48), to_signed(-800911635, 48)),

        (to_signed(-50264543732, 48), to_signed(-95908453044, 48), to_signed(-783394685, 48)),

        (to_signed(-50378797768, 48), to_signed(-96104964370, 48), to_signed(-805014903, 48)),

        (to_signed(-50467183333, 48), to_signed(-96341391080, 48), to_signed(-835765194, 48)),

        (to_signed(-50555211762, 48), to_signed(-96566337377, 48), to_signed(-786713102, 48)),

        (to_signed(-50675877188, 48), to_signed(-96737999457, 48), to_signed(-824609423, 48)),

        (to_signed(-50725075626, 48), to_signed(-96883444612, 48), to_signed(-821635647, 48)),

        (to_signed(-50816621044, 48), to_signed(-97044248277, 48), to_signed(-821914317, 48)),

        (to_signed(-50895219671, 48), to_signed(-97196895369, 48), to_signed(-790115045, 48)),

        (to_signed(-50957905818, 48), to_signed(-97361862222, 48), to_signed(-850258468, 48)),

        (to_signed(-51047671305, 48), to_signed(-97513714760, 48), to_signed(-763038627, 48)),

        (to_signed(-51117107789, 48), to_signed(-97686144475, 48), to_signed(-799103452, 48)),

        (to_signed(-51215403226, 48), to_signed(-97815812661, 48), to_signed(-813874617, 48)),

        (to_signed(-51249830627, 48), to_signed(-98048587275, 48), to_signed(-819339713, 48)),

        (to_signed(-51369688696, 48), to_signed(-98221896758, 48), to_signed(-814426742, 48)),

        (to_signed(-51469506841, 48), to_signed(-98404877637, 48), to_signed(-811273361, 48)),

        (to_signed(-51541664483, 48), to_signed(-98560363448, 48), to_signed(-809990223, 48)),

        (to_signed(-51671119704, 48), to_signed(-98837080873, 48), to_signed(-813568237, 48)),

        (to_signed(-51826781494, 48), to_signed(-99128663872, 48), to_signed(-824505235, 48)),

        (to_signed(-51966609320, 48), to_signed(-99478361879, 48), to_signed(-832437355, 48)),

        (to_signed(-52118043544, 48), to_signed(-99779846908, 48), to_signed(-834782927, 48)),

        (to_signed(-52293491834, 48), to_signed(-100116007523, 48), to_signed(-838633417, 48)),

        (to_signed(-52448091216, 48), to_signed(-100383468166, 48), to_signed(-819460309, 48)),

        (to_signed(-52596884278, 48), to_signed(-100756847463, 48), to_signed(-831642002, 48)),

        (to_signed(-52784728592, 48), to_signed(-101049190011, 48), to_signed(-894050183, 48)),

        (to_signed(-52925368538, 48), to_signed(-101361220000, 48), to_signed(-836832876, 48)),

        (to_signed(-53058130387, 48), to_signed(-101736774219, 48), to_signed(-848965540, 48)),

        (to_signed(-53316407017, 48), to_signed(-102281884429, 48), to_signed(-860773731, 48)),

        (to_signed(-53611125390, 48), to_signed(-102816013051, 48), to_signed(-875205286, 48)),

        (to_signed(-53862340659, 48), to_signed(-103351686974, 48), to_signed(-858288252, 48)),

        (to_signed(-54133596135, 48), to_signed(-103896361649, 48), to_signed(-869902652, 48)),

        (to_signed(-54353967365, 48), to_signed(-104419197513, 48), to_signed(-907418018, 48)),

        (to_signed(-54613300376, 48), to_signed(-104857355922, 48), to_signed(-894746749, 48)),

        (to_signed(-54766557345, 48), to_signed(-105170603080, 48), to_signed(-921439076, 48)),

        (to_signed(-54912770071, 48), to_signed(-105451038976, 48), to_signed(-931844961, 48)),

        (to_signed(-55056017978, 48), to_signed(-105696346198, 48), to_signed(-922774807, 48)),

        (to_signed(-55157980246, 48), to_signed(-105918392306, 48), to_signed(-901353104, 48)),

        (to_signed(-55306410778, 48), to_signed(-106241963645, 48), to_signed(-903392308, 48)),

        (to_signed(-55449910294, 48), to_signed(-106467787982, 48), to_signed(-914336376, 48)),

        (to_signed(-55569224048, 48), to_signed(-106733948226, 48), to_signed(-914340860, 48)),

        (to_signed(-55708849238, 48), to_signed(-107038190620, 48), to_signed(-921407342, 48)),

        (to_signed(-55794725852, 48), to_signed(-107286164574, 48), to_signed(-944391080, 48)),

        (to_signed(-55940567449, 48), to_signed(-107535198140, 48), to_signed(-929943775, 48)),

        (to_signed(-56046614272, 48), to_signed(-107751537434, 48), to_signed(-925688455, 48)),

        (to_signed(-56079058844, 48), to_signed(-107862401720, 48), to_signed(-927051686, 48)),

        (to_signed(-56159997834, 48), to_signed(-107982554676, 48), to_signed(-920349434, 48)),

        (to_signed(-56233153483, 48), to_signed(-108103629965, 48), to_signed(-929002219, 48)),

        (to_signed(-56250557423, 48), to_signed(-108211307723, 48), to_signed(-935578760, 48)),

        (to_signed(-56324477468, 48), to_signed(-108334758446, 48), to_signed(-924110436, 48)),

        (to_signed(-56408328654, 48), to_signed(-108427461792, 48), to_signed(-943099027, 48)),

        (to_signed(-56451527577, 48), to_signed(-108554761107, 48), to_signed(-958038971, 48)),

        (to_signed(-56520432333, 48), to_signed(-108651730304, 48), to_signed(-946568875, 48)),

        (to_signed(-56586349100, 48), to_signed(-108795565660, 48), to_signed(-956919954, 48)),

        (to_signed(-56641320999, 48), to_signed(-108951879759, 48), to_signed(-957598358, 48)),

        (to_signed(-56742736720, 48), to_signed(-109180855300, 48), to_signed(-951382677, 48)),

        (to_signed(-56930293549, 48), to_signed(-109494565216, 48), to_signed(-965424756, 48)),

        (to_signed(-57062450583, 48), to_signed(-109788474506, 48), to_signed(-961600172, 48)),

        (to_signed(-57247877772, 48), to_signed(-110107787517, 48), to_signed(-992506295, 48)),

        (to_signed(-57410200570, 48), to_signed(-110482313044, 48), to_signed(-961461517, 48)),

        (to_signed(-57577032845, 48), to_signed(-110767591779, 48), to_signed(-969323045, 48)),

        (to_signed(-57746655645, 48), to_signed(-111122257165, 48), to_signed(-987355020, 48)),

        (to_signed(-57896412389, 48), to_signed(-111474749525, 48), to_signed(-966889519, 48)),

        (to_signed(-58076233637, 48), to_signed(-111797491290, 48), to_signed(-966523288, 48)),

        (to_signed(-58223847665, 48), to_signed(-112121683287, 48), to_signed(-1013316713, 48)),

        (to_signed(-58396004875, 48), to_signed(-112464843830, 48), to_signed(-1003095929, 48)),

        (to_signed(-58565947744, 48), to_signed(-112792148693, 48), to_signed(-1007156794, 48)),

        (to_signed(-58743942094, 48), to_signed(-113151702389, 48), to_signed(-1013974881, 48)),

        (to_signed(-58894723551, 48), to_signed(-113446161650, 48), to_signed(-987685016, 48)),

        (to_signed(-58997367972, 48), to_signed(-113718503671, 48), to_signed(-1006575052, 48)),

        (to_signed(-59126631738, 48), to_signed(-113942433966, 48), to_signed(-1009482907, 48)),

        (to_signed(-59276430789, 48), to_signed(-114201515381, 48), to_signed(-1040386210, 48)),

        (to_signed(-59383358013, 48), to_signed(-114444472897, 48), to_signed(-997828328, 48)),

        (to_signed(-59497412748, 48), to_signed(-114657176975, 48), to_signed(-1031002074, 48)),

        (to_signed(-59663021305, 48), to_signed(-114905388456, 48), to_signed(-1010927160, 48)),

        (to_signed(-59750891660, 48), to_signed(-115159260385, 48), to_signed(-1009000945, 48)),

        (to_signed(-59896119113, 48), to_signed(-115433588418, 48), to_signed(-992548389, 48)),

        (to_signed(-60000423474, 48), to_signed(-115666353329, 48), to_signed(-1039056710, 48)),

        (to_signed(-60138382396, 48), to_signed(-115865694287, 48), to_signed(-1068455487, 48)),

        (to_signed(-60265162499, 48), to_signed(-116094817145, 48), to_signed(-1014727620, 48)),

        (to_signed(-60371491803, 48), to_signed(-116269430939, 48), to_signed(-987620163, 48)),

        (to_signed(-60452684010, 48), to_signed(-116512892125, 48), to_signed(-997057282, 48)),

        (to_signed(-60558437891, 48), to_signed(-116727416926, 48), to_signed(-1014341476, 48)),

        (to_signed(-60687271796, 48), to_signed(-116946973160, 48), to_signed(-1026122888, 48)),

        (to_signed(-60770690647, 48), to_signed(-117150694674, 48), to_signed(-1004348956, 48)),

        (to_signed(-60918584701, 48), to_signed(-117366641209, 48), to_signed(-1034239246, 48)),

        (to_signed(-61001122225, 48), to_signed(-117563351169, 48), to_signed(-1009929518, 48)),

        (to_signed(-61129635640, 48), to_signed(-117770328531, 48), to_signed(-1009456718, 48)),

        (to_signed(-61236074628, 48), to_signed(-118024157538, 48), to_signed(-1000136056, 48)),

        (to_signed(-61355367663, 48), to_signed(-118289264673, 48), to_signed(-971541982, 48)),

        (to_signed(-61501622470, 48), to_signed(-118553696171, 48), to_signed(-1011175714, 48)),

        (to_signed(-61624663148, 48), to_signed(-118770326544, 48), to_signed(-1026216321, 48)),

        (to_signed(-61734973057, 48), to_signed(-119058379185, 48), to_signed(-1018115446, 48)),

        (to_signed(-61896925777, 48), to_signed(-119340378534, 48), to_signed(-1047436324, 48)),

        (to_signed(-62008617840, 48), to_signed(-119562131014, 48), to_signed(-1029481283, 48)),

        (to_signed(-62176983052, 48), to_signed(-119791215948, 48), to_signed(-1024762325, 48)),

        (to_signed(-62284449621, 48), to_signed(-120096477265, 48), to_signed(-1026795983, 48)),

        (to_signed(-62404213064, 48), to_signed(-120342469588, 48), to_signed(-1015667957, 48)),

        (to_signed(-62604926198, 48), to_signed(-120615325977, 48), to_signed(-1032242773, 48)),

        (to_signed(-62711888880, 48), to_signed(-120878519656, 48), to_signed(-999857890, 48)),

        (to_signed(-62823897844, 48), to_signed(-121121602736, 48), to_signed(-1018882998, 48)),

        (to_signed(-62972046356, 48), to_signed(-121402053996, 48), to_signed(-1019263314, 48)),

        (to_signed(-63097473337, 48), to_signed(-121652859616, 48), to_signed(-1024829250, 48)),

        (to_signed(-63248893633, 48), to_signed(-121912110238, 48), to_signed(-1016945230, 48)),

        (to_signed(-63372368019, 48), to_signed(-122188877846, 48), to_signed(-1005926854, 48)),

        (to_signed(-63511492897, 48), to_signed(-122421187157, 48), to_signed(-1034538545, 48)),

        (to_signed(-63642599569, 48), to_signed(-122733920770, 48), to_signed(-1030173178, 48)),

        (to_signed(-63831545906, 48), to_signed(-123073778913, 48), to_signed(-1022156470, 48)),

        (to_signed(-64028208513, 48), to_signed(-123427105794, 48), to_signed(-1036091785, 48)),

        (to_signed(-64238840861, 48), to_signed(-123826188049, 48), to_signed(-1023707709, 48)),

        (to_signed(-64438169554, 48), to_signed(-124185648778, 48), to_signed(-1014403529, 48)),

        (to_signed(-64635304167, 48), to_signed(-124561281893, 48), to_signed(-988195077, 48)),

        (to_signed(-64819487402, 48), to_signed(-124917917920, 48), to_signed(-994910870, 48)),

        (to_signed(-65031226325, 48), to_signed(-125303179431, 48), to_signed(-992519044, 48)),

        (to_signed(-65223640114, 48), to_signed(-125695553043, 48), to_signed(-977073789, 48)),

        (to_signed(-65402207425, 48), to_signed(-126071391127, 48), to_signed(-988657762, 48)),

        (to_signed(-65630936968, 48), to_signed(-126451764965, 48), to_signed(-974805691, 48)),

        (to_signed(-65859546925, 48), to_signed(-126855708082, 48), to_signed(-978091936, 48)),

        (to_signed(-66042449276, 48), to_signed(-127254870706, 48), to_signed(-966911679, 48)),

        (to_signed(-66273481579, 48), to_signed(-127657150477, 48), to_signed(-976104882, 48)),

        (to_signed(-66491385473, 48), to_signed(-128003466225, 48), to_signed(-1002090078, 48)),

        (to_signed(-66664660507, 48), to_signed(-128341172470, 48), to_signed(-958272048, 48)),

        (to_signed(-66869690513, 48), to_signed(-128696732633, 48), to_signed(-926995166, 48)),

        (to_signed(-67034757458, 48), to_signed(-129040098639, 48), to_signed(-930171305, 48)),

        (to_signed(-67200888421, 48), to_signed(-129348748698, 48), to_signed(-924442358, 48)),

        (to_signed(-67333262991, 48), to_signed(-129628404553, 48), to_signed(-914883774, 48)),

        (to_signed(-67516095523, 48), to_signed(-129926066293, 48), to_signed(-929118743, 48)),

        (to_signed(-67685447863, 48), to_signed(-130204313573, 48), to_signed(-922279328, 48)),

        (to_signed(-67828048361, 48), to_signed(-130498986212, 48), to_signed(-930935780, 48)),

        (to_signed(-68039251684, 48), to_signed(-130820802940, 48), to_signed(-920859689, 48)),

        (to_signed(-68158393544, 48), to_signed(-131091011740, 48), to_signed(-900209506, 48)),

        (to_signed(-68309605041, 48), to_signed(-131365261892, 48), to_signed(-885326167, 48)),

        (to_signed(-68507536085, 48), to_signed(-131670732011, 48), to_signed(-902847082, 48)),

        (to_signed(-68623732027, 48), to_signed(-131927963764, 48), to_signed(-903044050, 48)),

        (to_signed(-68777152581, 48), to_signed(-132162097258, 48), to_signed(-890985250, 48)),

        (to_signed(-68916188930, 48), to_signed(-132391853596, 48), to_signed(-876756790, 48)),

        (to_signed(-69019264718, 48), to_signed(-132629875119, 48), to_signed(-907080110, 48)),

        (to_signed(-69095253216, 48), to_signed(-132783690271, 48), to_signed(-917883520, 48)),

        (to_signed(-69233765997, 48), to_signed(-132988612643, 48), to_signed(-885100222, 48)),

        (to_signed(-69336120841, 48), to_signed(-133179168597, 48), to_signed(-892847653, 48)),

        (to_signed(-69451460174, 48), to_signed(-133366210786, 48), to_signed(-877396425, 48)),

        (to_signed(-69561479485, 48), to_signed(-133543400560, 48), to_signed(-867854339, 48)),

        (to_signed(-69630803771, 48), to_signed(-133712085223, 48), to_signed(-869444425, 48)),

        (to_signed(-69752640195, 48), to_signed(-133859853904, 48), to_signed(-833911287, 48)),

        (to_signed(-69830619807, 48), to_signed(-134017159347, 48), to_signed(-849237251, 48)),

        (to_signed(-69933377248, 48), to_signed(-134176942545, 48), to_signed(-846117465, 48)),

        (to_signed(-70010870535, 48), to_signed(-134326803360, 48), to_signed(-837159154, 48)),

        (to_signed(-70106851559, 48), to_signed(-134471298554, 48), to_signed(-863143977, 48)),

        (to_signed(-70188585446, 48), to_signed(-134632483726, 48), to_signed(-823043594, 48)),

        (to_signed(-70308092130, 48), to_signed(-134830467372, 48), to_signed(-838187581, 48)),

        (to_signed(-70397606222, 48), to_signed(-135005542922, 48), to_signed(-822107139, 48)),

        (to_signed(-70503042399, 48), to_signed(-135104160266, 48), to_signed(-847778187, 48)),

        (to_signed(-70587618470, 48), to_signed(-135299908289, 48), to_signed(-852302623, 48)),

        (to_signed(-70667377411, 48), to_signed(-135437887125, 48), to_signed(-808952435, 48)),

        (to_signed(-70754550299, 48), to_signed(-135610887744, 48), to_signed(-812798712, 48)),

        (to_signed(-70894017065, 48), to_signed(-135805952364, 48), to_signed(-829922111, 48)),

        (to_signed(-71016673266, 48), to_signed(-136014853987, 48), to_signed(-823267898, 48)),

        (to_signed(-71161236137, 48), to_signed(-136259419788, 48), to_signed(-783684886, 48)),

        (to_signed(-71329760813, 48), to_signed(-136530046613, 48), to_signed(-816410744, 48)),

        (to_signed(-71457926825, 48), to_signed(-136812062924, 48), to_signed(-762785420, 48)),

        (to_signed(-71663297662, 48), to_signed(-137034691076, 48), to_signed(-799139891, 48)),

        (to_signed(-71837555053, 48), to_signed(-137281698131, 48), to_signed(-766868567, 48)),

        (to_signed(-72012872764, 48), to_signed(-137575828426, 48), to_signed(-776641333, 48)),

        (to_signed(-72124661755, 48), to_signed(-137808352310, 48), to_signed(-754645175, 48)),

        (to_signed(-72306631736, 48), to_signed(-138065099434, 48), to_signed(-767794437, 48)),

        (to_signed(-72486391683, 48), to_signed(-138308537677, 48), to_signed(-755297668, 48)),

        (to_signed(-72648610990, 48), to_signed(-138569664349, 48), to_signed(-745780684, 48)),

        (to_signed(-72840039614, 48), to_signed(-138841409961, 48), to_signed(-757181847, 48)),

        (to_signed(-72953189186, 48), to_signed(-139047954658, 48), to_signed(-722249741, 48)),

        (to_signed(-73168596576, 48), to_signed(-139306655522, 48), to_signed(-737873146, 48)),

        (to_signed(-73345471661, 48), to_signed(-139540419971, 48), to_signed(-727682262, 48)),

        (to_signed(-73511673110, 48), to_signed(-139791585555, 48), to_signed(-735113546, 48)),

        (to_signed(-73692321910, 48), to_signed(-140019330999, 48), to_signed(-756004097, 48)),

        (to_signed(-73873178208, 48), to_signed(-140262704523, 48), to_signed(-710804327, 48)),

        (to_signed(-74066738772, 48), to_signed(-140486727590, 48), to_signed(-661706583, 48)),

        (to_signed(-74222109337, 48), to_signed(-140691074374, 48), to_signed(-683604218, 48)),

        (to_signed(-74374986585, 48), to_signed(-140978774799, 48), to_signed(-691674969, 48)),

        (to_signed(-74560531766, 48), to_signed(-141218795225, 48), to_signed(-690346551, 48)),

        (to_signed(-74732917385, 48), to_signed(-141403008055, 48), to_signed(-680143200, 48)),

        (to_signed(-74944765850, 48), to_signed(-141667168105, 48), to_signed(-665925120, 48)),

        (to_signed(-75129334341, 48), to_signed(-141910847455, 48), to_signed(-689499147, 48)),

        (to_signed(-75294803712, 48), to_signed(-142115897331, 48), to_signed(-645675243, 48)),

        (to_signed(-75481398285, 48), to_signed(-142364616733, 48), to_signed(-647496759, 48)),

        (to_signed(-75653228791, 48), to_signed(-142541015139, 48), to_signed(-642679831, 48)),

        (to_signed(-75889234208, 48), to_signed(-142777471098, 48), to_signed(-642602708, 48)),

        (to_signed(-76024430852, 48), to_signed(-143014224910, 48), to_signed(-644860120, 48)),

        (to_signed(-76241996465, 48), to_signed(-143187039797, 48), to_signed(-629130617, 48)),

        (to_signed(-76435760493, 48), to_signed(-143450589942, 48), to_signed(-625720484, 48)),

        (to_signed(-76627969310, 48), to_signed(-143637249989, 48), to_signed(-636965199, 48)),

        (to_signed(-76800555251, 48), to_signed(-143830186271, 48), to_signed(-636462072, 48)),

        (to_signed(-76920783198, 48), to_signed(-143998875255, 48), to_signed(-620943016, 48)),

        (to_signed(-77095165983, 48), to_signed(-144180024322, 48), to_signed(-592476886, 48)),

        (to_signed(-77307055041, 48), to_signed(-144391387636, 48), to_signed(-634574722, 48)),

        (to_signed(-77514301064, 48), to_signed(-144590397381, 48), to_signed(-633399482, 48)),

        (to_signed(-77705366939, 48), to_signed(-144755872625, 48), to_signed(-601006803, 48)),

        (to_signed(-77878892031, 48), to_signed(-144960792405, 48), to_signed(-597909816, 48)),

        (to_signed(-78118408944, 48), to_signed(-145101475745, 48), to_signed(-590847918, 48)),

        (to_signed(-78346432437, 48), to_signed(-145318796646, 48), to_signed(-584655792, 48)),

        (to_signed(-78532496927, 48), to_signed(-145513048958, 48), to_signed(-587485898, 48)),

        (to_signed(-78740109743, 48), to_signed(-145689654008, 48), to_signed(-553737963, 48)),

        (to_signed(-78987940610, 48), to_signed(-145901186008, 48), to_signed(-600584974, 48)),

        (to_signed(-79150765436, 48), to_signed(-146080718509, 48), to_signed(-582618675, 48)),

        (to_signed(-79403784730, 48), to_signed(-146248285846, 48), to_signed(-564651073, 48)),

        (to_signed(-79766972501, 48), to_signed(-146537980332, 48), to_signed(-582309042, 48)),

        (to_signed(-80147994127, 48), to_signed(-146805441493, 48), to_signed(-549313889, 48)),

        (to_signed(-80574888025, 48), to_signed(-147041380630, 48), to_signed(-509978312, 48)),

        (to_signed(-81013074040, 48), to_signed(-147292998281, 48), to_signed(-528992352, 48)),

        (to_signed(-81441901447, 48), to_signed(-147563335988, 48), to_signed(-516961864, 48)),

        (to_signed(-81794937396, 48), to_signed(-147821194043, 48), to_signed(-533464054, 48)),

        (to_signed(-82251891875, 48), to_signed(-148113108793, 48), to_signed(-514152440, 48)),

        (to_signed(-82583006043, 48), to_signed(-148329198860, 48), to_signed(-503729901, 48)),

        (to_signed(-82717019196, 48), to_signed(-148350750332, 48), to_signed(-501368222, 48)),

        (to_signed(-82846665840, 48), to_signed(-148451945896, 48), to_signed(-473138130, 48)),

        (to_signed(-82985785823, 48), to_signed(-148521334202, 48), to_signed(-483886739, 48)),

        (to_signed(-83126363015, 48), to_signed(-148565436218, 48), to_signed(-510493110, 48)),

        (to_signed(-83259288040, 48), to_signed(-148648981322, 48), to_signed(-486312974, 48)),

        (to_signed(-83384037485, 48), to_signed(-148721258481, 48), to_signed(-480692561, 48)),

        (to_signed(-83525979837, 48), to_signed(-148763177992, 48), to_signed(-468525506, 48)),

        (to_signed(-83662196956, 48), to_signed(-148880890844, 48), to_signed(-459739657, 48)),

        (to_signed(-83781826492, 48), to_signed(-148925121521, 48), to_signed(-501889882, 48)),

        (to_signed(-83898005158, 48), to_signed(-148981615941, 48), to_signed(-497539527, 48)),

        (to_signed(-83963103490, 48), to_signed(-149000811047, 48), to_signed(-504426065, 48)),

        (to_signed(-84127421153, 48), to_signed(-149002418649, 48), to_signed(-486645427, 48)),

        (to_signed(-84159241769, 48), to_signed(-149042286839, 48), to_signed(-474286844, 48)),

        (to_signed(-84251257329, 48), to_signed(-149064520615, 48), to_signed(-464938130, 48)),

        (to_signed(-84422383719, 48), to_signed(-149086442623, 48), to_signed(-481601496, 48)),

        (to_signed(-84557375897, 48), to_signed(-149160436587, 48), to_signed(-483193816, 48)),

        (to_signed(-84721886847, 48), to_signed(-149218270684, 48), to_signed(-472782004, 48)),

        (to_signed(-84944636372, 48), to_signed(-149285640091, 48), to_signed(-485754780, 48)),

        (to_signed(-85166998045, 48), to_signed(-149374382865, 48), to_signed(-432378700, 48)),

        (to_signed(-85405507019, 48), to_signed(-149380177219, 48), to_signed(-490099353, 48)),

        (to_signed(-85590402631, 48), to_signed(-149506465190, 48), to_signed(-455719779, 48)),

        (to_signed(-85837028974, 48), to_signed(-149564950219, 48), to_signed(-420560668, 48)),

        (to_signed(-86064320101, 48), to_signed(-149639164130, 48), to_signed(-450088999, 48)),

        (to_signed(-86306471809, 48), to_signed(-149702644319, 48), to_signed(-449083342, 48)),

        (to_signed(-86570448005, 48), to_signed(-149767397723, 48), to_signed(-447583890, 48)),

        (to_signed(-86791492513, 48), to_signed(-149831102894, 48), to_signed(-440511521, 48)),

        (to_signed(-87004509486, 48), to_signed(-149913893347, 48), to_signed(-410488020, 48)),

        (to_signed(-87257735608, 48), to_signed(-149958087003, 48), to_signed(-466932259, 48)),

        (to_signed(-87436912121, 48), to_signed(-149984449111, 48), to_signed(-401022950, 48)),

        (to_signed(-87664548785, 48), to_signed(-150027269211, 48), to_signed(-447566060, 48)),

        (to_signed(-87878447788, 48), to_signed(-150030036933, 48), to_signed(-425076032, 48)),

        (to_signed(-88071873953, 48), to_signed(-150082673374, 48), to_signed(-424730199, 48)),

        (to_signed(-88287990925, 48), to_signed(-150112488214, 48), to_signed(-404580712, 48)),

        (to_signed(-88513142978, 48), to_signed(-150147602965, 48), to_signed(-438193399, 48)),

        (to_signed(-88699279188, 48), to_signed(-150172943493, 48), to_signed(-400553675, 48)),

        (to_signed(-88973374194, 48), to_signed(-150204182779, 48), to_signed(-371736296, 48)),

        (to_signed(-89197987323, 48), to_signed(-150230686979, 48), to_signed(-426269508, 48)),

        (to_signed(-89451454467, 48), to_signed(-150203934031, 48), to_signed(-397917169, 48)),

        (to_signed(-89719682429, 48), to_signed(-150223277570, 48), to_signed(-409906796, 48)),

        (to_signed(-89979027195, 48), to_signed(-150216135307, 48), to_signed(-389470846, 48)),

        (to_signed(-90314991885, 48), to_signed(-150176495780, 48), to_signed(-394378146, 48)),

        (to_signed(-90588001965, 48), to_signed(-150144625138, 48), to_signed(-403545101, 48)),

        (to_signed(-90916109592, 48), to_signed(-150144109948, 48), to_signed(-382680942, 48)),

        (to_signed(-91235309747, 48), to_signed(-150107929874, 48), to_signed(-358905043, 48)),

        (to_signed(-91525159300, 48), to_signed(-150046248985, 48), to_signed(-390842420, 48)),

        (to_signed(-91870794526, 48), to_signed(-150032464426, 48), to_signed(-374026656, 48)),

        (to_signed(-92198826504, 48), to_signed(-149954550775, 48), to_signed(-406262315, 48)),

        (to_signed(-92517531194, 48), to_signed(-149950408278, 48), to_signed(-399073740, 48)),

        (to_signed(-92797466975, 48), to_signed(-149951132833, 48), to_signed(-373564343, 48)),

        (to_signed(-93108713185, 48), to_signed(-149870112006, 48), to_signed(-355151329, 48)),

        (to_signed(-93251936648, 48), to_signed(-149836261265, 48), to_signed(-372873913, 48)),

        (to_signed(-93510452252, 48), to_signed(-149780922641, 48), to_signed(-382881808, 48)),

        (to_signed(-93641207521, 48), to_signed(-149751172053, 48), to_signed(-376430905, 48)),

        (to_signed(-93860275114, 48), to_signed(-149724694128, 48), to_signed(-396186828, 48)),

        (to_signed(-94059584040, 48), to_signed(-149702816599, 48), to_signed(-363855834, 48)),

        (to_signed(-94261249752, 48), to_signed(-149645688172, 48), to_signed(-357984277, 48)),

        (to_signed(-94439557197, 48), to_signed(-149616355769, 48), to_signed(-379161637, 48)),

        (to_signed(-94607775238, 48), to_signed(-149561586075, 48), to_signed(-378497567, 48)),

        (to_signed(-94727353194, 48), to_signed(-149484968600, 48), to_signed(-365349153, 48)),

        (to_signed(-94882666802, 48), to_signed(-149409823758, 48), to_signed(-376335072, 48)),

        (to_signed(-95020781274, 48), to_signed(-149374215416, 48), to_signed(-369315933, 48)),

        (to_signed(-95168123015, 48), to_signed(-149343897294, 48), to_signed(-332177206, 48)),

        (to_signed(-95301697699, 48), to_signed(-149259371310, 48), to_signed(-370747377, 48)),

        (to_signed(-95434297948, 48), to_signed(-149189751159, 48), to_signed(-371813204, 48)),

        (to_signed(-95606873565, 48), to_signed(-149163054563, 48), to_signed(-375863484, 48)),

        (to_signed(-95739520194, 48), to_signed(-149098069338, 48), to_signed(-351712347, 48)),

        (to_signed(-95857978596, 48), to_signed(-149029846925, 48), to_signed(-366543382, 48)),

        (to_signed(-96055726238, 48), to_signed(-148957177392, 48), to_signed(-373952058, 48)),

        (to_signed(-96249823999, 48), to_signed(-148847048274, 48), to_signed(-340444025, 48)),

        (to_signed(-96434572387, 48), to_signed(-148773869420, 48), to_signed(-338349283, 48)),

        (to_signed(-96617194590, 48), to_signed(-148678717292, 48), to_signed(-371794146, 48)),

        (to_signed(-96832614192, 48), to_signed(-148600860479, 48), to_signed(-393009214, 48)),

        (to_signed(-97045407528, 48), to_signed(-148484391330, 48), to_signed(-345042899, 48)),

        (to_signed(-97237855218, 48), to_signed(-148356013616, 48), to_signed(-373684661, 48)),

        (to_signed(-97466346542, 48), to_signed(-148265469433, 48), to_signed(-349186286, 48)),

        (to_signed(-97651874040, 48), to_signed(-148121321852, 48), to_signed(-395755944, 48)),

        (to_signed(-97896079212, 48), to_signed(-148048081447, 48), to_signed(-347980093, 48)),

        (to_signed(-98059039447, 48), to_signed(-147928688247, 48), to_signed(-383527789, 48)),

        (to_signed(-98277168158, 48), to_signed(-147807892720, 48), to_signed(-351199812, 48)),

        (to_signed(-98485613791, 48), to_signed(-147734589538, 48), to_signed(-363757034, 48)),

        (to_signed(-98668950366, 48), to_signed(-147618659760, 48), to_signed(-381200556, 48)),

        (to_signed(-98846299597, 48), to_signed(-147485185329, 48), to_signed(-373570278, 48)),

        (to_signed(-99041545424, 48), to_signed(-147303641052, 48), to_signed(-357002476, 48)),

        (to_signed(-99273770582, 48), to_signed(-147199316977, 48), to_signed(-368516023, 48)),

        (to_signed(-99448675685, 48), to_signed(-147012373506, 48), to_signed(-362263462, 48)),

        (to_signed(-99622012770, 48), to_signed(-146929994106, 48), to_signed(-340684762, 48)),

        (to_signed(-99795414427, 48), to_signed(-146782665980, 48), to_signed(-401863200, 48)),

        (to_signed(-99971489393, 48), to_signed(-146625124560, 48), to_signed(-350262903, 48)),

        (to_signed(-100176672339, 48), to_signed(-146482574853, 48), to_signed(-377420073, 48)),

        (to_signed(-100343789783, 48), to_signed(-146340574736, 48), to_signed(-395925997, 48)),

        (to_signed(-100537600951, 48), to_signed(-146199105593, 48), to_signed(-404609442, 48)),

        (to_signed(-100713191813, 48), to_signed(-146046415283, 48), to_signed(-386906977, 48)),

        (to_signed(-100904536623, 48), to_signed(-145897872836, 48), to_signed(-369714921, 48))
    );

begin

    clk <= not clk after CLK_PERIOD / 2;

    uut : ctra_ukf_supreme
        port map (
            clk => clk, reset => reset, start => start,
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            px_current => px_out, py_current => py_out, v_current => v_out,
            theta_current => theta_out, omega_current => omega_out,
            a_current => a_out, z_current => z_out,
            p11_diag => p11_out, p22_diag => p22_out, p33_diag => p33_out,
            p44_diag => p44_out, p55_diag => p55_out, p66_diag => p66_out,
            p77_diag => p77_out,
            done => done
        );

    stim_proc : process
        file output_file : text;
        variable line_buf : line;
        variable hex_val : std_logic_vector(47 downto 0);
    begin

        reset <= '1';
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        file_open(output_file, "vhdl_output_f1_silverstone_2024_750cycles.txt", write_mode);

        write(line_buf, string'("cycle,px_hex,py_hex,v_hex,theta_hex,omega_hex,a_hex,z_hex,p11_hex,p22_hex,p33_hex,p44_hex,p55_hex,p66_hex,p77_hex"));
        writeline(output_file, line_buf);

        for i in 0 to NUM_CYCLES - 1 loop

            z_x_meas <= MEAS_DATA(i)(0);
            z_y_meas <= MEAS_DATA(i)(1);
            z_z_meas <= MEAS_DATA(i)(2);

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            wait until done = '1';
            wait for CLK_PERIOD;

            write(line_buf, integer'image(i));
            write(line_buf, string'(","));

            hex_val := std_logic_vector(px_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(py_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(v_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(theta_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(omega_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(a_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(z_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p11_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p22_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p33_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p44_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p55_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p66_out);
            hwrite(line_buf, hex_val);
            write(line_buf, string'(","));

            hex_val := std_logic_vector(p77_out);
            hwrite(line_buf, hex_val);

            writeline(output_file, line_buf);

            if (i mod 50 = 0) or (i = NUM_CYCLES - 1) then
                report "CTRA-UKF Cycle " & integer'image(i) & "/" & integer'image(NUM_CYCLES - 1) & " complete";
            end if;

            wait for CLK_PERIOD;
        end loop;

        file_close(output_file);
        report "=== CTRA-UKF SIMULATION COMPLETE ===" &
               " Dataset: f1_silverstone_2024_750cycles" &
               " Cycles: " & integer'image(NUM_CYCLES);

        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end behavioral;
