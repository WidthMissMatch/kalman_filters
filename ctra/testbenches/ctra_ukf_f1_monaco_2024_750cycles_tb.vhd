library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity ctra_ukf_f1_monaco_2024_750cycles_tb is
end entity ctra_ukf_f1_monaco_2024_750cycles_tb;

architecture behavioral of ctra_ukf_f1_monaco_2024_750cycles_tb is

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

        (to_signed(119377693, 48), to_signed(-60050331, 48), to_signed(-14232150, 48)),

        (to_signed(254261176, 48), to_signed(-91118088, 48), to_signed(-23696676, 48)),

        (to_signed(390644349, 48), to_signed(-94441302, 48), to_signed(-15010979, 48)),

        (to_signed(482861089, 48), to_signed(-165419574, 48), to_signed(-22794378, 48)),

        (to_signed(604558747, 48), to_signed(-142700087, 48), to_signed(-32527847, 48)),

        (to_signed(756679090, 48), to_signed(-215960455, 48), to_signed(-18225288, 48)),

        (to_signed(854240084, 48), to_signed(-268686032, 48), to_signed(-18160358, 48)),

        (to_signed(940161272, 48), to_signed(-338099728, 48), to_signed(-36681002, 48)),

        (to_signed(1063813471, 48), to_signed(-363861430, 48), to_signed(-17351886, 48)),

        (to_signed(1153609044, 48), to_signed(-437180087, 48), to_signed(-65271596, 48)),

        (to_signed(1260243333, 48), to_signed(-477387308, 48), to_signed(-53342802, 48)),

        (to_signed(1378789514, 48), to_signed(-488395008, 48), to_signed(-66096522, 48)),

        (to_signed(1449303624, 48), to_signed(-584869523, 48), to_signed(-89362031, 48)),

        (to_signed(1553302615, 48), to_signed(-614388850, 48), to_signed(-63060228, 48)),

        (to_signed(1621138547, 48), to_signed(-682387056, 48), to_signed(-64190458, 48)),

        (to_signed(1661909913, 48), to_signed(-708095978, 48), to_signed(-37231197, 48)),

        (to_signed(1732504827, 48), to_signed(-714719119, 48), to_signed(-52514204, 48)),

        (to_signed(1760328748, 48), to_signed(-791866242, 48), to_signed(-80755268, 48)),

        (to_signed(1800198572, 48), to_signed(-787858895, 48), to_signed(-32940550, 48)),

        (to_signed(1896812835, 48), to_signed(-843311884, 48), to_signed(-44036312, 48)),

        (to_signed(1916765664, 48), to_signed(-901541873, 48), to_signed(-55230677, 48)),

        (to_signed(1970016729, 48), to_signed(-918414461, 48), to_signed(-69271225, 48)),

        (to_signed(1973596750, 48), to_signed(-955228141, 48), to_signed(-81448470, 48)),

        (to_signed(2008534254, 48), to_signed(-1006033540, 48), to_signed(-71221856, 48)),

        (to_signed(2039695874, 48), to_signed(-1087730663, 48), to_signed(-46336604, 48)),

        (to_signed(2038691855, 48), to_signed(-1118506884, 48), to_signed(-32610175, 48)),

        (to_signed(2084472912, 48), to_signed(-1155381103, 48), to_signed(-37962469, 48)),

        (to_signed(2088260121, 48), to_signed(-1197398098, 48), to_signed(-71680844, 48)),

        (to_signed(2113610779, 48), to_signed(-1230657046, 48), to_signed(-81888887, 48)),

        (to_signed(2128577048, 48), to_signed(-1283009750, 48), to_signed(-60366657, 48)),

        (to_signed(2189915502, 48), to_signed(-1353315322, 48), to_signed(-92025337, 48)),

        (to_signed(2178780407, 48), to_signed(-1369454183, 48), to_signed(-56559506, 48)),

        (to_signed(2182121441, 48), to_signed(-1411750600, 48), to_signed(-64183451, 48)),

        (to_signed(2247686554, 48), to_signed(-1482339717, 48), to_signed(-71155763, 48)),

        (to_signed(2250768313, 48), to_signed(-1550372830, 48), to_signed(-92126642, 48)),

        (to_signed(2313552299, 48), to_signed(-1634304150, 48), to_signed(-58963802, 48)),

        (to_signed(2315967818, 48), to_signed(-1720381000, 48), to_signed(-78726438, 48)),

        (to_signed(2365359841, 48), to_signed(-1809051670, 48), to_signed(-91625767, 48)),

        (to_signed(2429743366, 48), to_signed(-1915530506, 48), to_signed(-122395001, 48)),

        (to_signed(2477627474, 48), to_signed(-1960246129, 48), to_signed(-76876680, 48)),

        (to_signed(2506008497, 48), to_signed(-2043118909, 48), to_signed(-48707842, 48)),

        (to_signed(2530969386, 48), to_signed(-2115433545, 48), to_signed(-50954760, 48)),

        (to_signed(2557634189, 48), to_signed(-2214796719, 48), to_signed(-86879642, 48)),

        (to_signed(2567656616, 48), to_signed(-2284900103, 48), to_signed(-89699055, 48)),

        (to_signed(2610161345, 48), to_signed(-2322480562, 48), to_signed(-72115661, 48)),

        (to_signed(2644286319, 48), to_signed(-2414199711, 48), to_signed(-97115290, 48)),

        (to_signed(2699526352, 48), to_signed(-2475488952, 48), to_signed(-75686708, 48)),

        (to_signed(2717331970, 48), to_signed(-2559834084, 48), to_signed(-68282016, 48)),

        (to_signed(2708477386, 48), to_signed(-2647007322, 48), to_signed(-60363630, 48)),

        (to_signed(2768574106, 48), to_signed(-2724881034, 48), to_signed(-82197046, 48)),

        (to_signed(2781756859, 48), to_signed(-2842396894, 48), to_signed(-83502405, 48)),

        (to_signed(2801941188, 48), to_signed(-2925242738, 48), to_signed(-94384016, 48)),

        (to_signed(2848640868, 48), to_signed(-3027727346, 48), to_signed(-93095249, 48)),

        (to_signed(2880756532, 48), to_signed(-3120377568, 48), to_signed(-82590770, 48)),

        (to_signed(2904032819, 48), to_signed(-3215361590, 48), to_signed(-72239442, 48)),

        (to_signed(2898096520, 48), to_signed(-3339267383, 48), to_signed(-63075406, 48)),

        (to_signed(2930756254, 48), to_signed(-3483845865, 48), to_signed(-91877919, 48)),

        (to_signed(2965269377, 48), to_signed(-3587565330, 48), to_signed(-53359654, 48)),

        (to_signed(2999846353, 48), to_signed(-3756462069, 48), to_signed(-82951512, 48)),

        (to_signed(2999207935, 48), to_signed(-3877407861, 48), to_signed(-78761296, 48)),

        (to_signed(3027900027, 48), to_signed(-4014469765, 48), to_signed(-90938944, 48)),

        (to_signed(3036221369, 48), to_signed(-4115635668, 48), to_signed(-119074815, 48)),

        (to_signed(3058481296, 48), to_signed(-4269433914, 48), to_signed(-63570992, 48)),

        (to_signed(3115949957, 48), to_signed(-4388239703, 48), to_signed(-66040624, 48)),

        (to_signed(3148839690, 48), to_signed(-4563294376, 48), to_signed(-83122706, 48)),

        (to_signed(3148645351, 48), to_signed(-4666710075, 48), to_signed(-77278895, 48)),

        (to_signed(3189443256, 48), to_signed(-4785359548, 48), to_signed(-69750822, 48)),

        (to_signed(3192297380, 48), to_signed(-4894474342, 48), to_signed(-104662341, 48)),

        (to_signed(3189030187, 48), to_signed(-4973548807, 48), to_signed(-87363528, 48)),

        (to_signed(3219540079, 48), to_signed(-5095673024, 48), to_signed(-65202273, 48)),

        (to_signed(3244987421, 48), to_signed(-5130041234, 48), to_signed(-99577787, 48)),

        (to_signed(3220896062, 48), to_signed(-5169432575, 48), to_signed(-73601191, 48)),

        (to_signed(3250061162, 48), to_signed(-5268404632, 48), to_signed(-101277915, 48)),

        (to_signed(3182172442, 48), to_signed(-5324107028, 48), to_signed(-70684826, 48)),

        (to_signed(3242227381, 48), to_signed(-5346564516, 48), to_signed(-79100161, 48)),

        (to_signed(3232212226, 48), to_signed(-5398762964, 48), to_signed(-105591585, 48)),

        (to_signed(3228048982, 48), to_signed(-5488351448, 48), to_signed(-58945059, 48)),

        (to_signed(3236918657, 48), to_signed(-5540944402, 48), to_signed(-90802518, 48)),

        (to_signed(3204346968, 48), to_signed(-5592937924, 48), to_signed(-92063870, 48)),

        (to_signed(3236321032, 48), to_signed(-5665082024, 48), to_signed(-75097071, 48)),

        (to_signed(3248311544, 48), to_signed(-5712253835, 48), to_signed(-59183100, 48)),

        (to_signed(3269428811, 48), to_signed(-5768003625, 48), to_signed(-95488673, 48)),

        (to_signed(3238252406, 48), to_signed(-5818353969, 48), to_signed(-77403168, 48)),

        (to_signed(3235696939, 48), to_signed(-5860369904, 48), to_signed(-71235611, 48)),

        (to_signed(3243156799, 48), to_signed(-5910174042, 48), to_signed(-66793549, 48)),

        (to_signed(3269246458, 48), to_signed(-5942405957, 48), to_signed(-75453707, 48)),

        (to_signed(3260673621, 48), to_signed(-6053962461, 48), to_signed(-84560289, 48)),

        (to_signed(3246821813, 48), to_signed(-6120114202, 48), to_signed(-92282662, 48)),

        (to_signed(3264872534, 48), to_signed(-6239634060, 48), to_signed(-76948165, 48)),

        (to_signed(3258441648, 48), to_signed(-6336289317, 48), to_signed(-96376346, 48)),

        (to_signed(3273615745, 48), to_signed(-6423553393, 48), to_signed(-127396384, 48)),

        (to_signed(3246137704, 48), to_signed(-6553126667, 48), to_signed(-71055416, 48)),

        (to_signed(3252970564, 48), to_signed(-6627290277, 48), to_signed(-63209582, 48)),

        (to_signed(3252440961, 48), to_signed(-6730328975, 48), to_signed(-118013938, 48)),

        (to_signed(3235017360, 48), to_signed(-6824275150, 48), to_signed(-95306399, 48)),

        (to_signed(3265090762, 48), to_signed(-6927101197, 48), to_signed(-67973662, 48)),

        (to_signed(3262479855, 48), to_signed(-7024468402, 48), to_signed(-43859101, 48)),

        (to_signed(3254834153, 48), to_signed(-7226642788, 48), to_signed(-78054433, 48)),

        (to_signed(3243169697, 48), to_signed(-7410773602, 48), to_signed(-90626777, 48)),

        (to_signed(3215716488, 48), to_signed(-7598241179, 48), to_signed(-81491028, 48)),

        (to_signed(3224762264, 48), to_signed(-7783027641, 48), to_signed(-55365556, 48)),

        (to_signed(3218426778, 48), to_signed(-7970323527, 48), to_signed(-89279256, 48)),

        (to_signed(3203073647, 48), to_signed(-8125603223, 48), to_signed(-91859612, 48)),

        (to_signed(3206184753, 48), to_signed(-8307641169, 48), to_signed(-86560108, 48)),

        (to_signed(3208026579, 48), to_signed(-8526970474, 48), to_signed(-94464836, 48)),

        (to_signed(3225249731, 48), to_signed(-8717281214, 48), to_signed(-76422190, 48)),

        (to_signed(3188890765, 48), to_signed(-8881329229, 48), to_signed(-51232296, 48)),

        (to_signed(3182639867, 48), to_signed(-9084424699, 48), to_signed(-73079127, 48)),

        (to_signed(3169316460, 48), to_signed(-9217896671, 48), to_signed(-82602242, 48)),

        (to_signed(3131584054, 48), to_signed(-9311134833, 48), to_signed(-82920634, 48)),

        (to_signed(3156541103, 48), to_signed(-9425993095, 48), to_signed(-103907243, 48)),

        (to_signed(3151206666, 48), to_signed(-9460624112, 48), to_signed(-62521530, 48)),

        (to_signed(3184732754, 48), to_signed(-9542480925, 48), to_signed(-78299946, 48)),

        (to_signed(3133389367, 48), to_signed(-9668915453, 48), to_signed(-79678405, 48)),

        (to_signed(3134886012, 48), to_signed(-9751162930, 48), to_signed(-22735400, 48)),

        (to_signed(3122454759, 48), to_signed(-9825886164, 48), to_signed(-70951013, 48)),

        (to_signed(3096640200, 48), to_signed(-9911094747, 48), to_signed(-88232616, 48)),

        (to_signed(3128630988, 48), to_signed(-9991681274, 48), to_signed(-82429149, 48)),

        (to_signed(3113333923, 48), to_signed(-10051019742, 48), to_signed(-56308984, 48)),

        (to_signed(3104415473, 48), to_signed(-10168011804, 48), to_signed(-74253100, 48)),

        (to_signed(3066312749, 48), to_signed(-10258734071, 48), to_signed(-100860519, 48)),

        (to_signed(3095530301, 48), to_signed(-10348779746, 48), to_signed(-61884873, 48)),

        (to_signed(3038901740, 48), to_signed(-10418199325, 48), to_signed(-89093330, 48)),

        (to_signed(3062131684, 48), to_signed(-10492051224, 48), to_signed(-47195776, 48)),

        (to_signed(3073854975, 48), to_signed(-10594298979, 48), to_signed(-62721143, 48)),

        (to_signed(3005306157, 48), to_signed(-10766001958, 48), to_signed(-90563004, 48)),

        (to_signed(2997243071, 48), to_signed(-10886474561, 48), to_signed(-63783145, 48)),

        (to_signed(2993235214, 48), to_signed(-11023415848, 48), to_signed(-86353452, 48)),

        (to_signed(2967935793, 48), to_signed(-11136113605, 48), to_signed(-75401555, 48)),

        (to_signed(2935186269, 48), to_signed(-11246567863, 48), to_signed(-83793101, 48)),

        (to_signed(2947171752, 48), to_signed(-11430780472, 48), to_signed(-108341922, 48)),

        (to_signed(2913018329, 48), to_signed(-11562996622, 48), to_signed(-107156234, 48)),

        (to_signed(2921337728, 48), to_signed(-11689905045, 48), to_signed(-81110850, 48)),

        (to_signed(2879546110, 48), to_signed(-11857075206, 48), to_signed(-105959340, 48)),

        (to_signed(2902554396, 48), to_signed(-11998625127, 48), to_signed(-109066857, 48)),

        (to_signed(2844989326, 48), to_signed(-12180903334, 48), to_signed(-120271074, 48)),

        (to_signed(2834306163, 48), to_signed(-12357820233, 48), to_signed(-99091981, 48)),

        (to_signed(2834937336, 48), to_signed(-12502975057, 48), to_signed(-73547385, 48)),

        (to_signed(2782217629, 48), to_signed(-12655375930, 48), to_signed(-128013059, 48)),

        (to_signed(2788255622, 48), to_signed(-12821272047, 48), to_signed(-111592908, 48)),

        (to_signed(2787745089, 48), to_signed(-12986881053, 48), to_signed(-88534314, 48)),

        (to_signed(2720201934, 48), to_signed(-13137805734, 48), to_signed(-113529617, 48)),

        (to_signed(2731624824, 48), to_signed(-13296393908, 48), to_signed(-104569930, 48)),

        (to_signed(2714243447, 48), to_signed(-13453132519, 48), to_signed(-129949487, 48)),

        (to_signed(2704356303, 48), to_signed(-13625747620, 48), to_signed(-104905694, 48)),

        (to_signed(2651843057, 48), to_signed(-13799744809, 48), to_signed(-115197267, 48)),

        (to_signed(2631798215, 48), to_signed(-13954789452, 48), to_signed(-95485715, 48)),

        (to_signed(2644064682, 48), to_signed(-14097318905, 48), to_signed(-92068500, 48)),

        (to_signed(2621659227, 48), to_signed(-14291650510, 48), to_signed(-68507088, 48)),

        (to_signed(2602486192, 48), to_signed(-14433548581, 48), to_signed(-102138366, 48)),

        (to_signed(2585703023, 48), to_signed(-14608122311, 48), to_signed(-106307282, 48)),

        (to_signed(2550088633, 48), to_signed(-14762830211, 48), to_signed(-108422250, 48)),

        (to_signed(2546935929, 48), to_signed(-14906418609, 48), to_signed(-117613349, 48)),

        (to_signed(2529470176, 48), to_signed(-15090401670, 48), to_signed(-106054602, 48)),

        (to_signed(2494082285, 48), to_signed(-15258569013, 48), to_signed(-116734650, 48)),

        (to_signed(2518883492, 48), to_signed(-15447902998, 48), to_signed(-108997547, 48)),

        (to_signed(2477044464, 48), to_signed(-15578308649, 48), to_signed(-89763453, 48)),

        (to_signed(2430621988, 48), to_signed(-15745739587, 48), to_signed(-128801270, 48)),

        (to_signed(2443103384, 48), to_signed(-15886393063, 48), to_signed(-92835610, 48)),

        (to_signed(2396562102, 48), to_signed(-16101133061, 48), to_signed(-89909154, 48)),

        (to_signed(2406945939, 48), to_signed(-16265575610, 48), to_signed(-114034619, 48)),

        (to_signed(2394005163, 48), to_signed(-16438351323, 48), to_signed(-147699655, 48)),

        (to_signed(2341379776, 48), to_signed(-16594547662, 48), to_signed(-122301022, 48)),

        (to_signed(2351787731, 48), to_signed(-16803315683, 48), to_signed(-90327074, 48)),

        (to_signed(2323026697, 48), to_signed(-16977739638, 48), to_signed(-112454266, 48)),

        (to_signed(2310369684, 48), to_signed(-17152925984, 48), to_signed(-128819684, 48)),

        (to_signed(2308877130, 48), to_signed(-17340697966, 48), to_signed(-120506464, 48)),

        (to_signed(2253413716, 48), to_signed(-17532022613, 48), to_signed(-97918053, 48)),

        (to_signed(2225361472, 48), to_signed(-17701980363, 48), to_signed(-102832221, 48)),

        (to_signed(2203559912, 48), to_signed(-17867928054, 48), to_signed(-115997075, 48)),

        (to_signed(2185272883, 48), to_signed(-18083866627, 48), to_signed(-118126323, 48)),

        (to_signed(2178207698, 48), to_signed(-18245502192, 48), to_signed(-118529856, 48)),

        (to_signed(2166350463, 48), to_signed(-18444028507, 48), to_signed(-127432720, 48)),

        (to_signed(2146394616, 48), to_signed(-18596782250, 48), to_signed(-84855738, 48)),

        (to_signed(2136755978, 48), to_signed(-18826936017, 48), to_signed(-117364885, 48)),

        (to_signed(2104221914, 48), to_signed(-18995307710, 48), to_signed(-91536713, 48)),

        (to_signed(2109515665, 48), to_signed(-19164151368, 48), to_signed(-86433797, 48)),

        (to_signed(2061814837, 48), to_signed(-19328764174, 48), to_signed(-95208367, 48)),

        (to_signed(2093017540, 48), to_signed(-19540681791, 48), to_signed(-119198632, 48)),

        (to_signed(2038951977, 48), to_signed(-19733673008, 48), to_signed(-105248180, 48)),

        (to_signed(1993923614, 48), to_signed(-19882619972, 48), to_signed(-113523331, 48)),

        (to_signed(1969775951, 48), to_signed(-20129895900, 48), to_signed(-129617986, 48)),

        (to_signed(1975275303, 48), to_signed(-20333913808, 48), to_signed(-110353528, 48)),

        (to_signed(1942869890, 48), to_signed(-20481063455, 48), to_signed(-136915368, 48)),

        (to_signed(1938036127, 48), to_signed(-20688290452, 48), to_signed(-98547398, 48)),

        (to_signed(1913435010, 48), to_signed(-20888422530, 48), to_signed(-127607325, 48)),

        (to_signed(1883711748, 48), to_signed(-21050826545, 48), to_signed(-117776430, 48)),

        (to_signed(1850164987, 48), to_signed(-21250042204, 48), to_signed(-117737536, 48)),

        (to_signed(1818395122, 48), to_signed(-21455017878, 48), to_signed(-128173011, 48)),

        (to_signed(1815756977, 48), to_signed(-21658455859, 48), to_signed(-115325207, 48)),

        (to_signed(1817054456, 48), to_signed(-21813760218, 48), to_signed(-134474845, 48)),

        (to_signed(1785716580, 48), to_signed(-22008910765, 48), to_signed(-113228330, 48)),

        (to_signed(1739933529, 48), to_signed(-22217077314, 48), to_signed(-151316253, 48)),

        (to_signed(1741244460, 48), to_signed(-22383134214, 48), to_signed(-126614163, 48)),

        (to_signed(1722308928, 48), to_signed(-22630770908, 48), to_signed(-96204630, 48)),

        (to_signed(1678521117, 48), to_signed(-22837114153, 48), to_signed(-145517235, 48)),

        (to_signed(1673434272, 48), to_signed(-23021830602, 48), to_signed(-140105135, 48)),

        (to_signed(1649337181, 48), to_signed(-23209689340, 48), to_signed(-120112518, 48)),

        (to_signed(1606690150, 48), to_signed(-23403544198, 48), to_signed(-125721578, 48)),

        (to_signed(1609374094, 48), to_signed(-23610376249, 48), to_signed(-122851864, 48)),

        (to_signed(1590285230, 48), to_signed(-23799124693, 48), to_signed(-120527263, 48)),

        (to_signed(1576184961, 48), to_signed(-24023525206, 48), to_signed(-118083996, 48)),

        (to_signed(1549521051, 48), to_signed(-24164952060, 48), to_signed(-110099126, 48)),

        (to_signed(1482554541, 48), to_signed(-24377199231, 48), to_signed(-121825128, 48)),

        (to_signed(1463760714, 48), to_signed(-24543722401, 48), to_signed(-132732320, 48)),

        (to_signed(1461962476, 48), to_signed(-24743364089, 48), to_signed(-117384718, 48)),

        (to_signed(1435768327, 48), to_signed(-24928097571, 48), to_signed(-96777847, 48)),

        (to_signed(1409616306, 48), to_signed(-25112848061, 48), to_signed(-130861746, 48)),

        (to_signed(1426071783, 48), to_signed(-25332596343, 48), to_signed(-145009258, 48)),

        (to_signed(1325740759, 48), to_signed(-25560333847, 48), to_signed(-110125160, 48)),

        (to_signed(1286808612, 48), to_signed(-25787998434, 48), to_signed(-130758407, 48)),

        (to_signed(1207142068, 48), to_signed(-26119726815, 48), to_signed(-165232946, 48)),

        (to_signed(1125444698, 48), to_signed(-26423854763, 48), to_signed(-114607078, 48)),

        (to_signed(1032606418, 48), to_signed(-26749981367, 48), to_signed(-137848625, 48)),

        (to_signed(974008741, 48), to_signed(-27037040674, 48), to_signed(-130429059, 48)),

        (to_signed(871689087, 48), to_signed(-27385275790, 48), to_signed(-123383311, 48)),

        (to_signed(804061378, 48), to_signed(-27656439024, 48), to_signed(-125799816, 48)),

        (to_signed(723271078, 48), to_signed(-28000053508, 48), to_signed(-117136098, 48)),

        (to_signed(656943534, 48), to_signed(-28314469719, 48), to_signed(-136318190, 48)),

        (to_signed(618891882, 48), to_signed(-28570127108, 48), to_signed(-120346825, 48)),

        (to_signed(473219286, 48), to_signed(-28865513542, 48), to_signed(-133253154, 48)),

        (to_signed(440548775, 48), to_signed(-29121794780, 48), to_signed(-116446872, 48)),

        (to_signed(326466799, 48), to_signed(-29428658699, 48), to_signed(-118461273, 48)),

        (to_signed(273928811, 48), to_signed(-29690909959, 48), to_signed(-144415448, 48)),

        (to_signed(262948417, 48), to_signed(-29835973635, 48), to_signed(-110370931, 48)),

        (to_signed(208589642, 48), to_signed(-29932709001, 48), to_signed(-137451959, 48)),

        (to_signed(152261990, 48), to_signed(-30086634665, 48), to_signed(-114772322, 48)),

        (to_signed(121175086, 48), to_signed(-30193390356, 48), to_signed(-122036520, 48)),

        (to_signed(107409994, 48), to_signed(-30274907394, 48), to_signed(-97228272, 48)),

        (to_signed(46587061, 48), to_signed(-30395329654, 48), to_signed(-131686310, 48)),

        (to_signed(25304497, 48), to_signed(-30522223358, 48), to_signed(-133667034, 48)),

        (to_signed(-14730163, 48), to_signed(-30666432677, 48), to_signed(-128001575, 48)),

        (to_signed(-63594427, 48), to_signed(-30771858132, 48), to_signed(-132631577, 48)),

        (to_signed(-53860629, 48), to_signed(-30891966267, 48), to_signed(-113993564, 48)),

        (to_signed(-116362302, 48), to_signed(-31032188119, 48), to_signed(-154400851, 48)),

        (to_signed(-198141608, 48), to_signed(-31108379305, 48), to_signed(-144830814, 48)),

        (to_signed(-206197674, 48), to_signed(-31253070613, 48), to_signed(-145464852, 48)),

        (to_signed(-269014805, 48), to_signed(-31411402786, 48), to_signed(-112229928, 48)),

        (to_signed(-294612540, 48), to_signed(-31554102056, 48), to_signed(-100176049, 48)),

        (to_signed(-394957464, 48), to_signed(-31760484267, 48), to_signed(-132036932, 48)),

        (to_signed(-456333304, 48), to_signed(-32007662202, 48), to_signed(-134526110, 48)),

        (to_signed(-518683239, 48), to_signed(-32186981749, 48), to_signed(-131927657, 48)),

        (to_signed(-585377731, 48), to_signed(-32403703822, 48), to_signed(-115019040, 48)),

        (to_signed(-692787499, 48), to_signed(-32618493645, 48), to_signed(-151479713, 48)),

        (to_signed(-751009040, 48), to_signed(-32815832555, 48), to_signed(-133331327, 48)),

        (to_signed(-826112474, 48), to_signed(-32990383524, 48), to_signed(-122378579, 48)),

        (to_signed(-901852434, 48), to_signed(-33219219365, 48), to_signed(-131741901, 48)),

        (to_signed(-934019154, 48), to_signed(-33448980942, 48), to_signed(-138377401, 48)),

        (to_signed(-1031650058, 48), to_signed(-33641578084, 48), to_signed(-125872599, 48)),

        (to_signed(-1135286946, 48), to_signed(-33840504445, 48), to_signed(-189000875, 48)),

        (to_signed(-1174421955, 48), to_signed(-34061266259, 48), to_signed(-133256099, 48)),

        (to_signed(-1229756258, 48), to_signed(-34287034243, 48), to_signed(-156487923, 48)),

        (to_signed(-1322233613, 48), to_signed(-34496269104, 48), to_signed(-176254052, 48)),

        (to_signed(-1439241678, 48), to_signed(-34671081694, 48), to_signed(-136991346, 48)),

        (to_signed(-1496070355, 48), to_signed(-34873574980, 48), to_signed(-122548511, 48)),

        (to_signed(-1540886388, 48), to_signed(-35062538351, 48), to_signed(-147927455, 48)),

        (to_signed(-1648209728, 48), to_signed(-35264281418, 48), to_signed(-129661643, 48)),

        (to_signed(-1703086325, 48), to_signed(-35454709891, 48), to_signed(-118625459, 48)),

        (to_signed(-1771731552, 48), to_signed(-35678678852, 48), to_signed(-123641170, 48)),

        (to_signed(-1874474442, 48), to_signed(-35844977522, 48), to_signed(-118214509, 48)),

        (to_signed(-1959420202, 48), to_signed(-36116404405, 48), to_signed(-133190334, 48)),

        (to_signed(-2125129781, 48), to_signed(-36365619173, 48), to_signed(-144246110, 48)),

        (to_signed(-2238004272, 48), to_signed(-36776207836, 48), to_signed(-172388203, 48)),

        (to_signed(-2375122850, 48), to_signed(-37099729454, 48), to_signed(-149639920, 48)),

        (to_signed(-2541887348, 48), to_signed(-37489742611, 48), to_signed(-159659007, 48)),

        (to_signed(-2643633263, 48), to_signed(-37868200894, 48), to_signed(-109089302, 48)),

        (to_signed(-2845081931, 48), to_signed(-38229599081, 48), to_signed(-148462551, 48)),

        (to_signed(-2978538422, 48), to_signed(-38591064270, 48), to_signed(-143444643, 48)),

        (to_signed(-3119029797, 48), to_signed(-38942782320, 48), to_signed(-136259287, 48)),

        (to_signed(-3247110267, 48), to_signed(-39305335830, 48), to_signed(-144780149, 48)),

        (to_signed(-3445448150, 48), to_signed(-39687941553, 48), to_signed(-117073439, 48)),

        (to_signed(-3550020352, 48), to_signed(-40037805551, 48), to_signed(-155959068, 48)),

        (to_signed(-3660489313, 48), to_signed(-40212884302, 48), to_signed(-142224898, 48)),

        (to_signed(-3751097324, 48), to_signed(-40387772687, 48), to_signed(-157909203, 48)),

        (to_signed(-3800846879, 48), to_signed(-40577366172, 48), to_signed(-167561660, 48)),

        (to_signed(-3879229368, 48), to_signed(-40751979293, 48), to_signed(-155641884, 48)),

        (to_signed(-3966608350, 48), to_signed(-40918533511, 48), to_signed(-145962220, 48)),

        (to_signed(-4029336644, 48), to_signed(-41078184595, 48), to_signed(-152506086, 48)),

        (to_signed(-4110941565, 48), to_signed(-41273567747, 48), to_signed(-156883230, 48)),

        (to_signed(-4176541917, 48), to_signed(-41428656614, 48), to_signed(-168823170, 48)),

        (to_signed(-4241307059, 48), to_signed(-41620263165, 48), to_signed(-146586102, 48)),

        (to_signed(-4299776169, 48), to_signed(-41753501533, 48), to_signed(-170399585, 48)),

        (to_signed(-4421121560, 48), to_signed(-41917271657, 48), to_signed(-132365687, 48)),

        (to_signed(-4438537447, 48), to_signed(-42104166743, 48), to_signed(-143696945, 48)),

        (to_signed(-4581043754, 48), to_signed(-42237583520, 48), to_signed(-169496455, 48)),

        (to_signed(-4624809034, 48), to_signed(-42452485988, 48), to_signed(-150193210, 48)),

        (to_signed(-4674314544, 48), to_signed(-42587446547, 48), to_signed(-157641038, 48)),

        (to_signed(-4736229983, 48), to_signed(-42674224502, 48), to_signed(-139706490, 48)),

        (to_signed(-4808150784, 48), to_signed(-42775534550, 48), to_signed(-122611724, 48)),

        (to_signed(-4857954707, 48), to_signed(-42879962091, 48), to_signed(-176600326, 48)),

        (to_signed(-4919493554, 48), to_signed(-43031024275, 48), to_signed(-143249737, 48)),

        (to_signed(-4977869646, 48), to_signed(-43120339978, 48), to_signed(-147905539, 48)),

        (to_signed(-5010487163, 48), to_signed(-43254195070, 48), to_signed(-133995141, 48)),

        (to_signed(-5075510770, 48), to_signed(-43371556975, 48), to_signed(-141720914, 48)),

        (to_signed(-5162143829, 48), to_signed(-43494929095, 48), to_signed(-158013950, 48)),

        (to_signed(-5211157380, 48), to_signed(-43654132157, 48), to_signed(-150884387, 48)),

        (to_signed(-5309960453, 48), to_signed(-43874683426, 48), to_signed(-159085381, 48)),

        (to_signed(-5390344443, 48), to_signed(-44006623352, 48), to_signed(-127876613, 48)),

        (to_signed(-5482284510, 48), to_signed(-44191401133, 48), to_signed(-145770200, 48)),

        (to_signed(-5595622080, 48), to_signed(-44408210059, 48), to_signed(-114429797, 48)),

        (to_signed(-5679978053, 48), to_signed(-44574234012, 48), to_signed(-147542937, 48)),

        (to_signed(-5746908191, 48), to_signed(-44755745677, 48), to_signed(-158609044, 48)),

        (to_signed(-5879249005, 48), to_signed(-44987442182, 48), to_signed(-172044586, 48)),

        (to_signed(-6037531196, 48), to_signed(-45247953212, 48), to_signed(-176707626, 48)),

        (to_signed(-6182903306, 48), to_signed(-45496893656, 48), to_signed(-172840641, 48)),

        (to_signed(-6311127280, 48), to_signed(-45732959474, 48), to_signed(-141588898, 48)),

        (to_signed(-6490179068, 48), to_signed(-45959760682, 48), to_signed(-137342839, 48)),

        (to_signed(-6618766584, 48), to_signed(-46217220775, 48), to_signed(-172213095, 48)),

        (to_signed(-6787798639, 48), to_signed(-46486630540, 48), to_signed(-130391590, 48)),

        (to_signed(-7023448173, 48), to_signed(-46786038062, 48), to_signed(-152473909, 48)),

        (to_signed(-7236751351, 48), to_signed(-47165347989, 48), to_signed(-140868360, 48)),

        (to_signed(-7476727259, 48), to_signed(-47416856639, 48), to_signed(-115244212, 48)),

        (to_signed(-7712316700, 48), to_signed(-47783889638, 48), to_signed(-126207967, 48)),

        (to_signed(-7939452507, 48), to_signed(-48079355190, 48), to_signed(-144721279, 48)),

        (to_signed(-8214930692, 48), to_signed(-48410853662, 48), to_signed(-153947106, 48)),

        (to_signed(-8465715189, 48), to_signed(-48732679257, 48), to_signed(-173798002, 48)),

        (to_signed(-8744235256, 48), to_signed(-49010372052, 48), to_signed(-148463071, 48)),

        (to_signed(-8995464617, 48), to_signed(-49356583606, 48), to_signed(-138641007, 48)),

        (to_signed(-9264960047, 48), to_signed(-49661812900, 48), to_signed(-150362103, 48)),

        (to_signed(-9523022669, 48), to_signed(-49987302855, 48), to_signed(-134703254, 48)),

        (to_signed(-9776538296, 48), to_signed(-50297401629, 48), to_signed(-129912916, 48)),

        (to_signed(-10062124222, 48), to_signed(-50623005577, 48), to_signed(-133675884, 48)),

        (to_signed(-10267159207, 48), to_signed(-50953037969, 48), to_signed(-139585786, 48)),

        (to_signed(-10500950206, 48), to_signed(-51116978831, 48), to_signed(-125311915, 48)),

        (to_signed(-10686251135, 48), to_signed(-51344157759, 48), to_signed(-120187856, 48)),

        (to_signed(-10828258949, 48), to_signed(-51564169492, 48), to_signed(-145357169, 48)),

        (to_signed(-11016215324, 48), to_signed(-51747417444, 48), to_signed(-102852710, 48)),

        (to_signed(-11200834622, 48), to_signed(-51917236776, 48), to_signed(-127639180, 48)),

        (to_signed(-11333635918, 48), to_signed(-52045568972, 48), to_signed(-125648520, 48)),

        (to_signed(-11456282806, 48), to_signed(-52146773931, 48), to_signed(-114284816, 48)),

        (to_signed(-11583030303, 48), to_signed(-52227875283, 48), to_signed(-122455883, 48)),

        (to_signed(-11678604615, 48), to_signed(-52308503044, 48), to_signed(-110579540, 48)),

        (to_signed(-11803136826, 48), to_signed(-52349356046, 48), to_signed(-121955293, 48)),

        (to_signed(-11887315676, 48), to_signed(-52458881474, 48), to_signed(-137249349, 48)),

        (to_signed(-12018042217, 48), to_signed(-52539165579, 48), to_signed(-121111251, 48)),

        (to_signed(-12141324081, 48), to_signed(-52610186385, 48), to_signed(-146566733, 48)),

        (to_signed(-12244766029, 48), to_signed(-52704556648, 48), to_signed(-125758780, 48)),

        (to_signed(-12344345761, 48), to_signed(-52794000063, 48), to_signed(-128339535, 48)),

        (to_signed(-12472630863, 48), to_signed(-52874039454, 48), to_signed(-131475568, 48)),

        (to_signed(-12588867236, 48), to_signed(-52953037712, 48), to_signed(-130342366, 48)),

        (to_signed(-12682883807, 48), to_signed(-53033552120, 48), to_signed(-159959970, 48)),

        (to_signed(-12794761876, 48), to_signed(-53101811229, 48), to_signed(-137795777, 48)),

        (to_signed(-12919276361, 48), to_signed(-53194238512, 48), to_signed(-127233940, 48)),

        (to_signed(-13030573510, 48), to_signed(-53263909551, 48), to_signed(-126311592, 48)),

        (to_signed(-13170969140, 48), to_signed(-53375407509, 48), to_signed(-146211204, 48)),

        (to_signed(-13368616593, 48), to_signed(-53477769372, 48), to_signed(-107613999, 48)),

        (to_signed(-13539249819, 48), to_signed(-53618841321, 48), to_signed(-143248620, 48)),

        (to_signed(-13734254433, 48), to_signed(-53698840630, 48), to_signed(-112094969, 48)),

        (to_signed(-13932346433, 48), to_signed(-53837297926, 48), to_signed(-120835774, 48)),

        (to_signed(-14130113665, 48), to_signed(-53955264187, 48), to_signed(-138487945, 48)),

        (to_signed(-14317141903, 48), to_signed(-54149496101, 48), to_signed(-97504420, 48)),

        (to_signed(-14534069576, 48), to_signed(-54194764866, 48), to_signed(-146958241, 48)),

        (to_signed(-14770026365, 48), to_signed(-54363999408, 48), to_signed(-111691836, 48)),

        (to_signed(-14991826354, 48), to_signed(-54476188702, 48), to_signed(-110736275, 48)),

        (to_signed(-15232491240, 48), to_signed(-54645351092, 48), to_signed(-139184977, 48)),

        (to_signed(-15440146460, 48), to_signed(-54750747166, 48), to_signed(-104982722, 48)),

        (to_signed(-15669030654, 48), to_signed(-54911077413, 48), to_signed(-133035062, 48)),

        (to_signed(-15886690343, 48), to_signed(-55022048270, 48), to_signed(-126106844, 48)),

        (to_signed(-16133900191, 48), to_signed(-55097650178, 48), to_signed(-128693185, 48)),

        (to_signed(-16339225267, 48), to_signed(-55251140547, 48), to_signed(-137424330, 48)),

        (to_signed(-16550140260, 48), to_signed(-55362472640, 48), to_signed(-123678239, 48)),

        (to_signed(-16805596941, 48), to_signed(-55469702376, 48), to_signed(-126079154, 48)),

        (to_signed(-17024949541, 48), to_signed(-55594162659, 48), to_signed(-170837526, 48)),

        (to_signed(-17248027347, 48), to_signed(-55718134343, 48), to_signed(-121729171, 48)),

        (to_signed(-17499757870, 48), to_signed(-55834483495, 48), to_signed(-173597078, 48)),

        (to_signed(-17772219443, 48), to_signed(-55936157431, 48), to_signed(-130315978, 48)),

        (to_signed(-18058720409, 48), to_signed(-56113320265, 48), to_signed(-130670392, 48)),

        (to_signed(-18340245525, 48), to_signed(-56244853229, 48), to_signed(-169810886, 48)),

        (to_signed(-18654731818, 48), to_signed(-56371721351, 48), to_signed(-159720047, 48)),

        (to_signed(-18948484271, 48), to_signed(-56514171097, 48), to_signed(-172435487, 48)),

        (to_signed(-19247673076, 48), to_signed(-56656174019, 48), to_signed(-158547731, 48)),

        (to_signed(-19538814569, 48), to_signed(-56808743305, 48), to_signed(-161167025, 48)),

        (to_signed(-19854199442, 48), to_signed(-56982006199, 48), to_signed(-143975648, 48)),

        (to_signed(-20141301546, 48), to_signed(-57078795663, 48), to_signed(-136129962, 48)),

        (to_signed(-20497432527, 48), to_signed(-57268802919, 48), to_signed(-135754719, 48)),

        (to_signed(-20777056077, 48), to_signed(-57387863392, 48), to_signed(-169659136, 48)),

        (to_signed(-21095747838, 48), to_signed(-57548965759, 48), to_signed(-164794796, 48)),

        (to_signed(-21365398596, 48), to_signed(-57679078115, 48), to_signed(-190523220, 48)),

        (to_signed(-21646450384, 48), to_signed(-57782268752, 48), to_signed(-175618492, 48)),

        (to_signed(-21877729581, 48), to_signed(-57892175408, 48), to_signed(-145729134, 48)),

        (to_signed(-22104449522, 48), to_signed(-58000270649, 48), to_signed(-134630099, 48)),

        (to_signed(-22360778436, 48), to_signed(-58090058140, 48), to_signed(-182262440, 48)),

        (to_signed(-22516655497, 48), to_signed(-58198996146, 48), to_signed(-170630737, 48)),

        (to_signed(-22682662087, 48), to_signed(-58291471088, 48), to_signed(-159979289, 48)),

        (to_signed(-22829493928, 48), to_signed(-58351969751, 48), to_signed(-153681388, 48)),

        (to_signed(-22988374566, 48), to_signed(-58428958077, 48), to_signed(-170810043, 48)),

        (to_signed(-23124722519, 48), to_signed(-58550279552, 48), to_signed(-148958025, 48)),

        (to_signed(-23302345139, 48), to_signed(-58600430631, 48), to_signed(-162867732, 48)),

        (to_signed(-23490060605, 48), to_signed(-58679459245, 48), to_signed(-154005934, 48)),

        (to_signed(-23657545828, 48), to_signed(-58776984889, 48), to_signed(-143443774, 48)),

        (to_signed(-23796311059, 48), to_signed(-58829681702, 48), to_signed(-151346593, 48)),

        (to_signed(-23988805094, 48), to_signed(-58936049378, 48), to_signed(-157621119, 48)),

        (to_signed(-24098019639, 48), to_signed(-59012194670, 48), to_signed(-150984164, 48)),

        (to_signed(-24271049860, 48), to_signed(-59097974787, 48), to_signed(-149473140, 48)),

        (to_signed(-24486443684, 48), to_signed(-59189069454, 48), to_signed(-153443048, 48)),

        (to_signed(-24706038554, 48), to_signed(-59307764435, 48), to_signed(-150992894, 48)),

        (to_signed(-24853307420, 48), to_signed(-59413573199, 48), to_signed(-119245891, 48)),

        (to_signed(-25078425185, 48), to_signed(-59463586906, 48), to_signed(-136099932, 48)),

        (to_signed(-25289604975, 48), to_signed(-59622267954, 48), to_signed(-150446385, 48)),

        (to_signed(-25570990706, 48), to_signed(-59742411143, 48), to_signed(-133774542, 48)),

        (to_signed(-25788165055, 48), to_signed(-59879626270, 48), to_signed(-151046507, 48)),

        (to_signed(-26011889798, 48), to_signed(-59971938417, 48), to_signed(-125742629, 48)),

        (to_signed(-26245058131, 48), to_signed(-60101136220, 48), to_signed(-139201276, 48)),

        (to_signed(-26487265742, 48), to_signed(-60169110053, 48), to_signed(-147181523, 48)),

        (to_signed(-26699452399, 48), to_signed(-60296487918, 48), to_signed(-137921441, 48)),

        (to_signed(-26956431782, 48), to_signed(-60441393628, 48), to_signed(-171866605, 48)),

        (to_signed(-27169689033, 48), to_signed(-60509499291, 48), to_signed(-164415698, 48)),

        (to_signed(-27394062294, 48), to_signed(-60648258113, 48), to_signed(-165542414, 48)),

        (to_signed(-27616229887, 48), to_signed(-60787619683, 48), to_signed(-143113490, 48)),

        (to_signed(-27841702040, 48), to_signed(-60941543499, 48), to_signed(-116444898, 48)),

        (to_signed(-28101289538, 48), to_signed(-60978615303, 48), to_signed(-108076672, 48)),

        (to_signed(-28336939558, 48), to_signed(-61157804611, 48), to_signed(-134806956, 48)),

        (to_signed(-28518545751, 48), to_signed(-61279537175, 48), to_signed(-137108901, 48)),

        (to_signed(-28763186525, 48), to_signed(-61352216592, 48), to_signed(-175728411, 48)),

        (to_signed(-29010099568, 48), to_signed(-61445880736, 48), to_signed(-154616232, 48)),

        (to_signed(-29200298254, 48), to_signed(-61581029257, 48), to_signed(-158728495, 48)),

        (to_signed(-29458764923, 48), to_signed(-61714780321, 48), to_signed(-155929188, 48)),

        (to_signed(-29781763257, 48), to_signed(-61882646004, 48), to_signed(-148362423, 48)),

        (to_signed(-30141258768, 48), to_signed(-62046689569, 48), to_signed(-153490146, 48)),

        (to_signed(-30448660887, 48), to_signed(-62216657977, 48), to_signed(-178805265, 48)),

        (to_signed(-30816927517, 48), to_signed(-62401652264, 48), to_signed(-133050087, 48)),

        (to_signed(-31223253978, 48), to_signed(-62585284858, 48), to_signed(-163583169, 48)),

        (to_signed(-31575476600, 48), to_signed(-62768746391, 48), to_signed(-141559219, 48)),

        (to_signed(-31953649047, 48), to_signed(-62961008870, 48), to_signed(-110763371, 48)),

        (to_signed(-32314214635, 48), to_signed(-63133731579, 48), to_signed(-160973006, 48)),

        (to_signed(-32726064994, 48), to_signed(-63338088925, 48), to_signed(-187987060, 48)),

        (to_signed(-33071066034, 48), to_signed(-63491998878, 48), to_signed(-150321823, 48)),

        (to_signed(-33430890110, 48), to_signed(-63684241642, 48), to_signed(-127027600, 48)),

        (to_signed(-33718287175, 48), to_signed(-63799706824, 48), to_signed(-112382227, 48)),

        (to_signed(-33948765104, 48), to_signed(-63891709377, 48), to_signed(-165605472, 48)),

        (to_signed(-34203258856, 48), to_signed(-63984909410, 48), to_signed(-136383030, 48)),

        (to_signed(-34413699011, 48), to_signed(-64106392369, 48), to_signed(-152262082, 48)),

        (to_signed(-34637273651, 48), to_signed(-64261683626, 48), to_signed(-145972195, 48)),

        (to_signed(-34864239541, 48), to_signed(-64365474036, 48), to_signed(-99569165, 48)),

        (to_signed(-35053456433, 48), to_signed(-64406703368, 48), to_signed(-168467517, 48)),

        (to_signed(-35160539842, 48), to_signed(-64495477878, 48), to_signed(-138132261, 48)),

        (to_signed(-35344181678, 48), to_signed(-64539270778, 48), to_signed(-133680164, 48)),

        (to_signed(-35482769373, 48), to_signed(-64582781301, 48), to_signed(-122447729, 48)),

        (to_signed(-35588287234, 48), to_signed(-64664763353, 48), to_signed(-138157763, 48)),

        (to_signed(-35714075690, 48), to_signed(-64703256906, 48), to_signed(-133770864, 48)),

        (to_signed(-35854231706, 48), to_signed(-64783913632, 48), to_signed(-144647314, 48)),

        (to_signed(-36021533042, 48), to_signed(-64828129257, 48), to_signed(-132698788, 48)),

        (to_signed(-36121506246, 48), to_signed(-64869182517, 48), to_signed(-142109247, 48)),

        (to_signed(-36275060366, 48), to_signed(-64957781152, 48), to_signed(-125060637, 48)),

        (to_signed(-36375103699, 48), to_signed(-64980172797, 48), to_signed(-140827362, 48)),

        (to_signed(-36513352383, 48), to_signed(-65044399789, 48), to_signed(-127437082, 48)),

        (to_signed(-36712009792, 48), to_signed(-65107639553, 48), to_signed(-132735814, 48)),

        (to_signed(-36900275573, 48), to_signed(-65192989568, 48), to_signed(-111552670, 48)),

        (to_signed(-37107335746, 48), to_signed(-65254633608, 48), to_signed(-129491847, 48)),

        (to_signed(-37335983457, 48), to_signed(-65373985312, 48), to_signed(-156279000, 48)),

        (to_signed(-37564274031, 48), to_signed(-65481856604, 48), to_signed(-103263770, 48)),

        (to_signed(-37842203183, 48), to_signed(-65571166707, 48), to_signed(-137533814, 48)),

        (to_signed(-38062575731, 48), to_signed(-65662669634, 48), to_signed(-131209374, 48)),

        (to_signed(-38325295259, 48), to_signed(-65769531071, 48), to_signed(-128137381, 48)),

        (to_signed(-38575067995, 48), to_signed(-65868235935, 48), to_signed(-92987446, 48)),

        (to_signed(-38808928252, 48), to_signed(-65979260561, 48), to_signed(-149780207, 48)),

        (to_signed(-39070354461, 48), to_signed(-66077138050, 48), to_signed(-59257788, 48)),

        (to_signed(-39317373707, 48), to_signed(-66187457956, 48), to_signed(-93047347, 48)),

        (to_signed(-39581370484, 48), to_signed(-66225395855, 48), to_signed(-107370887, 48)),

        (to_signed(-39780680387, 48), to_signed(-66363402901, 48), to_signed(-113025474, 48)),

        (to_signed(-40065420957, 48), to_signed(-66441944816, 48), to_signed(-108301993, 48)),

        (to_signed(-40330121604, 48), to_signed(-66530158127, 48), to_signed(-105338103, 48)),

        (to_signed(-40567161748, 48), to_signed(-66590876371, 48), to_signed(-104244456, 48)),

        (to_signed(-40825005864, 48), to_signed(-66698624602, 48), to_signed(-106736172, 48)),

        (to_signed(-41079198144, 48), to_signed(-66760527986, 48), to_signed(-115543044, 48)),

        (to_signed(-41317556459, 48), to_signed(-66880546379, 48), to_signed(-121345039, 48)),

        (to_signed(-41567521172, 48), to_signed(-66952351793, 48), to_signed(-121560485, 48)),

        (to_signed(-41841499952, 48), to_signed(-67058832794, 48), to_signed(-123280849, 48)),

        (to_signed(-42094629824, 48), to_signed(-67096613823, 48), to_signed(-101977616, 48)),

        (to_signed(-42341953375, 48), to_signed(-67240313505, 48), to_signed(-112029183, 48)),

        (to_signed(-42628328179, 48), to_signed(-67302976438, 48), to_signed(-172307238, 48)),

        (to_signed(-42867498615, 48), to_signed(-67385326812, 48), to_signed(-112959805, 48)),

        (to_signed(-43071939283, 48), to_signed(-67471352086, 48), to_signed(-122891402, 48)),

        (to_signed(-43320336582, 48), to_signed(-67561222320, 48), to_signed(-129234812, 48)),

        (to_signed(-43606837492, 48), to_signed(-67636702815, 48), to_signed(-139168600, 48)),

        (to_signed(-43847711140, 48), to_signed(-67710200826, 48), to_signed(-117520270, 48)),

        (to_signed(-44106887050, 48), to_signed(-67789813220, 48), to_signed(-124212306, 48)),

        (to_signed(-44315178712, 48), to_signed(-67847586803, 48), to_signed(-156805308, 48)),

        (to_signed(-44602775211, 48), to_signed(-67903082665, 48), to_signed(-140738778, 48)),

        (to_signed(-44878429462, 48), to_signed(-68025933323, 48), to_signed(-167599088, 48)),

        (to_signed(-45150866964, 48), to_signed(-68112872004, 48), to_signed(-179750776, 48)),

        (to_signed(-45422070388, 48), to_signed(-68162894998, 48), to_signed(-173263113, 48)),

        (to_signed(-45653705497, 48), to_signed(-68180952330, 48), to_signed(-157472976, 48)),

        (to_signed(-45931808870, 48), to_signed(-68300534893, 48), to_signed(-165143748, 48)),

        (to_signed(-46204981227, 48), to_signed(-68322370454, 48), to_signed(-181719383, 48)),

        (to_signed(-46453967822, 48), to_signed(-68384541921, 48), to_signed(-187355434, 48)),

        (to_signed(-46723265853, 48), to_signed(-68484795539, 48), to_signed(-200053483, 48)),

        (to_signed(-46938815308, 48), to_signed(-68528780717, 48), to_signed(-228668788, 48)),

        (to_signed(-47214329746, 48), to_signed(-68573825507, 48), to_signed(-219853050, 48)),

        (to_signed(-47491255325, 48), to_signed(-68670324977, 48), to_signed(-222863860, 48)),

        (to_signed(-47728292583, 48), to_signed(-68730198580, 48), to_signed(-232830590, 48)),

        (to_signed(-48013824261, 48), to_signed(-68799360854, 48), to_signed(-234731837, 48)),

        (to_signed(-48288354367, 48), to_signed(-68867447268, 48), to_signed(-251918085, 48)),

        (to_signed(-48478168706, 48), to_signed(-68904152424, 48), to_signed(-266397761, 48)),

        (to_signed(-48724499150, 48), to_signed(-68956630545, 48), to_signed(-262832573, 48)),

        (to_signed(-48980760735, 48), to_signed(-68978361288, 48), to_signed(-289724299, 48)),

        (to_signed(-49196370057, 48), to_signed(-69034688000, 48), to_signed(-312567379, 48)),

        (to_signed(-49437685213, 48), to_signed(-69060684596, 48), to_signed(-309000419, 48)),

        (to_signed(-49676012378, 48), to_signed(-69133547349, 48), to_signed(-327254633, 48)),

        (to_signed(-49867092239, 48), to_signed(-69144729382, 48), to_signed(-334577484, 48)),

        (to_signed(-50080414297, 48), to_signed(-69179133215, 48), to_signed(-334167125, 48)),

        (to_signed(-50365731135, 48), to_signed(-69269403724, 48), to_signed(-353529735, 48)),

        (to_signed(-50620916720, 48), to_signed(-69274574710, 48), to_signed(-358117497, 48)),

        (to_signed(-50960752188, 48), to_signed(-69306258146, 48), to_signed(-399709887, 48)),

        (to_signed(-51277483266, 48), to_signed(-69393154098, 48), to_signed(-379351375, 48)),

        (to_signed(-51602692826, 48), to_signed(-69391035433, 48), to_signed(-398204863, 48)),

        (to_signed(-52006104034, 48), to_signed(-69462714768, 48), to_signed(-433036976, 48)),

        (to_signed(-52389649186, 48), to_signed(-69532221076, 48), to_signed(-429371613, 48)),

        (to_signed(-52803258842, 48), to_signed(-69571976789, 48), to_signed(-445805520, 48)),

        (to_signed(-53183634869, 48), to_signed(-69612322167, 48), to_signed(-509609132, 48)),

        (to_signed(-53587869806, 48), to_signed(-69671062379, 48), to_signed(-516538568, 48)),

        (to_signed(-53989890403, 48), to_signed(-69713946911, 48), to_signed(-537749653, 48)),

        (to_signed(-54399962480, 48), to_signed(-69789080276, 48), to_signed(-561717959, 48)),

        (to_signed(-54767865269, 48), to_signed(-69817886748, 48), to_signed(-551779137, 48)),

        (to_signed(-54890349801, 48), to_signed(-69859554701, 48), to_signed(-576480663, 48)),

        (to_signed(-55039453678, 48), to_signed(-69852810928, 48), to_signed(-585200007, 48)),

        (to_signed(-55209092840, 48), to_signed(-69881218274, 48), to_signed(-621914801, 48)),

        (to_signed(-55335860176, 48), to_signed(-69893501722, 48), to_signed(-585168409, 48)),

        (to_signed(-55469755023, 48), to_signed(-69875531731, 48), to_signed(-624153645, 48)),

        (to_signed(-55655203691, 48), to_signed(-69893069144, 48), to_signed(-609890221, 48)),

        (to_signed(-55762914158, 48), to_signed(-69916267004, 48), to_signed(-613775496, 48)),

        (to_signed(-55927981722, 48), to_signed(-69959920970, 48), to_signed(-603134430, 48)),

        (to_signed(-56052126194, 48), to_signed(-69962011812, 48), to_signed(-655454240, 48)),

        (to_signed(-56219339126, 48), to_signed(-69951459313, 48), to_signed(-691688270, 48)),

        (to_signed(-56342094524, 48), to_signed(-69979033288, 48), to_signed(-642758659, 48)),

        (to_signed(-56423100469, 48), to_signed(-69949131723, 48), to_signed(-618985108, 48)),

        (to_signed(-56478969317, 48), to_signed(-69988077550, 48), to_signed(-631756133, 48)),

        (to_signed(-56559399838, 48), to_signed(-69998086992, 48), to_signed(-652374233, 48)),

        (to_signed(-56662910384, 48), to_signed(-70013127867, 48), to_signed(-667489551, 48)),

        (to_signed(-56721005876, 48), to_signed(-70012334022, 48), to_signed(-649049525, 48)),

        (to_signed(-56851297726, 48), to_signed(-70024779795, 48), to_signed(-682606132, 48)),

        (to_signed(-56985723440, 48), to_signed(-70027120369, 48), to_signed(-664954429, 48)),

        (to_signed(-57166125044, 48), to_signed(-70039728345, 48), to_signed(-671139653, 48)),

        (to_signed(-57317936319, 48), to_signed(-70085744546, 48), to_signed(-668506313, 48)),

        (to_signed(-57467397865, 48), to_signed(-70111670899, 48), to_signed(-646667920, 48)),

        (to_signed(-57643821184, 48), to_signed(-70136921616, 48), to_signed(-693057333, 48)),

        (to_signed(-57797030374, 48), to_signed(-70114371206, 48), to_signed(-714853622, 48)),

        (to_signed(-57934888570, 48), to_signed(-70158183992, 48), to_signed(-713417344, 48)),

        (to_signed(-58122642761, 48), to_signed(-70192570767, 48), to_signed(-749342095, 48)),

        (to_signed(-58260136294, 48), to_signed(-70166710675, 48), to_signed(-737990928, 48)),

        (to_signed(-58450626158, 48), to_signed(-70148000426, 48), to_signed(-740251945, 48)),

        (to_signed(-58560357354, 48), to_signed(-70205027364, 48), to_signed(-748888956, 48)),

        (to_signed(-58682633656, 48), to_signed(-70205957465, 48), to_signed(-744251008, 48)),

        (to_signed(-58885859649, 48), to_signed(-70233751631, 48), to_signed(-767315901, 48)),

        (to_signed(-58995335191, 48), to_signed(-70251883088, 48), to_signed(-741421097, 48)),

        (to_signed(-59109857014, 48), to_signed(-70249903944, 48), to_signed(-766936283, 48)),

        (to_signed(-59260518386, 48), to_signed(-70285292982, 48), to_signed(-773806677, 48)),

        (to_signed(-59388458226, 48), to_signed(-70291036379, 48), to_signed(-785862691, 48)),

        (to_signed(-59542391382, 48), to_signed(-70305224779, 48), to_signed(-784468749, 48)),

        (to_signed(-59668378627, 48), to_signed(-70336930164, 48), to_signed(-779940451, 48)),

        (to_signed(-59808424497, 48), to_signed(-70324483237, 48), to_signed(-814741601, 48)),

        (to_signed(-59907875030, 48), to_signed(-70362221624, 48), to_signed(-814939622, 48)),

        (to_signed(-60044853184, 48), to_signed(-70390124927, 48), to_signed(-812698626, 48)),

        (to_signed(-60165112120, 48), to_signed(-70386603827, 48), to_signed(-833887606, 48)),

        (to_signed(-60299340796, 48), to_signed(-70428838101, 48), to_signed(-828757194, 48)),

        (to_signed(-60422265818, 48), to_signed(-70431450849, 48), to_signed(-826706678, 48)),

        (to_signed(-60542996760, 48), to_signed(-70450235983, 48), to_signed(-807751891, 48)),

        (to_signed(-60650776325, 48), to_signed(-70450024028, 48), to_signed(-821721349, 48)),

        (to_signed(-60781676486, 48), to_signed(-70479892763, 48), to_signed(-826594638, 48)),

        (to_signed(-60884552159, 48), to_signed(-70508645679, 48), to_signed(-819331910, 48)),

        (to_signed(-60959544666, 48), to_signed(-70517358453, 48), to_signed(-840513850, 48)),

        (to_signed(-61084699405, 48), to_signed(-70530606982, 48), to_signed(-836259745, 48)),

        (to_signed(-61209734559, 48), to_signed(-70567424789, 48), to_signed(-849143956, 48)),

        (to_signed(-61289062106, 48), to_signed(-70599462103, 48), to_signed(-847561665, 48)),

        (to_signed(-61421011840, 48), to_signed(-70644497250, 48), to_signed(-866392299, 48)),

        (to_signed(-61553309866, 48), to_signed(-70663210431, 48), to_signed(-902133318, 48)),

        (to_signed(-61640979032, 48), to_signed(-70673314109, 48), to_signed(-868071111, 48)),

        (to_signed(-61760403170, 48), to_signed(-70701271705, 48), to_signed(-846550052, 48)),

        (to_signed(-61839864247, 48), to_signed(-70717035144, 48), to_signed(-859482013, 48)),

        (to_signed(-61938608159, 48), to_signed(-70735800356, 48), to_signed(-863426171, 48)),

        (to_signed(-62004634324, 48), to_signed(-70753726307, 48), to_signed(-863357515, 48)),

        (to_signed(-62104708649, 48), to_signed(-70802512502, 48), to_signed(-886480585, 48)),

        (to_signed(-62191302782, 48), to_signed(-70831884238, 48), to_signed(-888529269, 48)),

        (to_signed(-62251145073, 48), to_signed(-70877681332, 48), to_signed(-906073822, 48)),

        (to_signed(-62379590189, 48), to_signed(-70950622515, 48), to_signed(-904885831, 48)),

        (to_signed(-62415973842, 48), to_signed(-70971955771, 48), to_signed(-893123748, 48)),

        (to_signed(-62484427131, 48), to_signed(-70997330379, 48), to_signed(-887128509, 48)),

        (to_signed(-62599599969, 48), to_signed(-71053924953, 48), to_signed(-913537524, 48)),

        (to_signed(-62633037704, 48), to_signed(-71062281161, 48), to_signed(-922622592, 48)),

        (to_signed(-62723980990, 48), to_signed(-71085381210, 48), to_signed(-918932477, 48)),

        (to_signed(-62814060697, 48), to_signed(-71129332169, 48), to_signed(-912726424, 48)),

        (to_signed(-62873910308, 48), to_signed(-71192077229, 48), to_signed(-950908529, 48)),

        (to_signed(-62923864026, 48), to_signed(-71202202670, 48), to_signed(-969079854, 48)),

        (to_signed(-63036371093, 48), to_signed(-71267020768, 48), to_signed(-943605066, 48)),

        (to_signed(-63112381951, 48), to_signed(-71367623368, 48), to_signed(-957777754, 48)),

        (to_signed(-63201120206, 48), to_signed(-71472375910, 48), to_signed(-948602378, 48)),

        (to_signed(-63284538439, 48), to_signed(-71567276039, 48), to_signed(-945336145, 48)),

        (to_signed(-63333216701, 48), to_signed(-71668830683, 48), to_signed(-953240651, 48)),

        (to_signed(-63438377135, 48), to_signed(-71759575765, 48), to_signed(-924047645, 48)),

        (to_signed(-63499680758, 48), to_signed(-71859857608, 48), to_signed(-945713741, 48)),

        (to_signed(-63585762210, 48), to_signed(-71962617207, 48), to_signed(-948934087, 48)),

        (to_signed(-63646579507, 48), to_signed(-72055454422, 48), to_signed(-946315909, 48)),

        (to_signed(-63725884542, 48), to_signed(-72142926016, 48), to_signed(-978640864, 48)),

        (to_signed(-63790942439, 48), to_signed(-72247087589, 48), to_signed(-944880614, 48)),

        (to_signed(-63893773133, 48), to_signed(-72388047635, 48), to_signed(-966364733, 48)),

        (to_signed(-63963112932, 48), to_signed(-72503424572, 48), to_signed(-956534256, 48)),

        (to_signed(-64016890085, 48), to_signed(-72518268180, 48), to_signed(-987643772, 48)),

        (to_signed(-64049807131, 48), to_signed(-72630242468, 48), to_signed(-997606675, 48)),

        (to_signed(-64077907047, 48), to_signed(-72684447568, 48), to_signed(-959694954, 48)),

        (to_signed(-64113420910, 48), to_signed(-72773674451, 48), to_signed(-968979698, 48)),

        (to_signed(-64183476411, 48), to_signed(-72857642009, 48), to_signed(-992306652, 48)),

        (to_signed(-64195299450, 48), to_signed(-72891692138, 48), to_signed(-993641201, 48)),

        (to_signed(-64229029160, 48), to_signed(-72961406447, 48), to_signed(-962046950, 48)),

        (to_signed(-64286720674, 48), to_signed(-73057181778, 48), to_signed(-1002761569, 48)),

        (to_signed(-64304053525, 48), to_signed(-73164346596, 48), to_signed(-957125007, 48)),

        (to_signed(-64390406934, 48), to_signed(-73203407163, 48), to_signed(-1001672332, 48)),

        (to_signed(-64440190719, 48), to_signed(-73261035903, 48), to_signed(-977729921, 48)),

        (to_signed(-64491034824, 48), to_signed(-73365787883, 48), to_signed(-995831600, 48)),

        (to_signed(-64468258630, 48), to_signed(-73396519741, 48), to_signed(-981496378, 48)),

        (to_signed(-64510379720, 48), to_signed(-73452153110, 48), to_signed(-1001794197, 48)),

        (to_signed(-64550290775, 48), to_signed(-73494477598, 48), to_signed(-996445986, 48)),

        (to_signed(-64572661190, 48), to_signed(-73554490515, 48), to_signed(-994077560, 48)),

        (to_signed(-64624240923, 48), to_signed(-73625122372, 48), to_signed(-1012627280, 48)),

        (to_signed(-64592325506, 48), to_signed(-73641022089, 48), to_signed(-984433690, 48)),

        (to_signed(-64659190509, 48), to_signed(-73716057156, 48), to_signed(-1006522250, 48)),

        (to_signed(-64687523206, 48), to_signed(-73766155809, 48), to_signed(-1002796520, 48)),

        (to_signed(-64710675949, 48), to_signed(-73832395792, 48), to_signed(-1016322774, 48)),

        (to_signed(-64750630477, 48), to_signed(-73874675718, 48), to_signed(-1043149645, 48)),

        (to_signed(-64790792503, 48), to_signed(-73932583724, 48), to_signed(-1003886193, 48)),

        (to_signed(-64844334445, 48), to_signed(-73970981100, 48), to_signed(-960679818, 48)),

        (to_signed(-64865767227, 48), to_signed(-73988260635, 48), to_signed(-988064263, 48)),

        (to_signed(-64884706691, 48), to_signed(-74088893812, 48), to_signed(-1001621825, 48)),

        (to_signed(-64936314089, 48), to_signed(-74141846990, 48), to_signed(-1005780217, 48)),

        (to_signed(-64974761925, 48), to_signed(-74138992571, 48), to_signed(-1001063677, 48)),

        (to_signed(-65052672607, 48), to_signed(-74216085373, 48), to_signed(-992332407, 48)),

        (to_signed(-65103303314, 48), to_signed(-74272697474, 48), to_signed(-1021393245, 48)),

        (to_signed(-65136313248, 48), to_signed(-74289877809, 48), to_signed(-982840206, 48)),

        (to_signed(-65182869404, 48), to_signed(-74362031601, 48), to_signed(-989435662, 48)),

        (to_signed(-65215048243, 48), to_signed(-74365782243, 48), to_signed(-989290959, 48)),

        (to_signed(-65311401994, 48), to_signed(-74429590438, 48), to_signed(-993886061, 48)),

        (to_signed(-65307298342, 48), to_signed(-74493347450, 48), to_signed(-1000820159, 48)),

        (to_signed(-65392239704, 48), to_signed(-74486533855, 48), to_signed(-989852127, 48)),

        (to_signed(-65453379480, 48), to_signed(-74570455516, 48), to_signed(-991203464, 48)),

        (to_signed(-65519826730, 48), to_signed(-74585408837, 48), to_signed(-1007063867, 48)),

        (to_signed(-65587239156, 48), to_signed(-74630403661, 48), to_signed(-1010739083, 48)),

        (to_signed(-65602293590, 48), to_signed(-74651151188, 48), to_signed(-999398370, 48)),

        (to_signed(-65671502862, 48), to_signed(-74684358798, 48), to_signed(-975110582, 48)),

        (to_signed(-65751003719, 48), to_signed(-74747585494, 48), to_signed(-1021879187, 48)),

        (to_signed(-65810521685, 48), to_signed(-74793083671, 48), to_signed(-1025720737, 48)),

        (to_signed(-65855060905, 48), to_signed(-74802799556, 48), to_signed(-998352451, 48)),

        (to_signed(-65882059342, 48), to_signed(-74851959977, 48), to_signed(-1000279855, 48)),

        (to_signed(-65975161039, 48), to_signed(-74836511708, 48), to_signed(-998241864, 48)),

        (to_signed(-66058886648, 48), to_signed(-74890628234, 48), to_signed(-997064444, 48)),

        (to_signed(-66100653255, 48), to_signed(-74921676171, 48), to_signed(-1004909257, 48)),

        (to_signed(-66163968188, 48), to_signed(-74935076848, 48), to_signed(-976176029, 48)),

        (to_signed(-66267501172, 48), to_signed(-74983404474, 48), to_signed(-1028037747, 48)),

        (to_signed(-66286028114, 48), to_signed(-74999732600, 48), to_signed(-1015086153, 48)),

        (to_signed(-66351853912, 48), to_signed(-74985920194, 48), to_signed(-1002925852, 48)),

        (to_signed(-66400840986, 48), to_signed(-75031700461, 48), to_signed(-1028761286, 48)),

        (to_signed(-66446762819, 48), to_signed(-75049431504, 48), to_signed(-1004139863, 48)),

        (to_signed(-66524144295, 48), to_signed(-75034051362, 48), to_signed(-973311035, 48)),

        (to_signed(-66612817887, 48), to_signed(-75034349735, 48), to_signed(-1000831825, 48)),

        (to_signed(-66692132872, 48), to_signed(-75053368163, 48), to_signed(-997308086, 48)),

        (to_signed(-66695656399, 48), to_signed(-75059906939, 48), to_signed(-1022317025, 48)),

        (to_signed(-66803098456, 48), to_signed(-75100502410, 48), to_signed(-1011512160, 48)),

        (to_signed(-66869120046, 48), to_signed(-75122847168, 48), to_signed(-1007462446, 48)),

        (to_signed(-66935020256, 48), to_signed(-75084992593, 48), to_signed(-1006494433, 48)),

        (to_signed(-66996553958, 48), to_signed(-75126782110, 48), to_signed(-979658007, 48)),

        (to_signed(-67067560999, 48), to_signed(-75136764369, 48), to_signed(-991800281, 48)),

        (to_signed(-67140025248, 48), to_signed(-75121460337, 48), to_signed(-1019800318, 48)),

        (to_signed(-67204907532, 48), to_signed(-75145275729, 48), to_signed(-997013961, 48)),

        (to_signed(-67262948038, 48), to_signed(-75151673529, 48), to_signed(-992789496, 48)),

        (to_signed(-67338181451, 48), to_signed(-75127713681, 48), to_signed(-982018387, 48)),

        (to_signed(-67407689632, 48), to_signed(-75179547173, 48), to_signed(-974628486, 48)),

        (to_signed(-67469604388, 48), to_signed(-75154725002, 48), to_signed(-1018183181, 48)),

        (to_signed(-67581218420, 48), to_signed(-75160758618, 48), to_signed(-1014786990, 48)),

        (to_signed(-67657258419, 48), to_signed(-75148632473, 48), to_signed(-1022312047, 48)),

        (to_signed(-67832517749, 48), to_signed(-75118918823, 48), to_signed(-1005169925, 48)),

        (to_signed(-67875280031, 48), to_signed(-75127465762, 48), to_signed(-993449861, 48)),

        (to_signed(-67978237258, 48), to_signed(-75118378286, 48), to_signed(-984739664, 48)),

        (to_signed(-68139479436, 48), to_signed(-75100839272, 48), to_signed(-1002608968, 48)),

        (to_signed(-68215993686, 48), to_signed(-75116379414, 48), to_signed(-1006731205, 48)),

        (to_signed(-68322026707, 48), to_signed(-75115759690, 48), to_signed(-998849310, 48)),

        (to_signed(-68444959713, 48), to_signed(-75110632641, 48), to_signed(-1015437092, 48)),

        (to_signed(-68539945805, 48), to_signed(-75117517205, 48), to_signed(-966399409, 48)),

        (to_signed(-68651079199, 48), to_signed(-75041453348, 48), to_signed(-1028458461, 48)),

        (to_signed(-68696699655, 48), to_signed(-75083787374, 48), to_signed(-998343431, 48)),

        (to_signed(-68798951024, 48), to_signed(-75057420287, 48), to_signed(-967417213, 48)),

        (to_signed(-68881867177, 48), to_signed(-75046782082, 48), to_signed(-1001178437, 48)),

        (to_signed(-68979643911, 48), to_signed(-75025410155, 48), to_signed(-1004405673, 48)),

        (to_signed(-69095949375, 48), to_signed(-75005537131, 48), to_signed(-1007127244, 48)),

        (to_signed(-69141400669, 48), to_signed(-74995473127, 48), to_signed(-1003962896, 48)),

        (to_signed(-69179983986, 48), to_signed(-75010378440, 48), to_signed(-977709971, 48)),

        (to_signed(-69264291881, 48), to_signed(-74994086408, 48), to_signed(-1037657553, 48)),

        (to_signed(-69287419499, 48), to_signed(-74977228213, 48), to_signed(-974628040, 48)),

        (to_signed(-69359007269, 48), to_signed(-74976828009, 48), to_signed(-1024050946, 48)),

        (to_signed(-69403421832, 48), to_signed(-74936275914, 48), to_signed(-1004645243, 48)),

        (to_signed(-69421605467, 48), to_signed(-74945549891, 48), to_signed(-1007471390, 48)),

        (to_signed(-69462479908, 48), to_signed(-74932002265, 48), to_signed(-990493884, 48)),

        (to_signed(-69512389431, 48), to_signed(-74923754552, 48), to_signed(-1027278551, 48)),

        (to_signed(-69523283111, 48), to_signed(-74905732615, 48), to_signed(-992810808, 48)),

        (to_signed(-69597270685, 48), to_signed(-74912927587, 48), to_signed(-966700804, 48)),

        (to_signed(-69605199781, 48), to_signed(-74928266239, 48), to_signed(-1023631653, 48)),

        (to_signed(-69641982892, 48), to_signed(-74890347744, 48), to_signed(-997676952, 48)),

        (to_signed(-69693526821, 48), to_signed(-74898525736, 48), to_signed(-1012064216, 48)),

        (to_signed(-69719261904, 48), to_signed(-74887010882, 48), to_signed(-993911101, 48)),

        (to_signed(-69783765653, 48), to_signed(-74858551657, 48), to_signed(-1000885144, 48)),

        (to_signed(-69816511431, 48), to_signed(-74832211897, 48), to_signed(-1013102698, 48)),

        (to_signed(-69904354757, 48), to_signed(-74837227588, 48), to_signed(-995289139, 48)),

        (to_signed(-69979261033, 48), to_signed(-74817000735, 48), to_signed(-974336283, 48)),

        (to_signed(-70022130324, 48), to_signed(-74778221292, 48), to_signed(-1008944999, 48)),

        (to_signed(-70120785286, 48), to_signed(-74787338178, 48), to_signed(-994800574, 48)),

        (to_signed(-70218160367, 48), to_signed(-74727005058, 48), to_signed(-1029806619, 48)),

        (to_signed(-70313203887, 48), to_signed(-74738162700, 48), to_signed(-1025430878, 48)),

        (to_signed(-70369478499, 48), to_signed(-74754187395, 48), to_signed(-1002734315, 48)),

        (to_signed(-70493685374, 48), to_signed(-74689004043, 48), to_signed(-987036082, 48)),

        (to_signed(-70535320449, 48), to_signed(-74672244561, 48), to_signed(-1007244655, 48)),

        (to_signed(-70692247665, 48), to_signed(-74633997197, 48), to_signed(-1019738538, 48)),

        (to_signed(-70721414546, 48), to_signed(-74621337868, 48), to_signed(-1015773624, 48)),

        (to_signed(-70838893751, 48), to_signed(-74611951203, 48), to_signed(-1038015535, 48)),

        (to_signed(-70941476291, 48), to_signed(-74601064796, 48), to_signed(-1007492857, 48)),

        (to_signed(-71048557327, 48), to_signed(-74552221334, 48), to_signed(-1003123816, 48)),

        (to_signed(-71133317477, 48), to_signed(-74530397356, 48), to_signed(-1025447198, 48)),

        (to_signed(-71240018016, 48), to_signed(-74511671452, 48), to_signed(-1024457825, 48)),

        (to_signed(-71320249018, 48), to_signed(-74477861071, 48), to_signed(-1010820574, 48)),

        (to_signed(-71436215671, 48), to_signed(-74445523324, 48), to_signed(-1021317657, 48)),

        (to_signed(-71534983189, 48), to_signed(-74452722077, 48), to_signed(-1013809682, 48)),

        (to_signed(-71642977975, 48), to_signed(-74465211049, 48), to_signed(-976182120, 48)),

        (to_signed(-71737205705, 48), to_signed(-74423492160, 48), to_signed(-1014263454, 48)),

        (to_signed(-71830459000, 48), to_signed(-74396679104, 48), to_signed(-1014840446, 48)),

        (to_signed(-71963687662, 48), to_signed(-74412789603, 48), to_signed(-1018401889, 48)),

        (to_signed(-72056987336, 48), to_signed(-74390611473, 48), to_signed(-993761916, 48)),

        (to_signed(-72121271377, 48), to_signed(-74373920505, 48), to_signed(-1007997267, 48)),

        (to_signed(-72230247374, 48), to_signed(-74373139234, 48), to_signed(-1014560947, 48)),

        (to_signed(-72335573489, 48), to_signed(-74334898379, 48), to_signed(-980207917, 48)),

        (to_signed(-72434025355, 48), to_signed(-74334401572, 48), to_signed(-977339796, 48)),

        (to_signed(-72577378373, 48), to_signed(-74327013400, 48), to_signed(-1011372013, 48)),

        (to_signed(-72741140692, 48), to_signed(-74350621221, 48), to_signed(-1032755716, 48)),

        (to_signed(-72894018015, 48), to_signed(-74344750493, 48), to_signed(-984678892, 48)),

        (to_signed(-73026549692, 48), to_signed(-74326971199, 48), to_signed(-1013210144, 48)),

        (to_signed(-73203617754, 48), to_signed(-74352872498, 48), to_signed(-989396255, 48)),

        (to_signed(-73341361740, 48), to_signed(-74327676282, 48), to_signed(-1036991112, 48)),

        (to_signed(-73537783400, 48), to_signed(-74373387241, 48), to_signed(-990240459, 48)),

        (to_signed(-73652960123, 48), to_signed(-74372945406, 48), to_signed(-1026813353, 48)),

        (to_signed(-73823305321, 48), to_signed(-74371101244, 48), to_signed(-995510575, 48)),

        (to_signed(-73987946428, 48), to_signed(-74420576282, 48), to_signed(-1008808803, 48)),

        (to_signed(-74136762777, 48), to_signed(-74436354055, 48), to_signed(-1026330215, 48)),

        (to_signed(-74286315274, 48), to_signed(-74442441382, 48), to_signed(-1018432207, 48)),

        (to_signed(-74458246695, 48), to_signed(-74405695002, 48), to_signed(-1001366260, 48)),

        (to_signed(-74667157448, 48), to_signed(-74446168823, 48), to_signed(-1012381662, 48)),

        (to_signed(-74818748145, 48), to_signed(-74404023249, 48), to_signed(-1005630956, 48)),

        (to_signed(-74968770824, 48), to_signed(-74466441746, 48), to_signed(-983554111, 48)),

        (to_signed(-75114318542, 48), to_signed(-74463958508, 48), to_signed(-1044174711, 48)),

        (to_signed(-75176288443, 48), to_signed(-74452154810, 48), to_signed(-990882428, 48)),

        (to_signed(-75267366324, 48), to_signed(-74455342824, 48), to_signed(-1016347611, 48)),

        (to_signed(-75322273980, 48), to_signed(-74465385543, 48), to_signed(-1033261167, 48)),

        (to_signed(-75408297672, 48), to_signed(-74490671169, 48), to_signed(-1040584693, 48)),

        (to_signed(-75476101059, 48), to_signed(-74504735628, 48), to_signed(-1021522308, 48)),

        (to_signed(-75559658393, 48), to_signed(-74522947950, 48), to_signed(-1002970332, 48))
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

        file_open(output_file, "vhdl_output_f1_monaco_2024_750cycles.txt", write_mode);

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
               " Dataset: f1_monaco_2024_750cycles" &
               " Cycles: " & integer'image(NUM_CYCLES);

        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end behavioral;
