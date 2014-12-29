require 'find'

file_csv = open("kifu_floodgate.csv", "w")

i = 0
Find.find("./2013") {|f|
  begin
    next unless f =~ /\.csa$/
    file_csa = open(f)
    i += 1
    native_kid = ""
    black_name = ""
    white_name = ""
    black_rate = ""
    white_rate = ""
    date = ""
    result = ""
    result_type = ""
    moves = ""
    num = 0
    file_csa.each {|line|
      if line =~ /^N\+(.+)$/
        black_name = $1
      elsif line =~ /^N\-(.+)$/
        white_name = $1
      elsif line =~ /^\$EVENT\:(.+)$/
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
    puts i if i % 100 == 0
  rescue
    log = "[ERROR] " + i.to_s + ": " + f
    puts log
  end
}

file_csv.close
