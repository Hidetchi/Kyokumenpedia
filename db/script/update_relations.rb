game_ids = Game.where(relation_updated: false).pluck(:id)
n = game_ids.count
i = 1
game_ids.each do |id|
  Game.update_relations(id)
  puts i.to_s + "/" + n.to_s
  i += 1
end
