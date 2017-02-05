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
tESt10
Test2
tESt6
Apery_5960X_8c
ZAKO
GPSFish-WCSC24
tESt
gpsfish_XeonX5680_12c
SRX70
tESt4
gpsf_u
PonaX_1.01
Ponax1.01_4930_6c
tESt5
tatakinopasso
tESt3
AWAKE_i7_2620M_2c
tESt9
Charlotte
tESt12
ponax_i7_3770
gasg
Onax18.0
YWU
AaAaA
tsutsukana_time24_usiponder
xuohk
Apery_WCSC24_3930K_6c
ponax_i7_3770
Apery_2700K_4c
tESt2
CcC
qwer
CrazyKing
tESt8
ttkn_eval130807_2630QM
gpsfish_XeonX5470_8c
PonaX_
ZXV
kbzyc
pona2600
JimmieVaughan
HOGU
tESt7
YssF_6t_x1
SRV
tsutsukana_4930K_6c
Vskf
Titanda_L
luminos
KGD
Titanda_L
Gekisashi_X5590_1c
Blunder_i7
Boomers
SVD
Titanda_L
Jokerman
Amachan
NimbleFingers
Spiritual
GreatDreams
ponzu
gpsfish
SolidRock
DarkEnd
MapleWise0.02
b68c
SecondLine
Hilarity
Bonanza611_4770K_4c
CherryBall
SmallChange
gpsfishone_win
LiveTogether
nozomi_i7-4790
TampUpSolid
b65960x8cu1410
Chauffeur
BigCity
KindHearted
GreatDream
MidnightOasis
SingleHanded
TravelingShoes
Uncloudy
gpsfish_cygwin
Asclepios
Alimony
shogiisukideathnote
SweetHarmony
SlowTrain
Bonanza6.0_2697v2_12c
TightConnection
Boogaloo
Sleepwalk
KeepTheF
Bonanza6.0_2697v2_24c
gpsfish_normal_1c
Crossroads
Hades
Desolation
Poseidon
gps810rasche
Jupiter
Apollo
BlazeBlade
Pretender
Bona6_miya2009_4670_4c
ChickenSkin
Tambourine
Saved
Zeus
Subterranean
Apollon
AnyOldTime
GoneBlind
Soho_Amano
RockingChair
Communique
Theseus
bonta
Tombstone
Lazybones
Tribulations
SwingSultans
ttbnt
CreoleEyes
Freewheeling
BlunderXX_Q6700_2c
nanohamini0211_8c_ubuntu
Skateaway
Revisited
6.0bookKai_4700MQ-4cHT4t
Blunder
Shades
Changing
DoReMi
nozomi_i7-2620M
gpsf_021
benkei_houshi
ThunderSmasher
Nanoha24a_1t
LetBygones
test_t_dti
bps_2
Bringing
kato2
bps
Flummi2
bpsf_0
Burlesque
Flummi
Pledging
frenzy-floodgate
Saya_chan
Calamity141027_Phenom2_4c
Watchtower
boNanoha
gpsfish1c_dfgd_human
flummi2
nozomi_dev140906_i7-2620M
Bonanza6.0-Opteron250-2c
gps810patras
nozomi_dev140828_i7-2620M
Himawari_5960X
Skyline
)

f = open("kifu_floodgate_2014_rated_only.csv")
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
  next if hash[:black_name] =~ /human/ || hash[:white_name] =~ /human/

  n += 1

  if MODE == VIA_RUNNER
    params = ActionController::Parameters.new(hash)
    response = Game.save_after_validation(params)
    puts i.to_s + " " + response[:result]
  elsif MODE == VIA_API_POST
    hash[:csa] = CGI.escape(hash[:csa])
    query = hash.map{|k, v| "#{k}=#{v}"}.join('&')
    #Net::HTTP.start('27.120.94.96', 3000) {|http|
    Net::HTTP.start('localhost', 80) {|http|
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
