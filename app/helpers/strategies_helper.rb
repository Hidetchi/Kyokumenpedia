module StrategiesHelper
  def render_register_tree(strategy, position_id)
    res = ""
    if (strategy.ancestry == nil)
      res += "<li>" + strategy.name
    else
      res += "<li>" + link_to(strategy.name, position_strategy_path(position_id, strategy.id), data: {:method => 'put', :confirm => '本当に「' + strategy.name + '」で登録してよろしいですか？'})
    end
    if (strategy.children)
      res += "<ul>"
      strategy.children.each do |child|
        res += render_register_tree(child, position_id)
      end
      res += "</ul>"
    end
    res
  end

  def render_jump_tree(strategy)
    res = ""
    if (strategy.ancestry == nil)
      handicap_id = ["", "平手", "香落ち", "角落ち", "飛車落ち", "飛香落ち", "二枚落ち", "四枚落ち", "六枚落ち", "八枚落ち"].index(strategy.name)
      res += "<li>" + link_to(strategy.name, '/positions/start/' + handicap_id.to_s)
    elsif (strategy.main_position_id)
      res += "<li>" + link_to(strategy.name, position_path(strategy.main_position_id))
    else
      res += "<li>" + strategy.name
    end
    if (strategy.children)
      res += "<ul>"
      strategy.children.each do |child|
        res += render_jump_tree(child)
      end
      res += "</ul>"
    end
    res
  end
end
