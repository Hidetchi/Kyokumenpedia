class Headline < ActiveRecord::Base
  belongs_to :position

  def self.update(key, position)
    return unless position
    if (headline = Headline.find_by(name: key))
      headline.update_attributes(position_id: position.id) unless headline.position_id == position.id
    else
      Headline.create(name: key, position_id: position.id)
    end
  end
  
  def self.get_position(key)
    if (headline = Headline.find_by(name: key))
      headline.position
    else
      nil
    end
  end
end
