require 'find'

players = %w(
AWAKE_i7_5960X_8c
NineDayFever_XeonE5-2690_16c
Test
Test3
AVR0
ponanza-990XEE
UNKO
testtt
Ponax1.01_4930_6c_1
Test2
ggks
Apery_5960X_8c
tESt
ZAKO
GPSFish-WCSC24
gpsfish_XeonX5680_12c
SRX70
gpsf_u
PonaX_1.01
Ponax1.01_4930_6c
tESt3
tatakinopasso
AWAKE_i7_2620M_2c
zyx
Charlotte
PonaX-1.01
ponax_i7_3770
Onax18.0
YWU
gasg
AaAaA
tsutsukana_time24_usiponder
tESt2
xuohk
Apery_WCSC24_3930K_6c
Apery_2700K_4c
ponax_i7_3770
CcC
qwer
ttkn_eval130807_2630QM
PonaX_
CrazyKing
ZXV
gpsfish_XeonX5470_8c
kbzyc
JimmieVaughan
pona2600
HOGU
YssF_6t_x1
SRV
tsutsukana_4930K_6c
Titanda_L
Vskf
luminos
KGD
gpsfish
gpsfish_XeonX5680_12c
CrazyKing
Titanda_L
Gekisashi_X5590_1c
Boomers
SVD
NimbleFingers
Jokerman
Amachan
Spiritual
GreatDreams
DarkEnd
SolidRock
nozomi_i7-4790
ponzu
Titanda_L
b68c
SecondLine
Bonanza611_4770K_4c
CherryBall
Hilarity
ZXCV
SmallChange
BigCity
SingleHanded
gpsfishone_win
b65960x8cu1410
nijiya
LiveTogether
Chauffeur
BlazeBlade
TampUpSolid
R_Xeon_human
KindHearted
GreatDream
MidnightOasis
OffTheHook
GPSFish_3630QM
SlowTrain
Alimony
gpsfish_cygwin
Uncloudy
shogiisukideathnote
Asclepios
SweetHarmony
TravelingShoes
Bonanza6.0_2697v2_24c
Bonanza6.0_4770K_4c
Bonanza6.0_2697v2_12c
TightConnection
Boogaloo
KeepTheF
Sleepwalk
gpsfish_normal_1c
Hades
Poseidon
Apollo
Jupiter
Crossroads
Desolation
Pretender
Bona6_miya2009_4670_4c
GoneBlind
ChickenSkin
Tambourine
Zeus
WithoutWarning
Subterranean
Apollon
Saved
AnyOldTime
RockingChair
Communique
Theseus
bonta
Tombstone
Lazybones
SwingSultans
Tribulations
CreoleEyes
ttbnt
Freewheeling
ThunderSmasher
BlunderXX_Q6700_2c
Soho_Amano
Skateaway
6.0bookKai_4700MQ-4cHT4t
Revisited
Shades
benkei_houshi
DoReMi
Changing
gpsf_021
nozomi_i7-2620M
Nanoha24a_1t
LetBygones
test_t_dti
MOJITO
bps
kato2
bps_2
Bringing
boNanoha
Flummi2
bpsf_0
Burlesque
Flummi
Pledging
Calamity141027_Phenom2_4c
Watchtower
frenzy-floodgate
Hurricane
gpsfish1c_dfgd_human
Bloody_Mary
nozomi_dev140906_i7-2620M
flummi2
Bonanza6.0-Opteron250-2c
nozomi_dev140828_i7-2620M
gps810patras
Himawari_5960X
tubasa_human
Bonanza6.0_mpi
tsutsukana_fg_4930K_6c
6h_human
bonanza6.0
AnotherSide
Bonanza6.0_1c_try
Bonanza6.0_1c_bookR4
Bonanza6.0_1c_L4
GPSShogi_AMD_C-60_2c
vixviox
gps_l
himawari_4c
abc_human
Bonanza6.0_1c_X
Bonanza6.0_1c_hikikaku
himawari
SlashingSilverSnow_G-T56N
Metal_Dungeon12
Lightning_Silph
Lightning_Silph20
himawari_fvbin_i7-3517U_2c
sakurapyon_4G
ShortBuster
sakurapyon_vps
YSS
Lightning_Silph24.4
YaneuraOu_koma
Kakinoki-Z
Bonanza_6.0_RPi
freedom
sakurapyon_dti
Sunfish2
bonanza_on_RaspberryPi
gps_normal
RightAndKind
dasapyon
yuttii
YssL_100k
sawa_test
SPEAR
yaneKOMAx86_1c
march
bona6_D5
Tori
SPEAR_level7
moon_human
sakura_human
rdfi
Gasyou_Core-i5-2430M_1c2t
Bonanza6.0_Depth5
VanishingTrooper
sawa_test
gps500
Gasyou_Core-i7-4930K_1c2t
YssL_10k
AceAttacker
Laramie_V3
Gasyou_Athlon-5350_4c
usapyon2011
Gasyou_Atom-D510_1c2t
garyu
usapyon2012
YssL_1k
bona6_D2
KifuWarabe
Laby_test
YssL_100
)

file_csv = open("kifu_floodgate_2008.csv", "a")

i = 0
n = 0
Find.find("/mnt/hgfs/VMWareShare/2013") {|f|
  begin
    next unless f =~ /\.csa$/
    i += 1
    tokens = f.split("+")
    black_name = tokens[tokens.length-3]
    white_name = tokens[tokens.length-2]
    next unless (players.include?(black_name) && players.include?(white_name))
    file_csa = open(f)
    native_kid = ""
    black_rate = ""
    white_rate = ""
    date = ""
    result = ""
    result_type = ""
    moves = ""
    num = 0
    file_csa.each {|line|
      if line =~ /^\$EVENT\:(.+)$/
        native_kid = $1
        date = native_kid.split("+")[4]
        date = date[0..3] + "/" + date[4..5] + "/" + date[6..7]
        native_kid = date + "/" + native_kid
      elsif line =~ /^([\+\-]\d{4}[A-Z]{2})$/
        num += 1
        moves += $1
      elsif line =~ /^\%TORYO$/
        moves += "%TORYO"
      elsif line =~ /^'summary/
        tokens = line.split(":")
        result_type = tokens[1]
        if tokens[2] =~ /\swin$/
          result = 0
        elsif tokens[3] =~ /\swin$/
          result = 1
        else
          result = 2
        end
      end
    }
    file_csa.close

    file_csv.puts sprintf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", native_kid, black_name, white_name, black_rate, white_rate, date, result, result_type, moves, num)
    puts sprintf("#%d %s vs %s", i, black_name, white_name)
    n += 1
  rescue
    log = "[ERROR] " + i.to_s + ": " + f
    puts log
  end
}

puts sprintf("Total added: %d/%d", n, i)

file_csv.close
