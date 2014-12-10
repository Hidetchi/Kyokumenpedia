module StrategiesHelper
  def render_tree(strategy, position_id)
    res = ""
    if (strategy.ancestry == nil)
      res += "<li>" + strategy.name
    else
      res += "<li>" + link_to(strategy.name, position_strategy_path(position_id, strategy.id), data: {:method => 'put', :confirm => '本当に「' + strategy.name + '」で登録してよろしいですか？'})
    end
    if (strategy.children)
      res += "<ul>"
      strategy.children.each do |child|
        res += render_tree(child, position_id)
      end
      res += "</ul>"
    end
    res
  end
end
