module WikipostsHelper
	def interpret_wiki(position_id, content, logged_in = false, is_note = false)
    logged_in = true
    board = Position.find(position_id).to_board
		lines = content.split("\n")
		new_lines = []
		hash = Hash.new(0)
		resembles = []
		famous_games = []
		com_evals = []
		book_appearances = []
    blames = []
		level = 2
		ref_num = 0
    unless is_note
      # interpret #REDIRECT [[sfen]] as identical(symmetric) position link
      if (lines[0] =~ /^\s*#REDIRECT\s*$/)
        return identical_position_template(board)
      end
    end
    
    lines.each do |line|
      line.chomp!
      unless is_note
        # interpret {{Conclusion|text}} and ignore
        next if (line =~ /^\s*\{\{Conclusion\|.+\}\}\s*$/)
        # interpret #BLAME
        if (line =~ /^\s*#BLAME\s+(.+)$/)
          blames << $1
          next
        end
        # interpret {{Resemble|sfen|comment}} as resembling position object
        if (line =~ /^\s*\{\{Resemble\|(.+)\|(.+)\}\}\s*$/)
          record = Hash.new
          record[:sfen] = $1
          record[:comment] = $2
          resembles << record 
          next
        end
        # interpret {{FamousGame|sente|gote|date|event|result|comment|url}} as resembling position object
        if (line =~ /^\s*\{\{FamousGame\|(.+)\|(.+)\|(.+)\|(.+)\|(.*)\|(.*)\|(.*)\}\}\s*$/)
          record = Hash.new
          record[:sente] = $1
          record[:gote] = $2
          record[:date] = $3
          record[:event] = $4
          record[:result] = $5 ? $5 : ""
          record[:comment] = $6 ? $6 : ""
          record[:url] = $7 ? $7 : ""
          famous_games << record
          next
        end
        # interpret {{ComEval|cp|name|date|condition}} as computer evaluation result
        if (line =~ /^\s*\{\{ComEval\|(.+)\|(.+)\|(.+)\|(.*)\|(.*)\}\}\s*$/)
          record = Hash.new
          record[:cp] = $1
          record[:name] = $2
          record[:date] = $3
          record[:best] = $4 ? $4 : ""
          record[:condition] = $5 ? $5 : ""
          com_evals << record 
          next
        end
        # interpret {{Book|isbn10/13|page|evaluation}} as book coverage
        if (line =~ /^\s*\{\{Book\|([\d\-A-Z]+)\|(.*)\|(.*)\}\}\s*$/)
          number = $1
          page = $2
          evaluation = $3 ? $3 : ""
          number.gsub!(/\-/,"")
          if (ISBN.asin_valid?(number) || ISBN.isbn13_valid?(number))
            record = Hash.new
            record[:isbn13] = number.length == 13 ? number : ISBN.asin_to_isbn13(number)
            record[:page] = page
            record[:evaluation] = evaluation
            Book.load_info(record)
            book_appearances << record
            next
          end
        end
      end

      # html_escape "<" and """
      line = line.gsub(/\"/, "&quot;").gsub(/</, "&lt;")
			# interpret <ref> tag
			line = line.gsub(/&lt;ref>(.+?)&lt;\/ref>/) {
			  lines << "==脚注==" if (ref_num == 0)
			  ref_num += 1
			  lines << "#" + $1
			  "<sup>[" + ref_num.to_s + "]</sup> "
			}
			# interpret [[sfen-or-CSAmoves|text]] as <a> tag link to a position
			line = line.gsub(/\[{2}(.+?)\|(.+?)\]{2}/) {
				match1 = $1
				match2 = $2
        sfen = nil
				if (match1 =~ /^([\+\-]\d{4}[A-Z]{2})+$/)
          if (referred_board = board.do_moves_str(match1))
            sfen = referred_board.to_sfen 
          end
				elsif (match1 =~ /\A([\+1-9krbgsnlp]+\/){8}[\+1-9krbgsnlp]+\s[bw]\s[0-9rbgsnlp\-]+\z/i)
          sfen = match1
        end
        if sfen
          '<a href="/positions/' + sfen + '" class="preview">' + match2 + '</a>'
				else
          '<span class="dark_red"><i>[[内部リンクエラー]]</i></span>'
        end
			}
			# interpret [url( text)] as <a> tag link to an outside web
			line = line.gsub(/\[(https?:\/\/.+?)\]/) {
				match = $1
				if (match =~ /^(.+?)\s(.+)$/)
          link_to($2, $1, :class => 'external', :target => '_blank')
				else
          link_to(match, match, :class => 'external', :target => '_blank')
				end
			}
			# interpret '''''text''''' as bold italic font
			line = line.gsub(/'''''(.+?)'''''/) {
				match = $1
				'<strong><i>' + match + '</i></strong>'
			}
			# interpret '''text''' as bold font
			line = line.gsub(/'''(.+?)'''/) {
				match = $1
				'<strong>' + match + '</strong>'
			}
			# interpret ''text'' as italic font
			line = line.gsub(/''(.+?)''/) {
				match = $1
				'<i>' + match + '</i>'
			}
      # interpret $br; as <br> tag
      line = line.gsub(/&lt;br>/,"<br>")

			# interpret ===title=== as <h#> tag
			if (line =~ /^(=+)(.+?)(=+)$/)
				head = $1
				title = $2
				tail = $3
				new_line = ""
				if (hash[:ul] > 0)
					hash[:ul].times {	new_line += "</ul>" }
					hash[:ul] = 0
				end
				if (hash[:ol] > 0)
					hash[:ol].times {	new_line += "</ol>" }
					hash[:ol] = 0
				end
				if (hash[:p] > 0)
					new_line += "</div>"
					hash[:p] = 0
				end
				if (head.length == tail.length && head.length >= 2 && head.length <= 4)
					level = head.length + 1
					new_line += "<h" + level.to_s + ">" + title + "</h" + level.to_s + ">"
				end
			# interpret ***sentence as <ul><li> tag
			elsif (line =~ /^(\*+)(.+)$/)
				new_line = ""
				if (hash[:ol] > 0)
					hash[:ol].times {	new_line += "</ol>" }
					hash[:ol] = 0
				end
				if (hash[:p] == 0)
					new_line += "<div class='p level" + level.to_s + "'>"
					hash[:p] = 1
				end
				num = $1.length
				content = $2
				if (hash[:ul] < num)
					(num - hash[:ul]).times { new_line += "<ul class='article'>" }
					hash[:ul] = num
				elsif (hash[:ul] > num)
					(hash[:ul] - num).times { new_line += "</ul>" }
					hash[:ul] = num
				end
				new_line += "<li>" + content
			# interpret ###sentence as <ol><li> tag
			elsif (line =~ /^(#+)(.+)$/)
				new_line = ""
				if (hash[:ul] > 0)
					hash[:ul].times {	new_line += "</ul>" }
					hash[:ul] = 0
				end
				if (hash[:p] == 0)
					new_line += "<div class='p level" + level.to_s + "'>"
					hash[:p] = 1
				end
				num = $1.length
				content = $2
				if (hash[:ol] < num)
					(num - hash[:ol]).times { new_line += "<ol class='article'>" }
					hash[:ol] = num
				elsif (hash[:ol] > num)
					(hash[:ol] - num).times { new_line += "</ol>" }
					hash[:ol] = num
				end
				new_line += "<li>" + content
			# interpret double new-line as paragraph end
			elsif (line =~ /^\s*$/)
				new_line = ""
				if (hash[:ul] > 0)
					hash[:ul].times {	new_line += "</ul>" }
					hash[:ul] = 0
				end
				if (hash[:ol] > 0)
					hash[:ol].times {	new_line += "</ol>" }
					hash[:ol] = 0
				end
				if (hash[:p] > 0)
					new_line += "</div>"
					hash[:p] = 0
				end
			# Others
			else
				new_line = ""
				if (hash[:ul] > 0)
					hash[:ul].times {	new_line += "</ul>" }
					hash[:ul] = 0
				end
				if (hash[:ol] > 0)
					hash[:ol].times {	new_line += "</ol>" }
					hash[:ol] = 0
				end
				if (hash[:p] == 0)
					new_line += "<div class='p level" + level.to_s + "'>"
					hash[:p] = 1
				end	
				new_line += line
			end
			new_lines << new_line
		end
		new_line = ""
		# close <ul> block if needed
		hash[:ul].times {	new_line += "</ul>" } if (hash[:ul] > 0)
		# close <ol> block if needed
		hash[:ol].times {	new_line += "</ol>" } if (hash[:ol] > 0)
		new_line += "</div>" if (hash[:p] > 0)
		new_lines << new_line
		
    unless is_note
      if (blames.length > 0)
        new_line = "<div class='notify'>この局面はモデレータにより、解説の文体または内容に関して改訂が求められています。<ul style='margin:0;'>"
        blames.each {|blame_reason| new_line += "<li>" + blame_reason}
        new_line += "</ul></div>"
        new_lines.unshift(new_line)
      end
      if (famous_games.length > 0 || com_evals.length > 0 || resembles.length > 0 || book_appearances.length > 0)
        new_lines << "<h2>参考データ</h2>"
        new_lines << image_tag('denied.png', :style=>'vertical-align:-2px;') + " <span class='dark_red'>以下のデータを表示するにはログインして下さい</span>".html_safe unless logged_in
      end
      if (famous_games.length > 0)
        table_html = "<h3>有名局</h3><table class='wiki'><tr><th>先手<th>後手<th>棋戦<th>対局日<th>勝敗<th>コメント<th>リンク"
        famous_games.each do |r|
          r = {sente: "?", gote: "?", event: "?", date: "?", result: "?", comment: "?", url: nil} unless logged_in
          r[:result] = "先手勝" if r[:result] == "0"
          r[:result] = "後手勝" if r[:result] == "1"
          r[:result] = "引分" if r[:result] == "2"
          table_html += "<tr><td>" + r[:sente] + "<td>" + r[:gote] + "<td>" + r[:event] + "<td>" + r[:date] + "<td>" + r[:result] + "<td class='left'>" + r[:comment] + "<td>"
          table_html += link_to('棋譜', r[:url], :class => 'external', :target => '_blank') if (r[:url] && r[:url] =~ /^https?:\/\//)
        end
        table_html += "</table>"
        new_lines << table_html
      end
      if (book_appearances.length > 0)
        table_html = "<h3>本局面が掲載されている棋書</h3><table class='wiki'><tr><th colspan=2>タイトル<th>著者<th>出版社<th>発行<th>掲載ページ<th>局面評価"
        book_appearances.each do |r|
          r = {isbn13: "?", title: "?", author: "?", publisher: "?", date: "?", page: "?", evaluation: "?"} unless logged_in
          r[:publisher] = "毎コミ" if (r[:publisher] == "毎日コミュニケーションズ")
          table_html += "<tr><td style='border-right:0;text-align:left;'>" + r[:title] + "<td>"
          table_html += "<a class='external' href='http://www.amazon.co.jp/gp/product/" + ISBN.isbn13_to_asin(r[:isbn13]) + "/ref=as_li_tf_tl?tag=iscube-22' target='_blank'>amz</a>" if (logged_in && r[:title] != "-")
          table_html += "<td>" + r[:author] + "<td>" + r[:publisher] + "<td>" + r[:date].split("-")[0] + "<td>" + r[:page] + "<td>" + r[:evaluation]
        end
        table_html += "</table>"
        new_lines << table_html
      end
      if (com_evals.length > 0)
        table_html = "<h3>ソフト評価値</h3><table class='wiki'><tr><th>評価値<th>ソフト名<th>確認日<th>最善手<th>確認環境"
        com_evals.each do |r|
          r = {cp: "?", name: "?", date: "?", best: "?", condition: "?"} unless logged_in
          table_html += "<tr><td>" + r[:cp] + "<td>" + r[:name] + "<td>" + r[:date] + "<td>" + r[:best] + "<td class='left'>" + r[:condition]
        end
        table_html += "</table>"
        new_lines << table_html
      end
      if (resembles.length > 0)
        table_html = "<h3>類似局面</h3><table class='wiki'><tr><th>変化点<th width=60>リンク"
        resembles.each do |r|
          r = {comment: "?", sfen: nil} unless logged_in
          table_html += "<tr><td class='left'>" + r[:comment] + "<td>"
          if (r[:sfen])
            if (r[:sfen] =~ /\A([\+1-9krbgsnlp]+\/){8}[\+1-9krbgsnlp]+\s[bw]\s[0-9rbgsnlp\-]+\z/i)
              table_html += "<a href='/positions/" + r[:sfen] + "' class='preview'>Go</a>"
            else
              table_html += "<span class='dark_red'><i>SFENエラー</i></span>"
            end
          end
        end
        table_html += "</table>"
        new_lines << table_html
      end
    end

		return new_lines.join("\n")
	end
	
	def identical_position_template(board)
	  "<div class='notify'>この局面は、先後入れ替わりによって発生する、他との同一局面です。<br>解説は、出現頻度がより高い" + link_to('もう一方の局面', '/positions/' + board.reversed_board.to_sfen) + "をご覧下さい。</div>"
	end
end
