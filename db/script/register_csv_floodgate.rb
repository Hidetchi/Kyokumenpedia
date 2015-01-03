require 'cgi'
require 'uri'
require 'net/http'

VIA_API_POST = 1
VIA_RUNNER = 2

MODE = VIA_API_POST
#MODE = VIA_RUNNER

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
CrazyKing
PonaX_
ZXV
gpsfish_XeonX5470_8c
kbzyc
JimmieVaughan
pona2600
HOGU
SRV
YssF_6t_x1
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
Titanda_L
ponzu
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
gpsfish_cygwin
Alimony
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
boNanoha
MOJITO
bps
kato2
bps_2
Bringing
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
gps810patras
nozomi_dev140828_i7-2620M
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
)

f = open("/usr/local/Kyokumenpedia/db/script/kifu_floodgate_2008-2012_rated_only.csv")
i = 0
n = 0
f.each {|line|
  i += 1
#  break if i > 1000
#  next if i <= 38863
  par=line.split(",")
  hash=Hash[
:native_kid => CGI.escape(par[0]),
:black_name => par[1],
:white_name => par[2],
:black_rate => par[3],
:white_rate => par[4],
:date => par[5],
:result => par[6],
:csa => par[8],
:game_source_pass => "flood",
:handicap_id => 1
]
  next if par[9].to_i < 40
  next unless par[7] == "toryo" || par[7] == "sennichite"
  next unless players.include?(hash[:black_name]) && players.include?(hash[:white_name])

  n += 1

  if MODE == VIA_RUNNER
    params = ActionController::Parameters.new(hash)
    response = Game.save_after_validation(params)
    puts i.to_s + " " + response[:result]
  elsif MODE == VIA_API_POST
    hash[:csa] = CGI.escape(hash[:csa])
    query = hash.map{|k, v| "#{k}=#{v}"}.join('&')
    #Net::HTTP.start('27.120.94.96', 3000) {|http|
    Net::HTTP.start('localhost', 3000) {|http|
      response = http.post('/api/kifu_post', query)
      if (response.body =~ /(Error.+)</)
        puts i.to_s + " " + $1
      else
        puts i.to_s + " OK"
      end
    }
  end

}
f.close

puts "Total: " + n.to_s
