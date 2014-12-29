require 'cgi'
require 'uri'
require 'net/http'

VIA_API_POST = 1
VIA_RUNNER = 2

MODE = VIA_API_POST
#MODE = VIA_RUNNER

players = %w(
GekiYowauraOu338_1core
AWAKE_i7_5960X_8c
T_T
NineDayFever_XeonE5-2690_16c
Test
ponanza_expt
Test3
AVR0
ponanza-990XEE
testtt
Ponax1.01_4930_6c_1
Test2
ZAKO
GPSFish-WCSC24
gpsfish_XeonX5680_12c
SRX70
gasg
gpsf_u
PonaX_1.01
Ponax1.01_4930_6c
tatakinopasso
AWAKE_i7_2620M_2c
xuohk
Charlotte
zyx
Super_megutan_human
PonaX-1.01
guts
YWU
Onax18.0
tsutsukana_time24_usiponder
ponax_i7_3770
Apery_WCSC24_3930K_6c
Apery_2700K_4c
ttkn_eval130807_2630QM
PonaX_
hammer
YssF_6t_x1
qwer
ZXV
ponax_i7_3770
CrazyKing
JimmieVaughan
tsutsukana_4930K_6c
Titanda_L
R_Xeon_human
luminos
KGD
CrazyKing
gpsfish
Titanda_L
pona2600
Bonanza6.0x_i7_3770_4c
Gekisashi_X5590_1c
Amachan
)

f = open("/usr/local/Kyokumenpedia/db/script/kifu_floodgate.csv")
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
