module WikipostsHelper
	def interpret_wiki(position_id, content)
		lines = content.split("\n")
		new_lines = []
		hash = Hash.new(0)
		resembles = []
		famous_games = []
		com_evals = []
		level = 2
		ref_num = 0
		lines.each do |line|
			line.chomp!
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
			if (line =~ /^\s*\{\{ComEval\|(.+)\|(.+)\|(.+)\|(.*)\}\}\s*$/)
				record = Hash.new
				record[:cp] = $1
				record[:name] = $2
				record[:date] = $3
				record[:condition] = $4 ? $4 : ""
				com_evals << record 
				next
			end
			# interpret <ref> tag
			line = line.gsub(/<ref>(.+?)<\/ref>/) {
			  lines << "==脚注==" if (ref_num == 0)
			  ref_num += 1
			  lines << "#" + $1
			  "<sup>[" + ref_num.to_s + "]</sup> "
			}
			# interpret [[sfen-or-CSAmoves|text]] as <a> tag link to a position
			line = line.gsub(/\[{2}(.+?)\|(.+?)\]{2}/) {
				match1 = $1
				match2 = $2
				if (match1 =~ /^[\+\-]\d{4}[A-Z]{2}/)
					'<a href="/positions/' + position_id.to_s + '/' + match1 + '" target="_blank">' + match2 + '</a>'
				else
					'<a href="/positions/' + match1 + '" target="_blank">' + match2 + '</a>'
				end
			}
			# interpret [url( text)] as <a> tag link to an outside web
			line = line.gsub(/\[(http.+?)\]/) {
				match = $1
				if (match =~ /^(.+?)\s(.+)$/)
					'<a class="external" href="' + $1 + '" target="_blank">' + $2 + '</a>'
				else
					'<a class="external" href="' + match + '" target="_blank">' + match + '</a>'
				end
			}

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
		
		new_lines << "<h2>参考データ</h2>" if (famous_games.length > 0 || com_evals.length > 0 || resembles.length > 0)
		if (famous_games.length > 0)
			table_html = "<h3>有名局</h3><table class='wiki'><tr><th>先手<th>後手<th>棋戦<th>対局日<th>勝敗<th>コメント<th>リンク"
			famous_games.each do |r|
				table_html += "<tr><td>" + r[:sente] + "<td>" + r[:gote] + "<td>" + r[:event] + "<td>" + r[:date] + "<td>" + r[:result] + "<td class='left'>" + r[:comment] + "<td>"
				table_html += "<a class='external' href='" + r[:url] + "' target='_blank'>棋譜</a>" if (r[:url] && r[:url] =~ /^http/)
			end
			table_html += "</table>"
			new_lines << table_html
		end
		if (com_evals.length > 0)
			table_html = "<h3>ソフト評価値</h3><table class='wiki'><tr><th>評価値<th>ソフト名<th>確認日<th>確認環境"
			com_evals.each do |r|
				table_html += "<tr><td>" + r[:cp] + "<td>" + r[:name] + "<td>" + r[:date] + "<td class='left'>" + r[:condition]
			end
			table_html += "</table>"
			new_lines << table_html
		end
		if (resembles.length > 0)
			table_html = "<h3>類似局面</h3><table class='wiki'><tr><th>変化点<th width=60>リンク"
			resembles.each do |r|
				table_html += "<tr><td class='left'>" + r[:comment] + "<td><a href='/positions/" + r[:sfen] + "'>Go</a>"
			end
			table_html += "</table>"
			new_lines << table_html
		end

		return new_lines.join("\n")
	end
end
