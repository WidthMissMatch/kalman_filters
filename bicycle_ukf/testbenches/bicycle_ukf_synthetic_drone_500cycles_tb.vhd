library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity bicycle_ukf_synthetic_drone_500cycles_tb is
end entity bicycle_ukf_synthetic_drone_500cycles_tb;

architecture behavioral of bicycle_ukf_synthetic_drone_500cycles_tb is

    component bicycle_ukf_supreme is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            start : in  std_logic;
            v_init     : in signed(47 downto 0);
            theta_init : in signed(47 downto 0);
            z_x_meas : in signed(47 downto 0);
            z_y_meas : in signed(47 downto 0);
            z_z_meas : in signed(47 downto 0);
            px_current    : out signed(47 downto 0);
            py_current    : out signed(47 downto 0);
            v_current     : out signed(47 downto 0);
            theta_current : out signed(47 downto 0);
            delta_current : out signed(47 downto 0);
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

    signal px_out, py_out, v_out, theta_out, delta_out, a_out, z_out : signed(47 downto 0);

    signal p11_out, p22_out, p33_out, p44_out, p55_out, p66_out, p77_out : signed(47 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant NUM_CYCLES : integer := 500;

    type meas_triple is array(0 to 2) of signed(47 downto 0);
    type meas_data_array is array(0 to NUM_CYCLES-1) of meas_triple;

    constant MEAS_DATA : meas_data_array := (

        (signed'(x"0000327F28A8"), signed'(x"FFFFFFDC9AB6"), signed'(x"00000AA5CEEA")),

        (signed'(x"000033854172"), signed'(x"000000440DFA"), signed'(x"000009C61BE3")),

        (signed'(x"00003391B7F3"), signed'(x"000001C4723B"), signed'(x"0000098BE917")),

        (signed'(x"0000328522C3"), signed'(x"000001094EB6"), signed'(x"0000098EEAC2")),

        (signed'(x"00003233B426"), signed'(x"000000161050"), signed'(x"0000084E9CD8")),

        (signed'(x"000031600EC7"), signed'(x"0000017C72D7"), signed'(x"00000A5AAFC7")),

        (signed'(x"000031008343"), signed'(x"00000195FD52"), signed'(x"00000B837E2F")),

        (signed'(x"000031A6DAA4"), signed'(x"000003908E40"), signed'(x"000008A1993D")),

        (signed'(x"0000314BB32A"), signed'(x"0000041B4DE4"), signed'(x"000008E9BA12")),

        (signed'(x"0000322C5FA9"), signed'(x"000003E4AE92"), signed'(x"000009C7C121")),

        (signed'(x"000031260434"), signed'(x"000006D80D0A"), signed'(x"00000A1104ED")),

        (signed'(x"000030A3DD32"), signed'(x"0000064FBBD6"), signed'(x"000008DDFC19")),

        (signed'(x"000031D96B6C"), signed'(x"00000406A405"), signed'(x"000008C48D0A")),

        (signed'(x"000031C66382"), signed'(x"000007385D4D"), signed'(x"00000A467B76")),

        (signed'(x"0000316528A6"), signed'(x"000006AD11BF"), signed'(x"000008A227C7")),

        (signed'(x"000030B7FD5B"), signed'(x"00000702E273"), signed'(x"00000B2D532A")),

        (signed'(x"000031B479BA"), signed'(x"00000633EF4C"), signed'(x"00000A73B60C")),

        (signed'(x"000030E4E769"), signed'(x"000007C83DF6"), signed'(x"00000ABF60D8")),

        (signed'(x"000032392298"), signed'(x"000009E1FC7A"), signed'(x"0000094DFE12")),

        (signed'(x"000030CA7EEF"), signed'(x"000009C63281"), signed'(x"00000B209D35")),

        (signed'(x"000030862EFF"), signed'(x"000009BF7051"), signed'(x"0000090DB1CF")),

        (signed'(x"00002FB4911A"), signed'(x"00000B3C4B17"), signed'(x"00000B8627A6")),

        (signed'(x"000030B90D81"), signed'(x"00000BEA3E5C"), signed'(x"00000A8993A2")),

        (signed'(x"00003009C779"), signed'(x"00000BC2A12B"), signed'(x"00000BB8C662")),

        (signed'(x"00003087F461"), signed'(x"00000D732473"), signed'(x"000007926BFA")),

        (signed'(x"000031447C6D"), signed'(x"00000C750E02"), signed'(x"000009E6919E")),

        (signed'(x"000030694850"), signed'(x"00000ADDD03C"), signed'(x"000009FCEA82")),

        (signed'(x"0000308BB033"), signed'(x"00000ED080D5"), signed'(x"000009B282EA")),

        (signed'(x"00002F3E8906"), signed'(x"00000D50E70A"), signed'(x"00000B23912F")),

        (signed'(x"0000303DAE90"), signed'(x"00000DC491E2"), signed'(x"00000ABEA7C5")),

        (signed'(x"00002FDD28AE"), signed'(x"00000FBEA1BB"), signed'(x"00000989912A")),

        (signed'(x"00002F49FCF9"), signed'(x"00000EDC5EF0"), signed'(x"000008C8AA64")),

        (signed'(x"00002FC20528"), signed'(x"00000FFD4839"), signed'(x"00000A42AA8E")),

        (signed'(x"00002F1149A6"), signed'(x"00000EC96A75"), signed'(x"000009D7B3E4")),

        (signed'(x"00002ECB8659"), signed'(x"00000FDF4075"), signed'(x"00000A1C20DF")),

        (signed'(x"00002F5F6861"), signed'(x"00001307F49D"), signed'(x"00000A742353")),

        (signed'(x"00002F0D6988"), signed'(x"0000118A0D51"), signed'(x"0000085E449D")),

        (signed'(x"00002E9700A1"), signed'(x"0000122418B1"), signed'(x"00000CC216F3")),

        (signed'(x"00002E3DA9B5"), signed'(x"000012D8FA66"), signed'(x"00000A44A372")),

        (signed'(x"00002D13A786"), signed'(x"00001426F96F"), signed'(x"00000B100B15")),

        (signed'(x"00002ED815BC"), signed'(x"0000128FC068"), signed'(x"00000BB8AFAF")),

        (signed'(x"00002C7445CD"), signed'(x"000014846F4F"), signed'(x"00000C845947")),

        (signed'(x"00002CA9F60D"), signed'(x"000013D25C90"), signed'(x"00000A6F1F69")),

        (signed'(x"00002CF1DF30"), signed'(x"0000134AF9F7"), signed'(x"00000A692EBB")),

        (signed'(x"00002C2CDF1D"), signed'(x"000015C543CA"), signed'(x"0000096E465F")),

        (signed'(x"00002E928190"), signed'(x"000014F70BC6"), signed'(x"00000A093724")),

        (signed'(x"00002D9DBB7C"), signed'(x"000014F76F3B"), signed'(x"00000A97E834")),

        (signed'(x"00002DE2B3DF"), signed'(x"000015096DC2"), signed'(x"00000A8EF4CD")),

        (signed'(x"00002C9C10A4"), signed'(x"000017DEEB8B"), signed'(x"000009250AB0")),

        (signed'(x"00002ACBD2DD"), signed'(x"0000180DA0DF"), signed'(x"00000AAFBD21")),

        (signed'(x"00002C212ED6"), signed'(x"00001851566F"), signed'(x"000009B7A1E2")),

        (signed'(x"00002BDE962E"), signed'(x"000018B3B200"), signed'(x"000009B0D9E1")),

        (signed'(x"00002D41B949"), signed'(x"000019515DF3"), signed'(x"00000938C18C")),

        (signed'(x"00002BCC021B"), signed'(x"0000184D4EEA"), signed'(x"00000B3539F6")),

        (signed'(x"00002C0B4586"), signed'(x"000018E2D894"), signed'(x"00000B645BBB")),

        (signed'(x"00002B09FC5D"), signed'(x"00001AF4D80B"), signed'(x"00000C555004")),

        (signed'(x"00002A1E0BCA"), signed'(x"000019CE3A14"), signed'(x"0000098E03FF")),

        (signed'(x"000029477C2C"), signed'(x"00001AE78D5C"), signed'(x"00000ACB0FE7")),

        (signed'(x"00002A198E04"), signed'(x"00001C3A771E"), signed'(x"00000A790CBE")),

        (signed'(x"00002B002539"), signed'(x"00001B8DAB3F"), signed'(x"00000D3013A8")),

        (signed'(x"000029E4777A"), signed'(x"00001B5FFDC7"), signed'(x"000009678E25")),

        (signed'(x"0000297701EF"), signed'(x"00001C6B7F3C"), signed'(x"00000B3279E7")),

        (signed'(x"0000292ACB07"), signed'(x"00001CFA9B19"), signed'(x"000009A4E633")),

        (signed'(x"000026E2F382"), signed'(x"00001D02BEBD"), signed'(x"00000B5AE69C")),

        (signed'(x"00002851A23A"), signed'(x"00001C9D3149"), signed'(x"00000AADFAB6")),

        (signed'(x"00002830838D"), signed'(x"00001D601E55"), signed'(x"00000AAAFA97")),

        (signed'(x"0000278ECD4F"), signed'(x"00001D834B99"), signed'(x"00000AE13269")),

        (signed'(x"000027C07A68"), signed'(x"00002021E1BA"), signed'(x"00000B955A47")),

        (signed'(x"000025803F58"), signed'(x"00001E8077AD"), signed'(x"00000B0D66F3")),

        (signed'(x"000027137A6B"), signed'(x"000020578734"), signed'(x"00000E65D2F0")),

        (signed'(x"000026D020C2"), signed'(x"00002158B0F2"), signed'(x"00000B81B7F2")),

        (signed'(x"00002691C9C5"), signed'(x"00002046C36A"), signed'(x"00000B51C1DF")),

        (signed'(x"000024D14523"), signed'(x"000020BB7F8C"), signed'(x"00000A152C45")),

        (signed'(x"00002557312F"), signed'(x"000023A87BE2"), signed'(x"000008B55E5C")),

        (signed'(x"0000259C1485"), signed'(x"0000201A07AE"), signed'(x"00000A1C88B7")),

        (signed'(x"000025AC638D"), signed'(x"000022256E8B"), signed'(x"000009836757")),

        (signed'(x"00002386C87F"), signed'(x"000023202BE8"), signed'(x"000009DE49AD")),

        (signed'(x"0000241CAB83"), signed'(x"000022DA328B"), signed'(x"000009F467A3")),

        (signed'(x"000025B08B00"), signed'(x"000023CC4284"), signed'(x"00000896BA78")),

        (signed'(x"00002360F3CC"), signed'(x"000022DB1AC3"), signed'(x"00000B7955F0")),

        (signed'(x"0000220AF5E7"), signed'(x"000023C0C912"), signed'(x"00000B2255B6")),

        (signed'(x"000023573698"), signed'(x"000023039996"), signed'(x"00000A4D5E56")),

        (signed'(x"000021A2D86F"), signed'(x"000023E76A11"), signed'(x"00000C68E5B1")),

        (signed'(x"0000222615C5"), signed'(x"000023A2BC39"), signed'(x"00000B91D9E1")),

        (signed'(x"0000237ECBD0"), signed'(x"00002643BE38"), signed'(x"00000923DAC4")),

        (signed'(x"00002083D202"), signed'(x"000026D4B7EB"), signed'(x"000009F594FE")),

        (signed'(x"00002110D13E"), signed'(x"000026AAB0ED"), signed'(x"000009BF616D")),

        (signed'(x"0000202E8A93"), signed'(x"000022F9A55D"), signed'(x"000009A85BB1")),

        (signed'(x"00001F9AE090"), signed'(x"0000254A0670"), signed'(x"00000C526C2B")),

        (signed'(x"00001E0A5B95"), signed'(x"00002669DDF2"), signed'(x"00000AD3EA74")),

        (signed'(x"0000208592D4"), signed'(x"000025BB00F4"), signed'(x"00000BDE2263")),

        (signed'(x"00001EB290B4"), signed'(x"0000267E61B4"), signed'(x"00000B2C9402")),

        (signed'(x"00001E7D7510"), signed'(x"0000272E0B93"), signed'(x"00000ACA0FB5")),

        (signed'(x"00001D81A27B"), signed'(x"00002831CBB1"), signed'(x"00000B639B5C")),

        (signed'(x"00001F134E99"), signed'(x"00002723DCE8"), signed'(x"00000CDE107C")),

        (signed'(x"00001B21CF1F"), signed'(x"00002884DC89"), signed'(x"00000B54853E")),

        (signed'(x"00001CF4FD5F"), signed'(x"000028563DB1"), signed'(x"00000A8A8849")),

        (signed'(x"00001BC5A031"), signed'(x"000028A7A8E5"), signed'(x"00000B9B3505")),

        (signed'(x"00001C3548D9"), signed'(x"000028D4FB42"), signed'(x"00000BA9E697")),

        (signed'(x"00001BBDE61D"), signed'(x"00002A9D39A8"), signed'(x"00000B66ADE3")),

        (signed'(x"00001A2FA594"), signed'(x"000029836C19"), signed'(x"00000B86B079")),

        (signed'(x"00001B341270"), signed'(x"00002A5218C8"), signed'(x"00000AE74D7F")),

        (signed'(x"00001B722A98"), signed'(x"00002A038A58"), signed'(x"00000B573492")),

        (signed'(x"00001989EB7E"), signed'(x"00002AA5B35F"), signed'(x"00000BE65046")),

        (signed'(x"00001A22ED06"), signed'(x"00002BEF0856"), signed'(x"00000C1D1AB0")),

        (signed'(x"000018E64951"), signed'(x"00002C0D98E5"), signed'(x"00000A815856")),

        (signed'(x"000018C48C9A"), signed'(x"00002B7CD563"), signed'(x"00000AEB78FF")),

        (signed'(x"00001899F348"), signed'(x"00002B0AB3B3"), signed'(x"00000CEC2864")),

        (signed'(x"0000168F766D"), signed'(x"00002AE23A46"), signed'(x"00000BFED836")),

        (signed'(x"000017EA7A74"), signed'(x"00002CF49963"), signed'(x"00000B791531")),

        (signed'(x"000016AAE52A"), signed'(x"00002BA9C1D0"), signed'(x"00000AED7CAA")),

        (signed'(x"0000158E5063"), signed'(x"00002DC292E6"), signed'(x"00000AB64916")),

        (signed'(x"000014F56874"), signed'(x"00002CAF02C9"), signed'(x"00000B477D84")),

        (signed'(x"000014C4EE9B"), signed'(x"00002C65FCD3"), signed'(x"00000B1E0205")),

        (signed'(x"0000151FEBCC"), signed'(x"00002CECBB36"), signed'(x"00000A68E0F2")),

        (signed'(x"000014A80B45"), signed'(x"00002C30AB39"), signed'(x"0000097AFD9E")),

        (signed'(x"0000133F9FCF"), signed'(x"00002DA06FF4"), signed'(x"00000B34BA20")),

        (signed'(x"000014FBA1FB"), signed'(x"00002EE52B23"), signed'(x"00000ABE0524")),

        (signed'(x"00001306F837"), signed'(x"00002D3A4F37"), signed'(x"00000AE40D08")),

        (signed'(x"0000124B5989"), signed'(x"00002EBDBD1D"), signed'(x"00000A16D763")),

        (signed'(x"000012A321C8"), signed'(x"000030227B41"), signed'(x"00000AD0969D")),

        (signed'(x"0000120D7C8D"), signed'(x"00002F788FCA"), signed'(x"00000A87887D")),

        (signed'(x"000011680881"), signed'(x"00002EF7B206"), signed'(x"00000B090FC1")),

        (signed'(x"00000FF05A37"), signed'(x"00002F26219A"), signed'(x"00000B7159DD")),

        (signed'(x"000011B0E29C"), signed'(x"0000303F9BC8"), signed'(x"00000D1AE19F")),

        (signed'(x"00000EFFAF6D"), signed'(x"000030525134"), signed'(x"00000B2466C4")),

        (signed'(x"0000117B0BC5"), signed'(x"00002ECBD4FE"), signed'(x"00000A204ADB")),

        (signed'(x"00000E36F35E"), signed'(x"00002DA192DA"), signed'(x"00000A727593")),

        (signed'(x"00000D939DE1"), signed'(x"0000300D1A94"), signed'(x"00000B525458")),

        (signed'(x"00000FBB726A"), signed'(x"000030FDFF50"), signed'(x"00000A68EF9B")),

        (signed'(x"00000C79FDA8"), signed'(x"000030AB79E0"), signed'(x"000009AC6C45")),

        (signed'(x"00000EB95577"), signed'(x"0000317D1AA3"), signed'(x"00000A8811A4")),

        (signed'(x"00000AB21555"), signed'(x"000031CA2505"), signed'(x"00000AE4A078")),

        (signed'(x"00000D295FDC"), signed'(x"00002EF68697"), signed'(x"00000A6A46AB")),

        (signed'(x"00000B7160DA"), signed'(x"000030B8A111"), signed'(x"00000A92431E")),

        (signed'(x"00000B92BC34"), signed'(x"00002FB7F2B9"), signed'(x"00000AE2C9D9")),

        (signed'(x"00000A950CF4"), signed'(x"000031685CFE"), signed'(x"00000BBF2A5F")),

        (signed'(x"000008D90C4D"), signed'(x"00002F761707"), signed'(x"00000C51D3DE")),

        (signed'(x"000009D0799B"), signed'(x"000030581CD5"), signed'(x"00000C99954D")),

        (signed'(x"0000091B3804"), signed'(x"0000325D4540"), signed'(x"00000B1F83C4")),

        (signed'(x"00000A8F2182"), signed'(x"000033071FB1"), signed'(x"00000AD03B85")),

        (signed'(x"000008FA0EAE"), signed'(x"0000320018F8"), signed'(x"00000C7011EC")),

        (signed'(x"0000068BDD98"), signed'(x"0000321E5F2A"), signed'(x"00000C2262B7")),

        (signed'(x"0000054201DA"), signed'(x"000030526C97"), signed'(x"0000090B1C16")),

        (signed'(x"00000640748F"), signed'(x"0000324A5B90"), signed'(x"00000C9779F1")),

        (signed'(x"000006196759"), signed'(x"00003343A6E0"), signed'(x"000009B74843")),

        (signed'(x"000003D33A2E"), signed'(x"000031A34B7A"), signed'(x"00000B7C9EAD")),

        (signed'(x"000004FFA3B8"), signed'(x"00002FADC439"), signed'(x"00000B0530CF")),

        (signed'(x"0000033AA710"), signed'(x"00003276B602"), signed'(x"00000B7B8E6A")),

        (signed'(x"00000318757B"), signed'(x"00003152B17B"), signed'(x"00000A103EE5")),

        (signed'(x"0000037963EC"), signed'(x"000032D473C7"), signed'(x"00000A24C046")),

        (signed'(x"0000038ABFE4"), signed'(x"000031609B0F"), signed'(x"00000A57CF39")),

        (signed'(x"0000026E837D"), signed'(x"000030E677C2"), signed'(x"00000A96BBE8")),

        (signed'(x"000000D76433"), signed'(x"000033EC51BF"), signed'(x"00000B2F2CA1")),

        (signed'(x"000000D7003E"), signed'(x"00003230B5A1"), signed'(x"00000B0B1098")),

        (signed'(x"000000D19B07"), signed'(x"0000329A7577"), signed'(x"00000BEB6977")),

        (signed'(x"0000000261CB"), signed'(x"0000316BD834"), signed'(x"00000AE4BDBF")),

        (signed'(x"FFFFFDBCE6B3"), signed'(x"0000307C1B66"), signed'(x"00000C8ABBE1")),

        (signed'(x"0000012F4E6E"), signed'(x"000031BFB463"), signed'(x"00000BC21148")),

        (signed'(x"FFFFFF59E35D"), signed'(x"00003511D557"), signed'(x"00000C4EBAE8")),

        (signed'(x"FFFFFE697FCD"), signed'(x"00003105EC7B"), signed'(x"000009968388")),

        (signed'(x"FFFFFE3E6881"), signed'(x"000031348A04"), signed'(x"000009C74EAF")),

        (signed'(x"FFFFFCE4ECA7"), signed'(x"000030DBA1E6"), signed'(x"00000CE4F2A8")),

        (signed'(x"FFFFFDEC55DC"), signed'(x"000031E78877"), signed'(x"00000CB18924")),

        (signed'(x"FFFFFC9EB4C6"), signed'(x"00003104DF78"), signed'(x"00000CBE3716")),

        (signed'(x"FFFFFC9536AF"), signed'(x"000030CE565C"), signed'(x"00000B09306A")),

        (signed'(x"FFFFFAAB8C64"), signed'(x"0000306B1C3F"), signed'(x"00000C28A1F6")),

        (signed'(x"FFFFFCF515DD"), signed'(x"0000305B0898"), signed'(x"00000BCD42FD")),

        (signed'(x"FFFFF9E667B3"), signed'(x"000031370C84"), signed'(x"00000AA7180E")),

        (signed'(x"FFFFF9309F4E"), signed'(x"000031B19698"), signed'(x"00000A6B9FAE")),

        (signed'(x"FFFFF9D40706"), signed'(x"0000318872D8"), signed'(x"00000B04C575")),

        (signed'(x"FFFFF8279B0D"), signed'(x"000030F08796"), signed'(x"00000C04E97D")),

        (signed'(x"FFFFF911817F"), signed'(x"0000307788EC"), signed'(x"00000B5E8BB3")),

        (signed'(x"FFFFF8D32540"), signed'(x"00002FB2C2EA"), signed'(x"00000BD1CBDD")),

        (signed'(x"FFFFF6EAE189"), signed'(x"000031DB475C"), signed'(x"00000A84E046")),

        (signed'(x"FFFFF5486693"), signed'(x"00002F925E87"), signed'(x"00000B562632")),

        (signed'(x"FFFFF6DB1AFD"), signed'(x"0000303411F8"), signed'(x"00000BEEE204")),

        (signed'(x"FFFFF471AC8E"), signed'(x"000030F1F4F2"), signed'(x"00000A16F107")),

        (signed'(x"FFFFF4F6D02A"), signed'(x"000030F50CF5"), signed'(x"00000A723FBC")),

        (signed'(x"FFFFF4BE29AD"), signed'(x"000031CF519A"), signed'(x"00000ABC60D4")),

        (signed'(x"FFFFF579C019"), signed'(x"00002F900B72"), signed'(x"00000BD93C1D")),

        (signed'(x"FFFFF5985989"), signed'(x"00002E1ACDD5"), signed'(x"00000A872302")),

        (signed'(x"FFFFF43ED63F"), signed'(x"000030409E02"), signed'(x"00000BB3AFD5")),

        (signed'(x"FFFFF29499A5"), signed'(x"0000306A9340"), signed'(x"00000B2E58A4")),

        (signed'(x"FFFFF3DE9D57"), signed'(x"000030741D34"), signed'(x"00000BAE2584")),

        (signed'(x"FFFFF1CF011D"), signed'(x"00002F937ED2"), signed'(x"00000AEA8021")),

        (signed'(x"FFFFF2228F4F"), signed'(x"00002F80A90F"), signed'(x"00000BA4ED69")),

        (signed'(x"FFFFF3566205"), signed'(x"000030A652C6"), signed'(x"00000B08C97D")),

        (signed'(x"FFFFF1FC77F5"), signed'(x"00002F38820B"), signed'(x"00000953FCDA")),

        (signed'(x"FFFFEF4D279E"), signed'(x"00002D9A7E3E"), signed'(x"00000B0540C7")),

        (signed'(x"FFFFEFDA9BD1"), signed'(x"000030FDCF1F"), signed'(x"00000BB46BD2")),

        (signed'(x"FFFFEF24E2E6"), signed'(x"00002FFAFBA2"), signed'(x"0000092C28A5")),

        (signed'(x"FFFFEF20CD43"), signed'(x"00002FC0CDB5"), signed'(x"000009E92AD4")),

        (signed'(x"FFFFEF913B5C"), signed'(x"00002F25B8AA"), signed'(x"00000AFAD78A")),

        (signed'(x"FFFFEE96D1BE"), signed'(x"000030E6C501"), signed'(x"00000B952D91")),

        (signed'(x"FFFFEDBD3AD7"), signed'(x"00002DFD1684"), signed'(x"00000A8E84D6")),

        (signed'(x"FFFFEDDB9559"), signed'(x"00002D678CCD"), signed'(x"00000B7BDA63")),

        (signed'(x"FFFFEC168E0B"), signed'(x"00002E8C2A47"), signed'(x"00000BC0659B")),

        (signed'(x"FFFFED24C2BA"), signed'(x"00002D5CA441"), signed'(x"00000B275539")),

        (signed'(x"FFFFEAAB6955"), signed'(x"00002D39F3B3"), signed'(x"00000BCE7209")),

        (signed'(x"FFFFEBF31C0E"), signed'(x"00002C8AEEC8"), signed'(x"00000C4DE7CA")),

        (signed'(x"FFFFEC183DF3"), signed'(x"00002DAAFFA0"), signed'(x"00000D512B82")),

        (signed'(x"FFFFE98387F9"), signed'(x"00002BCB8570"), signed'(x"000009AAC69E")),

        (signed'(x"FFFFEB55963B"), signed'(x"00002D7982D7"), signed'(x"00000B654F87")),

        (signed'(x"FFFFE9ABD12E"), signed'(x"00002B788FC0"), signed'(x"00000DE70F1A")),

        (signed'(x"FFFFE91359A5"), signed'(x"00002C7A3E4E"), signed'(x"00000C302496")),

        (signed'(x"FFFFE8FC1F5D"), signed'(x"00002C5BF7E9"), signed'(x"00000AAD6120")),

        (signed'(x"FFFFE888FF03"), signed'(x"00002DC7BCFF"), signed'(x"00000CD18E7B")),

        (signed'(x"FFFFE93815BA"), signed'(x"00002B253B1D"), signed'(x"00000A7D2C1E")),

        (signed'(x"FFFFE710949A"), signed'(x"00002B776988"), signed'(x"00000C940013")),

        (signed'(x"FFFFE510B2ED"), signed'(x"00002CB0A50F"), signed'(x"00000B54CEA8")),

        (signed'(x"FFFFE5E685C0"), signed'(x"000029E4CF3B"), signed'(x"000009D6FA56")),

        (signed'(x"FFFFE6B906EC"), signed'(x"00002AB86856"), signed'(x"00000A35BFBD")),

        (signed'(x"FFFFE42DEA2B"), signed'(x"00002A0C50C2"), signed'(x"00000D2C99A2")),

        (signed'(x"FFFFE4CAD68C"), signed'(x"0000289D0661"), signed'(x"00000B43C410")),

        (signed'(x"FFFFE45C0131"), signed'(x"00002725E6CB"), signed'(x"00000B761DAC")),

        (signed'(x"FFFFE3FBEE84"), signed'(x"00002A43EFE7"), signed'(x"00000D5EAE65")),

        (signed'(x"FFFFE4ED6455"), signed'(x"000029053660"), signed'(x"00000A6B679A")),

        (signed'(x"FFFFE5F66F01"), signed'(x"000029107D8E"), signed'(x"00000B8B8FD4")),

        (signed'(x"FFFFE2F4DF44"), signed'(x"000028EA45EB"), signed'(x"00000B645A9F")),

        (signed'(x"FFFFE2005407"), signed'(x"000027E0C211"), signed'(x"00000B823BC4")),

        (signed'(x"FFFFE1A0F5B5"), signed'(x"0000276A6BCF"), signed'(x"00000BA72A8A")),

        (signed'(x"FFFFE18474EF"), signed'(x"000029550F6C"), signed'(x"000008E69130")),

        (signed'(x"FFFFE27795BD"), signed'(x"000028C52508"), signed'(x"0000097BB770")),

        (signed'(x"FFFFE0A3A4B3"), signed'(x"000026D827AC"), signed'(x"00000A2776D0")),

        (signed'(x"FFFFDFD041AE"), signed'(x"000025CB078D"), signed'(x"00000D51A505")),

        (signed'(x"FFFFE123B8BC"), signed'(x"000027DBF3C1"), signed'(x"00000C4B14CE")),

        (signed'(x"FFFFDEB0C666"), signed'(x"000025BE4425"), signed'(x"00000C10E063")),

        (signed'(x"FFFFDE376548"), signed'(x"000026A8335E"), signed'(x"00000B57548D")),

        (signed'(x"FFFFDEAF9680"), signed'(x"00002653D64E"), signed'(x"00000C07D5E0")),

        (signed'(x"FFFFDE534275"), signed'(x"00002671D0AD"), signed'(x"00000A829887")),

        (signed'(x"FFFFDEEE52FE"), signed'(x"0000258B19FA"), signed'(x"00000B495773")),

        (signed'(x"FFFFDE45F98C"), signed'(x"0000235C4704"), signed'(x"00000C865E08")),

        (signed'(x"FFFFDD65DC92"), signed'(x"000023BF1A62"), signed'(x"00000CA7964E")),

        (signed'(x"FFFFDC847A3A"), signed'(x"00002283C883"), signed'(x"00000A0DC2F0")),

        (signed'(x"FFFFDD786943"), signed'(x"0000224B11AA"), signed'(x"00000D5EB272")),

        (signed'(x"FFFFDA6DAE6D"), signed'(x"000024EAC029"), signed'(x"00000BD4B1DE")),

        (signed'(x"FFFFDC10301B"), signed'(x"00002251A7E0"), signed'(x"00000C060D15")),

        (signed'(x"FFFFDBC6854B"), signed'(x"0000239B67B2"), signed'(x"00000BBE4E4A")),

        (signed'(x"FFFFDB9EC479"), signed'(x"000021C6CBE8"), signed'(x"00000B93AB8A")),

        (signed'(x"FFFFDB70285F"), signed'(x"000020102027"), signed'(x"00000A4A4A65")),

        (signed'(x"FFFFDB89A66F"), signed'(x"00002192DA67"), signed'(x"00000B757F60")),

        (signed'(x"FFFFDA7B0F66"), signed'(x"000021606B98"), signed'(x"00000B1B9552")),

        (signed'(x"FFFFD95B05C6"), signed'(x"000020D90ED9"), signed'(x"00000AAC74C1")),

        (signed'(x"FFFFDA37AD9A"), signed'(x"00001E91B4E2"), signed'(x"00000CAF88C8")),

        (signed'(x"FFFFD9F60661"), signed'(x"00002024EE8A"), signed'(x"00000CA4C896")),

        (signed'(x"FFFFDAD64308"), signed'(x"00002084121F"), signed'(x"000009D31696")),

        (signed'(x"FFFFD7942EE0"), signed'(x"00001E7CA2CD"), signed'(x"00000BB22972")),

        (signed'(x"FFFFD91121C8"), signed'(x"00001DFE3338"), signed'(x"00000BDC6B29")),

        (signed'(x"FFFFD77D197E"), signed'(x"00001DB60E79"), signed'(x"00000A459E30")),

        (signed'(x"FFFFD7050397"), signed'(x"00001C926984"), signed'(x"00000AB50274")),

        (signed'(x"FFFFD8B300EC"), signed'(x"00001C92783A"), signed'(x"00000E51D377")),

        (signed'(x"FFFFD7D880D9"), signed'(x"00001D4D267E"), signed'(x"00000AD54AF6")),

        (signed'(x"FFFFD7C379FA"), signed'(x"00001C220A4B"), signed'(x"00000BD15B2E")),

        (signed'(x"FFFFD9569C26"), signed'(x"00001C33A5FE"), signed'(x"00000CD96AFD")),

        (signed'(x"FFFFD5CB4D35"), signed'(x"00001BD964FF"), signed'(x"00000D799AB1")),

        (signed'(x"FFFFD597F5C9"), signed'(x"00001D47BC85"), signed'(x"00000C6A883B")),

        (signed'(x"FFFFD562B0CC"), signed'(x"00001BAE573E"), signed'(x"00000CAF620A")),

        (signed'(x"FFFFD64D2912"), signed'(x"0000190E7823"), signed'(x"00000AFD50F6")),

        (signed'(x"FFFFD52AFD9D"), signed'(x"00001A20B66D"), signed'(x"00000C57671A")),

        (signed'(x"FFFFD55550BF"), signed'(x"0000187091C4"), signed'(x"00000C1AE1B1")),

        (signed'(x"FFFFD582B302"), signed'(x"000019E7B6CC"), signed'(x"00000CCF4397")),

        (signed'(x"FFFFD57B8AC3"), signed'(x"0000195F4C93"), signed'(x"00000BA9A5DA")),

        (signed'(x"FFFFD2BDA164"), signed'(x"000018E86F51"), signed'(x"00000BF1CC20")),

        (signed'(x"FFFFD46E4154"), signed'(x"000016C3AE8C"), signed'(x"00000AA8E408")),

        (signed'(x"FFFFD4F95AE3"), signed'(x"0000178FDD64"), signed'(x"00000C6D1C35")),

        (signed'(x"FFFFD3B72489"), signed'(x"00001730773C"), signed'(x"00000CAFD823")),

        (signed'(x"FFFFD2F110C2"), signed'(x"000016CFB830"), signed'(x"00000B4A4AA8")),

        (signed'(x"FFFFD2CC5CA3"), signed'(x"000015F5A5BB"), signed'(x"00000BFA7BD0")),

        (signed'(x"FFFFD2889969"), signed'(x"0000171361BE"), signed'(x"00000ADD92F4")),

        (signed'(x"FFFFD29C0996"), signed'(x"000014EDE42D"), signed'(x"00000D35FD1D")),

        (signed'(x"FFFFD2C811CB"), signed'(x"000015F29F31"), signed'(x"00000A483879")),

        (signed'(x"FFFFD2A52763"), signed'(x"00001559AFD5"), signed'(x"00000BDA8B0E")),

        (signed'(x"FFFFD33DC1E3"), signed'(x"0000137C76A5"), signed'(x"00000D2F37F6")),

        (signed'(x"FFFFD446E40D"), signed'(x"0000132E7041"), signed'(x"00000B555121")),

        (signed'(x"FFFFD33CFEF9"), signed'(x"000014A9A194"), signed'(x"00000B42722D")),

        (signed'(x"FFFFD12D19FB"), signed'(x"000012569222"), signed'(x"00000A710B4D")),

        (signed'(x"FFFFD07E6C0F"), signed'(x"000011269E35"), signed'(x"00000B0595D6")),

        (signed'(x"FFFFD132D685"), signed'(x"000011EC2480"), signed'(x"00000D57FAF2")),

        (signed'(x"FFFFD00F74C9"), signed'(x"000012343910"), signed'(x"00000B952CA0")),

        (signed'(x"FFFFD0D6E42F"), signed'(x"0000116C9A24"), signed'(x"00000AAD6F41")),

        (signed'(x"FFFFD11B2D1B"), signed'(x"00001071A4AB"), signed'(x"00000C4BCEBA")),

        (signed'(x"FFFFD0DA3DF2"), signed'(x"000012425AD2"), signed'(x"00000B2B5C1A")),

        (signed'(x"FFFFCFE06DF1"), signed'(x"00000EB4A2C7"), signed'(x"00000B414AF9")),

        (signed'(x"FFFFCF9E8FD3"), signed'(x"0000100A847C"), signed'(x"00000D3C02AF")),

        (signed'(x"FFFFCF8A365A"), signed'(x"00000D8AA2B2"), signed'(x"00000C49E719")),

        (signed'(x"FFFFCF6AC54B"), signed'(x"00000E86F86B"), signed'(x"00000C060528")),

        (signed'(x"FFFFCE5127BF"), signed'(x"00000EF5F77F"), signed'(x"00000D9EA91C")),

        (signed'(x"FFFFCF169745"), signed'(x"00000C8B1379"), signed'(x"00000C1CEF1C")),

        (signed'(x"FFFFCFE899EB"), signed'(x"00000D1B1B30"), signed'(x"00000DD731A6")),

        (signed'(x"FFFFCF466FDF"), signed'(x"00000B2A06FE"), signed'(x"00000A744C26")),

        (signed'(x"FFFFCE9A9D8B"), signed'(x"00000B717A2A"), signed'(x"00000DA19FC4")),

        (signed'(x"FFFFCEB47805"), signed'(x"00000B36851B"), signed'(x"00000BD2D1D0")),

        (signed'(x"FFFFD04DB2D1"), signed'(x"00000D071DBA"), signed'(x"00000B4FEBA4")),

        (signed'(x"FFFFCE85EAD3"), signed'(x"00000B0E3FBD"), signed'(x"00000C872DB7")),

        (signed'(x"FFFFD0C2F809"), signed'(x"00000A1AE53F"), signed'(x"00000B7D6B64")),

        (signed'(x"FFFFCF69AC8E"), signed'(x"00000A2375D9"), signed'(x"00000CAC37D2")),

        (signed'(x"FFFFCF3DD793"), signed'(x"0000099AB12F"), signed'(x"00000D064876")),

        (signed'(x"FFFFD008965D"), signed'(x"000008B1773C"), signed'(x"00000BB0EC1C")),

        (signed'(x"FFFFCEB859F6"), signed'(x"000008C1D43A"), signed'(x"00000B0B5293")),

        (signed'(x"FFFFCEDE79F7"), signed'(x"000006A9A430"), signed'(x"00000BE4900C")),

        (signed'(x"FFFFCFB5F344"), signed'(x"000006C07341"), signed'(x"00000BE9D47E")),

        (signed'(x"FFFFCD026203"), signed'(x"000006CF9836"), signed'(x"00000C83EAB9")),

        (signed'(x"FFFFD07968C4"), signed'(x"00000542A1C9"), signed'(x"00000C177F97")),

        (signed'(x"FFFFCE81D71C"), signed'(x"000006A5FA6F"), signed'(x"00000BC7B730")),

        (signed'(x"FFFFCE7D153D"), signed'(x"0000052E5E72"), signed'(x"00000C10973F")),

        (signed'(x"FFFFCDB84BE6"), signed'(x"00000444EA21"), signed'(x"00000CF45E58")),

        (signed'(x"FFFFCD1A0057"), signed'(x"000003B5A4C1"), signed'(x"00000B2EFAE8")),

        (signed'(x"FFFFCF4A3423"), signed'(x"0000018DF3A4"), signed'(x"00000B53CFC2")),

        (signed'(x"FFFFCE719917"), signed'(x"00000424DDFF"), signed'(x"00000BD2BD83")),

        (signed'(x"FFFFCD7CF063"), signed'(x"000003F5CF06"), signed'(x"00000A718CC2")),

        (signed'(x"FFFFCBD37E33"), signed'(x"00000204F65F"), signed'(x"00000B646078")),

        (signed'(x"FFFFCCFD8C5A"), signed'(x"000001C9B428"), signed'(x"00000C23F820")),

        (signed'(x"FFFFCD7074BA"), signed'(x"FFFFFF4C9FEE"), signed'(x"00000CC58D16")),

        (signed'(x"FFFFCEA677BE"), signed'(x"FFFFFFFAFF38"), signed'(x"00000DBF9440")),

        (signed'(x"FFFFCCEE82BC"), signed'(x"FFFFFE0DDA51"), signed'(x"00000B36577F")),

        (signed'(x"FFFFCDF67F9A"), signed'(x"FFFFFF52B1B6"), signed'(x"00000BAA5613")),

        (signed'(x"FFFFCE5F4A5E"), signed'(x"FFFFFD540A71"), signed'(x"00000D5A4F9E")),

        (signed'(x"FFFFCDF468B0"), signed'(x"FFFFFF3288D9"), signed'(x"00000C410D3E")),

        (signed'(x"FFFFCE83EC3F"), signed'(x"FFFFFE267D05"), signed'(x"00000C5C86C1")),

        (signed'(x"FFFFCEBA5D29"), signed'(x"FFFFFE6912F3"), signed'(x"00000C1CD044")),

        (signed'(x"FFFFCED37148"), signed'(x"FFFFFC7E18AD"), signed'(x"00000D5BC1E4")),

        (signed'(x"FFFFCD7A2B35"), signed'(x"FFFFFDE27469"), signed'(x"00000BE161E2")),

        (signed'(x"FFFFCCC3B5E4"), signed'(x"FFFFFBB6A77B"), signed'(x"00000B3DE190")),

        (signed'(x"FFFFCF1521E5"), signed'(x"FFFFFA6F58A5"), signed'(x"00000B7A912A")),

        (signed'(x"FFFFCC676AF0"), signed'(x"FFFFFA234FD7"), signed'(x"00000980D424")),

        (signed'(x"FFFFCCC42561"), signed'(x"FFFFFADA9759"), signed'(x"00000CB70CEE")),

        (signed'(x"FFFFCED64C5C"), signed'(x"FFFFF8A15A67"), signed'(x"00000BE23522")),

        (signed'(x"FFFFCE797BFF"), signed'(x"FFFFF7F17EDC"), signed'(x"00000D6FD1D8")),

        (signed'(x"FFFFCF6D4DF8"), signed'(x"FFFFF862C8D9"), signed'(x"00000BF65A48")),

        (signed'(x"FFFFCED59ADE"), signed'(x"FFFFF6122BC6"), signed'(x"00000BB0B468")),

        (signed'(x"FFFFCE067E7C"), signed'(x"FFFFF69E2564"), signed'(x"00000BA88656")),

        (signed'(x"FFFFD0975FF1"), signed'(x"FFFFF7C48968"), signed'(x"00000B5EC2CD")),

        (signed'(x"FFFFCF7517C6"), signed'(x"FFFFF808DD02"), signed'(x"00000CDE2D69")),

        (signed'(x"FFFFCF0A6108"), signed'(x"FFFFF57F664B"), signed'(x"00000CA4B260")),

        (signed'(x"FFFFCF79B3E9"), signed'(x"FFFFF68CD301"), signed'(x"00000C95072F")),

        (signed'(x"FFFFD03CC3E2"), signed'(x"FFFFF4A189EC"), signed'(x"00000D442436")),

        (signed'(x"FFFFCF7F061F"), signed'(x"FFFFF6C101DF"), signed'(x"00000B42E9BB")),

        (signed'(x"FFFFD126735D"), signed'(x"FFFFF463E087"), signed'(x"00000B4D07D6")),

        (signed'(x"FFFFCF0D04B6"), signed'(x"FFFFF362FA05"), signed'(x"00000C60D215")),

        (signed'(x"FFFFD02ED43B"), signed'(x"FFFFF2A634EA"), signed'(x"00000BEE6E91")),

        (signed'(x"FFFFD1EEBB58"), signed'(x"FFFFF477BD8A"), signed'(x"00000C64CA40")),

        (signed'(x"FFFFCFF699E3"), signed'(x"FFFFF260F8E5"), signed'(x"00000C92917B")),

        (signed'(x"FFFFCF0AD464"), signed'(x"FFFFF1857666"), signed'(x"00000A4AC236")),

        (signed'(x"FFFFD09BE297"), signed'(x"FFFFF1F280F7"), signed'(x"00000B7A9EF1")),

        (signed'(x"FFFFD1EEDE13"), signed'(x"FFFFEF98DF65"), signed'(x"00000A7FD43B")),

        (signed'(x"FFFFD0BCD957"), signed'(x"FFFFF164F61D"), signed'(x"00000DA62DC9")),

        (signed'(x"FFFFD03697D3"), signed'(x"FFFFF0F3AECA"), signed'(x"00000BED9C8C")),

        (signed'(x"FFFFD0A9C3BA"), signed'(x"FFFFF048CE7A"), signed'(x"00000C9ED524")),

        (signed'(x"FFFFCF6D7F72"), signed'(x"FFFFF0680ED8"), signed'(x"00000D598063")),

        (signed'(x"FFFFD08D35DA"), signed'(x"FFFFEEDB4CE7"), signed'(x"00000C7705A1")),

        (signed'(x"FFFFD19D95F2"), signed'(x"FFFFED7174E5"), signed'(x"00000B4CF56F")),

        (signed'(x"FFFFD183011C"), signed'(x"FFFFEEB35FD7"), signed'(x"00000C846455")),

        (signed'(x"FFFFD15A8D21"), signed'(x"FFFFEDD60126"), signed'(x"0000092054CE")),

        (signed'(x"FFFFD3109460"), signed'(x"FFFFEADCDC8D"), signed'(x"00000B9D17D6")),

        (signed'(x"FFFFD0FE1B5A"), signed'(x"FFFFEAD910A4"), signed'(x"00000D235C82")),

        (signed'(x"FFFFD1D86EAB"), signed'(x"FFFFEC07FDF5"), signed'(x"00000BEE7B4D")),

        (signed'(x"FFFFD2FEE097"), signed'(x"FFFFEB4E41CE"), signed'(x"00000AB257C2")),

        (signed'(x"FFFFD3B98DF6"), signed'(x"FFFFEA480639"), signed'(x"00000A6C975C")),

        (signed'(x"FFFFD283D3B9"), signed'(x"FFFFEBD2FFCD"), signed'(x"00000CD50324")),

        (signed'(x"FFFFD2D03CC2"), signed'(x"FFFFE986540F"), signed'(x"00000BA949C0")),

        (signed'(x"FFFFD5765AF9"), signed'(x"FFFFE9CF038C"), signed'(x"00000C69FAFA")),

        (signed'(x"FFFFD4A4D172"), signed'(x"FFFFE9387242"), signed'(x"00000BB9D471")),

        (signed'(x"FFFFD3A64B45"), signed'(x"FFFFE877A74F"), signed'(x"00000BF2DCCF")),

        (signed'(x"FFFFD4CF7503"), signed'(x"FFFFE8268CA6"), signed'(x"00000CB82F9A")),

        (signed'(x"FFFFD43E44E2"), signed'(x"FFFFE7BD42F3"), signed'(x"000009FD523B")),

        (signed'(x"FFFFD57C610D"), signed'(x"FFFFE79255AE"), signed'(x"00000CFC92D5")),

        (signed'(x"FFFFD1EC561B"), signed'(x"FFFFE8E164FF"), signed'(x"00000BD98FF0")),

        (signed'(x"FFFFD62E8E74"), signed'(x"FFFFE5525643"), signed'(x"00000C9A5F97")),

        (signed'(x"FFFFD4475EBF"), signed'(x"FFFFE54F4E80"), signed'(x"00000DE7B178")),

        (signed'(x"FFFFD5678142"), signed'(x"FFFFE5B9C29E"), signed'(x"00000CDCA0DA")),

        (signed'(x"FFFFD65B9329"), signed'(x"FFFFE53C6385"), signed'(x"00000C5B80AC")),

        (signed'(x"FFFFD88964E1"), signed'(x"FFFFE49B9AAC"), signed'(x"00000C31BA38")),

        (signed'(x"FFFFD775992F"), signed'(x"FFFFE55A8AC7"), signed'(x"00000D2E4A86")),

        (signed'(x"FFFFD753B8C1"), signed'(x"FFFFE2B0CD30"), signed'(x"00000DA0BA19")),

        (signed'(x"FFFFD5D36035"), signed'(x"FFFFE3B97D64"), signed'(x"00000B3D9F70")),

        (signed'(x"FFFFD7321AC7"), signed'(x"FFFFE35783A6"), signed'(x"00000C51202B")),

        (signed'(x"FFFFD7F94330"), signed'(x"FFFFE4388A07"), signed'(x"00000C731879")),

        (signed'(x"FFFFD79A8243"), signed'(x"FFFFE32B10DC"), signed'(x"00000D2F9EA5")),

        (signed'(x"FFFFD6EB8910"), signed'(x"FFFFE266C985"), signed'(x"00000CB2BB53")),

        (signed'(x"FFFFD8276FE2"), signed'(x"FFFFE2C86663"), signed'(x"00000BD8ECE4")),

        (signed'(x"FFFFD8E29566"), signed'(x"FFFFE0D70FE1"), signed'(x"00000C036D7F")),

        (signed'(x"FFFFD7F99DEB"), signed'(x"FFFFDF2EA876"), signed'(x"00000D97B978")),

        (signed'(x"FFFFD88A43D8"), signed'(x"FFFFDF3E42B4"), signed'(x"000009D858CB")),

        (signed'(x"FFFFD9115342"), signed'(x"FFFFDE86E7B6"), signed'(x"00000DA40BC3")),

        (signed'(x"FFFFDB0A348A"), signed'(x"FFFFDEC7D4EF"), signed'(x"00000E40617B")),

        (signed'(x"FFFFDB56C9E5"), signed'(x"FFFFDEC40E6D"), signed'(x"0000097FF7E4")),

        (signed'(x"FFFFDCFAAA91"), signed'(x"FFFFDD538A41"), signed'(x"00000A5AA517")),

        (signed'(x"FFFFDC0BA57F"), signed'(x"FFFFE0C8C1B6"), signed'(x"00000D62488C")),

        (signed'(x"FFFFDBECDBF7"), signed'(x"FFFFDE92354F"), signed'(x"00000CDA6B18")),

        (signed'(x"FFFFDC765A2C"), signed'(x"FFFFDDE49403"), signed'(x"00000C1AA548")),

        (signed'(x"FFFFDBFC8A35"), signed'(x"FFFFDC7F19C2"), signed'(x"00000BB822A6")),

        (signed'(x"FFFFDAB49594"), signed'(x"FFFFDCCB5A42"), signed'(x"00000B02EB2E")),

        (signed'(x"FFFFDBA5CA92"), signed'(x"FFFFDCB7E420"), signed'(x"00000D645A2A")),

        (signed'(x"FFFFDE06A168"), signed'(x"FFFFDA9E0232"), signed'(x"00000B02A5F4")),

        (signed'(x"FFFFDE6880DF"), signed'(x"FFFFDADBACDD"), signed'(x"00000BC678E3")),

        (signed'(x"FFFFDE617CE4"), signed'(x"FFFFDA875B58"), signed'(x"00000C1AEE76")),

        (signed'(x"FFFFDCDD0C1A"), signed'(x"FFFFDA8E4C5E"), signed'(x"00000C51C9D5")),

        (signed'(x"FFFFDCF98001"), signed'(x"FFFFDB42F2D5"), signed'(x"00000BFADB8D")),

        (signed'(x"FFFFDF7E592B"), signed'(x"FFFFDAB66641"), signed'(x"00000D5D0EAD")),

        (signed'(x"FFFFDF716B4C"), signed'(x"FFFFD9BB0010"), signed'(x"00000C1F1700")),

        (signed'(x"FFFFE03DBBBF"), signed'(x"FFFFD9E2416F"), signed'(x"00000C0A1BF8")),

        (signed'(x"FFFFDF610DB8"), signed'(x"FFFFD8D9D757"), signed'(x"00000A989429")),

        (signed'(x"FFFFE237962A"), signed'(x"FFFFD7F3E57D"), signed'(x"00000B4E2E84")),

        (signed'(x"FFFFE0238579"), signed'(x"FFFFD9C73377"), signed'(x"00000BB3F849")),

        (signed'(x"FFFFE27F643D"), signed'(x"FFFFD7E67691"), signed'(x"00000C46CD87")),

        (signed'(x"FFFFE0CF71A3"), signed'(x"FFFFDA69D212"), signed'(x"00000ACF4015")),

        (signed'(x"FFFFE25AB501"), signed'(x"FFFFD899B64B"), signed'(x"00000C691858")),

        (signed'(x"FFFFE242D38D"), signed'(x"FFFFD78A0F09"), signed'(x"00000C0A41D0")),

        (signed'(x"FFFFE2B4404B"), signed'(x"FFFFD856E7EE"), signed'(x"00000E34CE4E")),

        (signed'(x"FFFFE2B3891D"), signed'(x"FFFFD5B76228"), signed'(x"00000BE82C9C")),

        (signed'(x"FFFFE63FC3C3"), signed'(x"FFFFD5FF427F"), signed'(x"00000DA23E1F")),

        (signed'(x"FFFFE5C2AE6F"), signed'(x"FFFFD5F748B4"), signed'(x"00000C902272")),

        (signed'(x"FFFFE6209AE4"), signed'(x"FFFFD5DD028A"), signed'(x"00000BCA323F")),

        (signed'(x"FFFFE4561323"), signed'(x"FFFFD4F46C03"), signed'(x"00000B57ED77")),

        (signed'(x"FFFFE41D9967"), signed'(x"FFFFD5BC224E"), signed'(x"00000B38D9E4")),

        (signed'(x"FFFFE5FF6709"), signed'(x"FFFFD3E16425"), signed'(x"00000C527BAC")),

        (signed'(x"FFFFE7063BD4"), signed'(x"FFFFD32EAF84"), signed'(x"00000C5D5770")),

        (signed'(x"FFFFE7D9175D"), signed'(x"FFFFD3B5E43F"), signed'(x"00000DA98F0B")),

        (signed'(x"FFFFE778AF2D"), signed'(x"FFFFD3F6A840"), signed'(x"00000BEEE472")),

        (signed'(x"FFFFE80B97DB"), signed'(x"FFFFD47F499A"), signed'(x"00000C86DF24")),

        (signed'(x"FFFFE700D7B8"), signed'(x"FFFFD458FDF1"), signed'(x"00000A92CFDA")),

        (signed'(x"FFFFE8408D1A"), signed'(x"FFFFD309299B"), signed'(x"00000B403117")),

        (signed'(x"FFFFEA0A8F58"), signed'(x"FFFFD4CBFE56"), signed'(x"00000C982EE8")),

        (signed'(x"FFFFE8282D45"), signed'(x"FFFFD328CE84"), signed'(x"00000D328B92")),

        (signed'(x"FFFFE9D65C13"), signed'(x"FFFFD591E274"), signed'(x"00000C606BF7")),

        (signed'(x"FFFFEA561641"), signed'(x"FFFFD2B87A19"), signed'(x"00000C1DA6A2")),

        (signed'(x"FFFFEA714AB4"), signed'(x"FFFFD385832A"), signed'(x"00000CF01AAC")),

        (signed'(x"FFFFEA430F7B"), signed'(x"FFFFD1453933"), signed'(x"00000A24D5ED")),

        (signed'(x"FFFFEC02CE3C"), signed'(x"FFFFD14A8080"), signed'(x"000009D378D1")),

        (signed'(x"FFFFEC593F2A"), signed'(x"FFFFD4AF48AD"), signed'(x"00000BF8C1E5")),

        (signed'(x"FFFFED41F2B3"), signed'(x"FFFFD2134F2A"), signed'(x"00000BE0AFF4")),

        (signed'(x"FFFFEDCC9A61"), signed'(x"FFFFD1828367"), signed'(x"00000C3E2390")),

        (signed'(x"FFFFEDAA304A"), signed'(x"FFFFD0F17013"), signed'(x"00000CF7531C")),

        (signed'(x"FFFFEDA20953"), signed'(x"FFFFD0ABD4C2"), signed'(x"00000C826025")),

        (signed'(x"FFFFED6046B3"), signed'(x"FFFFD1468A99"), signed'(x"00000BF65A8F")),

        (signed'(x"FFFFEFD42F53"), signed'(x"FFFFD18C1261"), signed'(x"00000BF1EEB2")),

        (signed'(x"FFFFF007E5AC"), signed'(x"FFFFD24ADD93"), signed'(x"00000C86C821")),

        (signed'(x"FFFFEFB1FB7E"), signed'(x"FFFFCF6CC579"), signed'(x"00000AE6F2BB")),

        (signed'(x"FFFFEFDA6539"), signed'(x"FFFFCFF767C2"), signed'(x"00000BC76127")),

        (signed'(x"FFFFF0B0A443"), signed'(x"FFFFD0F31845"), signed'(x"00000BE4D0B9")),

        (signed'(x"FFFFF198AEF5"), signed'(x"FFFFD055451D"), signed'(x"000009FCC11E")),

        (signed'(x"FFFFF0A60CD0"), signed'(x"FFFFCFFA5F00"), signed'(x"00000AC0650B")),

        (signed'(x"FFFFF2AAD9FD"), signed'(x"FFFFD182D92F"), signed'(x"00000D2DACA0")),

        (signed'(x"FFFFF255BC23"), signed'(x"FFFFD1558CCC"), signed'(x"00000C1B511D")),

        (signed'(x"FFFFF2B1887D"), signed'(x"FFFFCF1912E1"), signed'(x"00000BA76788")),

        (signed'(x"FFFFF3203C9F"), signed'(x"FFFFCFC125F7"), signed'(x"00000C1D83A6")),

        (signed'(x"FFFFF4007E0D"), signed'(x"FFFFCFE608C6"), signed'(x"00000D24C682")),

        (signed'(x"FFFFF56F354E"), signed'(x"FFFFCDDBF172"), signed'(x"00000965B888")),

        (signed'(x"FFFFF5E80348"), signed'(x"FFFFCDDD4CF3"), signed'(x"00000BB98807")),

        (signed'(x"FFFFF44A43CD"), signed'(x"FFFFCD524EB9"), signed'(x"00000C7D3975")),

        (signed'(x"FFFFF6B56A07"), signed'(x"FFFFCE71AC0B"), signed'(x"0000095AD578")),

        (signed'(x"FFFFF5E4BEF0"), signed'(x"FFFFCF507566"), signed'(x"00000A770FE3")),

        (signed'(x"FFFFF71D4884"), signed'(x"FFFFCED06453"), signed'(x"00000C857A10")),

        (signed'(x"FFFFF78AF253"), signed'(x"FFFFCDC49E67"), signed'(x"00000D2301DF")),

        (signed'(x"FFFFF7C1F5FB"), signed'(x"FFFFCEA1689E"), signed'(x"00000B01446C")),

        (signed'(x"FFFFF7F77B48"), signed'(x"FFFFCDB1D395"), signed'(x"00000BC3668E")),

        (signed'(x"FFFFFA9DC558"), signed'(x"FFFFCD2254F2"), signed'(x"00000A521609")),

        (signed'(x"FFFFFADEFC87"), signed'(x"FFFFCE3A6BD4"), signed'(x"00000B4359AA")),

        (signed'(x"FFFFFAEF8B72"), signed'(x"FFFFCDC4B575"), signed'(x"00000DC18EFB")),

        (signed'(x"FFFFFB11FF27"), signed'(x"FFFFCDD3D98F"), signed'(x"00000E15D487")),

        (signed'(x"FFFFFA48A591"), signed'(x"FFFFCF010323"), signed'(x"00000C39A12A")),

        (signed'(x"FFFFFCB05935"), signed'(x"FFFFCFC6562F"), signed'(x"00000BF4A5AD")),

        (signed'(x"FFFFFB21BD1F"), signed'(x"FFFFCEA12BD0"), signed'(x"00000B3E6503")),

        (signed'(x"FFFFFE65A840"), signed'(x"FFFFCE4479B8"), signed'(x"00000B8DCB8C")),

        (signed'(x"FFFFFD113799"), signed'(x"FFFFCCC009F3"), signed'(x"00000AF2010C")),

        (signed'(x"FFFFFE9508A2"), signed'(x"FFFFCD696583"), signed'(x"00000ADE23DD")),

        (signed'(x"FFFFFE6AF775"), signed'(x"FFFFCF3B09CA"), signed'(x"00000CA19B03")),

        (signed'(x"FFFFFF607B54"), signed'(x"FFFFCD44F949"), signed'(x"00000A7CF75D")),

        (signed'(x"00000061C951"), signed'(x"FFFFCDB09A19"), signed'(x"00000BA82004")),

        (signed'(x"000000B5715B"), signed'(x"FFFFCE8F6090"), signed'(x"00000C5C6D20")),

        (signed'(x"0000020BA963"), signed'(x"FFFFCD5B4BBE"), signed'(x"00000CD49E75")),

        (signed'(x"0000007003F5"), signed'(x"FFFFCE452160"), signed'(x"00000D6DBEB3")),

        (signed'(x"000001636A54"), signed'(x"FFFFCE8BC9E8"), signed'(x"00000CF8604E")),

        (signed'(x"00000103F2C0"), signed'(x"FFFFCD2E0A8B"), signed'(x"00000AD9B155")),

        (signed'(x"FFFFFFE9EB97"), signed'(x"FFFFD01770FB"), signed'(x"00000ACA1594")),

        (signed'(x"000002288CC6"), signed'(x"FFFFCDC7A401"), signed'(x"00000C328929")),

        (signed'(x"000003B1D788"), signed'(x"FFFFCEF18463"), signed'(x"00000B4DE5EC")),

        (signed'(x"00000335FA8C"), signed'(x"FFFFCE6595D8"), signed'(x"00000BA2D1D0")),

        (signed'(x"0000057BE78E"), signed'(x"FFFFCEA43870"), signed'(x"00000C9DEC8F")),

        (signed'(x"00000509AF41"), signed'(x"FFFFCF5D8098"), signed'(x"00000C0F70A3")),

        (signed'(x"0000039372EE"), signed'(x"FFFFCEA34017"), signed'(x"00000B39A584")),

        (signed'(x"000004D77032"), signed'(x"FFFFCEE0268A"), signed'(x"00000D1CAE9F")),

        (signed'(x"000005E365FC"), signed'(x"FFFFCEA77C7F"), signed'(x"00000D92BA8F")),

        (signed'(x"0000069A9FCC"), signed'(x"FFFFD1021C5D"), signed'(x"00000C6F012D")),

        (signed'(x"000005191C9C"), signed'(x"FFFFCF39DC1C"), signed'(x"00000C3F134F")),

        (signed'(x"000008A4BE69"), signed'(x"FFFFCF3787F6"), signed'(x"00000BB94FAF")),

        (signed'(x"0000069FA895"), signed'(x"FFFFCE692526"), signed'(x"00000B0245B2")),

        (signed'(x"000007C2C698"), signed'(x"FFFFCF4A0DBC"), signed'(x"00000D86BE2F")),

        (signed'(x"0000093A85E5"), signed'(x"FFFFCD973751"), signed'(x"00000C4C4CC6")),

        (signed'(x"00000A85B22C"), signed'(x"FFFFCE44808C"), signed'(x"00000BB76660")),

        (signed'(x"000009D4C040"), signed'(x"FFFFCE302CAF"), signed'(x"00000C7EE31E")),

        (signed'(x"00000A2F68C4"), signed'(x"FFFFCF7E440F"), signed'(x"00000AF4F0E0")),

        (signed'(x"00000A5B7FFF"), signed'(x"FFFFCFE6CE01"), signed'(x"00000B77E5C9")),

        (signed'(x"00000D026EDC"), signed'(x"FFFFCEE3D3DA"), signed'(x"00000C100F01")),

        (signed'(x"00000CB3A02F"), signed'(x"FFFFCDFC8A02"), signed'(x"00000A12F60F")),

        (signed'(x"00000ABA90B9"), signed'(x"FFFFD0C99CD2"), signed'(x"00000B47A249")),

        (signed'(x"00000F4BF833"), signed'(x"FFFFCF15EF59"), signed'(x"00000C035421")),

        (signed'(x"00000EC37633"), signed'(x"FFFFD1C92BD1"), signed'(x"00000DE2FEAC")),

        (signed'(x"00000EE94BC1"), signed'(x"FFFFD0F03C1F"), signed'(x"00000C6A1881"))
    );

begin

    clk <= not clk after CLK_PERIOD / 2;

    uut : bicycle_ukf_supreme
        port map (
            clk => clk, reset => reset, start => start,
            v_init => signed'(x"00001394B4CB"), theta_init => signed'(x"0000018D0938"),
            z_x_meas => z_x_meas, z_y_meas => z_y_meas, z_z_meas => z_z_meas,
            px_current => px_out, py_current => py_out, v_current => v_out,
            theta_current => theta_out, delta_current => delta_out,
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

        file_open(output_file, "vhdl_output_synthetic_drone_500cycles.txt", write_mode);

        write(line_buf, string'("cycle,px_hex,py_hex,v_hex,theta_hex,delta_hex,a_hex,z_hex,p11_hex,p22_hex,p33_hex,p44_hex,p55_hex,p66_hex,p77_hex"));
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

            hex_val := std_logic_vector(delta_out);
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
                report "Bicycle-UKF Cycle " & integer'image(i) & "/" & integer'image(NUM_CYCLES - 1) & " complete";
            end if;

            wait for CLK_PERIOD;
        end loop;

        file_close(output_file);
        report "=== BICYCLE-UKF SIMULATION COMPLETE ===" &
               " Dataset: synthetic_drone_500cycles" &
               " Cycles: " & integer'image(NUM_CYCLES);

        wait for CLK_PERIOD * 10;
        std.env.stop;
    end process;

end behavioral;
