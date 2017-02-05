require 'cgi'
require 'uri'
require 'net/http'

VIA_API_POST = 1
VIA_RUNNER = 2

MODE = VIA_API_POST
#MODE = VIA_RUNNER

players = %w(
gpsshogi
ponanza
kagerou
levercol
)

f = open("kifu_81dojo_4dan_until_2014.csv")
i = 0
f.each {|line|
  i += 1
  #break if i > 150
  #next if i < 130
  par=line.split(",")
  hash=Hash[
    :native_kid => par[0],
    :black_name => par[1],
    :white_name => par[2],
    :black_rate => par[3],
    :white_rate => par[4],
    :date => par[5],
    :result => par[6].to_i - 1,
    :csa => par[8],
    :game_source_pass => "shogi81",
    :handicap_id => 1
    ]
  next if par[9].to_i < 40
  next if players.include?(hash[:black_name].downcase)
  next if hash[:black_name] =~ /^com_/i
  next if players.include?(hash[:white_name].downcase)
  next if hash[:white_name] =~ /^com_/i

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
