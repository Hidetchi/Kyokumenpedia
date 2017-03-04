require 'cgi'
require 'uri'
require 'net/http'

VIA_API_POST = 1
VIA_RUNNER = 2

MODE = VIA_API_POST
#MODE = VIA_RUNNER

players = %w(
)

f = open("/app/Kyokumenpedia/db/script/kifu_floodgate_2016_above3000.csv")
lines = []
f.each {|line|
  lines.push(line)
}
f.close

i = 0
n = 0
lines.sort.each {|line|
  i += 1
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
  next if par[9].to_i > 256
  next unless par[7] == "toryo" || par[7] == "sennichite"
#  next unless players.include?(hash[:black_name]) && players.include?(hash[:white_name])
  next if hash[:black_name] =~ /human/ || hash[:white_name] =~ /human/

  n += 1

  if MODE == VIA_RUNNER
    params = ActionController::Parameters.new(hash)
    response = Game.save_after_validation(params)
    puts i.to_s + " " + response[:result]
  elsif MODE == VIA_API_POST
    hash[:csa] = CGI.escape(hash[:csa])
    query = hash.map{|k, v| "#{k}=#{v}"}.join('&')
    Net::HTTP.start('kyokumen.jp', 80) {|http|
      response = http.post('/api/kifu_post', query)
      if (response.body =~ /(Error.+)</)
        puts i.to_s + " " + $1
      else
        puts i.to_s + " OK"
      end
    }
  end

}

puts "Total: " + n.to_s
