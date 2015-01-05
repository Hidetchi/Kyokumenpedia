require 'find'

file_csv = open("kifu_database.csv", "w")

i = 0
Find.find("./pro") {|f|
  next unless f =~ /\.kif$/
  i += 1
#  next if i <= 69400
  file_kif = File.read(f, encoding:'cp932')
  native_kid = f.split("/kif").last.split(".")[0]
  black_name = ""
  white_name = ""
  black_rate = ""
  white_rate = ""
  event = ""
  date = ""
  result = ""
  result_type = ""
  moves = ""
  handicap = 0
  num = 0
  x = nil
  y = nil
  teban = true
  file_kif.split("\n").each {|line|
    line = line.encode('utf-8')
    if line =~ /^開始日時：(.+)$/
      date = $1.chomp.gsub("/", "-")
    elsif line =~ /^棋戦：(.+)$/
      event = $1.chomp
    elsif line =~ /^手合割：(.+)$/
      teban = false
      case $1.chomp
      when "平手"
        handicap = 1
        teban = true
      when "香落ち"
        handicap = 2
      when "角落ち"
        handicap = 3
      when "飛車落ち"
        handicap = 4
      when "飛香落ち"
        handicap = 5
      end
    elsif line =~ /^後手：(.+)$/
      white_name = $1.chomp
    elsif line =~ /^先手：(.+)$/
      black_name = $1.chomp
    elsif line =~ /^\s*\d+\s+(.+?)\s*(\([\s\d\:]+\/[\d\:]+\))?\s*$/
      move = $1
      if move =~ /^([１２３４５６７８９][一二三四五六七八九]|同　)(成?.)(不?成?)(打|\(\d\d\))$/
        piece = nil
        xy = nil
        destination = $1
        piece_ja = $2
        promote = $3 == "成"
        origin = $4
        unless destination =~ /^同/
          x = %w(0 １ ２ ３ ４ ５ ６ ７ ８ ９).index(destination[0])
          y = %w(0 一 二 三 四 五 六 七 八 九).index(destination[1])
        end
        case piece_ja
        when "歩"
          piece = promote ? "TO" : "FU"
        when "香"
          piece = promote ? "NY" : "KY"
        when "桂"
          piece = promote ? "NK" : "KE"
        when "銀"
          piece = promote ? "NG" : "GI"
        when "金"
          piece = "KI"
        when "角"
          piece = promote ? "UM" : "KA"
        when "飛"
          piece = promote ? "RY" : "HI"
        when "玉", "王"
          piece = "OU"
        when "と"
          piece = "TO"
        when "成香", "杏"
          piece = "NY"
        when "成桂", "圭"
          piece = "NK"
        when "成銀", "全"
          piece = "NG"
        when "馬"
          piece = "UM"
        when "龍", "竜"
          piece = "RY"
        end
        if origin == "打"
          xy = "00"
        elsif origin =~ /^\((\d\d)\)$/
          xy = $1
        end
        moves += (teban ? "+" : "-") + xy + x.to_s + y.to_s + piece
        teban = !teban
        num += 1
      elsif move == "投了"
        moves += "%TORYO"
        result_type = "#RESIGN"
        result = teban ? 1 : 0
        break
      elsif move == "千日手"
        result_type = "#SENNICHITE"
        result = 2
        break
      else
        puts "Error: Could not interpret move " + move + " in " + f
        result_type = "Abnormal"
        break
      end
    end
  }

  file_csv.puts sprintf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s", native_kid, black_name, white_name, black_rate, white_rate, date, result, result_type, moves, num, handicap, event)
  puts i if i % 100 == 0
  file_logger = open("log.txt", "a")
  file_logger.puts sprintf("%d %s convert OK", i, f)
  file_logger.close
}

file_csv.close

# Sort it again
hash = Hash.new
f = open("/usr/local/Kyokumenpedia/db/script/kifu_database.csv", "r")
f.each {|line|
  kid=line.split(",")[0]
  hash[kid]=line
}
f.close

array = hash.sort_by{|k, v| k.to_i}

f = open("/usr/local/Kyokumenpedia/db/script/kifu_database.csv", "w")
array.each do |h|
  f.puts h[1]
end
f.close
