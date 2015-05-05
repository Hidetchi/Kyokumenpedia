module NotesHelper
  def note_info_header(note)
  	created_time = note.created_at.localtime
  	updated_time = note.updated_at.localtime
    note_category_name(note.category) + " | " + (note.public ? ("閲覧数: " + note.views.to_s) : "非公開") + " | 作成: " + created_time.strftime("%Y/%m/%d") + " | 更新: " + updated_time.strftime("%Y/%m/%d %H:%M")
  end

  def note_category_name(n)
    case n
    when 0
      "その他"
    when 1
      "メモ"
    when 2
      "研究"
    when 3
      "自戦記"
    when 4
      "観戦記"
    else
      ""
    end
  end
end
